//
//  LSRWActivitesVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/06/25.
//

import UIKit
import WebKit
import AVFoundation

@available(iOS 15.0, *)
class LSRWActivitesVC: UIViewController, AVAudioRecorderDelegate, DeleteImge, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var attachmentHeight: NSLayoutConstraint!
    @IBOutlet weak var subjectView: UIView!
    @IBOutlet weak var senderView: UIView!
    @IBOutlet weak var taskTypeView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var videoWeb: WKWebView!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var senderLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var vicecImg: UIImageView!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var waveView: AudioView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var outerplayerView: UIView!
    @IBOutlet weak var recoderTime: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var testTable: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var addAttachmentView: ImageSelection!
    @IBOutlet weak var recordingView: UIView!
    
    // MARK: - Properties
    var lsrw: LSRW?
    private let audioManager = AudioManager()
    private var attachments: [AttachmentItem] = []
    private var isRecording = false
    private var playVoiceActive = false
    private let photoPickManager = PhotoPickerManager.shared
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudio()
        setupCollectionViews()
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioManager.stopPlayback()
        audioManager.stopRecording { _, _ in }
        audioManager.invalidateTimer()
        recordingTimer?.invalidate()
        recordingTimer = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        titleLbl.text = lsrw?.title
        descriptionLbl.text = lsrw?.description
        SubjectLbl.text = lsrw?.subject
        dateLbl.text = lsrw?.submitedOn
        typeLbl.text = lsrw?.type
        attachmentView.isHidden = lsrw?.filePath.isEmpty ?? true
        deleteBtn.isHidden = true
        configureViews(for: lsrw?.type, fileType: lsrw?.filePath.first?.type)
        applyShadowAndCornerRadius(to: [playerView, taskTypeView, dateView, subjectView, senderView])
    }
    
    private func configureViews(for taskType: String?, fileType: String?) {
        let isVideo = fileType == "video"
        let isAudio = fileType == "audio"
        
        videoView.isHidden = !isVideo
        imageView.isHidden = isVideo || isAudio
        outerplayerView.isHidden = !isAudio
        if isAudio, let audioURLString = lsrw?.filePath.first?.url, let audioURL = URL(string: audioURLString) {
            audioManager.setupPlayer(with: audioURL)
        }
        
        switch taskType {
        case "listen":
            recordingView.isHidden = true
            addAttachmentView.isHidden = true
            testView.isHidden = true
        case "read":
            recordingView.isHidden = true
            addAttachmentView.isHidden = true
            testView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.testTable.reloadData()
                self.updateTableHeight()
            }
            imageView.isHidden = false
        case "write":
            recordingView.isHidden = true
            addAttachmentView.isHidden = false
            testView.isHidden = true
        case "speak":
            recordingView.isHidden = false
            addAttachmentView.isHidden = true
            testView.isHidden = true
        default:
            break
        }
    }
    
    private func setupAudio() {
        audioManager.delegate = self
        audioManager.checkRecordPermission { [weak self] granted in
            if !granted {
                DispatchQueue.main.async {
                    self?.showMicPermissionAlert()
                }
            }
        }
    }
    
    private func setupCollectionViews() {
        imageCollection.delegate = self
        imageCollection.dataSource = self
        addAttachmentView.imageCollectionview.delegate = self
        addAttachmentView.imageCollectionview.dataSource = self
        addAttachmentView.imageCollectionview.backgroundColor = .clear
        
        let imagePdfCellNib = UINib(nibName: CellConfingName.ImagePdfCvCell, bundle: nil)
        imageCollection.register(imagePdfCellNib, forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        
        let attachmentCellNib = UINib(nibName: CellConfingName.AttachmentCVCell, bundle: nil)
        addAttachmentView.imageCollectionview.register(attachmentCellNib, forCellWithReuseIdentifier: CellConfingName.AttachmentCVCell)
        
        let imageCellNib = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        addAttachmentView.imageCollectionview.register(imageCellNib, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        // Update table height after reload
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.attachmentHeight.constant = self.imageCollection.collectionViewLayout.collectionViewContentSize.height
            self.testTable.reloadData()
            self.updateTableHeight()
        }
        
        //        self.imageCollection.collectionViewLayout.invalidateLayout()
        //        self.imageCollection.performBatchUpdates(nil) { _ in
        //            self.imageCollection.layoutIfNeeded()
        //            self.attachmentHeight.constant = self.imageCollection.collectionViewLayout.collectionViewContentSize.height
        //        }
        setupImageSelection()
    }
    private func updateTableHeight() {
        self.testTable.layoutIfNeeded()
        self.tableHeight.constant = self.testTable.contentSize.height
    }
    private func setupTableView() {
        testTable.register(UINib(nibName: "TestTVC", bundle: nil), forCellReuseIdentifier: "TestTVC")
        testTable.delegate = self
        testTable.dataSource = self
    }
    
    private func setupImageSelection() {
        photoPickManager.onCameraImagePicked = { [weak self] image in
            guard let self = self else { return }
            self.addAttachment(.init(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
        }
        
        photoPickManager.onImagesPicked = { [weak self] images in
            guard let self = self else { return }
            let imageItems = images.map { AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE) }
            self.addAttachments(imageItems)
        }
        
        photoPickManager.onFilePicked = { [weak self] url in
            guard let self = self else { return }
            self.addAttachment(.init(image: nil, imageURL: url.absoluteString, fileType: CommonStringFile.pdf))
        }
    }
    
    private func applyShadowAndCornerRadius(to views: [UIView]) {
        views.forEach { view in
            view.layer.cornerRadius = 8
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.2
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            view.layer.masksToBounds = false
        }
    }
    
    // MARK: - Actions
    @IBAction private func recorderTapped(_ sender: UIButton) {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        audioManager.checkRecordPermission { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if granted {
                    self.recordingStartTime = Date()
                    self.timerLbl.text = "00:00"
                    self.recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateRecordingTime), userInfo: nil, repeats: true)
                    self.audioManager.startRecording()
                    self.isRecording = true
                    self.outerplayerView.isHidden = true
                    self.playBtn.setImage(ImageName.playbutton, for: .normal)
                    self.vicecImg.image = UIImage.gifImageWithName("Mic")
                    UIApplication.shared.isIdleTimerDisabled = true
                } else {
                    self.showMicPermissionAlert()
                }
            }
        }
    }
    
    private func stopRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        audioManager.stopRecording { [weak self] url, duration in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isRecording = false
                self.playBtn.setImage(ImageName.playbutton, for: .normal)
                self.vicecImg.image = ImageName.mic1
                self.deleteBtn.isHidden = false
                self.durationLbl.text = self.formatTime(Double(duration ?? 0))
                if let url = url {
                    self.audioManager.setupPlayer(with: url)
                    self.outerplayerView.isHidden = false
                }
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    
    // MARK: - UPDATE RECORDING DURATION
    @objc private func updateRecordingTime() {
        guard let startTime = recordingStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        if elapsed >= 180 {
            stopRecording()
            timerLbl.text = "03:00"
        } else {
            let minutes = Int(elapsed) / 60
            let seconds = Int(elapsed) % 60
            timerLbl.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    @IBAction private func playVoice(_ sender: UIButton) {
        audioManager.togglePlayback { [weak self] isPlaying in
            DispatchQueue.main.async {
                self?.playBtn.setImage(isPlaying ? ImageName.pausebutton : ImageName.playbutton, for: .normal)
                self?.playVoiceActive = isPlaying
                self?.waveView.isAnimating = isPlaying
            }
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        sender.setTitle("Submit", for: .normal)
    }
    
    @IBAction private func deleteAudio(_ sender: UIButton) {
        audioManager.deleteRecording()
        outerplayerView.isHidden = true
    }
    
    @IBAction private func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func showMicPermissionAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: "Please allow microphone usage from settings",
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
    
    private func addAttachment(_ item: AttachmentItem) {
        attachments.removeAll { $0.fileType != item.fileType }
        attachments.append(item)
        user_inputs.selectedFileType = item.fileType
        addAttachmentView.imageCollectionview.reloadData()
        updateCollectionViewHeight()
    }
    
    private func addAttachments(_ items: [AttachmentItem]) {
        if !items.isEmpty {
            attachments.removeAll { $0.fileType != items.first?.fileType }
            attachments.append(contentsOf: items)
            user_inputs.selectedFileType = items.first?.fileType ?? CommonStringFile.IMAGE
            addAttachmentView.imageCollectionview.reloadData()
            updateCollectionViewHeight()
        }
    }
    
    private func updateCollectionViewHeight() {
        let totalItems = attachments.count
        collectionViewHeght.constant = totalItems <= 2 ? 120 : 220
    }
}
// MARK: - DeleteImageDelegate
@available(iOS 15.0, *)
extension LSRWActivitesVC: DeleteImge {
    func deleteImage(index: Int) {
        guard index < attachments.count else { return }
        attachments.remove(at: index)
        addAttachmentView.imageCollectionview.reloadData()
        updateCollectionViewHeight()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
@available(iOS 15.0, *)
extension LSRWActivitesVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lsrw?.test.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestTVC", for: indexPath) as! TestTVC
        if let test = lsrw?.test[indexPath.row] {
            cell.test = test
            cell.questionLbl.text = test.question
            cell.layoutIfNeeded()
        }
        self.tableHeight.constant = self.testTable.contentSize.height
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
@available(iOS 15.0, *)
extension LSRWActivitesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imageCollection {
            return lsrw?.filePath.count ?? 0
        } else {
            return 1 + attachments.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imageCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
            
            if let file = lsrw?.filePath[indexPath.row], let fileURL = URL(string: file.url) {
                let iconName = getFileIconName(for: fileURL)
                if iconName != "image" {
                    cell.hide = false
                    cell.webView.load(URLRequest(url: fileURL))
                    cell.webView.isHidden = false
                    cell.imageView.isHidden = true
                } else {
                    cell.hide = false
                    cell.webView.isHidden = true
                    cell.imageView.isHidden = false
                    cell.imageView.kf.setImage(with: fileURL, placeholder: ImageName.placeholder)
                }
                cell.IndicaterImageView.image = UIImage(named: iconName)
            }
            return cell
        } else {
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
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == imageCollection{
            let width = (imageCollection.frame.width - 30) / 3
            return CGSize(width: width, height: 100)
        }else{
            let width = (addAttachmentView.imageCollectionview.frame.width - 30) / 3
            return CGSize(width: width, height: 100)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == addAttachmentView.imageCollectionview else { return }
        
        if indexPath.item == 0 {
            showAttachmentOptions()
        } else {
            let adjustedIndex = indexPath.item - 1
            guard adjustedIndex < attachments.count else { return }
            
            let item = attachments[adjustedIndex]
            guard item.fileType != "video" else { return }
            
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
            present(vc, animated: true)
        }
    }
    
    private func showAttachmentOptions() {
        let alertController = UIAlertController(
            title: "Select".translated(),
            message: "Choose an option".translated(),
            preferredStyle: .actionSheet
        )
        
        alertController.addAction(UIAlertAction(title: "Camera".translated(), style: .default) { [weak self] _ in
            self?.openCamera()
        })
        
        alertController.addAction(UIAlertAction(title: "Gallery".translated(), style: .default) { [weak self] _ in
            self?.selectImages()
        })
        
        alertController.addAction(UIAlertAction(title: "Document".translated(), style: .default) { [weak self] _ in
            self?.selectPDF()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel".translated(), style: .cancel))
        present(alertController, animated: true)
    }
    
    private func selectImages() {
        let imageCount = attachments.filter { $0.fileType == CommonStringFile.IMAGE }.count
        guard imageCount < 5 else {
            showLimitReachedAlert()
            return
        }
        photoPickManager.presentPicker(ofType: .gallery(selectionLimit: 5 - imageCount), from: self)
    }
    
    private func openCamera() {
        let imageCount = attachments.filter { $0.fileType == CommonStringFile.IMAGE }.count
        guard imageCount < 5 else {
            showLimitReachedAlert()
            return
        }
        photoPickManager.presentPicker(ofType: .camera, from: self)
    }
    
    private func selectPDF() {
        let pdfCount = attachments.filter { $0.fileType == CommonStringFile.pdf }.count
        guard pdfCount < 5 else {
            showLimitReachedAlert()
            return
        }
        photoPickManager.presentPicker(ofType: .file, from: self)
        photoPickManager.limiSelection = 5 - pdfCount
    }
    
    private func showLimitReachedAlert() {
        let alert = CustomAlert()
        alert.showAlert(title: "", message: "Already reached your limit".translated(), on: self)
    }
}

// MARK: - AudioManager
protocol AudioManagerDelegate: AnyObject {
    func audioManagerDidFinishPlaying()
    func audioManagerDidUpdateTime(currentTime: Double, duration: Double)
}


import UIKit
import AVFoundation
import Accelerate

// MARK: - AudioProcessor (Enhanced)
class AudioProcessor {
    static func extractAmplitudes(from url: URL, sampleCount: Int, completion: @escaping ([Float]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let file = try AVAudioFile(forReading: url)
                let format = file.processingFormat
                let frameCount = UInt32(file.length)
                
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                    DispatchQueue.main.async { completion([]) }
                    return
                }
                
                try file.read(into: buffer)
                
                guard let channelData = buffer.floatChannelData?[0] else {
                    DispatchQueue.main.async { completion([]) }
                    return
                }
                
                let frameLength = Int(buffer.frameLength)
                let samplesPerSegment = max(1, frameLength / sampleCount)
                var amplitudes: [Float] = []
                
                for i in 0..<sampleCount {
                    let startFrame = i * samplesPerSegment
                    let endFrame = min(startFrame + samplesPerSegment, frameLength)
                    let segmentLength = endFrame - startFrame
                    
                    var rms: Float = 0.0
                    vDSP_rmsqv(channelData + startFrame, 1, &rms, UInt(segmentLength))
                    
                    // Convert RMS to a more visual representation
                    let db = 20 * log10(max(rms, 0.000001)) // Avoid log(0)
                    let normalizedDb = max(0, (db + 60) / 60) // Normalize -60dB to 0dB to 0-1 range
                    amplitudes.append(normalizedDb)
                }
                
                // Smooth the amplitudes
                let smoothedAmplitudes = smoothAmplitudes(amplitudes)
                
                DispatchQueue.main.async {
                    completion(smoothedAmplitudes)
                }
            } catch {
                print("Error processing audio: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }
    }
    
    private static func smoothAmplitudes(_ amplitudes: [Float]) -> [Float] {
        guard amplitudes.count > 2 else { return amplitudes }
        
        var smoothed = amplitudes
        for i in 1..<(amplitudes.count - 1) {
            smoothed[i] = (amplitudes[i-1] + amplitudes[i] + amplitudes[i+1]) / 3.0
        }
        return smoothed
    }
}

// MARK: - Enhanced AudioView
@available(iOS 15.0, *)
class AudioView: UIView {
    
    // MARK: - Properties
    private var waveLayers: [CAShapeLayer] = []
    private var displayLink: CADisplayLink?
    private var panGesture: UIPanGestureRecognizer!
    
    // Wave configuration
    private let numberOfBars: Int = 40
    private let maxBarHeight: CGFloat = 32.0
    private let minBarHeight: CGFloat = 3.0
    
    // Animation properties
    private var animationPhase: CGFloat = 0.0
    private var recordingAmplitudes: [Float] = []
    private var playbackAmplitudes: [Float] = []
    
    // Progress tracking
    var progress: CGFloat = 0.0 {
        didSet {
            updateProgressVisual()
        }
    }
    
    // Audio state
    private var isRecordingState = false
    private var currentPlaybackAmplitudes: [Float] = []
    
    // Customizable properties
    var waveColor: UIColor = UIColor.systemGray4 {
        didSet { updateWaveColors() }
    }
    
    var progressColor: UIColor = UIColor.systemBlue {
        didSet { updateWaveColors() }
    }
    
    var barWidth: CGFloat = 2.0 {
        didSet { setupWaveBars() }
    }
    
    var barSpacing: CGFloat = 2.0 {
        didSet { setupWaveBars() }
    }
    
    var cornerRadius: CGFloat = 1.0 {
        didSet { updateWaveAppearance() }
    }
    
    var isAnimating: Bool = false {
        didSet {
            if isAnimating {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }
    
    // Callbacks
    var onProgressChanged: ((CGFloat) -> Void)?
    var onSeekingStarted: (() -> Void)?
    var onSeekingEnded: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        setupWaveBars()
        setupGesture()
        
        // Initialize with default amplitudes
        generateDefaultAmplitudes()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupWaveBars()
    }
    
    // MARK: - Wave Setup
    private func setupWaveBars() {
        // Remove existing layers
        waveLayers.forEach { $0.removeFromSuperlayer() }
        waveLayers.removeAll()
        
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        let totalSpacing = CGFloat(numberOfBars - 1) * barSpacing
        let availableWidth = bounds.width - totalSpacing
        let actualBarWidth = min(barWidth, availableWidth / CGFloat(numberOfBars))
        
        for i in 0..<numberOfBars {
            let barLayer = CAShapeLayer()
            barLayer.fillColor = waveColor.cgColor
            barLayer.strokeColor = UIColor.clear.cgColor
            
            let xPosition = CGFloat(i) * (actualBarWidth + barSpacing)
            barLayer.frame = CGRect(x: xPosition, y: 0, width: actualBarWidth, height: bounds.height)
            
            layer.addSublayer(barLayer)
            waveLayers.append(barLayer)
        }
        
        updateWaveAppearance()
        updateStaticWaveBars()
    }
    
    private func updateWaveAppearance() {
        waveLayers.forEach { layer in
            layer.cornerRadius = cornerRadius
        }
    }
    
    private func updateWaveColors() {
        for (index, barLayer) in waveLayers.enumerated() {
            let progressPosition = CGFloat(index) / CGFloat(numberOfBars - 1)
            let isInProgress = progressPosition <= progress
            
            barLayer.fillColor = isInProgress ? progressColor.cgColor : waveColor.cgColor
        }
    }
    
    // MARK: - Gesture Setup
    private func setupGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleWaveSlide(_:)))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Gesture Actions
    @objc private func handleWaveSlide(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let newProgress = max(0, min(location.x / bounds.width, 1.0))
        
        switch gesture.state {
        case .began:
            onSeekingStarted?()
        case .changed:
            progress = newProgress
            onProgressChanged?(progress)
        case .ended, .cancelled:
            onSeekingEnded?()
        default:
            break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let newProgress = max(0, min(location.x / bounds.width, 1.0))
        
        onSeekingStarted?()
        progress = newProgress
        onProgressChanged?(progress)
        onSeekingEnded?()
    }
    
    // MARK: - Audio Loading
    func loadAudio(from url: URL) {
        AudioProcessor.extractAmplitudes(from: url, sampleCount: numberOfBars) { [weak self] amplitudes in
            guard let self = self else { return }
            self.playbackAmplitudes = amplitudes
            self.currentPlaybackAmplitudes = amplitudes
            self.isRecordingState = false
            self.updateStaticWaveBars()
        }
    }
    
    // MARK: - Recording Functions
    func startRecording() {
        isRecordingState = true
        recordingAmplitudes.removeAll()
        progress = 0
        isAnimating = true
        generateDefaultAmplitudes() // Start with default pattern
    }
    
    func stopRecording() {
        isRecordingState = false
        isAnimating = false
        
        // If we have recorded amplitudes, use them
        if !recordingAmplitudes.isEmpty {
            playbackAmplitudes = recordingAmplitudes
            currentPlaybackAmplitudes = recordingAmplitudes
        }
        
        updateStaticWaveBars()
    }
    
    func updateRecordingLevel(_ level: Float) {
        guard isRecordingState else { return }
        
        let normalizedLevel = max(0.1, min(1.0, level))
        recordingAmplitudes.append(normalizedLevel)
        
        // Update the display with recorded data
        if recordingAmplitudes.count >= numberOfBars {
            let recentAmplitudes = Array(recordingAmplitudes.suffix(numberOfBars))
            currentPlaybackAmplitudes = recentAmplitudes
        } else {
            // Fill remaining bars with default values
            var displayAmplitudes = recordingAmplitudes
            while displayAmplitudes.count < numberOfBars {
                displayAmplitudes.append(0.2)
            }
            currentPlaybackAmplitudes = displayAmplitudes
        }
    }
    
    // MARK: - Playback Functions
    func startPlayback() {
        isRecordingState = false
        isAnimating = true
    }
    
    func pausePlayback() {
        isAnimating = false
    }
    
    func stopPlayback() {
        isAnimating = false
        progress = 0
    }
    
    // MARK: - Default Amplitudes
    private func generateDefaultAmplitudes() {
        currentPlaybackAmplitudes = (0..<numberOfBars).map { i in
            let normalized = Float(i) / Float(numberOfBars - 1)
            return 0.2 + 0.5 * sin(normalized * 4 * .pi) * sin(normalized * 2 * .pi)
        }
    }
    
    // MARK: - Progress Update
    private func updateProgressVisual() {
        updateWaveColors()
    }
    
    // MARK: - Animation Control
    private func startAnimation() {
        guard displayLink == nil else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateWaveBars))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 20, maximum: 60)
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        updateStaticWaveBars()
    }
    
    // MARK: - Wave Animation
    @objc private func updateWaveBars() {
        animationPhase += 0.15
        
        for (index, barLayer) in waveLayers.enumerated() {
            let baseAmplitude: Float
            if index < currentPlaybackAmplitudes.count {
                baseAmplitude = currentPlaybackAmplitudes[index]
            } else {
                baseAmplitude = 0.2
            }
            
            var animatedHeight: CGFloat
            
            if isRecordingState {
                // Recording animation - more dynamic
                let wave1 = sin(animationPhase + CGFloat(index) * 0.3)
                let wave2 = sin(animationPhase * 1.5 + CGFloat(index) * 0.2) * 0.6
                let combinedWave = (wave1 + wave2) * 0.5 + 0.5 // Normalize to 0-1
                
                let baseHeight = CGFloat(baseAmplitude) * maxBarHeight
                animatedHeight = baseHeight * (0.4 + 0.6 * combinedWave)
            } else {
                // Playback animation - subtle pulsing
                let progressFactor: CGFloat = abs(progress - CGFloat(index) / CGFloat(numberOfBars - 1))
                let proximityBoost = max(0.0, 1.0 - progressFactor * 8.0)
                
                let pulseWave = sin(animationPhase * 2.0) * 0.2 + 1.0
                let baseHeight = CGFloat(baseAmplitude) * maxBarHeight
                animatedHeight = baseHeight * (0.8 + 0.2 * pulseWave + 0.3 * proximityBoost)
            }
            
            // Clamp height
            animatedHeight = max(minBarHeight, min(maxBarHeight, animatedHeight))
            
            let path = createBarPath(height: animatedHeight, width: barLayer.bounds.width)
            barLayer.path = path.cgPath
        }
    }
    
    private func updateStaticWaveBars() {
        for (index, barLayer) in waveLayers.enumerated() {
            let amplitude: Float
            if index < currentPlaybackAmplitudes.count {
                amplitude = currentPlaybackAmplitudes[index]
            } else {
                amplitude = 0.2
            }
            
            let height = max(minBarHeight, CGFloat(amplitude) * maxBarHeight)
            let path = createBarPath(height: height, width: barLayer.bounds.width)
            barLayer.path = path.cgPath
        }
    }
    
    private func createBarPath(height: CGFloat, width: CGFloat) -> UIBezierPath {
        let centerY = bounds.height / 2
        let rect = CGRect(
            x: 0,
            y: centerY - height / 2,
            width: width,
            height: height
        )
        
        return UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
    }
    
    // MARK: - Public Methods
    func setProgress(_ newProgress: CGFloat, animated: Bool = true) {
        let clampedProgress = max(0, min(1, newProgress))
        
        if animated {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                self.progress = clampedProgress
            }
        } else {
            progress = clampedProgress
        }
    }
    
    func reset() {
        progress = 0
        recordingAmplitudes.removeAll()
        playbackAmplitudes.removeAll()
        generateDefaultAmplitudes()
        updateStaticWaveBars()
    }
    
    // MARK: - Cleanup
    deinit {
        displayLink?.invalidate()
    }
}

// MARK: - Enhanced AudioManager
class AudioManager: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    var player: AVPlayer?
    private var updateTimer: Timer?
    private var levelTimer: Timer?
    private var recordingStartTime: Date?
    private var audioURL: URL?
    weak var delegate: AudioManagerDelegate?
    
    // Level monitoring
    var onLevelUpdate: ((Float) -> Void)?
    
    func checkRecordPermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                completion(allowed)
            }
        @unknown default:
            completion(false)
        }
    }
    
    func startRecording() {
        setupAudioSession()
        setupRecorder()
        recordingStartTime = Date()
        audioRecorder?.record()
        startLevelMonitoring()
    }
    
    func stopRecording(completion: @escaping (URL?, Int?) -> Void) {
        audioRecorder?.stop()
        stopLevelMonitoring()
        let duration = recordingStartTime.map { Int(Date().timeIntervalSince($0)) }
        completion(audioURL, duration)
    }
    
    private func startLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            let averagePower = recorder.averagePower(forChannel: 0)
            let normalizedLevel = self.normalizeAudioLevel(averagePower)
            self.onLevelUpdate?(normalizedLevel)
        }
    }
    
    private func stopLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
    }
    
    private func normalizeAudioLevel(_ power: Float) -> Float {
        // Convert decibel to linear scale
        let minDb: Float = -60.0
        let maxDb: Float = 0.0
        
        let clampedPower = max(minDb, min(maxDb, power))
        let normalizedPower = (clampedPower - minDb) / (maxDb - minDb)
        
        return normalizedPower
    }
    
    func setupPlayer(with url: URL) {
        player = AVPlayer(playerItem: AVPlayerItem(url: url))
        player?.volume = 1.0
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
    
    func togglePlayback(completion: @escaping (Bool) -> Void) {
        guard let player = player else { return }
        let isPlaying = player.rate != 0
        
        if isPlaying {
            player.pause()
            updateTimer?.invalidate()
            updateTimer = nil
        } else {
            player.play()
            updateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        }
        completion(!isPlaying)
    }
    
    func deleteRecording() {
        guard let url = audioURL, FileManager.default.fileExists(atPath: url.path) else { return }
        try? FileManager.default.removeItem(at: url)
        player = nil
        audioURL = nil
    }
    
    func stopPlayback() {
        player?.pause()
        player?.seek(to: .zero)
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func invalidateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
        stopLevelMonitoring()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    private func setupRecorder() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RecordedAudio.m4a")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
        audioURL = fileURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print("Recorder setup error: \(error)")
        }
    }
    
    @objc private func updateSlider() {
        guard let player = player, let currentItem = player.currentItem else { return }
        let duration = CMTimeGetSeconds(currentItem.duration)
        let currentTime = CMTimeGetSeconds(player.currentTime())
        delegate?.audioManagerDidUpdateTime(currentTime: currentTime, duration: duration)
    }
    
    @objc private func playerDidFinishPlaying() {
        player?.seek(to: .zero)
        updateTimer?.invalidate()
        updateTimer = nil
        delegate?.audioManagerDidFinishPlaying()
    }
}

