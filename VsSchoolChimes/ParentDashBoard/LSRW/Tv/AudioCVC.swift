//
//  AudioCVC.swift
//  School Chimes
//
//  Created by Chandhru on 18/08/25.
//

import UIKit

// MARK: - Protocol for managing audio playback across cells
@available(iOS 15.0, *)
protocol AudioPlaybackDelegate: AnyObject {
    func audioCell(_ cell: AudioCVC, willStartPlayingAtIndex index: Int)
    func audioCell(_ cell: AudioCVC, didStopPlayingAtIndex index: Int)
}

@available(iOS 15.0, *)
class AudioCVC: UICollectionViewCell {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var waveView: AudioMessageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var TrashIcon: UIButton!
    
    var delegate: DeleteImge?
    weak var audioDelegate: AudioPlaybackDelegate?
    var cellIndex: Int = 0
    
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
        setupUI()
        setupNotifications()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopPlayback()
        audioURL = nil
        cellIndex = 0
        audioDelegate = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        TrashIcon.layer.cornerRadius = TrashIcon.frame.width/2
        TrashIcon.layer.borderWidth = 1
        TrashIcon.layer.borderColor = UIColor.red.cgColor
        playerView.setShadow(cornerRadius: 10)
        
        // Set initial play button state
        updatePlayButtonState(isPlaying: false)
    }
    
    private func setupNotifications() {
        // Listen for notifications to stop playback when other cells start playing
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(otherAudioStartedPlaying(_:)),
            name: NSNotification.Name("AudioCellStartedPlaying"),
            object: nil
        )
    }
    
    @objc private func otherAudioStartedPlaying(_ notification: Notification) {
        guard let playingCellIndex = notification.object as? Int,
              playingCellIndex != cellIndex else { return }
        
        // Stop this cell's playback if another cell started playing
        stopPlayback()
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
        if waveView.isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        // Notify other cells to stop playing
        NotificationCenter.default.post(
            name: NSNotification.Name("AudioCellStartedPlaying"),
            object: cellIndex
        )
        
        // Notify delegate
        audioDelegate?.audioCell(self, willStartPlayingAtIndex: cellIndex)
        
        // Start playback
        waveView.isPlaying = true
        waveView.startPlaybackAnimation()
        updatePlayButtonState(isPlaying: true)
    }
    
    func stopPlayback() {
        playBtn.setImage(UIImage(named: "play-button"), for: .normal)
        waveView.isPlaying = false
        waveView.stopPlaybackAnimation()
        updatePlayButtonState(isPlaying: false)
        
        // Notify delegate
        audioDelegate?.audioCell(self, didStopPlayingAtIndex: cellIndex)
    }
    
    private func updatePlayButtonState(isPlaying: Bool) {
        playBtn.isSelected = isPlaying
        let imageName = isPlaying ? "pause-button" : "play-button"
        playBtn.setImage(UIImage(named: imageName), for: .normal)
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
    
    @IBAction func deleteImg(_ sender: UIButton) {
        delegate?.deleteImage(index: sender.tag)
    }
}

