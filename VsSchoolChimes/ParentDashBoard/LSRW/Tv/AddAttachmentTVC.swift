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
    @IBOutlet weak var addAttachmentLbl: UILabel!
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
    
    private let maxAttachments = 10
    private var lastAttachmentCount = 0
    private var isReloading = false
    let tempKey = "TempRecordings"
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        addAttachmentLbl.setFont(style: .body, size: FontSize.BodySize)
        descriptionLbl.setRequiredText(CommonStringFile.addDescription)
        addAttachmentLbl.setRequiredText("   \(CommonStringFile.Add_attachment)")
        setupCollectionView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Stop all audio playback before reuse
        stopAllAudioPlayback()
    }
    
    func config(_ attachment: [AttachmentItem], task: LSRWType?) {
        attachments = attachment
        taskType = task
        setupPhotoPickerClosures()
        reloadAttachments()
    }
    
    // MARK: - Height Adjustment
    private func adjustCollectionViewHeight() {
        guard let collectionView = addAttachmentView.imageCollectionview else { return }
        
        // Force layout update first
        collectionView.layoutIfNeeded()
        
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        let newHeight = max(height, 120)
        
        // Only update if height actually changed
        if abs(collectionViewHeight.constant - newHeight) > 1.0 {
            collectionViewHeight.constant = newHeight
            
            // Notify table view to update its layout
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let tableView = self.findSuperview(ofType: UITableView.self) {
                    UIView.performWithoutAnimation {
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                }
            }
        }
    }
    
    // Helper to find parent table view
    private func findSuperview<T: UIView>(ofType type: T.Type) -> T? {
        var view = self.superview
        while view != nil {
            if let tableView = view as? T {
                return tableView
            }
            view = view?.superview
        }
        return nil
    }
    
    // MARK: - SAFE Reload
    private func reloadAttachments() {
        // Prevent concurrent reloads
        guard !isReloading else {
            print("⚠️ Reload already in progress, skipping...")
            return
        }
        
        isReloading = true
        
        // Stop all audio before reload
        stopAllAudioPlayback()
        
        guard let collectionView = addAttachmentView.imageCollectionview else {
            isReloading = false
            return
        }
        
        print("🔄 Reloading with \(attachments.count) attachments")
        collectionView.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            UIView.performWithoutAnimation {
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
            }
            DispatchQueue.main.async {
                self.adjustCollectionViewHeight()
                if self.lastAttachmentCount != self.attachments.count {
                    self.lastAttachmentCount = self.attachments.count
                    self.Adddelegate?.editDta(edit: self.attachments)
                }
                
                self.isReloading = false
            }
        }
    }
    
    // MARK: - Stop All Audio
   func stopAllAudioPlayback() {
        guard let collectionView = addAttachmentView.imageCollectionview else { return }
        
        for cell in collectionView.visibleCells {
            if let audioCell = cell as? AudioCVC {
                audioCell.stopPlayback()
            }
        }
    }
    
    // MARK: - CollectionView Setup
    private func setupCollectionView() {
        let imageCV = addAttachmentView.imageCollectionview
        
        imageCV?.register(UINib(nibName: CellConfingName.AttachmentCVCell, bundle: nil),
                          forCellWithReuseIdentifier: CellConfingName.AttachmentCVCell)
        
        imageCV?.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil),
                          forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        imageCV?.register(UINib(nibName: "AudioCVC", bundle: nil),
                          forCellWithReuseIdentifier: "AudioCVC")
        
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        imageCV?.collectionViewLayout = layout
        
        imageCV?.delegate = self
        imageCV?.dataSource = self
        imageCV?.backgroundColor = .clear
        
        // Enable prefetching for better performance
        imageCV?.isPrefetchingEnabled = true
    }
    
    // MARK: - Picker Closures
    private func setupPhotoPickerClosures() {
        resetPickerClosures()
        
        PhotoPickerManager.shared.onCameraImagePicked = { [weak self] img in
            guard let self = self else { return }
            self.attachments.append(.init(image: img, imageURL: nil, fileType: CommonStringFile.IMAGE))
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            self.reloadAttachments()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [weak self] imgs in
            guard let self = self else { return }
            let items = imgs.map { AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE) }
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            self.attachments.append(contentsOf: items)
            self.reloadAttachments()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [weak self] fileURL in
            guard let self = self else { return }
            self.attachments.append(.init(image: nil, imageURL: fileURL.absoluteString, fileType: CommonStringFile.pdf))
            user_inputs.selectedFileType = CommonStringFile.pdf
            self.reloadAttachments()
        }
        
        PhotoPickerManager.shared.onVideoPicked = { [weak self] fileURL in
            guard let self = self else { return }
            self.attachments.append(.init(image: nil, imageURL: fileURL.absoluteString,
                                          fileType: CommonStringFile.VIDEO, VideoURl: nil))
            user_inputs.selectedFileType = CommonStringFile.VIDEO
            self.reloadAttachments()
        }
    }
    
    private func resetPickerClosures() {
        PhotoPickerManager.shared.onCameraImagePicked = nil
        PhotoPickerManager.shared.onImagesPicked = nil
        PhotoPickerManager.shared.onFilePicked = nil
        PhotoPickerManager.shared.onVideoPicked = nil
    }
    
    // MARK: - CV Helpers
    private func getCellType(at index: Int) -> String {
        if index == 0 { return "add_button" }
        
        let realIndex = index - 1
        
        // Prevent crash
        guard realIndex >= 0, realIndex < attachments.count else {
            print("❌ getCellType out of range → index: \(index), attachments: \(attachments.count)")
            return "invalid"
        }
        
        return attachments[realIndex].fileType.lowercased() == "audio" ? "audio" : "non_audio"
    }
    
    
    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = 1 + attachments.count
        print("📊 Collection view items: \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = getCellType(at: indexPath.item)
        
        if type == "add_button" {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.AttachmentCVCell,
                for: indexPath
            ) as! AttachmentCVCell
            return cell
        }
        
        let data = attachments[indexPath.item - 1]
        
        if type == "audio" {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AudioCVC",
                for: indexPath
            ) as! AudioCVC
            // In your cell configuration
            if let urlStr = data.imageURL {
                let url = URL(fileURLWithPath: urlStr)
                cell.audioURL = url
                cell.TrashIcon.isHidden = false
                cell.TrashIcon.isUserInteractionEnabled = true
            }

            cell.audioDelegate = self
            cell.delegate = self
            cell.cellIndex = indexPath.item - 1
            cell.TrashIcon.tag = indexPath.item - 1
            cell.waveView.setParentCell(cell)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellConfingName.ImageCvCell,
            for: indexPath
        ) as! ImageCvCell
        
        cell.delegate = self
        cell.deleteBtn.tag = indexPath.item - 1
        
        if let img = data.image {
            cell.imageViews.image = img
        }
        else if let urlStr = data.imageURL, let url = URL(string: urlStr) {
            if data.fileType.uppercased() == CommonStringFile.IMAGE {
                cell.imageViews.kf.setImage(with: url)
            } else {
                cell.imageViews.image = UIImage(named: getFileIconName(for: url))
            }
        }
        else if let videoURL = data.VideoURl {
            cell.imageViews.image = UIImage(named: getFileIconName(for: videoURL))
        }
        return cell
    }
    
    // MARK: - Delete Delegate
    func deleteImage(index: Int) {
        guard index < attachments.count else {
            return
        }
        if let collectionView = addAttachmentView.imageCollectionview {
            let cellIndexPath = IndexPath(item: index + 1, section: 0) // +1 for add button
            if let audioCell = collectionView.cellForItem(at: cellIndexPath) as? AudioCVC {
                audioCell.stopPlayback()
            }
        }
        let urlString = attachments[index].imageURL
//        if let url = urlString.flatMap(URL.init), url.isFileURL {
//            url.stopAccessingSecurityScopedResource()
//        }
        if let urlStr = attachments[index].imageURL,
               let url = URL(string: urlStr),
               url.isFileURL {
            removeTempRecording(at: index)
                try? FileManager.default.removeItem(at: url)
            }
        attachments.remove(at: index)
        reloadAttachments()
    }
    func removeTempRecording(at index: Int) {
        var list = UserDefaults.standard.stringArray(forKey: tempKey) ?? []
        guard index < list.count else { return }
        let urlString = list[index]
        if let url = URL(string: urlString), url.isFileURL {
            do {
                try FileManager.default.removeItem(at: url)
                print("✅ File deleted: \(url.lastPathComponent)")
            } catch {
                print("❌ Failed to delete file: \(error.localizedDescription)")
            }
        }
        list.remove(at: index)
        UserDefaults.standard.set(list, forKey: tempKey)
    }


    // MARK: - Selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            presentAttachmentOptions(for: taskType ?? .unknown(""))
            delegate?.backtohome(type: "")
            return
        }
        
        let item = attachments[indexPath.item - 1]
        if item.fileType.lowercased() == "audio" { return }
        
        let vc = PreviewImageVC()
        vc.modalPresentationStyle = .fullScreen
        
        if item.fileType == CommonStringFile.IMAGE {
            vc.img = item.image
            vc.selectedFileURL = item.imageURL.flatMap(URL.init)
        } else {
            vc.selectedFileURL = item.imageURL.flatMap(URL.init)
        }
        
        vc.type = item.fileType
        getCurrentViewController()?.present(vc, animated: true)
    }
    
    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let type = getCellType(at: indexPath.item)
        let width = collectionView.frame.width
        
        if type == "audio" {
            return CGSize(width: width - 20, height: 70)
        }
        
        let cellWidth = (width - 40) / 3 // 10 left + 10 right + 10*2 spacing
        return CGSize(width: cellWidth, height: 100)
    }
    
    // Ensure proper spacing
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // MARK: - Audio Delegate
    func audioCell(_ cell: AudioCVC, willStartPlayingAtIndex index: Int) {
        stopAllOtherAudioCells(except: index)
    }
    
    func audioCell(_ cell: AudioCVC, didStopPlayingAtIndex index: Int) {
        print("🎵 Audio stopped at index \(index)")
    }
    
    private func stopAllOtherAudioCells(except playingIndex: Int) {
        guard let collectionView = addAttachmentView.imageCollectionview else { return }
        
        for cell in collectionView.visibleCells {
            if let audioCell = cell as? AudioCVC, audioCell.cellIndex != playingIndex {
                audioCell.stopPlayback()
            }
        }
    }
    
    // MARK: - Options Picker
    private func presentAttachmentOptions(for task: LSRWType) {
        
        let alert = UIAlertController(
            title: "Select".translated(),
            message: "Choose an option".translated(),
            preferredStyle: .actionSheet
        )
        
        let options: [(String, () -> Void)] = [
            ("Camera".translated(), { [weak self] in self?.handleCameraSelection() }),
            ("Gallery".translated(), { [weak self] in self?.handleGallerySelection() }),
            ("Document".translated(), { [weak self] in self?.handlePDFSelection() }),
            ("Recording".translated(), { self.delegate?.backtohome(type: "Recording") }),
            ("Audio".translated(), { [weak self] in self?.audio() }),
            ("Video", { [weak self] in self?.VideoPick() })
        ]
        
        options.forEach { title, handler in
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in handler() })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".translated(), style: .cancel))
        
        getCurrentViewController()?.present(alert, animated: true)
    }
    
    // MARK: - Picking Helpers
    func VideoPick() {
        guard let vc = getCurrentViewController() else { return }
        PhotoPickerManager.shared.presentPicker(ofType: .video, from: vc)
    }
    
    func audio() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        picker.delegate = self
        getCurrentViewController()?.present(picker, animated: true)
    }
    
    private func handleGallerySelection() {
        guard let vc = getCurrentViewController() else { return }
        let limit = max(0, maxAttachments - attachments.count)
        guard limit > 0 else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: vc)
            return
        }
        PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: limit), from: vc)
    }
    
    private func handleCameraSelection() {
        guard let vc = getCurrentViewController() else { return }
        guard attachments.count < maxAttachments else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: vc)
            return
        }
        PhotoPickerManager.shared.presentPicker(ofType: .camera, from: vc)
    }
    
    private func handlePDFSelection() {
        guard let vc = getCurrentViewController() else {
            return
        }
        
        let remaining = max(0, maxAttachments - attachments.count)
        guard remaining > 0 else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: vc)
            return
        }
        PhotoPickerManager.shared.limiSelection = remaining
        PhotoPickerManager.shared.presentPicker(ofType: .file, from: vc)
    }
    
    // optional: handle cancel
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {

        guard let fileURL = urls.first else { return }

        // Allow external file access
        guard fileURL.startAccessingSecurityScopedResource() else {
            print("❌ Cannot access file")
            return
        }
        
        attachments.append(.init(
            image: nil,
            imageURL: fileURL.path,      // store original path
            fileType: CommonStringFile.audio
        ))

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
