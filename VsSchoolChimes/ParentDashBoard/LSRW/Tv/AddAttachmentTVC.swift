//
//  AddAttachmentTVC.swift
//  School Chimes
//
//  Created by Chandhru on 09/07/25.
//

import UIKit
import Kingfisher

@available(iOS 15.0, *)
class AddAttachmentTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var addAttachmentView: ImageSelection!
    
    // MARK: - Properties
    var attachments: [AttachmentItem] = []
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Register collection view cells
        addAttachmentView.imageCollectionview.register(UINib(nibName: CellConfingName.AttachmentCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.AttachmentCVCell)
        addAttachmentView.imageCollectionview.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        addAttachmentView.imageCollectionview.delegate = self
        addAttachmentView.imageCollectionview.dataSource = self
        addAttachmentView.imageCollectionview.backgroundColor = .clear
    }

    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + attachments.count
    }
    
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell, for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
            let adjustedIndex = indexPath.item - 1
            guard adjustedIndex < attachments.count else { return cell }
            
            let item = attachments[adjustedIndex]
            cell.delegate = self
            cell.deleteBtn.tag = adjustedIndex
            
            if let image = item.image {
                cell.imageViews.image = image
            } else if let urlStr = item.imageURL, let url = URL(string: urlStr) {
                if item.fileType.uppercased() != CommonStringFile.IMAGE {
                    cell.imageViews.image = UIImage(named: getFileIconName(for: url))
                } else {
                    cell.imageViews.kf.setImage(with: url)
                }
            } else {
                cell.imageViews.image = nil
            }
            return cell
        }
    }

    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            showAttachmentOptions()
        } else {
            let adjustedIndex = indexPath.item - 1
            guard adjustedIndex < attachments.count else { return }
            
            let item = attachments[adjustedIndex]
            guard item.fileType.lowercased() != "video" else { return }
            
            let vc = PreviewImageVC()
            vc.modalPresentationStyle = .fullScreen
            
            if item.fileType != CommonStringFile.IMAGE {
                if let url = item.imageURL, let fileURL = URL(string: url) {
                    vc.selectedFileURL = fileURL
                }
            } else {
                if let image = item.image {
                    vc.img = image
                } else if let urlString = item.imageURL, let url = URL(string: urlString) {
                    vc.selectedFileURL = url
                }
            }
            vc.type = item.fileType
            
            getCurrentViewController()?.present(vc, animated: true)
        }
    }

    // MARK: - Attachment Option Alert
    private func showAttachmentOptions() {
        let alertController = UIAlertController(
            title: "Select".translated(),
            message: "Choose an option".translated(),
            preferredStyle: .actionSheet
        )
        
        alertController.addAction(UIAlertAction(title: "Camera".translated(), style: .default) { [weak self] _ in
            self?.handleCameraSelection()
        })
        
        alertController.addAction(UIAlertAction(title: "Gallery".translated(), style: .default) { [weak self] _ in
            self?.handleGallerySelection()
        })
        
        alertController.addAction(UIAlertAction(title: "Document".translated(), style: .default) { [weak self] _ in
            self?.handlePDFSelection()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel".translated(), style: .cancel))

        getCurrentViewController()?.present(alertController, animated: true)
    }

    // MARK: - Picker Handlers
    private func handleGallerySelection() {
        guard let vc = getCurrentViewController() else { return }
        let imageCount = attachments.filter { $0.fileType == CommonStringFile.IMAGE }.count
        guard imageCount < 5 else {
            showLimitReachedAlert()
            return
        }
        PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5 - imageCount), from: vc)
    }

    private func handleCameraSelection() {
        guard let vc = getCurrentViewController() else { return }
        let imageCount = attachments.filter { $0.fileType == CommonStringFile.IMAGE }.count
        guard imageCount < 5 else {
            showLimitReachedAlert()
            return
        }
        PhotoPickerManager.shared.presentPicker(ofType: .camera, from: vc)
    }

    private func handlePDFSelection() {
        guard let vc = getCurrentViewController() else { return }
        let pdfCount = attachments.filter { $0.fileType == CommonStringFile.pdf }.count
        guard pdfCount < 5 else {
            showLimitReachedAlert()
            return
        }
        PhotoPickerManager.shared.limiSelection = 5 - pdfCount
        PhotoPickerManager.shared.presentPicker(ofType: .file, from: vc)
    }

    // MARK: - Alert
    private func showLimitReachedAlert() {
        guard let vc = getCurrentViewController() else { return }
        let alert = CustomAlert()
        alert.showAlert(title: "", message: "Already reached your limit".translated(), on: vc)
    }

    // MARK: - Current VC Helper
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }

}

// MARK: - DeleteImage Delegate
@available(iOS 15.0, *)
extension AddAttachmentTVC: DeleteImge {
    func deleteImage(index: Int) {
        guard index < attachments.count else { return }
        attachments.remove(at: index)
        addAttachmentView.imageCollectionview.reloadData()
    }
}