// MARK: - Updated LSRWActivitesVC Integration
@available(iOS 15.0, *)
extension LSRWActivitesVC {
    
    private func setupAudioWithWaveform() {
        audioManager.delegate = self
        
        // Setup level monitoring for waveform
        audioManager.onLevelUpdate = { [weak self] level in
            DispatchQueue.main.async {
                self?.waveView.updateRecordingLevel(level)
            }
        }
        
        // Setup waveform callbacks
        waveView.onProgressChanged = { [weak self] progress in
            // Handle seeking during playback
            guard let self = self, let player = self.audioManager.player else { return }
            let duration = CMTimeGetSeconds(player.currentItem?.duration ?? .zero)
            let seekTime = CMTime(seconds: Double(progress) * duration, preferredTimescale: 600)
            player.seek(to: seekTime)
        }
        
        waveView.onSeekingStarted = { [weak self] in
            // Pause during seeking
            self?.audioManager.player?.pause()
        }
        
        waveView.onSeekingEnded = { [weak self] in
            // Resume if was playing
            if self?.playVoiceActive == true {
                self?.audioManager.player?.play()
            }
        }
    }
    
    // Update your existing recording methods
    private func startRecordingWithWaveform() {
        audioManager.checkRecordPermission { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if granted {
                    self.recordingStartTime = Date()
                    self.timerLbl.text = "00:00"
                    self.recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateRecordingTime), userInfo: nil, repeats: true)
                    
                    // Start waveform recording animation
                    self.waveView.startRecording()
                    
                    self.audioManager.startRecording()
                    self.isRecording = true
                    self.outerplayerView.isHidden = true
                    self.playBtn.setImage(ImageName.playbutton, for: .normal)
                    self.vicecImg.image = UIImage.gifImageWithName("Mic")
                    UIApplication.shared.isIdleTimerDisabled = true
                } else {
                    self.showMicPermissionAlert()
                }
            }
        }
    }
    
    private func stopRecordingWithWaveform() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        waveView.stopRecording()
        
        audioManager.stopRecording { [weak self] url, duration in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isRecording = false
                self.playBtn.setImage(ImageName.playbutton, for: .normal)
                self.vicecImg.image = ImageName.mic1
                self.durationLbl.text = self.formatTime(Double(duration ?? 0))
                if let url = url {
                    self.audioManager.setupPlayer(with: url)
                    self.waveView.loadAudio(from: url)
                    self.outerplayerView.isHidden = false
                }
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
}

// MARK: - Enhanced AudioManagerDelegate
@available(iOS 15.0, *)
extension LSRWActivitesVC: AudioManagerDelegate {
    func audioManagerDidFinishPlaying() {
        playBtn.setImage(ImageName.playbutton, for: .normal)
        playVoiceActive = false
        waveView.pausePlayback()
        waveView.setProgress(0, animated: true)
    }
    
    func audioManagerDidUpdateTime(currentTime: Double, duration: Double) {
        guard duration.isFinite && duration > 0 else { return }
        let progress = currentTime / duration
        waveView.setProgress(CGFloat(progress), animated: false)
        durationLbl.text = "\(formatTime(currentTime)) / \(formatTime(duration))"
    }
}
