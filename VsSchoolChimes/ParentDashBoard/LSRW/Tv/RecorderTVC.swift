//
//  RecorderTVC.swift
//  School Chimes
//
//  Created by Chandhru on 09/07/25.
//

import UIKit

@available(iOS 15.0, *)
class RecorderTVC: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var vicecImg: UIImageView!
    @IBOutlet weak var waveView: AudioView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var outerplayerView: UIView!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var recoderTime: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    // MARK: - Properties
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private var isRecording = false
    var playVoiceActive = false
    private let audioManager = AudioManager()
    var audioURLString: String?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        stopAllAudioActions()
        if let urlStr = audioURLString, let audioURL = URL(string: urlStr) {
            audioManager.setupPlayer(with: audioURL)
        }
    }

    private func stopAllAudioActions() {
        audioManager.stopPlayback()
        audioManager.stopRecording { _, _ in }
        audioManager.invalidateTimer()
        recordingTimer?.invalidate()
        recordingTimer = nil
        UIApplication.shared.isIdleTimerDisabled = false
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
        
        getCurrentViewController()?.present(alert, animated: true)
    }

    // MARK: - Actions
    @IBAction private func recorderTapped(_ sender: UIButton) {
        isRecording ? stopRecording() : startRecording()
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

    @objc private func updateRecordingTime() {
        guard let startTime = recordingStartTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        if elapsed >= 180 {
            stopRecording()
            timerLbl.text = "03:00"
        } else {
            timerLbl.text = formatTime(elapsed)
        }
    }

    @IBAction private func deleteAudio(_ sender: UIButton) {
        audioManager.deleteRecording()
        outerplayerView.isHidden = true
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
    
    // MARK: - Time Formatting
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    // MARK: - Helper
    private func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topMostViewController()
    }
}

// MARK: - AudioManagerDelegate
@available(iOS 15.0, *)
extension RecorderTVC: AudioManagerDelegate {
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
