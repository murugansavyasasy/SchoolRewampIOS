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
protocol selectedAudio : AnyObject{
    func selectedAudio(index:Int)
}
@available(iOS 15.0, *)
class CommunicationTVC: UITableViewCell {

    @IBOutlet weak var selectBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var selectBtnName: UIButton!
    @IBOutlet weak var runningDurationLbl: UILabel!
    @IBOutlet weak var tottalDurationLbl: UILabel!
    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var emergencyBtnName: UIButton!
    // MARK: - Outlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var waveView: AudioMessageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var PostedByLbl: UILabel!
    
    
    // MARK: - Delegates
    var delegate: DeleteImge?
    weak var audioDelegate: AudioPlaybackDelegate1?
   weak var selectedAudioDelegate: selectedAudio?
    // MARK: - Properties
    var cellIndex: Int = 0
    private let audioManager = AudioManager()

    var audioURL: URL? {
        didSet {
            guard let url = audioURL else { return }
//            if url.isFileURL {
                // Local file
                prepareLocalAudio(url: url)
//            } else {
//                // Remote file
//                downloadAndPrepareAudio(from: url)
//            }
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupNotifications()
    }

//    override func prepareForReuse() {
//        super.prepareForReuse()
//        stopPlayback()
//        audioURL = nil
//        cellIndex = 0
//        audioDelegate = nil
//    }
    override func prepareForReuse() {
        super.prepareForReuse()
        stopPlayback()
        audioManager.stop()
        waveView.reset()
        waveView.audioURL = nil
        runningDurationLbl.text = "00:00"
        tottalDurationLbl.text = "00:00"
        playBtn.isSelected = false
        playBtn.isEnabled = true
        newImageView.isHidden = true
        emergencyBtnName.isHidden = true
        selectBtnName.isHidden = true
        selectBtnHeight.constant = 0
        audioDelegate = nil
        selectedAudioDelegate = nil
        cellIndex = -1
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupUI() {
        outerView.setShadow(cornerRadius: 10)
        selectBtnName.layer.cornerRadius = 4
        updatePlayButtonState(isPlaying: false)
        dateLbl.setFont(style: .body, size: FontSize.BodySize)
        tittleLbl.setFont(style: .title, size: FontSize.TitleSize)
        PostedByLbl.setFont(style: .body, size: FontSize.BodySize)
        PostedByLbl.isHidden = true
    }

    @IBAction func selectBtnAct(_ sender: UIButton) {
        selectedAudioDelegate?.selectedAudio(index: sender.tag)
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
            showErrorAlert(message: "Failed to load audio file")
        }
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
                    self.waveView.onDurationUpdate = { [weak self] time in
                        self?.runningDurationLbl.text = time
                    }
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
