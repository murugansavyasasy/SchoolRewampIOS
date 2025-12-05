import UIKit
import AVFoundation

// MARK: - AudioManagerDelegate Protocol
protocol AudioManagerDelegate: AnyObject {
    func audioManagerDidUpdateTime(currentTime: Double, duration: Double)
    func audioManagerDidFinishPlaying()
    func audioManagerDidFailWithError(_ error: Error)
    func audioManagerDidStartBuffering()
    func audioManagerDidFinishBuffering()
}

@available(iOS 15.0, *)
class RecorderTVC: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var vicecImg: UIImageView!
    @IBOutlet weak var recoderTime: UILabel!
    @IBOutlet weak var recordButton: UIButton! // connect this if you have the button in nib

    // MARK: - Properties
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private(set) var isRecording = false
    private let audioManager = AudioManager()
    private var audioURL: URL? // Can be local or remote
    private var isRemoteAudio = false

   var delegate: EditObjectDelegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        audioManager.delegate = self

        // Stop recording if the app goes to background
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopRecordingIfNeeded()
        resetUI()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        invalidateTimer()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        recoderTime.text = "00:00"
        vicecImg.image = UIImage(systemName: "microphone.circle.fill")
        recordButton?.setTitle(nil, for: .normal) // optional, if you only show icon
    }

    private func resetUI() {
        vicecImg.image = UIImage(systemName: "microphone.circle.fill")
        recoderTime.text = "00:00"
        isRemoteAudio = false
    }

    // MARK: - Actions
    @IBAction private func recorderTapped(_ sender: UIButton) {
        isRecording ? stopRecording() : startRecording()
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
        // UI setup
        isRecording = true
        recordingStartTime = Date()
        recoderTime.text = "00:00"

        // Start a 1s tick timer (no retain cycle)
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRecordingTime()
        }

        // Start recording
        audioManager.startRecording()

        // Optional animated indicator (if you have this helper; otherwise keep the SF Symbol)
        if let gif = UIImage.gifImageWithName("Mic") {
            vicecImg.image = gif
        } else {
            vicecImg.image = UIImage(systemName: "mic.circle.fill")
        }

        UIApplication.shared.isIdleTimerDisabled = true
    }

    private func stopRecording() {
        invalidateTimer()

        audioManager.stopRecording { [weak self] url, duration in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isRecording = false
                self.vicecImg.image = UIImage(systemName: "microphone.circle.fill")
                self.recoderTime.text = self.formatTime(duration ?? 0)

                if let url = url {
                    self.audioURL = url
                    self.isRemoteAudio = false
                    self.delegate?.editDta(edit: AttachmentItem(image: nil, imageURL: url.absoluteString, fileType: "audio", VideoURl: nil, VimeoVideoURL: nil))
                }

                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }

    private func stopRecordingIfNeeded() {
        guard isRecording else { return }
        stopRecording()
    }

    private func invalidateTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStartTime = nil
    }

    @objc private func appDidEnterBackground() {
        if isRecording {
            stopRecording()
        }
    }

    @objc private func updateRecordingTime() {
        guard let startTime = recordingStartTime, isRecording else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        recoderTime.text = formatTime(elapsed)
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: CommonStringFile.Time_formate, mins, secs)
    }

    private func showMicPermissionAlert() {
        let alert = UIAlertController(
            title: "Microphone Access Required",
            message: "Please allow microphone access in Settings to record audio.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        getCurrentViewController()?.present(alert, animated: true)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Audio Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        getCurrentViewController()?.present(alert, animated: true)
    }

    private func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topMostViewController()
    }

    // Public setter if you want to prefill with local audio (not recording)
    func setLocalAudioURL(_ url: URL) {
        audioURL = url
        isRemoteAudio = false
    }
}

// MARK: - AudioManagerDelegate
@available(iOS 15.0, *)
extension RecorderTVC: AudioManagerDelegate {
    func audioManagerDidUpdateTime(currentTime: Double, duration: Double) {
        // If you also use AudioManager progress while recording, you can reflect it here
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isRecording else { return }
            self.recoderTime.text = self.formatTime(currentTime)
        }
    }

    func audioManagerDidFinishPlaying() {
        // Not used for recording, but keep for completeness
    }

    func audioManagerDidFailWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showErrorAlert(message: error.localizedDescription)
        }
    }

    func audioManagerDidStartBuffering() {
        // Likely N/A during recording
    }

    func audioManagerDidFinishBuffering() {
        // Likely N/A during recording
    }
}



// MARK: - Enhanced AudioManager Class
class AudioManager: NSObject {
    // MARK: - Properties
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var avPlayer: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var audioURL: URL?
    private var recordingStartTime: Date?
    private var playbackTimer: Timer?
    private var levelTimer: Timer?
    private var timeObserver: Any?
    weak var delegate: AudioManagerDelegate?
    var onLevelUpdate: ((Float) -> Void)?
    
