//
//  QuizAttachmentPicker.swift
//  School Chimes
//
//  Created by apple on 17/12/25.
//

import UIKit
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers

@available(iOS 14.0, *)
class QuizAttachmentPicker: NSObject {

    static let shared = QuizAttachmentPicker()

    weak var presenter: UIViewController?

    var onImagesPicked: (([UIImage]) -> Void)?
    var onCameraPicked: ((UIImage) -> Void)?
    var onVideoPicked: ((URL) -> Void)?
    var onDocumentPicked: (([URL]) -> Void)?

    private override init() {}

    // MARK: - Present Action Sheet
    func presentOptions(from vc: UIViewController, maxLimit: Int, videoLimit: Int) {
        presenter = vc

        let alert = UIAlertController(title: "Add Attachment",
                                      message: "Choose file type",
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "📷 Camera", style: .default) { _ in
            self.openCamera()
        })

        alert.addAction(UIAlertAction(title: "🖼 Photos", style: .default) { _ in
            self.openGallery(selectionLimit: maxLimit)
        })

        alert.addAction(UIAlertAction(title: "🎥 Video", style: .default) { _ in
            self.openVideoPicker(videoLimit: videoLimit)
        })

        alert.addAction(UIAlertAction(title: "📄 Document", style: .default) { _ in
            self.openDocument()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        vc.present(alert, animated: true)
    }

    // MARK: - Camera
    private func openCamera() {
        guard let presenter = presenter else { return }

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            self.showAlert("Camera Not Available")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self

        presenter.present(picker, animated: true)
    }

    // MARK: - Multi Image Picker
    func openGallery(selectionLimit: Int) {
        var config = PHPickerConfiguration()
        config.selectionLimit = selectionLimit
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        presenter?.present(picker, animated: true)
    }

    // MARK: - Video Picker
    func openVideoPicker(videoLimit: Int) {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = videoLimit

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        presenter?.present(picker, animated: true)
    }

    // MARK: - Document Picker
    func openDocument() {
        let types: [UTType] = [.pdf, .text, .rtf, .plainText, UTType(filenameExtension: "docx")!]

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = self

        presenter?.present(picker, animated: true)
    }

    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        presenter?.present(alert, animated: true)
    }
}


// MARK: - PHPicker Delegate
@available(iOS 14.0, *)
extension QuizAttachmentPicker: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        var images: [UIImage] = []
        let group = DispatchGroup()

        for item in results {
            if item.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                item.itemProvider.loadObject(ofClass: UIImage.self) { (object, _) in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            self.onImagesPicked?(images)
        }

        if let first = results.first,
           first.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {

            first.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                guard let url else { return }
                let temp = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                try? FileManager.default.copyItem(at: url, to: temp)
                DispatchQueue.main.async {
                    self.onVideoPicked?(temp)
                }
            }
        }
    }
}


// MARK: - Camera
@available(iOS 14.0, *)
extension QuizAttachmentPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let img = info[.originalImage] as? UIImage {
            onCameraPicked?(img)
        }
        picker.dismiss(animated: true)
    }
}


// MARK: - Document Picker
@available(iOS 14.0, *)
extension QuizAttachmentPicker: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        onDocumentPicked?(urls)
    }
}
