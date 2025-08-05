//
//  SenderLSRWVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/06/25.
//

import UIKit
import PDFKit
import UniformTypeIdentifiers

@available(iOS 15.0, *)
class SenderLSRWVC: UIViewController, DeleteImge, SelectNotice, VideoPickerManagerDelegate, UITextFieldDelegate, UIDocumentPickerDelegate{
    
    // MARK: - Protocol Methods
    func didTapButton(
        title: String,
        content: String,
        items: [FilePath],
        editId:String
    ) {
        print("Button tapped with title: \(title)")
    }
    
    func deleteImage(index: Int) {
        guard index < attachments.count else { return }
        attachments.remove(at: index)
        uploadAttachmentView.imageCollectionview.reloadData()
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var waveView: AudioMessageView!
    @IBOutlet weak var voiceImg: UIImageView!
    @IBOutlet weak var audioFile: UIView!
    @IBOutlet weak var outerplayerView: UIView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var recorderTime: UILabel! // Fixed typo: recoderTime -> recorderTime
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet var skillButtons: [UIButton]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ToStdOrSecBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var TitleTxtfield: UITextField!
    @IBOutlet weak var DetailsLbl: UILabel!
    @IBOutlet weak var DetailsTxtview: UITextView!
    @IBOutlet weak var wordsCountLbl: UILabel!
    @IBOutlet weak var titleCountLbl: UILabel!
    @IBOutlet weak var uploadattachmentLbl: UILabel!
    @IBOutlet weak var uploadAttachmentView: ImageSelection!
    @IBOutlet weak var recordingTimeLbl: UILabel!
    @IBOutlet weak var RecipientBtn: UIButton!
    @IBOutlet weak var TextViewheight: NSLayoutConstraint!
    @IBOutlet weak var VideoView: UIView!
    
    @IBOutlet weak var recordingStack: UIStackView!
    
    // MARK: - Properties
    var attachments: [AttachmentItem] = []
    let photoPickManager = PhotoPickerManager.shared
    let Img = ImageName()
    let formatter = DateFormatter()
    var image = "image/pdf"
    var delegate: HistorySelectDelegate?
    let customdate = DateFormatter()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var alert = CustomAlert()
    var videoPicker: VideoPickerManager?
    var selectedVideoURL: URL?
    
    // Audio Properties
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private var isRecording = false
    private let audioManager = AudioManager()
    private var audioURL: URL?
    private var isRemoteAudio = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialConfiguration()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        recordingTimer?.invalidate()
    }
    
    // MARK: - Setup Methods
    private func setupInitialConfiguration() {
        videoPicker = VideoPickerManager(presenter: self, delegate: self)
        setupTextViews()
        setupNotifications()
        setupCollectionView()
        setupAudioUI()
        styleAndTranslate()
        imageSelection()
        VideoView.isHidden = true
        // Apply selected style
        skillButtons.first?.layer.borderWidth = 2
        skillButtons.first?.layer.cornerRadius = 10
        skillButtons.first?.layer.borderColor = UIColor.systemBlue.cgColor
        skillButtons.first?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        skillButtons.first?.setTitleColor(.systemBlue, for: .normal)
    }
    
