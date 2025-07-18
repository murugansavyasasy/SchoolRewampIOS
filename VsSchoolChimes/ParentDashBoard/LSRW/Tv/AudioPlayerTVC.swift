////
////  AudioPlayerTVC.swift
////  School Chimes
////
////  Created by Chandhru on 16/07/25.

import UIKit
import AVFoundation

// MARK: - Cell
@available(iOS 15.0, *)
class AudioPlayerTVC: UITableViewCell {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var waveView: AudioMessageView!
    @IBOutlet weak var playerView: UIView!
    var audioURL: URL? {
        didSet {
            guard let url = audioURL else { return }
            // Check if it's a remote URL (http or https)
            if url.isFileURL {
                do {
                    try audioManager.setupPlayer(with: url)
                    waveView.audioURL = url
                } catch {
                    print("❌ Failed to set up audio player:", error)
                }
            } else {
                // Remote URL - download it first
                downloadAndPrepareAudio(from: url)
            }

        }
    }

    private let audioManager = AudioManager()
    override func awakeFromNib() {
        super.awakeFromNib()
        playerView.setShadow(cornerRadius: 10)
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

    @IBAction func playAudio(_ sender: UIButton) {
        waveView.isPlaying.toggle()
        playBtn.isSelected = waveView.isPlaying
        playBtn.setImage(UIImage(named: waveView.isPlaying ? "pause-button" : "play-button"), for: .normal)
        if waveView.isPlaying {
            waveView.startPlaybackAnimation()
        } else {
            waveView.stopPlaybackAnimation()
        }
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
}
@available(iOS 15.0, *)
class AudioMessageView: UIView, AVAudioPlayerDelegate {
    private let waveformView = UIStackView()
    private let durationLabel = UILabel()
    private let progressView = UIView()
    
    private var waveformBars: [UIView] = []
    private var barHeightConstraints: [NSLayoutConstraint] = []

    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    var isPlaying = false {
        didSet {
            updatePlayingState()
        }
    }
    
    private var barsGenerated = false
    private var panGesture: UIPanGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!

    var audioURL: URL? {
        didSet {
            resetState()
            loadAudio()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !barsGenerated && waveformView.bounds.width > 0 {
            generateWaveformBars()
            barsGenerated = true
        }
    }

    private func setupUI() {
        setupWaveformView()
        setupDurationLabel()
        setupProgressView()
        setupConstraints()
//        setupStyling()
        setupGestures()
    }

    private func setupWaveformView() {
        waveformView.axis = .horizontal
        waveformView.spacing = 2
        waveformView.alignment = .center
        waveformView.distribution = .fillEqually
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(waveformView)
    }

    private func setupDurationLabel() {
        durationLabel.text = "0:00"
        durationLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        durationLabel.textColor = .systemGray
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(durationLabel)
    }

    private func setupProgressView() {
        progressView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        progressView.layer.cornerRadius = 8
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.alpha = 0
        insertSubview(progressView, at: 0)
    }


    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveformView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            waveformView.centerYAnchor.constraint(equalTo: centerYAnchor),
            waveformView.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -8),
            waveformView.heightAnchor.constraint(equalToConstant: 24),

            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            durationLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            progressView.topAnchor.constraint(equalTo: topAnchor),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupGestures() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWaveformTap(_:)))
        waveformView.addGestureRecognizer(tapGesture)

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleWaveformPan(_:)))
        waveformView.addGestureRecognizer(panGesture)
    }

    private func generateWaveformBars() {
        let barWidth: CGFloat = 2
        let spacing: CGFloat = waveformView.spacing
        let availableWidth = waveformView.bounds.width
        let numberOfBars = Int(availableWidth / (barWidth + spacing))

        for _ in 0..<numberOfBars {
            let bar = UIView()
            bar.backgroundColor = .systemBlue
            bar.layer.cornerRadius = 1
            bar.translatesAutoresizingMaskIntoConstraints = false

            bar.widthAnchor.constraint(equalToConstant: barWidth).isActive = true
            let height = CGFloat.random(in: 4...20)
            let heightConstraint = bar.heightAnchor.constraint(equalToConstant: height)
            heightConstraint.isActive = true

            waveformView.addArrangedSubview(bar)
            waveformBars.append(bar)
            barHeightConstraints.append(heightConstraint)
        }
    }

    private func loadAudio() {
        guard let url = audioURL else {
            print("Invalid audio URL: nil")
            durationLabel.text = "Error"
            return
        }
        
        // For debugging
        print("Trying to load audio at: \(url)")
        print("File exists: \(FileManager.default.fileExists(atPath: url.path))")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // AVAudioPlayer only works with *file-based* URLs
            guard url.isFileURL else {
                print("AVAudioPlayer cannot load non-file URLs")
                durationLabel.text = "Error"
                return
            }

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()

            let duration = audioPlayer?.duration ?? 0
            durationLabel.text = formatTime(duration)

            // Generate waveform
            let sampleCount = Int(bounds.width / 4)
            AudioProcessor.extractAmplitudes(from: url, sampleCount: sampleCount) { [weak self] amplitudes in
                DispatchQueue.main.async {
                    self?.barsGenerated = true
                }
            }
        } catch {
            print("Error loading audio: \(error.localizedDescription) (Code: \((error as NSError).code))")
            durationLabel.text = "Error"
        }
    }

    func startPlaybackAnimation() {
        guard let player = audioPlayer else {
            print("Audio player not initialized")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            player.play()
            isPlaying = true
//            animateWaveformBars()
            startTimer()
//            
//            UIView.animate(withDuration: 0.3) {
//                self.progressView.alpha = 1.0
//            }
        } catch {
            print("Failed to start playback: \(error.localizedDescription)")
            isPlaying = false
        }
    }

    func stopPlaybackAnimation() {
        audioPlayer?.pause()
        isPlaying = false
        stopAnimations()
        timer?.invalidate()
        timer = nil
//        
//        UIView.animate(withDuration: 0.3) {
//            self.progressView.alpha = 0.0
//        }
    }
    
    private func stopAnimations() {
        waveformBars.forEach { bar in
            bar.layer.removeAllAnimations()
            bar.alpha = 1.0
        }
    }
    
    private func updatePlayingState() {
        if isPlaying {
//            animateWaveformBars()
        } else {
            stopAnimations()
        }
    }
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateUI()
        }
    }

    private func updateUI() {
        guard let player = audioPlayer, player.isPlaying else { return }
        
        let remainingTime = player.duration - player.currentTime
        durationLabel.text = formatTime(remainingTime)
        
        let progress = player.currentTime / player.duration
        DispatchQueue.main.async {
            self.progressView.frame = CGRect(
                x: 0,
                y: 0,
                width: self.bounds.width * progress,
                height: self.bounds.height
            )
        }
        
        updateWaveformColor(progress: progress)
        
        if player.currentTime >= player.duration {
            reset()
        }
    }

    private func updateWaveformColor(progress: Double) {
        let index = Int(progress * Double(waveformBars.count))
        for (i, bar) in waveformBars.enumerated() {
            bar.backgroundColor = i <= index ? .systemBlue : .systemGray4
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    @objc private func handleWaveformTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: waveformView)
        seekToLocation(location.x)
    }

    @objc private func handleWaveformPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: waveformView)
        switch gesture.state {
        case .began:
            let wasPlaying = isPlaying
            stopPlaybackAnimation()
            gesture.view?.tag = wasPlaying ? 1 : 0
        case .changed:
            seekToLocation(location.x)
        case .ended, .cancelled:
            if gesture.view?.tag == 1 {
                startPlaybackAnimation()
            }
        default:
            break
        }
    }

    private func seekToLocation(_ xPosition: CGFloat) {
        guard let player = audioPlayer else { return }
        let width = waveformView.bounds.width
        let clampedX = min(max(0, xPosition), width)
        let ratio = clampedX / width
        player.currentTime = ratio * player.duration
        updateUI()
    }

    func reset() {
        stopPlaybackAnimation()
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        
        UIView.animate(withDuration: 0.3) {
            self.progressView.alpha = 0
        }
        
        durationLabel.text = formatTime(audioPlayer?.duration ?? 0)
        updateWaveformColor(progress: 0)
    }
    
    private func resetState() {
        timer?.invalidate()
        timer = nil
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        barsGenerated = false
        
        waveformBars.forEach { $0.removeFromSuperview() }
        waveformBars.removeAll()
        barHeightConstraints.removeAll()
        
        progressView.alpha = 0
        durationLabel.text = "0:00"
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.reset()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async {
            self.reset()
            self.durationLabel.text = "Error"
        }
    }
}
//
//// MARK: - AudioProcessor
class AudioProcessor {
    static func extractAmplitudes(from url: URL, sampleCount: Int, completion: @escaping ([Float]) -> Void) {
        guard FileManager.default.fileExists(atPath: url.path) || url.scheme != nil else {
            DispatchQueue.main.async {
                completion(generateDefaultAmplitudes(count: sampleCount))
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let asset = AVAsset(url: url)
                guard let track = asset.tracks(withMediaType: .audio).first else {
                    DispatchQueue.main.async {
                        completion(generateDefaultAmplitudes(count: sampleCount))
                    }
                    return
                }

                let reader = try AVAssetReader(asset: asset)
                let outputSettings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatLinearPCM,
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVLinearPCMBitDepthKey: 16,
                    AVLinearPCMIsBigEndianKey: false,
                    AVLinearPCMIsFloatKey: false,
                    AVLinearPCMIsNonInterleaved: false
                ]

                let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
                reader.add(trackOutput)

                guard reader.startReading() else {
                    DispatchQueue.main.async {
                        completion(generateDefaultAmplitudes(count: sampleCount))
                    }
                    return
                }

                var amplitudes: [Float] = []

                while reader.status == .reading {
                    autoreleasepool {
                        if let sampleBuffer = trackOutput.copyNextSampleBuffer(),
                           let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
                            let bufferLength = CMBlockBufferGetDataLength(blockBuffer)
                            var data = Data(count: bufferLength)

                            data.withUnsafeMutableBytes { bytes in
                                CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: bufferLength, destination: bytes.bindMemory(to: UInt8.self).baseAddress!)
                            }

                            let samples = data.withUnsafeBytes { bytes in
                                bytes.bindMemory(to: Int16.self).map { abs(Float($0)) / Float(Int16.max) }
                            }

                            amplitudes.append(contentsOf: samples)
                        }
                    }
                }

