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
                        UIDocumentPickerDelegate,
                        DeleteImge,
                        AudioPlaybackDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var discriptionView: UIView!
    @IBOutlet weak var descriptionTXT: UITextField!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var addAttachmentView: ImageSelection!
    
    // MARK: - Properties
    var attachments: [AttachmentItem] = []
    var delegate: BaktoHome?
    var Adddelegate: EditObjectDelegate?
    var taskType: LSRWType?
    private let maxAttachments = 5
    private var lastAttachmentCount = 0
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }

    func config(_ attachment:[AttachmentItem], task:LSRWType?) {
        attachments = attachment
        taskType = task
        setupPhotoPickerClosures()
        reloadAttachments()
    }
    
    // MARK: - Height Adjustment
    private func adjustCollectionViewHeight() {
        if let collectionView = addAttachmentView.imageCollectionview {
            collectionView.layoutIfNeeded()
            let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
            collectionViewHeight.constant = max(contentHeight, 120) // minimum 120
        }
    }
    
    // MARK: - Reload Helper
    private func reloadAttachments() {
        addAttachmentView.imageCollectionview.reloadData()
        adjustCollectionViewHeight()
        if lastAttachmentCount != attachments.count {
            lastAttachmentCount = attachments.count
            Adddelegate?.editDta(edit: attachments)
        }
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        let imageCV = addAttachmentView.imageCollectionview
        imageCV?.register(UINib(nibName: CellConfingName.AttachmentCVCell, bundle: nil),
                          forCellWithReuseIdentifier: CellConfingName.AttachmentCVCell)
        imageCV?.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil),
                          forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        imageCV?.register(UINib(nibName: "AudioCVC", bundle: nil),
                          forCellWithReuseIdentifier: "AudioCVC")
        let layout = LeftAlignedFlowLayout()
        imageCV?.collectionViewLayout = layout
        imageCV?.delegate = self
        imageCV?.dataSource = self
        imageCV?.backgroundColor = .clear
    }
    
    // MARK: - Picker Closures
    private func setupPhotoPickerClosures() {
        // Reset old closures
        PhotoPickerManager.shared.onCameraImagePicked = nil
        PhotoPickerManager.shared.onImagesPicked = nil
        PhotoPickerManager.shared.onFilePicked = nil
        PhotoPickerManager.shared.onVideoPicked = nil

        PhotoPickerManager.shared.onCameraImagePicked = { [weak self] image in
            guard let self = self else { return }
            self.attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            self.reloadAttachments()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [weak self] images in
            guard let self = self else { return }
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            self.attachments.append(contentsOf: imageItems)
            self.reloadAttachments()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [weak self] data in
            guard let self = self else { return }
            user_inputs.selectedFileType = CommonStringFile.pdf
            self.attachments.append(AttachmentItem(image: nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            self.reloadAttachments()
        }
        
        PhotoPickerManager.shared.onVideoPicked = { [weak self] data in
            guard let self = self else { return }
            user_inputs.selectedFileType = CommonStringFile.VIDEO
            self.attachments.append(
                AttachmentItem(image: nil, imageURL: data.absoluteString, fileType: CommonStringFile.VIDEO, VideoURl: nil)
            )
            self.reloadAttachments()
        }
    }
    
    // MARK: - Helper Methods
    private func getCellType(at index: Int) -> String {
        if index == 0 {
            return "add_button"
        } else {
            let attachment = attachments[index - 1]
            return attachment.fileType.lowercased() == "audio" ? "audio" : "non_audio"
        }
    }
    
    // MARK: - CollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1 + attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellType = getCellType(at: indexPath.item)
        
        switch cellType {
        case "add_button":
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.AttachmentCVCell,
                for: indexPath
            ) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
            
        case "audio":
            let file = attachments[indexPath.item - 1]
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AudioCVC",
                for: indexPath
            ) as! AudioCVC
            
            if let url = URL(string: file.imageURL ?? "") {
                cell.audioURL = url
                cell.TrashIcon.isHidden = false
                cell.TrashIcon.isUserInteractionEnabled = true
            }
            
            cell.audioDelegate = self
            cell.cellIndex = indexPath.item - 1
            cell.TrashIcon.tag = indexPath.item - 1
            cell.delegate = self
            cell.waveView.setParentCell(cell)
            
            return cell
            
        default:
            let file = attachments[indexPath.item - 1]
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.ImageCvCell,
                for: indexPath
            ) as! ImageCvCell
            
            cell.delegate = self
            cell.deleteBtn.tag = indexPath.item - 1
            
            if let image = file.image {
                cell.imageViews.image = image
            } else if let urlStr = file.imageURL, let url = URL(string: urlStr) {
                if file.fileType.uppercased() != CommonStringFile.IMAGE {
                    let iconName = getFileIconName(for: url)
                    cell.imageViews.image = UIImage(named: iconName)
                } else {
                    cell.imageViews.kf.setImage(with: url)
                }
            } else if let video = file.VideoURl {
                let iconName = getFileIconName(for: video)
                cell.imageViews.image = UIImage(named: iconName)
            } else {
                cell.imageViews.image = nil
            }
            return cell
        }
    }
    
    // MARK: - DeleteImage Delegate
    func deleteImage(index: Int) {
        guard index < attachments.count else { return }
        if let url = URL(string: attachments[index].imageURL ?? ""), url.isFileURL, FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        attachments.remove(at: index)
        reloadAttachments()
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            if let taskType = taskType {
                presentAttachmentOptions(for: taskType)
            } else {
                presentAttachmentOptions(for: .unknown(""))
            }
            delegate?.backtohome(type: "")
        } else {
            let file = attachments[indexPath.item - 1]
            guard file.fileType.lowercased() != "audio" else { return }
            
            let vc = PreviewImageVC()
            vc.modalPresentationStyle = .fullScreen
            
            if file.fileType == CommonStringFile.IMAGE {
                if let image = file.image {
                    vc.img = image
                } else if let url = file.imageURL.flatMap(URL.init) {
                    vc.selectedFileURL = url
                }
            } else if let url = file.imageURL.flatMap(URL.init) {
                vc.selectedFileURL = url
            }
            
            vc.type = file.fileType
            getCurrentViewController()?.present(vc, animated: true)
        }
    }
    
    // MARK: - FlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellType = getCellType(at: indexPath.item)
        let collectionViewWidth = addAttachmentView.imageCollectionview.frame.width
        
        switch cellType {
        case "add_button", "non_audio":
            let width = (collectionViewWidth - 30) / 3
            return CGSize(width: width, height: 100)
            
        case "audio":
            return CGSize(width: collectionViewWidth - 20, height: 70)
            
        default:
            let width = (collectionViewWidth - 30) / 3
            return CGSize(width: width, height: 100)
        }
    }
    
    // MARK: - Audio Delegate
    func audioCell(_ cell: AudioCVC, willStartPlayingAtIndex index: Int) {
        stopAllOtherAudioCells(except: index)
    }
    
    func audioCell(_ cell: AudioCVC, didStopPlayingAtIndex index: Int) {
        print("Audio stopped playing at index: \(index)")
    }
    
    private func stopAllOtherAudioCells(except playingIndex: Int) {
        for visibleCell in addAttachmentView.imageCollectionview.visibleCells {
            if let audioCell = visibleCell as? AudioCVC,
               audioCell.cellIndex != playingIndex {
                audioCell.stopPlayback()
            }
        }
    }
    
    // MARK: - Options / Picker
    private func presentAttachmentOptions(for task: LSRWType) {
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
                self?.VideoPick()
            }
        ]
        
        switch task {
        case .reading:
            options.removeAll { ![.video].contains($0.type) }
        case .listening, .writing:
            options.removeAll { $0.type == .recording || $0.type == .audio }
        case .speaking:
            options.removeAll { ![.recording, .audio, .video].contains($0.type) }
        default:
            break
        }
        
        for option in options {
            alertController.addAction(UIAlertAction(title: option.title,style: .default,
                                                    handler: { _ in option.handler() }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel".translated(),
                                                style: .cancel))
        getCurrentViewController()?.present(alertController, animated: true)
    }

    func VideoPick() {
        guard let vc = getCurrentViewController() else { return }
        let video = attachments.filter { $0.fileType != CommonStringFile.VIDEO }
        
        if video.count != 2 {
            if attachments.count <= 10 {
                PhotoPickerManager.shared.limiSelection = 10 - attachments.count
                PhotoPickerManager.shared.presentPicker(ofType: .video, from: vc)
            } else {
                CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: vc)
            }
        } else {
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: vc)
        }
    }
    
    func audio() {
        let supportedTypes: [UTType] = [.audio]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        getCurrentViewController()?.present(documentPicker, animated: true)
    }
    
    private func handleGallerySelection() {
        guard let vc = getCurrentViewController() else { return }
        let imageCount = attachments.filter { $0.fileType == CommonStringFile.IMAGE }.count
        guard imageCount < maxAttachments else { showLimitReachedAlert(); return }
        PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: maxAttachments - imageCount), from: vc)
    }
    
    private func handleCameraSelection() {
        guard let vc = getCurrentViewController() else { return }
        let imageCount = attachments.filter { $0.fileType == CommonStringFile.IMAGE }.count
        guard imageCount < maxAttachments else { showLimitReachedAlert(); return }
        PhotoPickerManager.shared.presentPicker(ofType: .camera, from: vc)
    }
    
    private func handlePDFSelection() {
        guard let vc = getCurrentViewController() else { return }
        let pdfCount = attachments.filter { $0.fileType == CommonStringFile.pdf }.count
        guard pdfCount < maxAttachments else { showLimitReachedAlert(); return }
        PhotoPickerManager.shared.limiSelection = maxAttachments - pdfCount
        PhotoPickerManager.shared.presentPicker(ofType: .file, from: vc)
    }
    
    private func showLimitReachedAlert() {
        if let vc = getCurrentViewController() {
            CustomAlert().showAlert(title: "",
                                    message: "Already reached your limit".translated(),
                                    on: vc)
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        self.attachments.append(AttachmentItem(image: nil, imageURL: selectedFileURL.absoluteString, fileType: CommonStringFile.audio))
        reloadAttachments()
    }
    
    // MARK: - Current VC
    func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }
}
