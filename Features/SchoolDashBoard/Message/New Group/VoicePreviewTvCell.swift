//
//  VoicePreviewTvCell.swift
//  School Chimes
//
//  Created by apple on 29/12/25.
//

import UIKit
protocol AudioPlaybackDelegates: AnyObject {
    func audioCell(_ cell: VoicePreviewTvCell, willStartPlayingAtIndex index: Int)
    func audioCell(_ cell: VoicePreviewTvCell, didStopPlayingAtIndex index: Int)
}
class VoicePreviewTvCell: UITableViewCell {

    @IBOutlet weak var contentLbl: ShimmerLabel!
    @IBOutlet weak var NewImageView: UIImageView!
    @IBOutlet weak var PlayerFullview: ShimmerView2!
    @IBOutlet weak var datelbl: ShimmerLabel!
    @IBOutlet weak var totaltime: UILabel!
    @IBOutlet weak var playBtn: ShimmerButton!
    @IBOutlet weak var playerView: AudioMessageView!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var outerview: ShimmerView2!
    @IBOutlet weak var emergencyMessageBtn: UIButton!
    private let audioManager = AudioManager()
    weak var audioDelegate: AudioPlaybackDelegates?
    var cellIndex: Int = 0
    var audioURL: URL? {
        didSet {
            guard let url = audioURL else { return }
            // Check if it's a remote URL (http or https)
            if url.isFileURL {
                do {
                    try audioManager.setupPlayer(with: url)
                    playerView.audioURL = url
                } catch {
                    print("❌ Failed to set up audio player:", error)
                }
            } else {
                // Remote URL - download it first
                downloadAndPrepareAudio(from: url)
            }

        }
    }
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupNotifications()
        playerView.setParentCell(self)
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
        playerView.setNeedsLayout()
        playerView.layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        outerview.layer.shadowColor = UIColor.black.cgColor
        outerview.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerview.layer.shadowRadius = 5
        outerview.layer.shadowOpacity = 0.3
        outerview.layer.cornerRadius = 20
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
                    self.playerView.audioURL = url
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
    
}
extension VoicePreviewTvCell{
    
    func configureShimmer() {
        outerview.removeShimmer()
        datelbl.removeShimmer()
        contentLbl.removeShimmer()
        PlayerFullview.removeShimmer()
        playBtn.removeShimmer()
        totaltime.isHidden = false
        playerView.isHidden = false
        sendbtn.isHidden = false
    }


    @IBAction func playAudio(_ sender: UIButton) {
        if playerView.isPlaying {
            stopPlayback()
        } else {
           
            startPlayback()
        }
    }
    
    
    private func startPlayback() {
        // Check if audio is loaded
        guard playerView.audioURL != nil else {
            showErrorAlert(message: "Audio not loaded yet")
            return
        }
        NotificationCenter.default.post(
            name: NSNotification.Name("AudioCellStartedPlaying"),
            object: cellIndex
        )
        audioDelegate?.audioCell(self, willStartPlayingAtIndex: cellIndex)
        playerView.isPlaying = true
        playerView.startPlaybackAnimation()
        updatePlayButtonState(isPlaying: true)
    }
    
    func stopPlayback() {
        playerView.isPlaying = false
        playerView.stopPlaybackAnimation()
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
    
    
}
