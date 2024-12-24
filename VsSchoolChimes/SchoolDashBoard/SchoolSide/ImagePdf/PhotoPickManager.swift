//
//  PhotoPickManager.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/16/24.
//

import Foundation
import UIKit
import PhotosUI
import AWSS3

@available(iOS 14.0, *)
class PhotoPickerManager: NSObject, PHPickerViewControllerDelegate,UIDocumentPickerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var selectedImages: [UIImage] = []
    var pdfData : Data? = nil
    var convertedImagesUrlArray = NSMutableArray()
    var  getImagePdfType : String!
    var imageUrlArray = NSMutableArray()
    var imageStr : [String] = []
    var currentImageCount = 0
    var totalImageCount = 0
    var originalImagesArray = [UIImage]()
    var onImagesPicked: (([UIImage]) -> Void)?
    static let shared = PhotoPickerManager()
    var onPdfPicked: ((Data) -> Void)?
    var pdfUrl :((URL) -> Void)?
    var onImagePicked: (([UIImage]) -> Void)?
    var onCameraImagePicked: ((UIImage) -> Void)?
    var onPdfString: ((String) -> Void)?
    
    private override init() {
        
    }
    
    static func createInstance() -> PhotoPickerManager {
        return PhotoPickerManager()
    }
    
    // Function to present the photo picker
    func presentPhotoPicker(from viewController: UIViewController, selectionLimit: Int) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        configuration.filter = .images // Only images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
    
    // Delegate method to handle selected items
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        var images = [UIImage]()
        print("images",images)
        let dispatchGroup = DispatchGroup()
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.onImagePicked?(images)
        }
    }
    
    
    
    
    