    private func setupTextViews() {
        DetailsTxtview.applyRightTxt()
        TitleTxtfield.applyRightTxt()
        wordsCountLbl.applyRightTxt()
        TitleTxtfield.addDoneButton()
        DetailsTxtview.addDoneButton()
        DetailsTxtview.delegate = self
        TitleTxtfield.delegate = self
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setupCollectionView() {
        uploadAttachmentView.imageCollectionview.delegate = self
        uploadAttachmentView.imageCollectionview.dataSource = self
    }
    
    private func setupAudioUI() {
        outerplayerView.setShadow(cornerRadius: 10)
        deleteBtn.isHidden = true
        playerView.isHidden = true
        voiceImg.image = UIImage(named: "mic 1")
        audioManager.delegate = self
    }
    @IBAction func selectSkillTypes(_ sender: UIButton) {
        for button in skillButtons {
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 10
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
        }
        
        // Apply selected style
        sender.layer.borderWidth = 2
        sender.layer.cornerRadius = 10
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        sender.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        sender.setTitleColor(.systemBlue, for: .normal)
        recordingStack.isHidden = sender.tag != 3 
    }
    
    // MARK: - Public Methods
    func setSelectedHomeWork(title: String, content: String, imageUrls: [FilePath]) {
        DetailsTxtview.text = content
        DetailsTxtview.textColor = content.isEmpty ? .lightGray : .black
        TitleTxtfield.text = title
        
        let imageItems = imageUrls.map {
            AttachmentItem(image: nil, imageURL: $0.url, fileType: $0.type ?? "")
        }
        
        updateTextViewHeight()
        attachments.removeAll()
        attachments.append(contentsOf: imageItems)
        wordsCountLbl.text = "\(content.count) / 500"
        titleCountLbl.text = "\(title.count) / 50"
        uploadAttachmentView.imageCollectionview.reloadData()
    }
    
    private func updateTextViewHeight() {
        let size = DetailsTxtview.sizeThatFits(CGSize(width: DetailsTxtview.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = min(max(size.height, initialHeight), maxHeight)
        TextViewheight.constant = newHeight
    }
    
    func styleAndTranslate() {
        TextViewheight.constant = initialHeight
        DetailsTxtview.layer.cornerRadius = 10
        DetailsTxtview.layer.borderWidth = 1
        DetailsTxtview.layer.borderColor = UIColor.lightGray.cgColor
        RecipientBtn.layer.cornerRadius = 10
        DetailsTxtview.text = CommonStringFile.Description
        DetailsTxtview.textColor = .lightGray
        customdate.dateFormat = "EEE d"
        RecipientBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        // Label Font Style
        titleLbl.setRequiredText(CommonStringFile.Title)
        DetailsLbl.setRequiredText(CommonStringFile.Description)
        wordsCountLbl.setFont(style: .body, size: FontSize.BodySize)
        titleCountLbl.setFont(style: .body, size: FontSize.BodySize)
        uploadattachmentLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        setAttributedText(
            for: uploadattachmentLbl,
            with: CommonStringFile.Add_attachment_optional.translated(),
            firstString: CommonStringFile.Add_attachment.translated(),
            secondString: CommonStringFile.Optional.translated(),
            color1: .black,
            color2: .lightGray
        )
        
        setAttributedText(
            for: recordingTimeLbl,
            with: CommonStringFile.Recording_Time.translated(),
            firstString: CommonStringFile.RTime.translated(),
            secondString: CommonStringFile.Optional.translated(),
            color1: .black,
            color2: .lightGray
        )
    }
    
    // MARK: - IBActions
    @IBAction func recording(_ sender: UIButton) {
        recordingView.isHidden = false
        isRecording ? stopRecording() : startRecording()
    }
    
    @IBAction func deleteVideo() {
        videoPickerManagerDidCloseVideo()
    }
    
    @IBAction func chooseVideoTapped(_ sender: UIButton) {
        videoPicker?.pickVideo()
    }
    
    @IBAction private func playVoice(_ sender: UIButton) {
        do {
            let isPlaying = try audioManager.togglePlayback()
            playBtn.setImage(UIImage(named: isPlaying ? "pause-button" : "play-button"), for: .normal)
            
            if isPlaying {
                waveView.startPlaybackAnimation()
            } else {
                waveView.stopPlaybackAnimation()
            }
        } catch {
            print("Playback error: \(error.localizedDescription)")
            showErrorAlert(message: error.localizedDescription)
        }
    }
    
    @IBAction private func deleteAudio(_ sender: UIButton) {
        if !isRemoteAudio {
            audioManager.deleteRecording()
            playerView.isHidden = true
            deleteBtn.isHidden = true
            waveView.reset()
            audioURL = nil
        }
    }
    
    @IBAction func recipientBtnAction(_ sender: Any) {
        guard let title = TitleTxtfield.text, !title.isEmpty,
              let description = DetailsTxtview.text, !description.isEmpty,
              description != CommonStringFile.Description else {
            alert.showAlert(
                title: "",
                message: AlertstringFile.enter_title_description,
                on: self
            )
            return
        }
        
        user_inputs.SelectedUrls = attachments
        user_inputs.VideoPath = selectedVideoURL
        
        let params: [String: Any] = [
            assignmentResquestStringKey.title: title,
            assignmentResquestStringKey.description: description,
        ]
        
        let vc = RecipientVc(nibName: nil, bundle: nil)
        vc.ScreenType = Menu_id.homeWorkMenuId
        vc.Common_request_params = params
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // MARK: - Audio Methods
    private func setupPlayerWithURL(_ url: URL) {
        do {
            try audioManager.setupPlayer(with: url)
            playerView.isHidden = false
            deleteBtn.isHidden = !url.isFileURL
            waveView.audioURL = url
        } catch {
            print("Failed to setup player: \(error.localizedDescription)")
            showErrorAlert(message: "Failed to load audio file")
        }
    }
    
    private func startRecording() {
        audioManager.checkRecordPermission { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                granted ? self.beginRecording() : self.showMicPermissionAlert()
            }
        }
    }
    
    private func beginRecording() {
        recordingStartTime = Date()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRecordingTime()
        }
        
        audioManager.startRecording()
        isRecording = true
        playerView.isHidden = true
        playBtn.setImage(UIImage(named: "play-button"), for: .normal)
        deleteBtn.isHidden = true
        voiceImg.image = UIImage.gifImageWithName("Mic")
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func stopRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        audioManager.stopRecording { [weak self] url, duration in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isRecording = false
                self.recordingView.isHidden = true
                self.playBtn.setImage(UIImage(named: "play-button"), for: .normal)
                self.voiceImg.image = UIImage(named: "mic 1")
                self.deleteBtn.isHidden = false
                
                if let url = url {
                    self.audioURL = url
                    self.isRemoteAudio = false
                    self.setupPlayerWithURL(url)
                }
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    
    @objc private func updateRecordingTime() {
        guard let startTime = recordingStartTime, isRecording else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        DispatchQueue.main.async {
            self.recorderTime.text = self.formatTime(elapsed)
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    // MARK: - Alert Methods
    private func showMicPermissionAlert() {
        let alert = UIAlertController(
            title: "Microphone Access Required",
            message: "Please allow microphone access in Settings to record audio",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Audio Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Public Audio Methods
    func setRemoteAudioURL(_ url: URL) {
        audioURL = url
        isRemoteAudio = true
        setupPlayerWithURL(url)
    }
    
    func setLocalAudioURL(_ url: URL) {
        audioURL = url
        isRemoteAudio = false
        setupPlayerWithURL(url)
    }
    
    // MARK: - Video Methods
    func pickVideoFromGallery() {
        videoPicker?.pickVideo()
    }
    
    // MARK: - Helper Methods
    func isStaff() -> Bool {
        guard let staffDetailsCount = staffDetailsCount, staffDetailsCount.count > 1 else {
            return false
        }
        
        return staff_role == PriorityType.is_principal ||
        staff_role == PriorityType.is_grouphead ||
        staff_role == PriorityType.is_admin
    }
    
    func gradientColours(button: UIButton, colours: [CGColor]) {
        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = button.layer.cornerRadius
        
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - File Attachment Methods
    func selectImages() {
        let imageAttachments = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        guard imageAttachments.count < 5 else {
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return
        }
        
        PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5 - imageAttachments.count), from: self)
    }
    
    func openCamera() {
        let imageAttachments = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        guard imageAttachments.count < 5 else {
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return
        }
        
        PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
    }
    
    func selectPDF() {
        let pdfAttachments = attachments.filter { $0.fileType != CommonStringFile.IMAGE }
        guard pdfAttachments.count < 5 else {
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return
        }
        
        PhotoPickerManager.shared.presentPicker(ofType: .file, from: self)
        PhotoPickerManager.shared.limiSelection = 5 - pdfAttachments.count
    }
    
    func imageSelection() {
        PhotoPickerManager.shared.onCameraImagePicked = { [weak self] image in
            guard let self = self else { return }
            
            self.attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            self.attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            self.uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [weak self] images in
            guard let self = self else { return }
            
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            self.attachments.append(contentsOf: imageItems)
            
            if !imageItems.isEmpty {
                self.attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            }
            self.uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [weak self] data in
            guard let self = self else { return }
            
            user_inputs.selectedFileType = CommonStringFile.pdf
            self.attachments.append(AttachmentItem(image: nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            self.attachments.removeAll { $0.fileType == CommonStringFile.IMAGE }
            
            self.uploadAttachmentView.imageCollectionview.reloadData()
        }
    }
}

// MARK: - VideoPickerManagerDelegate
@available(iOS 15.0, *)
extension SenderLSRWVC {
    func videoPickerManager(didPickVideo url: URL) {
        videoPicker?.playVideo(from: url, in: VideoView)
        attachments.removeAll()
        uploadAttachmentView.isHidden = true
        collectionViewHeight.constant = 0
        selectedVideoURL = url
        VideoView.isHidden = false
        RecipientBtn.isHidden = false
    }
    
    func videoPickerManagerDidCloseVideo() {
        selectedVideoURL = nil
        VideoView.isHidden = true
        uploadAttachmentView.isHidden = false
        collectionViewHeight.constant = 120
        uploadAttachmentView.imageCollectionview.reloadData()
    }
}

// MARK: - UICollectionView DataSource & Delegate
@available(iOS 15.0, *)
extension SenderLSRWVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.AttachmentCVCell,
                for: indexPath
            ) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.ImageCvCell,
                for: indexPath
            ) as! ImageCvCell
            
            let adjustedIndex = indexPath.item - 1
            guard adjustedIndex < attachments.count else { return cell }
            
            let item = attachments[adjustedIndex]
            cell.delegate = self
            cell.deleteBtn.tag = adjustedIndex
            
            if let image = item.image {
                cell.imageViews.image = image
            } else if let urlStr = item.imageURL, let url = URL(string: urlStr) {
                if item.fileType.uppercased() != CommonStringFile.IMAGE {
                    let iconName = getFileIconName(for: url)
                    cell.imageViews.image = UIImage(named: iconName)
                } else {
                    cell.imageViews.kf.setImage(with: url)
                }
            } else {
                cell.imageViews.image = nil
            }
            
            // Set collection view height dynamically
            let totalItems = attachments.count
            collectionViewHeight.constant = totalItems <= 2 ? 120 : 220
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (uploadAttachmentView.imageCollectionview.frame.width - 30) / 3
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            presentAttachmentOptions()
        } else {
            let adjustedIndex = indexPath.item - 1
            guard adjustedIndex < attachments.count else { return }
            
            let vc = PreviewImageVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            
            let attachment = attachments[adjustedIndex]
            if attachment.fileType != CommonStringFile.IMAGE {
                if let url = attachment.imageURL {
                    vc.selectedFileURL = URL(string: url)
                }
            } else {
                if let img = attachment.image {
                    vc.img = attachment.image
                } else {
                    vc.selectedFileURL = URL(string: attachment.imageURL ?? "")
                }
            }
            vc.type = attachment.fileType
            present(vc, animated: true)
        }
    }
    
    private func presentAttachmentOptions() {
        let alertController = UIAlertController(
            title: "Select".translated(),
            message: "Choose an option".translated(),
            preferredStyle: .actionSheet
        )
        
        let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [weak self] _ in
            self?.openCamera()
        }
        alertController.addAction(cameraAction)
        
        let galleryAction = UIAlertAction(title: "Gallery".translated(), style: .default) { [weak self] _ in
            self?.selectImages()
        }
        alertController.addAction(galleryAction)
        
        let pdfAction = UIAlertAction(title: "Document".translated(), style: .default) { [weak self] _ in
            self?.selectPDF()
        }
        alertController.addAction(pdfAction)
        let recording = UIAlertAction(title: "Recording".translated(), style: .default) { [weak self] _ in
            self?.recodeing()
        }
        alertController.addAction(recording)
        let audio = UIAlertAction(title: "Audio".translated(), style: .default) { [weak self] _ in
            self?.audio()
        }
        alertController.addAction(audio)
        let videoAction = UIAlertAction(title: "Video", style: .default) { [weak self] _ in
            self?.pickVideoFromGallery()
        }
        alertController.addAction(videoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    func recodeing(){
        playerView.isHidden = true
        recordingView.isHidden = false
    }
    func audio(){
        let supportedTypes: [UTType] = [.audio]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate
@available(iOS 15.0, *)
extension SenderLSRWVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if DetailsTxtview.text == CommonStringFile.Description {
            DetailsTxtview.text = ""
            DetailsTxtview.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if DetailsTxtview.text.isEmpty {
            DetailsTxtview.text = CommonStringFile.Description
            DetailsTxtview.textColor = .gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = min(max(size.height, initialHeight), maxHeight)
        TextViewheight.constant = newHeight
        DetailsTxtview.isScrollEnabled = size.height > maxHeight
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        if DetailsTxtview.isFirstResponder {
            adjustForKeyboardHeight()
        }
    }
    
    private func adjustForKeyboardHeight() {
        // Implementation would depend on your specific keyboard handling needs
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if newText.count <= 500 {
            wordsCountLbl.text = "\(newText.count) / 500"
            return true
        } else {
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count <= 50 {
            titleCountLbl.text = "\(newText.count) / 50"
            return true
        } else {
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return false
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + 30, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            scrollToView(DetailsTxtview)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    func scrollToView(_ view: UIView) {
        let rect = view.convert(view.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    // MARK: - PDF Helper Methods
    func createMultiPagePDF(from images: [UIImage]) -> Data? {
        guard !images.isEmpty else { return nil }
        
        let firstImage = images[0]
        let pageRect = CGRect(x: 0, y: 0, width: firstImage.size.width, height: firstImage.size.height)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            for image in images {
                context.beginPage()
                image.draw(in: CGRect(origin: .zero, size: image.size))
            }
        }
        
        return data
    }
    
    func previewPDF(data: Data, in containerView: UIView) {
        let pdfView = PDFView(frame: containerView.bounds)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: data)
        containerView.addSubview(pdfView)
        
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    //MARK: DOCUMENT PICKER
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            print("No file selected.")
            return
        }
        if selectedFileURL.isFileURL {
            do {
                try audioManager.setupPlayer(with: selectedFileURL)
                waveView.audioURL = selectedFileURL
            } catch {
                print("❌ Failed to set up audio player:", error)
            }
        } else {
            // Remote URL - download it first
            downloadAndPrepareAudio(from: selectedFileURL)
        }
        playerView.isHidden = false
        recordingView.isHidden = true
    }
    private func downloadAndPrepareAudio(from remoteURL: URL) {
        let session = URLSession.shared
        let task = session.downloadTask(with: remoteURL) { [weak self] (tempURL, response, error) in
            guard let self = self else { return }
            if let tempURL = tempURL {
                do {
                    try self.audioManager.setupPlayer(with: tempURL)
                    DispatchQueue.main.async {
                        self.waveView.audioURL = tempURL
                    }
                } catch {
                    print("Failed to setup player: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Failed to load audio file")
                    }
                }
            } else {
                print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Audio download failed.")
                }
            }
        }
        task.resume()
    }

    // Handle cancellation
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}

// MARK: - AudioManagerDelegate
@available(iOS 15.0, *)
extension SenderLSRWVC: AudioManagerDelegate {
    func audioManagerDidUpdateTime(currentTime: Double, duration: Double) {
        DispatchQueue.main.async {
            // Update progress if you have a progress indicator
            let progress = duration > 0 ? Float(currentTime / duration) : 0
            // self.progressSlider.value = progress
        }
    }
    
    func audioManagerDidFailWithError(_ error: any Error) {
        DispatchQueue.main.async {
            self.playBtn.setImage(UIImage(named: "play-button"), for: .normal)
            self.playBtn.isEnabled = true
            self.waveView.stopPlaybackAnimation()
            self.showErrorAlert(message: error.localizedDescription)
        }
    }
    
    func audioManagerDidStartBuffering() {
        DispatchQueue.main.async {
            self.playBtn.isEnabled = false
            // Optionally show loading indicator
        }
    }
    
    func audioManagerDidFinishBuffering() {
        DispatchQueue.main.async {
            self.playBtn.isEnabled = true
            self.playBtn.setImage(UIImage(named: "play-button"), for: .normal)
        }
    }
    
    func audioManagerDidFinishPlaying() {
        DispatchQueue.main.async {
            self.playBtn.setImage(UIImage(named: "play-button"), for: .normal)
            self.waveView.stopPlaybackAnimation()
        }
    }
}
