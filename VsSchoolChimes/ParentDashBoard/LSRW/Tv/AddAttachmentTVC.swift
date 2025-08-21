//
//  AddAttachmentTVC.swift
//  School Chimes
//
//  Created by Chandhru on 09/07/25.
//
import UIKit
import Kingfisher
import UniformTypeIdentifiers
@available(iOS 15.0, *)
class AddAttachmentTVC: UITableViewCell,
                        UICollectionViewDelegate,
                        UICollectionViewDataSource,
                        UICollectionViewDelegateFlowLayout,
                        UIDocumentPickerDelegate,DeleteImge{
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustCollectionViewHeight()
    }
    
    private func adjustCollectionViewHeight() {
        if let collectionView = addAttachmentView.imageCollectionview {
            collectionView.layoutIfNeeded()
            collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
            delegate?.backtohome(type: "")
        }
        
    }
    
    // After reloadData(), call this helper
    private func reloadAttachments() {
        addAttachmentView.imageCollectionview.reloadData()
        adjustCollectionViewHeight()
    }
    
    // MARK: - Setup Methods
    private func setupCollectionView() {
        let imageCV = addAttachmentView.imageCollectionview
        imageCV?.register(UINib(nibName: CellConfingName.AttachmentCVCell, bundle: nil),
                          forCellWithReuseIdentifier: CellConfingName.AttachmentCVCell)
        imageCV?.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil),
                          forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        imageCV?.delegate = self
        imageCV?.dataSource = self
        imageCV?.backgroundColor = .clear
    }
    
    private func setupImageSelection() {
        PhotoPickerManager.shared.onCameraImagePicked = { [weak self] image in
            guard let self = self else { return }
            self.attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            self.attachments.append(AttachmentItem(image: image,
                                                   imageURL: nil,
                                                   fileType: CommonStringFile.IMAGE))
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            self.reloadAttachments()
            self.delegate?.backtohome(type: "")
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [weak self] images in
            guard let self = self else { return }
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            self.attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            self.attachments.append(contentsOf: imageItems)
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            self.reloadAttachments()
            self.delegate?.backtohome(type: "")
        }
        
        PhotoPickerManager.shared.onFilePicked = { [weak self] fileURL in
            guard let self = self else { return }
            self.attachments.removeAll { $0.fileType == CommonStringFile.IMAGE }
            self.attachments.append(AttachmentItem(image: nil,
                                                   imageURL: fileURL.absoluteString,
                                                   fileType: CommonStringFile.pdf))
            user_inputs.selectedFileType = CommonStringFile.pdf
            self.reloadAttachments()
            self.delegate?.backtohome(type: "")
        }
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell,
                                                          for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell,
                                                          for: indexPath) as! ImageCvCell
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
    
    // MARK: - DeleteImage Delegate
    func deleteImage(index: Int) {
        guard index < attachments.count else { return }
        attachments.remove(at: index)
        reloadAttachments()
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            // FIXED: call correct function
            presentAttachmentOptions(for: "General")
            delegate?.backtohome(type: "")
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
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 30) / 3
        return CGSize(width: width, height: 120)
    }
    
    // MARK: - Options
    private func presentAttachmentOptions(for task: String) {
        let alertController = UIAlertController(
            title: "Select".translated(),
            message: "Choose an option".translated(),
            preferredStyle: .actionSheet
        )
        
        var options: [AttachmentOption] = [
            AttachmentOption(type: .camera, title: "Camera".translated()) { [weak self] in
                self?.handleCameraSelection()
            },
            AttachmentOption(type: .gallery, title: "Gallery".translated()) { [weak self] in
                self?.handleGallerySelection()
            },
            AttachmentOption(type: .pdf, title: "Document".translated()) { [weak self] in
                self?.handlePDFSelection()
            },
            AttachmentOption(type: .recording, title: "Recording".translated()) {
                self.delegate?.backtohome(type: "Recording")
            },
            AttachmentOption(type: .audio, title: "Audio".translated()) { [weak self] in
                self?.audio()
            },
            AttachmentOption(type: .video, title: "Video") { [weak self] in
                self?.videoPick()
            }
        ]
        
        if task == "Reading" {
            options.removeAll { $0.type == .recording || $0.type == .audio }
        }
        
        for option in options {
            alertController.addAction(UIAlertAction(title: option.title,
                                                    style: .default,
                                                    handler: { _ in option.handler() }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel".translated(),
                                                style: .cancel))
        getCurrentViewController()?.present(alertController, animated: true)
    }
    
    func videoPick() {
        let videoCount = attachments.filter { $0.fileType == CommonStringFile.VIDEO }.count
        guard videoCount < 2 else {
            if let vc = getCurrentViewController(){
                CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit,
                                        on: vc)
            }
            
            return
        }
        
        if attachments.count < 10 {
            PhotoPickerManager.shared.limiSelection = 10 - attachments.count
            if let vc = getCurrentViewController() {
                PhotoPickerManager.shared.presentPicker(ofType: .video, from: vc)
            }
        } else {
            if let vc = getCurrentViewController(){
                CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit,
                                        on: vc)
            }
           
        }
    }
    
    func audio() {
        let supportedTypes: [UTType] = [.audio]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        getCurrentViewController()?.present(documentPicker, animated: true)
    }
    
    // MARK: - Picker Handlers
    private func handleGallerySelection() {
        guard let vc = getCurrentViewController() else { return }
        let imageCount = attachments.filter { $0.fileType == CommonStringFile.IMAGE }.count
        guard imageCount < maxAttachments else {
            showLimitReachedAlert()
            return
        }
        PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: maxAttachments - imageCount),from: vc)
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
        if let vc = getCurrentViewController() {
            CustomAlert().showAlert(title: "",
                                    message: "Already reached your limit".translated(),
                                    on: vc)
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
