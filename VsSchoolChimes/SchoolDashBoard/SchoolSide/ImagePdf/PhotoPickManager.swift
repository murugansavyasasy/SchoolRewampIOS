//
//  PhotoPickManager.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 16/04/25.
//

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
    var limiSelection = 0
    private override init() {}

    // MARK: - Public API

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
                UTType.text,
                UTType.rtf,
                UTType.plainText,
                UTType.pdf,
                UTType(filenameExtension: "docx") ?? UTType.pdf,
                UTType(filenameExtension: "xlsx") ?? UTType.pdf,
                UTType(filenameExtension: "pptx") ?? UTType.pdf
            ]
            openDocumentPicker(from: viewController, types: supportedTypes)
        }
    }

    // MARK: - Camera
//    private func openCamera(from viewController: UIViewController) {
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
//            showAlert(title: "Camera Not Available", message: "This device has no camera.", on: viewController)
//            return
//        }
//        
//        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
//            UIApplication.shared.open(settingsURL)
//        }
//
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.sourceType = .camera
//        picker.allowsEditing = true
//        viewController.present(picker, animated: true)
//    }
    
    private func openCamera(from viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Not Available", message: "This device has no camera.", on: viewController)
            return
        }

        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch authStatus {
        case .authorized:
            // Permission granted
            presentCameraPicker(from: viewController)

        case .notDetermined:
            // Ask for permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentCameraPicker(from: viewController)
                    } else {
                        self.showPermissionAlert(on: viewController)
                    }
                }
            }

        case .denied, .restricted:
            // Permission denied
            showPermissionAlert(on: viewController)

        @unknown default:
            break
        }
    }
    
    private func presentCameraPicker(from viewController: UIViewController) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.mediaTypes = ["public.image"] // Restrict to photo only
        viewController.present(picker, animated: true)
    }

    private func showPermissionAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "To take a photo, please enable camera access in Settings.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        })

        viewController.present(alert, animated: true)
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
        picker.allowsMultipleSelection = true
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
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        let supportedExtensions = ["doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "rtf", "pdf"]
//        let supportedFiles = urls.filter {
//            supportedExtensions.contains($0.pathExtension.lowercased())
//        }
//        
//        // Enforce limit
//        if supportedFiles.count > limiSelection {
//            // Show alert and exit
//            let alert = UIAlertController(title: "Limit Exceeded", message: "You can only select up to 5 files.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            controller.present(alert, animated: true)
//            return
//        }
//
//        // If within limit, proceed
//        for fileURL in supportedFiles {
//            onFilePicked?(fileURL)
//        }
//    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let supportedExtensions = ["doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "rtf", "pdf"]
        let supportedFiles = urls.filter { supportedExtensions.contains($0.pathExtension.lowercased()) }

        if supportedFiles.count > limiSelection {
            let filesToProcess = supportedFiles.prefix(limiSelection)
            let alert = UIAlertController(title: "Limit Exceeded",
                                         message: "You can only select up to \(limiSelection) files. Only the first \(limiSelection) will be processed.",
                                         preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                for fileURL in filesToProcess {
                    self.onFilePicked?(fileURL)
                }
            })
            
            controller.present(alert, animated: true)
        } else {
            // If within limit, proceed immediately
            for fileURL in supportedFiles {
                let url = persistFileIfNeeded(at: fileURL)
                onFilePicked?(url)
            }
        }
    }
    
    func persistFileIfNeeded(at url: URL) -> URL {
        let fileManager = FileManager.default
        let tempDir = NSTemporaryDirectory()

        if url.path.contains(tempDir) || url.path.contains("-Inbox/") {
            let fileName = url.lastPathComponent
            let destinationURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: url, to: destinationURL)
                print("📁 File copied to persistent path: \(destinationURL.path)")
                return destinationURL
            } catch {
                print("❌ Failed to copy file: \(error)")
                return url
            }
        }
        return url
    }


    
    // MARK: - Utility
    private func showAlert(title: String, message: String, on vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        vc.present(alert, animated: true)
    }
}
