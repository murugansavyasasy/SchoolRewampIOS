//  SenderLSRWVC.swift (fixed)
//  School Chimes
//  Created by Chandhru on 30/06/25.
//

import UIKit
import PDFKit
import UniformTypeIdentifiers
import AVFAudio

@available(iOS 15.0, *)
class SenderLSRWVC: UIViewController, DeleteImge, SelectNotice, UITextFieldDelegate, UIDocumentPickerDelegate, Datepicker, AudioPlaybackDelegate {
    
    // MARK: - Protocol Methods
    func date(date: String) {
        dateLbl.text = date
        placeholderLabel.isHidden = !(DetailsTxtview.text?.isEmpty ?? true) && DetailsTxtview.textColor != .lightGray
    }
    
    func didTapButton(
        title: String,
        content: String,
        items: [FilePath],
        editId: String
    ) {
        print("Button tapped with title: \(title)")
    }
    
    func deleteImage(index: Int) {
        guard index < attachments.count else { return }
        // Stop audio if it's an audio file being deleted
        if attachments[index].fileType.lowercased() == "audio" {
            stopAllAudioPlayback()
        }
        let fileURL = URL(fileURLWithPath: attachments[index].imageURL ?? "")
            fileURL.stopAccessingSecurityScopedResource()
        attachments.remove(at: index)
        uploadAttachmentView.imageCollectionview.reloadData()
    }
    
    // MARK: - Audio Playback Delegate Methods
    func audioCell(_ cell: AudioCVC, willStartPlayingAtIndex index: Int) {
        print("Audio started playing at index: \(index)")
        stopAllOtherAudioCells(except: index)
    }
    
    func audioCell(_ cell: AudioCVC, didStopPlayingAtIndex index: Int) {
        print("Audio stopped playing at index: \(index)")
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var typeSectionCV: UICollectionView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLbl: UITextField!
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var voiceImg: UIImageView!
    @IBOutlet weak var audioFile: UIView!
    @IBOutlet weak var recorderTime: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ToStdOrSecBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var TitleTxtfield: UITextField!
    @IBOutlet weak var DetailsLbl: UILabel!
    @IBOutlet weak var DetailsTxtview: UITextView!
    @IBOutlet weak var uploadattachmentLbl: UILabel!
    @IBOutlet weak var uploadAttachmentView: ImageSelection!
    @IBOutlet weak var selectedDateLbl: UILabel!
    @IBOutlet weak var RecipientBtn: UIButton!
    @IBOutlet weak var TextViewheight: NSLayoutConstraint!
    @IBOutlet weak var recordingStack: UIStackView!
    
    // MARK: - Properties
    var attachments: [AttachmentItem] = []
    let photoPickManager = PhotoPickerManager.shared
    var delegate: HistorySelectDelegate?
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var alert = CustomAlert()
    var videoPicker: VideoPickerManager?
    var selectedVideoURL: URL?
    var placeholderLabel: UILabel!
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private var isRecording = false
    private let audioManager = AudioManager()
    private var audioURL: URL?
    private var isRemoteAudio = false
    var editReport:LSRWTask?
    let taskTypes = [
        ("Listening".translated(), "headphones"),
        ("Speaking".translated(), "mic"),
        ("Reading".translated(), "book"),
        ("Writing".translated(), "pencil")
    ]
    
    var selectedTaskIndex: Int = 0
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialConfiguration()
        setupPlaceholderIfNeeded()
        backBtn.setTitle(MenuStringFile.selectedMenuName, for: .normal)
        // Enable user interaction
        dateView.isUserInteractionEnabled = true
        uploadAttachmentView.imageCollectionview.backgroundColor = .clear
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        dateView.addGestureRecognizer(tapGesture)
        
        setupTaskTypesCollectionView()
        if let edit = editReport{
            fetchData(notice: edit)
        }
    }
    func fetchData(notice: LSRWTask?) {
        attachments.removeAll()
        
        if let notice = notice {
            TitleTxtfield.text = notice.title
            DetailsTxtview.text = notice.description
            DetailsTxtview.textColor = .black
            placeholderLabel?.isHidden = !DetailsTxtview.text.isEmpty
            
            if let files = notice.file_path {
                attachments = files.map { file in
                    let type = (file.type ?? "").lowercased()
                    return AttachmentItem(
                        image: nil,
                        imageURL: type != "video" ? file.url : nil,
                        fileType: type,
                        VideoURl: type == "video" ? URL(string: file.url ?? "") : nil
                    )
                }
            }
            updateTextViewHeight()
        } else {
            TitleTxtfield.text = ""
            DetailsTxtview.text = CommonStringFile.Description.translated()
            DetailsTxtview.textColor = .lightGray
            placeholderLabel?.isHidden = false
            
            attachments.removeAll()
        }
        uploadAttachmentView.imageCollectionview.reloadData()
    }
    
