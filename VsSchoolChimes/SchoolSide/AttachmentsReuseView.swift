//
//  AttachmentsReuseView.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/15/24.
//

import Foundation
import UIKit
import PhotosUI
import AWSS3
//AttachmentsReuseView
@available(iOS 14.0, *)



class CameraUtility: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate,PHPickerViewControllerDelegate {
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

   
    func getCurrentViewController() -> UIViewController? {
   //
           if let rootController = UIApplication.shared.keyWindow?.rootViewController {
               var currentController: UIViewController! = rootController
               while( currentController.presentedViewController != nil ) {
                   currentController = currentController.presentedViewController
               }
               return currentController
           }
           return nil
   
           }
    
    
    func dismissViewController() {
            // Call dismiss on the view controller if this method is in a view controller context
            if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                viewController.dismiss(animated: true, completion: nil)
            }
        }
    static func openCamera(from viewController: UIViewController) {
       
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            viewController.present(imagePicker, animated: true)
        } else {
            let alert = UIAlertController(title: "Camera Not Available".localized,
                                          message: "This device has no camera.".localized,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
            viewController.present(alert, animated: true)
        }
    }
    
    
    static func selectPDF(from viewController: UIViewController) {
       
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
        documentPicker.delegate = CameraUtility()
        viewController.present(documentPicker, animated: true, completion: nil)
    }
    // Handle the image once it has been captured
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: URL) {

        
        
        
        let fileurl: URL = urls as URL
        let filename = urls.lastPathComponent
        let fileextension = urls.pathExtension
        print("URL: \(fileurl)", "NAME: \(filename)", "EXTENSION: \(fileextension)")
        
 
        let imageData = NSData(contentsOf: urls)
        
        
        
        
        do {
            pdfData = try Data(contentsOf: urls, options: NSData.ReadingOptions())
            uploadPDFFileToAWS(pdfData: pdfData!)
            
        } catch {
            print("set PDF filer error : ", error)
            
        }
           
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadPDFFileToAWS(pdfData : Data){
        let S3BucketName = AwsCredentials.bucketNameIndia
        let CognitoPoolID = AwsCredentials.CognitoPoolID
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
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                  
                    let imageDict = NSMutableDictionary()
                    imageDict["FileName"] = absoluteString
                    self.imageUrlArray.add(imageDict)
                    self.convertedImagesUrlArray = self.imageUrlArray
                    
                    
                    
                    
                 
                }
            }
            else {
                
              
                print("Unexpected empty result.")
            }
            return nil
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
                    
                  
                    
                    
                    imageStr.append(absoluteString)
                  
                    
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
    
    
    
}




@available(iOS 14.0, *)
extension CameraUtility : PHPickerViewControllerDelegate{
    
   
    func selectImages(from viewController: UIViewController) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5  // Limit selection to 5 images
        config.filter = .images    // Only allow images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("bbbbPHPickerViewController")
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    guard let self = self, let image = image as? UIImage, error == nil else { return }
                    DispatchQueue.main.async { [self] in
                        self.selectedImages.append(image)
                        self.uploadAWS(image: image)
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
     [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            // Use the captured image
            // For example, display it in an image view or save it
            print("Captured Image: \(image)")
            self.selectedImages.append(image)
        } else if let image = info[.originalImage] as? UIImage {
            print("Captured Image: \(image)")
            self.selectedImages.append(image)
        }
        dismissViewController()
    }
    
    // Handle cancellation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissViewController()
    }
    
}