    // MARK: - Computed Properties
    var isRecording: Bool {
        return audioRecorder?.isRecording == true
    }
    
    var isPlaying: Bool {
        return (audioPlayer?.isPlaying == true) || (avPlayer?.rate != 0)
    }
    
    var currentTime: TimeInterval {
        if let player = audioPlayer {
            return player.currentTime
        } else if let player = avPlayer {
            return player.currentTime().seconds
        }
        return 0
    }
    
    var duration: TimeInterval {
        if let player = audioPlayer {
            return player.duration
        } else if let player = avPlayer,
                  let item = player.currentItem {
            let duration = item.duration.seconds
            return duration.isFinite ? duration : 0
        }
        return 0
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Recording Methods
    func checkRecordPermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission(completion)
        @unknown default:
            completion(false)
        }
    }
    
    func startRecording() {
        do {
            try setupAudioSession(forRecording: true)
            guard setupRecorder() else {
                delegate?.audioManagerDidFailWithError(AudioError.recorderSetupFailed)
                return
            }
            
            recordingStartTime = Date()
            audioRecorder?.record()
            startLevelMonitoring()
        } catch {
            delegate?.audioManagerDidFailWithError(error)
        }
    }
    
    func stopRecording(completion: @escaping (URL?, TimeInterval?) -> Void) {
        audioRecorder?.stop()
        stopLevelMonitoring()
        
        let duration = recordingStartTime.map { Date().timeIntervalSince($0) }
        completion(audioURL, duration)
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession(forRecording: Bool = false) throws {
        let session = AVAudioSession.sharedInstance()
        do {
            if forRecording {
                if #available(iOS 10.0, *) {
                    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
                } else {
                    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                }
            } else {
                try session.setCategory(.playback, mode: .default)
            }

            try session.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ Audio session configured for \(forRecording ? "recording" : "playback")")
        } catch {
            print("❌ Audio session setup failed: \(error.localizedDescription)")
            throw error
        }
    }

    private func setupRecorder() -> Bool {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = Int(Date().timeIntervalSince1970) // unique name
        let fileURL = documentsPath.appendingPathComponent("RecordedAudio_\(timestamp).m4a")

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }

        audioURL = fileURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 64000
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            return true
        } catch {
            print("AudioRecorder setup error: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Level Monitoring
    private func startLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, weakTarget: self) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            let level = recorder.averagePower(forChannel: 0)
            let normalizedLevel = self.normalizeAudioLevel(level)
            self.onLevelUpdate?(normalizedLevel)
        }
    }
    
    private func stopLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
    }
    
    private func normalizeAudioLevel(_ power: Float) -> Float {
        let minDb: Float = -60
        let maxDb: Float = 0
        let clampedPower = max(minDb, min(maxDb, power))
        let normalized = (clampedPower - minDb) / (maxDb - minDb)
        return pow(normalized, 0.5)
    }
    // MARK: - Enhanced Playback Methods
    func setupPlayer(with url: URL) throws {
        cleanup() // Clean up any existing player
        
        if url.isFileURL {
            // Local file playback
            try setupLocalPlayer(with: url)
        } else {
            // Remote URL playback
            try setupRemotePlayer(with: url)
        }
        
        audioURL = url
    }
    
    private func setupLocalPlayer(with url: URL) throws {
        try setupAudioSession(forRecording: false)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw AudioError.fileNotFound
        }
        
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
        audioPlayer?.enableRate = true
    }
    
    func setupRemotePlayer(with url: URL) throws {
        try setupAudioSession(forRecording: false)
        delegate?.audioManagerDidStartBuffering()
        playerItem = AVPlayerItem(url: url)
        avPlayer = AVPlayer(playerItem: playerItem)
        setupRemotePlayerObservers()
    }
    
    private func setupRemotePlayerObservers() {
        guard let playerItem = playerItem else { return }
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration), options: [.new], context: nil)
        
        // Buffering observers
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: [.new], context: nil)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: [.new], context: nil)
        
        // Add time observer
        if let player = avPlayer {
            let timeScale = CMTimeScale(NSEC_PER_SEC)
            let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
            timeObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
                self?.delegate?.audioManagerDidUpdateTime(currentTime: time.seconds, duration: self?.duration ?? 0)
            }
        }
        
        // Playback end notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    @objc private func playerDidFinishPlaying() {
        delegate?.audioManagerDidFinishPlaying()
    }
    
    func togglePlayback() throws -> Bool {
        if let player = audioPlayer {
            if player.isPlaying {
                pause()
                return false
            } else {
                try play()
                return true
            }
        } else if let player = avPlayer {
            if player.rate != 0 {
                pause()
                return false
            } else {
                try play()
                return true
            }
        }
        throw AudioError.playerNotInitialized
    }
    
    func play() throws {
        if let player = audioPlayer {
            try setupAudioSession(forRecording: false)
            player.play()
            startPlaybackTimer()
        } else if let player = avPlayer {
            try setupAudioSession(forRecording: false)
            player.play()
            // Time observer is already set up for AVPlayer
        } else {
            throw AudioError.playerNotInitialized
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        avPlayer?.pause()
        stopPlaybackTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        avPlayer?.pause()
        avPlayer?.seek(to: .zero)
        stopPlaybackTimer()
    }
    
    func seek(to time: TimeInterval) throws {
        if let player = audioPlayer {
            guard time >= 0 && time <= player.duration else {
                throw AudioError.playbackFailed
            }
            player.currentTime = time
            delegate?.audioManagerDidUpdateTime(currentTime: time, duration: duration)
        } else if let player = avPlayer {
            let timeCM = CMTime(seconds: time, preferredTimescale: CMTimeScale(1000))
            player.seek(to: timeCM)
        } else {
            throw AudioError.playerNotInitialized
        }
    }
    
    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, weakTarget: self) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.audioManagerDidUpdateTime(currentTime: self.currentTime, duration: self.duration)
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    // MARK: - KVO for AVPlayer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        
        switch keyPath {
        case #keyPath(AVPlayerItem.status):
            if let statusNumber = change?[.newKey] as? NSNumber,
               let status = AVPlayerItem.Status(rawValue: statusNumber.intValue) {
                handlePlayerStatusChange(status)
            }
            
        case #keyPath(AVPlayerItem.duration):
            delegate?.audioManagerDidUpdateTime(currentTime: currentTime, duration: duration)
            
        case #keyPath(AVPlayerItem.isPlaybackBufferEmpty):
            if let isEmpty = change?[.newKey] as? Bool, isEmpty {
                delegate?.audioManagerDidStartBuffering()
            }
            
        case #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp):
            if let isLikelyToKeepUp = change?[.newKey] as? Bool, isLikelyToKeepUp {
                delegate?.audioManagerDidFinishBuffering()
            }
            
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func handlePlayerStatusChange(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            delegate?.audioManagerDidFinishBuffering()
            delegate?.audioManagerDidUpdateTime(currentTime: currentTime, duration: duration)
        case .failed:
            if let error = playerItem?.error {
                delegate?.audioManagerDidFailWithError(error)
            } else {
                delegate?.audioManagerDidFailWithError(AudioError.playbackFailed)
            }
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Cleanup
    func deleteRecording() {
        stop()
        if let url = audioURL, url.isFileURL, FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        cleanup()
    }
    
    func cleanup() {
        stop()
        stopLevelMonitoring()
        
        // Clean up timers
        playbackTimer?.invalidate()
        playbackTimer = nil
        levelTimer?.invalidate()
        levelTimer = nil
        
        // Clean up AVPlayer observers
        if let timeObserver = timeObserver, let player = avPlayer {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        // Remove KVO observers
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration))
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
        
        // Remove notification observers
        NotificationCenter.default.removeObserver(self)
        
        // Clean up audio components
        audioRecorder = nil
        audioPlayer = nil
        avPlayer = nil
        playerItem = nil
        audioURL = nil
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}

// MARK: - AudioManager Delegates
extension AudioManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            delegate?.audioManagerDidFailWithError(AudioError.recordingFailed)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            delegate?.audioManagerDidFailWithError(error)
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaybackTimer()
        delegate?.audioManagerDidFinishPlaying()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            delegate?.audioManagerDidFailWithError(error)
        }
    }
}

// MARK: - Enhanced Error Handling
enum AudioError: Error, LocalizedError {
    case recorderSetupFailed
    case playerNotInitialized
    case recordingFailed
    case playbackFailed
    case permissionDenied
    case fileNotFound
    case networkError
    case bufferingTimeout
    
    var errorDescription: String? {
        switch self {
        case .recorderSetupFailed:
            return "Failed to setup audio recorder"
        case .playerNotInitialized:
            return "Audio player not initialized"
        case .recordingFailed:
            return "Recording failed"
        case .playbackFailed:
            return "Playback failed"
        case .permissionDenied:
            return "Audio permission denied"
        case .fileNotFound:
            return "Audio file not found"
        case .networkError:
            return "Network error while loading audio"
        case .bufferingTimeout:
            return "Audio loading timed out"
        }
    }
}

// MARK: - Timer Extension for Weak Target
extension Timer {
    static func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, weakTarget target: AnyObject, block: @escaping (Timer) -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { [weak target] timer in
            guard target != nil else {
                timer.invalidate()
                return
            }
            block(timer)
        }
        return timer
    }
}
