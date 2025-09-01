//
//  CommunicationTVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/08/25.
//

import UIKit
@available(iOS 15.0, *)
protocol AudioPlaybackDelegate1: AnyObject {
    func audioCell(_ cell: CommunicationTVC, willStartPlayingAtIndex index: Int)
    func audioCell(_ cell: CommunicationTVC, didStopPlayingAtIndex index: Int)
}
@available(iOS 15.0, *)
class CommunicationTVC: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var waveView: AudioMessageView!
    @IBOutlet weak var playerView: UIView!
    // MARK: - Delegates
    var delegate: DeleteImge?
    weak var audioDelegate: AudioPlaybackDelegate1?

    // MARK: - Properties
    var cellIndex: Int = 0
    private let audioManager = AudioManager()

    var audioURL: URL? {
        
        didSet {
            guard let url = audioURL else { return }
            if url.isFileURL {
                // Local file
                prepareLocalAudio(url: url)
            } else {
                // Remote file
                downloadAndPrepareAudio(from: url)
            }
        }
    }

    // MARK: - Lifecycle
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

    // MARK: - Setup
    private func setupUI() {
        playerView.layer.cornerRadius = 8
        playerView.layer.borderWidth = 0.6
        playerView.layer.borderColor = UIColor.systemGray6.cgColor
        outerView.setShadow(cornerRadius: 10)
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

    // MARK: - Audio Setup
    private func prepareLocalAudio(url: URL) {
        do {
            try audioManager.setupPlayer(with: url)
            waveView.audioURL = url
        } catch {
            print("❌ Failed to set up audio player:", error)
            showErrorAlert(message: "Failed to load audio file")
        }
    }

    private func downloadAndPrepareAudio(from remoteURL: URL) {
        URLSession.shared.downloadTask(with: remoteURL) { [weak self] (tempURL, _, error) in
            guard let self = self else { return }
            if let tempURL = tempURL {
                self.prepareLocalAudio(url: tempURL)
            } else {
                print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Audio download failed.")
                }
            }
        }.resume()
    }

    // MARK: - Notifications
    @objc private func otherAudioStartedPlaying(_ notification: Notification) {
        guard let playingCellIndex = notification.object as? Int,
              playingCellIndex != cellIndex else { return }
        stopPlayback()
    }

    // MARK: - Actions
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
        audioManager.stop()
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

    // MARK: - Error Handling
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