                let finalAmplitudes = downsample(amplitudes: amplitudes, to: sampleCount)
                DispatchQueue.main.async {
                    completion(finalAmplitudes)
                }
            } catch {
                print("Error processing audio: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(generateDefaultAmplitudes(count: sampleCount))
                }
            }
        }
    }

    private static func downsample(amplitudes: [Float], to sampleCount: Int) -> [Float] {
        guard !amplitudes.isEmpty else {
            return generateDefaultAmplitudes(count: sampleCount)
        }

        if amplitudes.count <= sampleCount {
            let padding = Array(repeating: Float(0.2), count: sampleCount - amplitudes.count)
            return amplitudes + padding
        }

        let step = amplitudes.count / sampleCount
        var downsampled: [Float] = []

        for i in 0..<sampleCount {
            let start = i * step
            let end = min(start + step, amplitudes.count)
            let slice = amplitudes[start..<end]
            let rms = sqrt(slice.reduce(0) { $0 + $1 * $1 } / Float(slice.count))
            downsampled.append(max(0.1, min(1.0, rms)))
        }

        return downsampled
    }

    static func generateDefaultAmplitudes(count: Int) -> [Float] {
        return (0..<count).map { i in
            let n = Float(i) / Float(max(1, count - 1))
            return 0.2 + 0.3 * sin(n * 4 * .pi) * sin(n * 2 * .pi)
        }
    }
}
