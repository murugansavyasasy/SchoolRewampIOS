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
class LSRWActivitesVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var testTable: UITableView!
    
    // MARK: - Properties
    var lsrw: LSRW?
    var captions = ["","","",""]
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        testTable.register(UINib(nibName: "TestTVC", bundle: nil), forCellReuseIdentifier: "TestTVC")
        testTable.register(UINib(nibName: "RecorderTVC", bundle: nil), forCellReuseIdentifier: "RecorderTVC")
        testTable.register(UINib(nibName: "AddAttachmentTVC", bundle: nil), forCellReuseIdentifier: "AddAttachmentTVC")
        testTable.register(UINib(nibName: "LSWTaskTVC", bundle: nil), forCellReuseIdentifier: "LSWTaskTVC")
        testTable.register(UINib(nibName: "LSWViewAttachmentTVC", bundle: nil), forCellReuseIdentifier: "LSWViewAttachmentTVC")
        testTable.delegate = self
        testTable.dataSource = self
    }

    // MARK: - Actions
    @IBAction func submit(_ sender: UIButton) {
        sender.setTitle("Submit", for: .normal)
        // Handle submit action here
    }

    @IBAction private func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
@available(iOS 15.0, *)
extension LSRWActivitesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch lsrw?.filePath.first?.type {
//        case "":
//            <#code#>
//        case "":
//            <#code#>
//        case .none:
//            <#code#>
//        case .some(_):
//            <#code#>
//        }
        return lsrw?.test.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let lsrwType = lsrw?.type.lowercased(),
              let test = lsrw?.test[indexPath.row] else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "LSWTaskTVC", for: indexPath) as! LSWTaskTVC
        cell.titleLbl.text = lsrw?.title
        cell.descriptionLbl.text = lsrw?.description
        cell.collectionView.reloadData()
//        switch lsrwType {
//        case "listen":
//            switch lsrw?.filePath.first?.type {
//            case "image":
//            case "video":
//            case "audio":
//            default:
//                break
//            }
//            
//            return cell
//
//        case "read":
////            if LSWViewAttachmentTVC
//            switch lsrw?.filePath.first?.type {
//            case "image":
//            case "video":
//            case "audio":
//            default:
//                break
//            }
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TestTVC", for: indexPath) as! TestTVC
//            cell.test = test
//            cell.questionLbl.text = test.question
//            return cell
//
//        case "write":
//            switch lsrw?.filePath.first?.type {
//            case "image":
//            case "video":
//            case "audio":
//            default:
//                break
//            }
//            // Use AddAttachmentTVC for file upload (PDF, Image, etc.)
//            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAttachmentTVC", for: indexPath) as! AddAttachmentTVC
//            cell.attachments = []
//            return cell
//
//        case "speak":
//            switch lsrw?.filePath.first?.type {
//            case "image":
//            case "video":
//            case "audio":
//            default:
//                break
//            }
//            // Use RecorderTVC for audio recording
//            let cell = tableView.dequeueReusableCell(withIdentifier: "RecorderTVC", for: indexPath) as! RecorderTVC
//            cell.recoderTime.text = test.question
//            cell.audioURLString = lsrw?.filePath.first?.url
//            return cell
//
//        default:
//            // Fallback to TestTVC
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TestTVC", for: indexPath) as! TestTVC
//            cell.test = test
//            cell.questionLbl.text = test.question
            return cell
//        }
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


