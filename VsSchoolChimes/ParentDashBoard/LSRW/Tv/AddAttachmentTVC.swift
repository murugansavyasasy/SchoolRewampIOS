//
//  AddAttachmentTVC.swift
//  School Chimes
//
//  Created by Chandhru on 09/07/25.
//

import UIKit
import Kingfisher

@available(iOS 15.0, *)
class AddAttachmentTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - IBOutlets
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addAttachmentView: ImageSelection!

    // MARK: - Properties
    var attachments: [AttachmentItem] = []
    var delegate: BaktoHome?
    private let maxAttachments = 5

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageSelection()
        setupCollectionView()
    }

    // MARK: - Setup Methods
    private func setupCollectionView() {
        let imageCV = addAttachmentView.imageCollectionview
        imageCV?.register(UINib(nibName: CellConfingName.AttachmentCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.AttachmentCVCell)
        imageCV?.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        imageCV?.delegate = self
        imageCV?.dataSource = self
        imageCV?.backgroundColor = .clear
    }

    private func setupImageSelection() {
        PhotoPickerManager.shared.onCameraImagePicked = { [weak self] image in
            guard let self = self else { return }
            self.attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            self.attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            self.addAttachmentView.imageCollectionview.reloadData()
            self.delegate?.backtohome()
        }

        PhotoPickerManager.shared.onImagesPicked = { [weak self] images in
            guard let self = self else { return }
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            self.attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            self.attachments.append(contentsOf: imageItems)
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            self.addAttachmentView.imageCollectionview.reloadData()
            self.delegate?.backtohome()
        }

        PhotoPickerManager.shared.onFilePicked = { [weak self] fileURL in
            guard let self = self else { return }
            self.attachments.removeAll { $0.fileType == CommonStringFile.IMAGE }
            self.attachments.append(AttachmentItem(image: nil, imageURL: fileURL.absoluteString, fileType: CommonStringFile.pdf))
            user_inputs.selectedFileType = CommonStringFile.pdf
            self.addAttachmentView.imageCollectionview.reloadData()
            self.delegate?.backtohome()
        }
    }

    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + attachments.count
    }

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

            collectionViewHeight.constant = attachments.count <= 2 ? 130 :260
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

            if item.fileType == CommonStringFile.IMAGE {
                if let image = item.image {
                    vc.img = image
                } else if let url = item.imageURL.flatMap(URL.init) {
                    vc.selectedFileURL = url
                }
            } else if let url = item.imageURL.flatMap(URL.init) {
                vc.selectedFileURL = url
            }

            vc.type = item.fileType
            getCurrentViewController()?.present(vc, animated: true)
        }
    }

    // MARK: - CollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 30) / 3
        return CGSize(width: width, height: 120)
    }

    // MARK: - Attachment Option Alert
    private func showAttachmentOptions() {
        let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)

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
        guard imageCount < maxAttachments else {
            showLimitReachedAlert()
            return
        }
        PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: maxAttachments - imageCount), from: vc)
    }

    private func handleCameraSelection() {
        guard let vc = getCurrentViewController() else { return }
        let imageCount = attachments.filter { $0.fileType == CommonStringFile.IMAGE }.count
        guard imageCount < maxAttachments else {
            showLimitReachedAlert()
            return
        }
        PhotoPickerManager.shared.presentPicker(ofType: .camera, from: vc)
    }

    private func handlePDFSelection() {
        guard let vc = getCurrentViewController() else { return }
        let pdfCount = attachments.filter { $0.fileType == CommonStringFile.pdf }.count
        guard pdfCount < maxAttachments else {
            showLimitReachedAlert()
            return
        }
        PhotoPickerManager.shared.limiSelection = maxAttachments - pdfCount
        PhotoPickerManager.shared.presentPicker(ofType: .file, from: vc)
    }

    // MARK: - Alert
    private func showLimitReachedAlert() {
        getCurrentViewController().flatMap {
            CustomAlert().showAlert(title: "", message: "Already reached your limit".translated(), on: $0)
        }
    }

    // MARK: - Current VC Helper
    func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
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
