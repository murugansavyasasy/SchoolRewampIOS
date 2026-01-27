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
//    private let audioManager = AudioManager()

    var audioURL: URL?{
        didSet {
            guard let url = audioURL else { return }
                waveView.audioURL = url
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupNotifications()
        waveView.setParentCell(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopPlayback()
//        audioManager.stop()
        waveView.reset()
        audioURL = nil
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

    
    private func saveToPermanentLocation(tempURL: URL, originalURL: URL) -> URL? {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFolderPath = documentsPath.appendingPathComponent("AudioFiles", isDirectory: true)
        
        // Create directory if needed
        if !fileManager.fileExists(atPath: audioFolderPath.path) {
            try? fileManager.createDirectory(at: audioFolderPath, withIntermediateDirectories: true)
        }
        let filename = originalURL.lastPathComponent.isEmpty ? UUID().uuidString + ".m4a" : originalURL.lastPathComponent
        let permanentURL = audioFolderPath.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: permanentURL.path) {
            try? fileManager.removeItem(at: permanentURL)
        }
        do {
            try fileManager.copyItem(at: tempURL, to: permanentURL)
            return permanentURL
        } catch {
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
        guard waveView.audioURL != nil else {
            showErrorAlert(message: "Audio not loaded yet")
            return
        }
        NotificationCenter.default.post(
            name: NSNotification.Name("AudioCellStartedPlaying"),
            object: cellIndex
        )
        audioDelegate?.audioCell(self, willStartPlayingAtIndex: cellIndex)
        self.waveView.onDurationUpdate = { [weak self] time in
            self?.runningDurationLbl.text = time
        }
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
