//
//  AudioCVC.swift
//  School Chimes
//
//  Created by Chandhru on 18/08/25.
//

import UIKit

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
                waveView.setupAudioUrl(url)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupNotifications()
        waveView.setParentCell(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopPlayback()
        audioURL = nil
        cellIndex = 0
        audioDelegate = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        waveView.setNeedsLayout()
        waveView.layoutIfNeeded()
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
        stopPlayback()
    }
    
    private func downloadAndPrepareAudio(from remoteURL: URL) {
        // Show loading state
        playBtn.isEnabled = false
        
        let session = URLSession.shared
        let task = session.downloadTask(with: remoteURL) { [weak self] (tempURL, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.playBtn.isEnabled = true
                    self.showErrorAlert(message: "Audio download failed.")
                }
                return
            }
            
            guard let tempURL = tempURL else {
                DispatchQueue.main.async {
                    self.playBtn.isEnabled = true
                    self.showErrorAlert(message: "Audio download failed.")
                }
                return
            }
            
            // Save to permanent location
            let permanentURL = self.saveToPermanentLocation(tempURL: tempURL, originalURL: remoteURL)
            
            DispatchQueue.main.async {
                self.playBtn.isEnabled = true
                if let url = permanentURL {
                    self.waveView.audioURL = url
                } else {
                    self.showErrorAlert(message: "Failed to save audio file")
                }
            }
        }
        task.resume()
    }
    
    private func saveToPermanentLocation(tempURL: URL, originalURL: URL) -> URL? {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFolderPath = documentsPath.appendingPathComponent("AudioFiles", isDirectory: true)
        
        // Create directory if needed
        if !fileManager.fileExists(atPath: audioFolderPath.path) {
            try? fileManager.createDirectory(at: audioFolderPath, withIntermediateDirectories: true)
        }
        
        // Generate unique filename
        let filename = originalURL.lastPathComponent.isEmpty ? UUID().uuidString + ".m4a" : originalURL.lastPathComponent
        let permanentURL = audioFolderPath.appendingPathComponent(filename)
        
        // Remove if already exists
        if fileManager.fileExists(atPath: permanentURL.path) {
            try? fileManager.removeItem(at: permanentURL)
        }
        do {
            try fileManager.copyItem(at: tempURL, to: permanentURL)
            print("✅ Audio saved to: \(permanentURL.path)")
            return permanentURL
        } catch {
            print("❌ Failed to save audio: \(error.localizedDescription)")
            return nil
        }
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        if waveView.isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    
    private func startPlayback() {
        // Check if audio is loaded
        guard waveView.audioURL != nil else {
            showErrorAlert(message: "Audio not loaded yet")
            return
        }
        NotificationCenter.default.post(
            name: NSNotification.Name("AudioCellStartedPlaying"),
            object: cellIndex
        )
        audioDelegate?.audioCell(self, willStartPlayingAtIndex: cellIndex)
        waveView.isPlaying = true
        waveView.startPlaybackAnimation()
        updatePlayButtonState(isPlaying: true)
    }
    
    func stopPlayback() {
        waveView.isPlaying = false
        waveView.stopPlaybackAnimation()
        updatePlayButtonState(isPlaying: false)
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
