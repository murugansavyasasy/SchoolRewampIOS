//
//  PhotoPickManager.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/16/24.
//

//import Foundation
//import UIKit
//import PhotosUI
//import AWSS3
//
//@available(iOS 14.0, *)
//class PhotoPickerManager: NSObject, PHPickerViewControllerDelegate,UIDocumentPickerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
//    var selectedImages: [UIImage] = []
//    var pdfData : Data? = nil
//    var convertedImagesUrlArray = NSMutableArray()
//    var  getImagePdfType : String!
//    var imageUrlArray = NSMutableArray()
//    var imageStr : [String] = []
//    var currentImageCount = 0
//    var totalImageCount = 0
//    var originalImagesArray = [UIImage]()
//    var onImagesPicked: (([UIImage]) -> Void)?
//    static let shared = PhotoPickerManager()
//    var onPdfPicked: ((Data) -> Void)?
//    var pdfUrl :((URL) -> Void)?
//    var onImagePicked: (([UIImage]) -> Void)?
//    var onCameraImagePicked: ((UIImage) -> Void)?
//    var onPdfString: ((String) -> Void)?
//    
//    private override init() {
//        
//    }
//    
//    static func createInstance() -> PhotoPickerManager {
//        return PhotoPickerManager()
//    }
//    
//    // Function to present the photo picker
//    func presentPhotoPicker(from viewController: UIViewController, selectionLimit: Int) {
//        var configuration = PHPickerConfiguration()
//        configuration.selectionLimit = selectionLimit
//        configuration.filter = .images // Only images
//        
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = self
//        viewController.present(picker, animated: true, completion: nil)
//    }
//    
//    // Delegate method to handle selected items
//    // MARK: - PHPickerViewControllerDelegate
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true, completion: nil)
//
//        var images = [UIImage]()
//        let totalCount = results.count
//        var loadedCount = 0
//
//        // 🌀 Show Circular Progress Loader
//        CircularProgressLoader.shared.show()
//
//        let dispatchGroup = DispatchGroup()
//        
//        for result in results {
//            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
//                dispatchGroup.enter()
//                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
//                    defer {
//                        // ✅ Update progress
//                        DispatchQueue.main.async {
//                            loadedCount += 1
//                            let percent = (Double(loadedCount) / Double(totalCount)) * 100
//                            CircularProgressLoader.shared.updateProgress(to: percent)
//                        }
//                        dispatchGroup.leave()
//                    }
//
//                    if let image = object as? UIImage {
//                        images.append(image)
//                    }
//                }
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) { [weak self] in
//            // ✅ Ensure loader is hidden at end (just in case)
//            CircularProgressLoader.shared.hide()
//            self?.onImagePicked?(images)
//        }
//    }
//
////    import Foundation
////    import UIKit
//
//    // Function to upload an image using a presigned URL
//    func uploadAWSUsingPresignedURL(image: UIImage, presignedURL: String, completion: @escaping (Result<String, Error>) -> Void) {
//        // Convert the UIImage to JPEG data
//        guard let imageData = image.jpegData(compressionQuality: 0.9),
//              let url = URL(string: presignedURL) else {
//            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid image or URL"])))
//            return
//        }
//
//        // Create a URLRequest for the presigned URL
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
//
//        // Use URLSession to upload the image
//        let uploadTask = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
//            if let error = error {
//                print("Upload failed: \(error.localizedDescription)")
//                completion(.failure(error))
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                if httpResponse.statusCode == 200 {
//                    print("Upload successful!")
//                    completion(.success(presignedURL)) // Returning the presigned URL as confirmation
//                } else {
//                    print("Upload failed with status code: \(httpResponse.statusCode)")
//                    let uploadError = NSError(domain: "UploadError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
//                    completion(.failure(uploadError))
//                }
//            }
//        }
//
//        // Start the upload task
//        uploadTask.resume()
//    }
//    
//    func pickPDF(from viewController: UIViewController) {
//        print("SELECT PDF")
//        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
//        documentPicker.delegate = self
//        viewController.present(documentPicker, animated: true, completion: nil)
//    }
//    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: URL) {
//        let fileurl: URL = urls as URL
//        let filename = urls.lastPathComponent
//        let fileextension = urls.pathExtension
//        print("URL: \(fileurl)", "NAME: \(filename)", "EXTENSION: \(fileextension)")
//        let imageData = NSData(contentsOf: urls)
//        do {
//            pdfData = try Data(contentsOf: urls, options: NSData.ReadingOptions())
//        } catch {
//            print("set PDF filer error : ", error)
//        }
//        let dispatchGroup = DispatchGroup()
//        dispatchGroup.notify(queue: .main) { [weak self] in
//            print("set PDF filer errr")
//            self?.onPdfPicked?(self!.pdfData!)
//            self?.pdfUrl?(fileurl)
//        }
//        
//    }
//    
//    func convertURLToData(from url: URL) -> Data? {
//        do {
//            let data = try Data(contentsOf: url)
//            return data
//        } catch {
//            print("Error converting URL to Data: \(error)")
//            return nil
//        }
//    }
//  
//    
//     func openCamera(from viewController: UIViewController) {
//        // Check if the camera is available
//         print("camera")
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = .camera
//            imagePicker.allowsEditing = true // Allows editing of the captured image
//            viewController.present(imagePicker, animated: true, completion: nil)
//        } else {
//            // Camera is not available, show an alert
//            let alert = UIAlertController(title: "Camera Not Available".translated(), message: "This device has no camera.".translated(), preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK".translated(), style: .default, handler: nil))
//            viewController.present(alert, animated: true, completion: nil)
//        }
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let editedImage = info[.editedImage] as? UIImage {
//                // Use the edited image
//                print("Captured Edited Image: \(editedImage)")
//                self.selectedImages.append(editedImage)
//                let dispatchGroup = DispatchGroup()
//               
//                dispatchGroup.notify(queue: .main) { [weak self] in
//                    self?.onCameraImagePicked?(editedImage)
//                }
//            } else if let originalImage = info[.originalImage] as? UIImage {
//                // Use the original image
//                print("Captured Original Image: \(originalImage)")
//                self.selectedImages.append(originalImage)
//            }
//            
//            picker.dismiss(animated: true, completion: nil)
//        }
//        
//    
//    // Handle cancellation
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//    
//    
//}
import Foundation
import UIKit
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers

@available(iOS 14.0, *)
class PhotoPickerManager: NSObject, PHPickerViewControllerDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    enum PickerType {
        case camera
        case gallery(selectionLimit: Int)
        case video
        case pdf
        case file
    }

    static let shared = PhotoPickerManager()
    
    // MARK: - Callbacks
    var onImagesPicked: (([UIImage]) -> Void)?
    var onCameraImagePicked: ((UIImage) -> Void)?
    var onVideoPicked: ((URL) -> Void)?
//    var onPdfPicked: ((Data) -> Void)?
    var onPdfPicked: ((URL) -> Void)?
    var onFilePicked: ((URL) -> Void)?

    private override init() {}

    // MARK: - Public API
//    func presentPicker(ofType type: PickerType, from viewController: UIViewController) {
//        switch type {
//        case .camera:
//            openCamera(from: viewController)
//        case .gallery(let selectionLimit):
//            openPhotoLibrary(from: viewController, selectionLimit: selectionLimit)
//        case .video:
//            openVideoPicker(from: viewController)
//        case .pdf:
//            openDocumentPicker(from: viewController, types: [UTType.pdf])
//        case .file:
//            openDocumentPicker(from: viewController, types: [UTType.item])
//        }
//    }
    func presentPicker(ofType type: PickerType, from viewController: UIViewController) {
        switch type {
        case .camera:
            openCamera(from: viewController)
        case .gallery(let selectionLimit):
            openPhotoLibrary(from: viewController, selectionLimit: selectionLimit)
        case .video:
            openVideoPicker(from: viewController)
        case .pdf:
            openDocumentPicker(from: viewController, types: [UTType.pdf])
        case .file:
            let supportedTypes: [UTType] = [
                UTType.item,
                UTType.text,
                UTType.rtf,
                UTType.plainText,
                UTType.pdf,
                UTType(filenameExtension: "docx")!,
                UTType(filenameExtension: "xlsx")!,
                UTType(filenameExtension: "pptx")!
            ]
            openDocumentPicker(from: viewController, types: supportedTypes)
        }
    }

    // MARK: - Camera
    private func openCamera(from viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Not Available", message: "This device has no camera.", on: viewController)
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        viewController.present(picker, animated: true)
    }

    // MARK: - Gallery
    private func openPhotoLibrary(from viewController: UIViewController, selectionLimit: Int) {
        var config = PHPickerConfiguration()
        config.selectionLimit = selectionLimit
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        viewController.present(picker, animated: true)
    }

    // MARK: - Video
    private func openVideoPicker(from viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        viewController.present(picker, animated: true)
    }

    // MARK: - File or PDF
    private func openDocumentPicker(from viewController: UIViewController, types: [UTType]) {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        viewController.present(picker, animated: true)
    }

    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        var images: [UIImage] = []
        let group = DispatchGroup()

        for result in results {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, _) in
                if let image = object as? UIImage {
                    images.append(image)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.onImagesPicked?(images)
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let mediaType = info[.mediaType] as? String {
            if mediaType == "public.image" {
                if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                    onCameraImagePicked?(image)
                }
            } else if mediaType == "public.movie", let mediaURL = info[.mediaURL] as? URL {
                onVideoPicked?(mediaURL)
            }
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    // MARK: - UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        let fileExtension = fileURL.pathExtension.lowercased()

        switch fileExtension {
        case "pdf":
            do {
                let data = try Data(contentsOf: fileURL)
                onPdfPicked?(fileURL)
            } catch {
                print("Error reading PDF data: \(error)")
            }

        case "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "rtf":
            onFilePicked?(fileURL)

        default:
            print("Unsupported file type: \(fileExtension)")
        }
    }


    // MARK: - Utility
    private func showAlert(title: String, message: String, on vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        vc.present(alert, animated: true)
    }
}
