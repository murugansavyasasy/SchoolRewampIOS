//
//  chatAttachmentPicker.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 02/07/25.
//


import UIKit
import PhotosUI
import UniformTypeIdentifiers
import MobileCoreServices

@available(iOS 14.0, *)
class MediaPickerManager: NSObject, PHPickerViewControllerDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static let shared = MediaPickerManager()
    
    var pickedMedia: [PickedMedia] = []
    var onMediaPicked: (([PickedMedia]) -> Void)?
    
    enum MediaType {
        case image(UIImage)
        case document(URL)
    }
    
    struct PickedMedia {
        let type: MediaType
    }
    
    private weak var presentingVC: UIViewController?
    
    // MARK: - Show Picker
    
    func showPicker(from vc: UIViewController) {
        presentingVC = vc
        
        let alert = UIAlertController(title: "Select Media", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.pickImageFromGallery(vc)
        })
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.takePhoto(vc)
        })
        alert.addAction(UIAlertAction(title: "Document", style: .default) { _ in
            self.pickDocument(vc)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.present(alert, animated: true)
    }
    
    // MARK: - Image from Gallery
    
    private func pickImageFromGallery(_ vc: UIViewController) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        vc.present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let group = DispatchGroup()
        var newMedia: [PickedMedia] = []
        
        for result in results {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (reading, error) in
                if let image = reading as? UIImage {
                    newMedia.append(PickedMedia(type: .image(image)))
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.pickedMedia.append(contentsOf: newMedia)
            self.onMediaPicked?(self.pickedMedia)
        }
    }
    
    // MARK: - Take Photo
    
    private func takePhoto(_ vc: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        vc.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            pickedMedia.append(PickedMedia(type: .image(image)))
            onMediaPicked?(pickedMedia)
        }
    }
    
    // MARK: - Document Picker
    
    private func pickDocument(_ vc: UIViewController) {
        let supportedTypes: [UTType] = [UTType.pdf, UTType.text, UTType.rtf, UTType.plainText, UTType.image]
        let docPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        docPicker.delegate = self
        vc.present(docPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            pickedMedia.append(PickedMedia(type: .document(url)))
        }
        onMediaPicked?(pickedMedia)
    }
}