    private func setupPlaceholderIfNeeded() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Description.translated()
        placeholderLabel.font = DetailsTxtview.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        DetailsTxtview.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: DetailsTxtview.leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: DetailsTxtview.trailingAnchor, constant: -8),
            placeholderLabel.topAnchor.constraint(equalTo: DetailsTxtview.topAnchor, constant: 8)
        ])
        let isEmptyContent = (DetailsTxtview.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || DetailsTxtview.text == CommonStringFile.Description
        placeholderLabel.isHidden = !isEmptyContent ? true : false
        if DetailsTxtview.text == CommonStringFile.Description {
            DetailsTxtview.text = ""
            DetailsTxtview.textColor = .black
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllAudioPlayback()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        recordingTimer?.invalidate()
        stopAllAudioPlayback()
    }
    
    @objc func viewTapped() {
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.date = dateLbl.text
        vc.minimumDate = Date()
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        present(vc, animated: false)
    }
    
    // MARK: - Setup Methods
    private func setupInitialConfiguration() {
        setupTextViews()
        setupNotifications()
        setupCollectionView()
        styleAndTranslate()
        imageSelection()
    }
    
    private func setupTaskTypesCollectionView() {
        typeSectionCV.dataSource = self
        typeSectionCV.delegate = self
        typeSectionCV.register(TaskTypeCell.self, forCellWithReuseIdentifier: TaskTypeCell.identifier)
        if let layout = typeSectionCV.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 12
            layout.estimatedItemSize = CGSize(width: 100, height: 80)
        }
    }
    
    private func setupTextViews() {
        DetailsTxtview.applyRightTxt()
        TitleTxtfield.applyRightTxt()
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
    
    // MARK: - Public Methods
    func setSelectedHomeWork(title: String, content: String, imageUrls: [FilePath]) {
        DetailsTxtview.text = content
        DetailsTxtview.textColor = content.isEmpty ? .lightGray : .black
        TitleTxtfield.text = title
        
        // Update placeholder visibility
        placeholderLabel.isHidden = !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let imageItems = imageUrls.map {
            AttachmentItem(image: nil, imageURL: $0.url, fileType: $0.type ?? "")
        }
        
        updateTextViewHeight()
        attachments.removeAll()
        attachments.append(contentsOf: imageItems)
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
        DetailsTxtview.layer.borderWidth = 0.5
        DetailsTxtview.layer.borderColor = UIColor.lightGray.cgColor
        dateView.layer.cornerRadius = 10
        dateView.layer.borderWidth = 0.5
        dateView.layer.borderColor = UIColor.lightGray.cgColor
        
        RecipientBtn.layer.cornerRadius = 10
        RecipientBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        // Label Font Style
        titleLbl.setRequiredText(CommonStringFile.Title)
        selectedDateLbl.setRequiredText(CommonStringFile.selectedDate)
        DetailsLbl.setRequiredText(CommonStringFile.Description)
        uploadattachmentLbl.setFont(style: .title, size: FontSize.TitleSize)
        TitleTxtfield.placeholder = CommonStringFile.Title.translated()
        setAttributedText(
            for: uploadattachmentLbl,
            with: CommonStringFile.Add_attachment_optional.translated(),
            firstString: CommonStringFile.Add_attachment.translated(),
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
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func selectRecipient(_ sender: UIButton) {
        // Individual validation checks with focused feedback
        let title = (TitleTxtfield.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty {
            showFieldAlert(title: "Missing Title", message: "Please enter the Title.", focus: TitleTxtfield)
            return
        }
        
        if isDescriptionEmpty() {
            showFieldAlert(title: "Missing Description", message: "Please enter the Description.", focus: DetailsTxtview)
            return
        }
        
        let dateText = (dateLbl.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if dateText.isEmpty || convertDate(dateText) == nil {
            showFieldAlert(title: "Missing Submission Date", message: "Please select a valid Submission Date.", focus: dateLbl)
            return
        }
        
        let recipientTitle = (RecipientBtn.title(for: .normal) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if recipientTitle.isEmpty || recipientTitle.lowercased().contains("select") {
            showFieldAlert(title: "Missing Recipient", message: "Please select recipient(s) to send this to.", focus: nil)
            return
        }
        user_inputs.SelectedUrls = attachments
        user_inputs.VideoPath = selectedVideoURL
        let params: [String: Any] = [
            assignmentResquestStringKey.title: title,
            assignmentResquestStringKey.description: DetailsTxtview.text ?? "",
            assignmentResquestStringKey.submission_date: convertDate(dateText) ?? "",
            assignmentResquestStringKey.activity_type: taskTypes[selectedTaskIndex].0,
        ]
        let vc = RecipientVc(nibName: nil, bundle: nil)
        vc.ScreenType = Menu_id.homeWorkMenuId
        vc.Common_request_params = params
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func showFieldAlert(title: String, message: String, focus: UIResponder?) {
        alert.showAlert(title: title, message: message, on: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focus?.becomeFirstResponder()
        }
    }
    
    private func isDescriptionEmpty() -> Bool {
        let text = DetailsTxtview.text ?? ""
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text == CommonStringFile.Description
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
                self.voiceImg.image = UIImage(named: "mic 1")
                
                if let url = url {
                    self.audioURL = url
                    self.isRemoteAudio = false
                    self.attachments.append(AttachmentItem(image: nil, imageURL: url.absoluteString, fileType: CommonStringFile.audio))
                    self.uploadAttachmentView.imageCollectionview.reloadData()
                    self.uploadAttachmentView.imageCollectionview.layoutIfNeeded()
                    self.collectionViewHeight.constant = self.uploadAttachmentView.imageCollectionview.collectionViewLayout.collectionViewContentSize.height
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
        return String(format: CommonStringFile.Time_formate, mins, secs)
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
    }
    
    func setLocalAudioURL(_ url: URL) {
        audioURL = url
        isRemoteAudio = false
    }
    
    // MARK: - Audio Management Methods
    func stopAllAudioPlayback() {
        for visibleCell in uploadAttachmentView.imageCollectionview.visibleCells {
            if let audioCell = visibleCell as? AudioCVC {
                audioCell.stopPlayback()
            }
        }
    }
    
    private func stopAllOtherAudioCells(except playingIndex: Int) {
        for visibleCell in uploadAttachmentView.imageCollectionview.visibleCells {
            if let audioCell = visibleCell as? AudioCVC,
               audioCell.cellIndex != playingIndex {
                audioCell.stopPlayback()
            }
        }
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
    
    // MARK: - File Attachment Methods
    func selectImages() {
        if attachments.count != 10{
            PhotoPickerManager.shared
                .presentPicker(
                    ofType: .gallery(selectionLimit: 10 - attachments.count),
                    from: self
                )
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    
    func openCamera() {
        if attachments.count != 10{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func VideoPick() {
        let video = attachments.filter { $0.fileType != CommonStringFile.VIDEO }
        
        if  video.count != 2{
            
            if attachments.count <= 10{
                PhotoPickerManager.shared.limiSelection = 10 - attachments.count
                PhotoPickerManager.shared.presentPicker(ofType: .video, from: self)
                
            }else{
                let alert = CustomAlert()
                alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            }
            
        }else{
            
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
        
    }
    func selectPDF() {
        if attachments.count != 10{
            PhotoPickerManager.shared.presentPicker(ofType: .file, from: self)
            PhotoPickerManager.shared.limiSelection = 10 - attachments.count
        }else{
            
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func imageSelection() {
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            
            attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            attachments.append(contentsOf: imageItems)
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [self] data in
            // handle picked PDF
            user_inputs.selectedFileType = CommonStringFile.pdf
            attachments.append(AttachmentItem(image:nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        PhotoPickerManager.shared.onVideoPicked = { [self] data in
            // handle picked PDF
            user_inputs.selectedFileType = CommonStringFile.VIDEO
            attachments
                .append(
                    AttachmentItem(
                        image:nil,
                        imageURL: nil,
                        fileType: CommonStringFile.VIDEO,
                        VideoURl: data
                    )
                )
            uploadAttachmentView.imageCollectionview.reloadData()
        }
    }
    
    private func presentAttachmentOptions(for task: String) {
        let alertController = UIAlertController(
            title: "Select".translated(),
            message: "Choose an option".translated(),
            preferredStyle: .actionSheet
        )
        var options: [AttachmentOption] = [
            AttachmentOption(type: .camera, title: "Camera".translated()) { [weak self] in
                self?.openCamera()
            },
            AttachmentOption(type: .gallery, title: "Gallery".translated()) { [weak self] in
                self?.selectImages()
            },
            AttachmentOption(type: .pdf, title: "Document".translated()) { [weak self] in
                self?.selectPDF()
            },
            AttachmentOption(type: .recording, title: "Recording".translated()) { [weak self] in
                self?.recording()
            },
            AttachmentOption(type: .audio, title: "Audio".translated()) { [weak self] in
                self?.audio()
            },
            AttachmentOption(type: .video, title: "Video") { [weak self] in
                self?.VideoPick()
            }
        ]
        if task == "Reading" {
            options.removeAll { $0.type == .recording || $0.type == .audio }
        }
        for option in options {
            let action = UIAlertAction(title: option.title, style: .default) { _ in
                option.handler()
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func recording() {
        recordingView.isHidden = false
    }
    
    func audio() {
        let supportedTypes: [UTType] = [.audio]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Methods
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
}

// MARK: - UICollectionView DataSource & Delegate for Attachments
@available(iOS 15.0, *)
extension SenderLSRWVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == typeSectionCV {
            return 1
        } else {
            return 2
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == typeSectionCV {
            return taskTypes.count
        } else {
            if section == 0 {
                let nonAudioCount = attachments.filter { $0.fileType.lowercased() != "audio" }.count
                return 1 + nonAudioCount
            } else {
                return attachments.filter { $0.fileType.lowercased() == "audio" }.count
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == typeSectionCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeCell.identifier, for: indexPath) as! TaskTypeCell
            let (title, icon) = taskTypes[indexPath.item]
            cell.configure(title: title, icon: icon, isSelected: indexPath.item == selectedTaskIndex)
            return cell
        } else {
            if indexPath.section == 0 {
                if indexPath.item == 0 {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CellConfingName.AttachmentCVCell,
                        for: indexPath
                    ) as! AttachmentCVCell
                    cell.layer.cornerRadius = 20
                    
                    return cell
                } else {
                    let nonAudioFiles = attachments.filter { $0.fileType.lowercased() != "audio" }
                    let file = nonAudioFiles[indexPath.item - 1]
                    
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
                    collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
                    return cell
                }
            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "AudioCVC",
                    for: indexPath
                ) as! AudioCVC
                configureAudioCell(cell, at: indexPath)
                
                return cell
            }
        }
    }
    
    // MARK: - Audio Cell Configuration
    private func configureAudioCell(_ cell: AudioCVC, at indexPath: IndexPath) {
        let audioFiles = attachments.filter { $0.fileType.lowercased() == "audio" }
        let file = audioFiles[indexPath.item]
        if let urlString = file.imageURL {
            let url: URL
            
            if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
                guard let remoteURL = URL(string: urlString) else { return }
                url = remoteURL
            } else {
                let cleanPath = urlString
                    .replacingOccurrences(of: "file://", with: "")
                    .removingPercentEncoding ?? urlString
                
                url = URL(fileURLWithPath: cleanPath)
            }
            
            cell.audioURL = url
            cell.TrashIcon.isHidden = false
            cell.TrashIcon.isUserInteractionEnabled = true
        }
        
        cell.audioDelegate = self
        cell.cellIndex = indexPath.item
        cell.TrashIcon.tag = indexPath.item
        cell.delegate = self
        cell.waveView.setParentCell(cell)
        collectionViewHeight.constant = uploadAttachmentView.imageCollectionview.collectionViewLayout.collectionViewContentSize.height
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == typeSectionCV {
            let width = (collectionView.frame.width - 40) / 4
            return CGSize(width: width, height: 60)
        } else {
            let width = (uploadAttachmentView.imageCollectionview.frame.width - 30) / 3
            if indexPath.section == 0 {
                return CGSize(width: width, height: 100)
            } else {
                return CGSize(width: collectionView.frame.width - 20, height: 70)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == typeSectionCV {
            selectedTaskIndex = indexPath.item
            collectionView.reloadData()
            print("Selected Task: \(taskTypes[selectedTaskIndex].0)")
        } else {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    presentAttachmentOptions(for: taskTypes[selectedTaskIndex].0)
                } else {
                    let nonAudioFiles = attachments.filter { $0.fileType.lowercased() != "audio" }
                    let adjustedIndex = indexPath.item - 1
                    guard adjustedIndex < nonAudioFiles.count else { return }
                    
                    let imageVC = ImageShowVc(nibName: nil, bundle: nil)
                    imageVC.attachment = nonAudioFiles
                    imageVC.subjectName = "LSRW"
                    imageVC.scrollIndex = indexPath
                    imageVC.index = adjustedIndex
                    imageVC.modalPresentationStyle = .fullScreen
                    present(imageVC, animated: true)
                }
            }
        }
    }
}

// MARK: - UITextViewDelegate
@available(iOS 15.0, *)
extension SenderLSRWVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Hide placeholder once user begins editing
        placeholderLabel.isHidden = true
        if DetailsTxtview.text == CommonStringFile.Description {
            DetailsTxtview.text = ""
            DetailsTxtview.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Show placeholder if text view is empty
        let isEmptyContent = (textView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        placeholderLabel.isHidden = !isEmptyContent ? true : false
        if isEmptyContent {
            DetailsTxtview.text = ""
            DetailsTxtview.textColor = .black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Update placeholder visibility
        placeholderLabel.isHidden = !(textView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
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
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return true
    }
}

// MARK: - UIDocumentPickerDelegate
@available(iOS 15.0, *)
extension SenderLSRWVC {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            print("No file selected.")
            return
        }

        // Start security access for external file
        guard selectedFileURL.startAccessingSecurityScopedResource() else {
            print("❌ Cannot access file")
            return
        }
        if attachments.contains(where: { $0.imageURL == selectedFileURL.path }) {
            print("⚠️ File already added")
            return
        }
        attachments.append(AttachmentItem(
            image: nil,
            imageURL: selectedFileURL.path,
            fileType: CommonStringFile.audio
        ))

        // Reload UI
        self.uploadAttachmentView.imageCollectionview.reloadData()
        self.uploadAttachmentView.imageCollectionview.layoutIfNeeded()
        collectionViewHeight.constant = self.uploadAttachmentView.imageCollectionview.collectionViewLayout.collectionViewContentSize.height
        recordingView.isHidden = true
    }

    // Handle cancellation
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}

// MARK: - TaskTypeCell
class TaskTypeCell: UICollectionViewCell {
    static let identifier = "TaskTypeCell"
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textAlignment = .center
        lbl.textColor = .darkGray
        return lbl
    }()
    
    private let stack: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = 6
        st.alignment = .center
        return st
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.backgroundColor = .systemBackground
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(titleLabel)
        
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, icon: String, isSelected: Bool) {
        titleLabel.text = title
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = isSelected ? .systemBlue : .systemGray
        titleLabel.textColor = isSelected ? .systemBlue : .darkGray
        contentView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.systemGray4.cgColor
        contentView.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.1) : .systemBackground
    }
}

// MARK: - Supporting Types
enum AttachmentType {
    case camera, gallery, pdf, recording, audio, video
}

struct AttachmentOption {
    let type: AttachmentType
    let title: String
    let handler: () -> Void
}
