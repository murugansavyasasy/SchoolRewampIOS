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
class PhotoPickerManager: NSObject, PHPickerViewControllerDelegate,UIDocumentPickerDelegate {
    // Completion handler to return selected images
    
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
    var onImagePicked: (([UIImage]) -> Void)?
   

    private override init() {
           // Private initializer
       }
    
    
    static func createInstance() -> PhotoPickerManager {
            return PhotoPickerManager()
        }
    
    // Function to present the photo picker
    func presentPhotoPicker(from viewController: UIViewController, selectionLimit: Int = 1) {
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
        if currentImageCount < images.count{
            self.uploadAWS(image: images[currentImageCount])
        }
    }
    
   
       
     

       // Function to handle document picking (for example, selecting PDFs)
//       func documentPicker(didPickDocumentAt urls: URL, completion: @escaping (Data?, String?, String?) -> Void) {
//           
//           let fileurl: URL = urls
//           let filename = urls.lastPathComponent
//           let fileextension = urls.pathExtension
//           print("URL: \(fileurl)", "NAME: \(filename)", "EXTENSION: \(fileextension)")
//           
//           do {
//               let pdfData = try Data(contentsOf: urls)
//               completion(pdfData, filename, fileextension)
//           } catch {
//               print("Error while loading the document: \(error)")
//               completion(nil, nil, nil)
//           }
//       }
//
//       // Function to handle the cancel event of the document picker
//       func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//           controller.dismiss(animated: true, completion: nil)
//       }

    
    func pickPDF(from viewController: UIViewController) {
           let types = [UTType.pdf] // Specify PDF file type
           let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
           picker.delegate = self
           picker.allowsMultipleSelection = false // Change to true if you need multiple files
           viewController.present(picker, animated: true, completion: nil)
       }

       // UIDocumentPickerDelegate methods
       func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
           guard let selectedURL = urls.first else { return }
           print("Picked PDF: \(selectedURL)")
           
           if let url = URL(string: "https://example.com/image.jpg") {
               do {
                   let data = try Data(contentsOf: url)
                   self.onPdfPicked?(data)
                  
                   print("Data downloaded successfully, size: \(data.count) bytes")
               } catch {
                   print("Error downloading data: \(error)")
               }
           } else {
               print("Invalid URL")
           }
          
           // Handle the selected PDF file (e.g., read data, copy it, etc.)
       }

       func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
           print("Picker was cancelled")
       }
    
    
    func convertURLToData(from url: URL) -> Data? {
        do {
            let data = try Data(contentsOf: url)
//            uploadPDFFileToAWS(pdfData: da, completion: <#T##(String?) -> Void#>)
            return data
        } catch {
            print("Error converting URL to Data: \(error)")
            return nil
        }
    }
       // Function to upload PDF to AWS S3
       func uploadPDFFileToAWS(pdfData: Data, completion: @escaping (String?) -> Void) {
           let S3BucketName = AwsCredentials.bucketNameIndia
           let Region = AWSRegionType.APSouth1
           let currentTimeStamp = NSString(format: "%ld", Date().timeIntervalSince1970)
           let imageName = "vc_\(currentTimeStamp).pdf"

           let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageName)

           do {
               try pdfData.write(to: imageURL)
           } catch {
               print("Error writing file to disk: \(error)")
               completion(nil)
               return
           }

           let uploadRequest = AWSS3TransferManagerUploadRequest()
           uploadRequest?.body = imageURL
           uploadRequest?.key = imageName
           uploadRequest?.bucket = S3BucketName
           uploadRequest?.contentType = "application/pdf"
           
           let transferManager = AWSS3TransferManager.default()
           transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
               if let error = task.error {
                   print("Upload failed: (\(error))")
                   completion(nil)
                   return nil
               }
               
               if let result = task.result {
                   let url = AWSS3.default().configuration.endpoint.url
                   let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                   if let absoluteString = publicURL?.absoluteString {
                       print("Uploaded to: \(absoluteString)")
                       completion(absoluteString)
                   }
               } else {
                   print("Unexpected empty result.")
                   completion(nil)
               }
               return nil
           }
       }
   }