//    import Foundation
//    import UIKit

    // Function to upload an image using a presigned URL
    func uploadAWSUsingPresignedURL(image: UIImage, presignedURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Convert the UIImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.9),
              let url = URL(string: presignedURL) else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid image or URL"])))
            return
        }

        // Create a URLRequest for the presigned URL
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")

        // Use URLSession to upload the image
        let uploadTask = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Upload successful!")
                    completion(.success(presignedURL)) // Returning the presigned URL as confirmation
                } else {
                    print("Upload failed with status code: \(httpResponse.statusCode)")
                    let uploadError = NSError(domain: "UploadError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
                    completion(.failure(uploadError))
                }
            }
        }

        // Start the upload task
        uploadTask.resume()
    }

    // Function to handle multiple image uploads
    func getImageURLUsingPresignedURL(images: [UIImage], presignedURLs: [String], completion: @escaping ([String]) -> Void) {
        guard images.count == presignedURLs.count else {
            print("Mismatch between image count and presigned URLs count.")
            completion([])
            return
        }

        var uploadedImageURLs: [String] = []
        var currentImageCount = 0

        func uploadNext() {
            if currentImageCount < images.count {
                let image = images[currentImageCount]
                let presignedURL = presignedURLs[currentImageCount]
                
                uploadAWSUsingPresignedURL(image: image, presignedURL: presignedURL) { result in
                    switch result {
                    case .success(let uploadedURL):
                        uploadedImageURLs.append(uploadedURL)
                        currentImageCount += 1
                        uploadNext() // Continue with the next image
                    case .failure(let error):
                        print("Error uploading image: \(error.localizedDescription)")
                        currentImageCount += 1
                        uploadNext() // Continue with the next image even on failure
                    }
                }
            } else {
                // All uploads complete
                completion(uploadedImageURLs)
            }
        }

        // Start the upload process
        uploadNext()
    }

    
    
    
    func uploadAWS(image : UIImage){
        let S3BucketName = AwsCredentials.bucketNameIndia
        let CognitoPoolID = AwsCredentials.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".png")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let  currentDate =   dateFormatter.string(from: Date())
        let ext = imageName as String
        let fileName = imageNameWithoutExtension
        let fileType = ".jpg"
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        let data = image.jpegData(compressionQuality: 0.9)
        do {
            try data?.write(to: imageURL)
        }
        catch {}
        print(imageURL)
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key =   currentDate +  "/" + "File_" + ext
        uploadRequest?.bucket = S3BucketName
        
        if getImagePdfType == "Image" {
            uploadRequest?.contentType = "image/png"
        } else{
            uploadRequest?.contentType = "image/png"
        }
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in
            if let error = task.error {
                print("Upload failed : (\(error))")
            }
            var imageFilePath = NSMutableArray()
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    let imageDicthome = NSMutableDictionary()
                    imageDicthome["path"] = absoluteString
                    imageDicthome["type"] = "IMAGE"
                    let imageDict = NSMutableDictionary()
                    var emptyDictionary = [String: String]()
                    imageFilePath.add(imageDicthome)
                    self.currentImageCount = self.currentImageCount + 1
                    if self.currentImageCount < self.totalImageCount{
                        DispatchQueue.main.async {
                            self.getImageURL(images: self.originalImagesArray)
                        }
                    }else{
                        self.convertedImagesUrlArray = self.imageUrlArray
                    }
                }
            }
            return nil
        }
    }
    
    func getImageURL(images : [UIImage]){
        self.originalImagesArray = images
        self.totalImageCount = images.count
        print("currentImageCount",currentImageCount,images.count)
        if currentImageCount < images.count{
            self.uploadAWS(image: images[currentImageCount])
        }
    }
    
    func pickPDF(from viewController: UIViewController) {
        print("SELECT PDF")
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
        documentPicker.delegate = self
        viewController.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: URL) {
        let fileurl: URL = urls as URL
        let filename = urls.lastPathComponent
        let fileextension = urls.pathExtension
        print("URL: \(fileurl)", "NAME: \(filename)", "EXTENSION: \(fileextension)")
        let imageData = NSData(contentsOf: urls)
        do {
            pdfData = try Data(contentsOf: urls, options: NSData.ReadingOptions())
        } catch {
            print("set PDF filer error : ", error)
        }
        let dispatchGroup = DispatchGroup()
        dispatchGroup.notify(queue: .main) { [weak self] in
            print("set PDF filer errr")
            self?.onPdfPicked?(self!.pdfData!)
            self?.pdfUrl?(fileurl)
        }
        
    }
    
    func convertURLToData(from url: URL) -> Data? {
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error converting URL to Data: \(error)")
            return nil
        }
    }
    // Function to upload PDF to AWS S3
    func uploadPDFFileToAWS(pdfData: Data) {
        let S3BucketName = AwsCredentials.bucketNameIndia
        let Region = AWSRegionType.APSouth1
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".pdf")
        let ext = imageName as String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let  currentDate =   dateFormatter.string(from: Date())
        let fileName = imageNameWithoutExtension
        let fileType = ".pdf"
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        do {
            try pdfData.write(to: imageURL)
        }
        catch {}
        print(imageURL)
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key =  currentDate +  "/" + "File_" + ext
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.contentType = "application/pdf"
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in
            if let error = task.error {
                print("Upload failed : (\(error))")
            }
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                let dispatchGroup = DispatchGroup()
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    print("set PDF filer errr")
                    self.onPdfString?(absoluteString)
                    let imageDict = NSMutableDictionary()
                    imageDict["FileName"] = absoluteString
                    self.imageUrlArray.add(imageDict)
                }
            }
            else {
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
     func openCamera(from viewController: UIViewController) {
        // Check if the camera is available
         print("camera")
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true // Allows editing of the captured image
            viewController.present(imagePicker, animated: true, completion: nil)
        } else {
            // Camera is not available, show an alert
            let alert = UIAlertController(title: "Camera Not Available".translated(), message: "This device has no camera.".translated(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".translated(), style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                // Use the edited image
                print("Captured Edited Image: \(editedImage)")
                self.selectedImages.append(editedImage)
                let dispatchGroup = DispatchGroup()
               
                dispatchGroup.notify(queue: .main) { [weak self] in
                    self?.onCameraImagePicked?(editedImage)
                }
            } else if let originalImage = info[.originalImage] as? UIImage {
                // Use the original image
                print("Captured Original Image: \(originalImage)")
                self.selectedImages.append(originalImage)
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
    
    // Handle cancellation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
