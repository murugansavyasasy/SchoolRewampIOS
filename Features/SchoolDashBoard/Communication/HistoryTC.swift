//
//  HistoryTC.swift
//
//
//  Created by admin on 13/11/24.
//

import UIKit
import AVFoundation
import AVFAudio

protocol ForwordDelegate{
    func voiceforword(selectedIndex:Int?)
}
protocol HistoryFinishPalyingDelegate: AnyObject {
    func didFinishPlaying(at index: Int)
}
class HistoryTC: UITableViewCell {
    
    var audioPlayUrl = ""
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var updateTimer: Timer?
    var isPlaying = false
    var totalsecont = "00:00"
    var lastPlayingduration = "00:00"
    var delegate: reloadDelegate?
    var ForwordDelegate : ForwordDelegate?
    @IBOutlet weak var NewImageView: UIImageView!
    @IBOutlet weak var PlayerFullview: ShimmerView2!
    @IBOutlet weak var sentBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var sentBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var datelbl: ShimmerLabel!
    @IBOutlet weak var contentlbl: ShimmerLabel!
    @IBOutlet weak var totaltime: UILabel!
    @IBOutlet weak var playBtn: ShimmerButton!
    @IBOutlet weak var playerView: WaveView!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var outerview: ShimmerView2!
    @IBOutlet weak var emergencyMessageBtn: UIButton!
    
    var playIndex: Int? = nil
    weak var FinishPlayingdelegate: HistoryFinishPalyingDelegate?
    var messageId: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outerview.layer.shadowColor = UIColor.black.cgColor
        outerview.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerview.layer.shadowRadius = 5
        outerview.layer.shadowOpacity = 0.3
        outerview.layer.cornerRadius = 20
        sendbtn.layer.cornerRadius = 4
        datelbl.setFont(style: .body, size: FontSize.BodySize)
        contentlbl.setFont(style: .title, size: FontSize.TitleSize)
        totaltime.setFont(style: .body, size: FontSize.BodySize)
        emergencyMessageBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        emergencyMessageBtn.isHidden = true
        playerView.isHidden = true
        totaltime.isHidden = true
        sendbtn.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Assuming 'myLabel' is your UILabel
        configureShimmer()
    }
    
    deinit {
        updateTimer?.invalidate()
        updateTimer = nil
        player?.pause()
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Invalidate timer if it's active
        updateTimer?.invalidate()
        updateTimer = nil
        // Reset player and wave view state
        player?.pause()
        player = nil
        playerItem = nil
        isPlaying = false
        // Reset UI: hide wave view and total time until intentionally set
        playerView.progress = 0.0
        playerView.isHidden = true
        totaltime.isHidden = true
        // Optionally reset button image to default play
        playBtn.setImage(ImageName.playbutton, for: .normal)
    }
    
    
    
    @IBAction func play(_ sender: UIButton) {
        sender.isSelected.toggle()
        delegate?.reload(index: sender.tag)
    }
    
    func updatePlayState(isPlaying: Bool, url: String?) {
        self.isPlaying = isPlaying
        if isPlaying {
            if player == nil {
                guard let urlString = url,
                      let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let audioURL = URL(string: encodedURLString) else { return }
                playerItem = AVPlayerItem(url: audioURL)
                player = AVPlayer(playerItem: playerItem)
                // Observe playback finished
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(playerDidFinishPlaying),
                                                       name: .AVPlayerItemDidPlayToEndTime,
                                                       object: playerItem)}
            player?.play()
            playBtn.setImage(ImageName.pausebutton, for: .normal)
            
            // Start timer
            updateTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                               target: self,
                                               selector: #selector(updateSlider),
                                               userInfo: nil,
                                               repeats: true)
            updateTimeDisplay()
            
        } else {
            player?.pause()
            playerView.updateWithLevel(0.0)
            playBtn.setImage(ImageName.playbutton, for: .normal)
            updateTimer?.invalidate()
            updateTimer = nil
            updateTimeDisplay()
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player?.currentItem?.status == .failed {
                print("Playback failed: \(String(describing: player?.currentItem?.error))")
            }
        }
    }
    @objc func updateSlider() {
        guard let audioPlayer = player, let currentItem = audioPlayer.currentItem else { return }
        let totalDuration = CMTimeGetSeconds(currentItem.duration)
        let elapsedTime = CMTimeGetSeconds(audioPlayer.currentTime())
        guard totalDuration.isFinite && elapsedTime.isFinite else { return }
        let currentFormatted = formatTime(elapsedTime)
        let totalFormatted = formatTime(totalDuration)
        lastPlayingduration = currentFormatted
        totaltime.text = "\(currentFormatted) / \(totalFormatted)"
        let progress = CGFloat(elapsedTime / totalDuration)
        playerView.progress = progress
        playerView.updateWithLevel(CGFloat(sin(progress * .pi)))
        playerView.setNeedsDisplay()
    }
    
    @objc func playerDidFinishPlaying() {
        playBtn.setImage(ImageName.playbutton, for: .normal)
        isPlaying = false
        playerView.progress = 1.0
        playerView.updateWithLevel(0.0)
        playerView.setNeedsDisplay()
        FinishPlayingdelegate?.didFinishPlaying(at: playBtn.tag)
        player?.seek(to: .zero)
    }
    
    private func updateTimeDisplay() {
        guard let currentItem = player?.currentItem,
              let currentTime = player?.currentTime() else { return }
        let totalDuration = CMTimeGetSeconds(currentItem.duration)
        let elapsedTime = CMTimeGetSeconds(currentTime)
        if totalDuration.isFinite && elapsedTime.isFinite {
            let currentFormatted = formatTime(elapsedTime)
            let totalFormatted = formatTime(totalDuration)
            totalsecont = totalFormatted
            totaltime.text = "\(currentFormatted) / \(totalFormatted)"
        } else {
            let currentFormatted = formatTime(elapsedTime)
            totaltime.text = "\(currentFormatted) / \(totalsecont)"
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: CommonStringFile.Time_formate, minutes, seconds)
    }
    
    func configureShimmer() {
        outerview.removeShimmer()
        datelbl.removeShimmer()
        contentlbl.removeShimmer()
        PlayerFullview.removeShimmer()
        playBtn.removeShimmer()
        totaltime.isHidden = false
        playerView.isHidden = false
        sendbtn.isHidden = false
    }
    @IBAction func forword(_ sender: UIButton) {
        ForwordDelegate?.voiceforword(selectedIndex: sender.tag)
    }
    
    func forceStopAndReset() {
        player?.pause()
        player = nil
        playerItem = nil
        updateTimer?.invalidate()
        updateTimer = nil
        isPlaying = false
        // Reset UI
        playBtn.setImage(ImageName.playbutton, for: .normal)
        totaltime.text = "00:00 / 00:00"
        playerView.progress = 0.0
        playerView.updateWithLevel(0.0)
        playerView.setNeedsDisplay()
    }
    
    func updatePlayState(isPlaying: Bool, url: String?, messageId: String) {
        self.messageId = messageId
        if isPlaying, let url = url {
            AudioPlaybackManager.shared.play(url: url, messageId: messageId)
            playBtn.setImage(ImageName.pausebutton, for: .normal)
        } else {
            AudioPlaybackManager.shared.pause()
            playBtn.setImage(ImageName.playbutton, for: .normal)
        }
    }
    func stopAudioPlay_back() {
        if let id = messageId, AudioPlaybackManager.shared.currentMessageId == id {
            AudioPlaybackManager.shared.stop()
        }
    }
}

extension HistoryTC {
    func stopAudioPlayback() {
        // Pause the player and invalidate timer
        player?.pause()
        updateTimer?.invalidate()
        updateTimer = nil
        isPlaying = false
        // Reset UI to show the play button instead of pause
        playBtn.setImage(ImageName.playbutton, for: .normal)
        // Optionally, reset the progress and time labels
        playerView.progress = 0.0
        totaltime.text = "00:00 / \(totalsecont)"
    }
}


import AVFoundation

class AudioPlaybackManager {
    static let shared = AudioPlaybackManager()
    private var player: AVPlayer?
    private(set) var currentMessageId: String?
    func play(url: String, messageId: String) {
        if currentMessageId != messageId {
            // New audio, reset player
            player = AVPlayer(url: URL(string: url)!)
            currentMessageId = messageId
        }
        player?.play()
    }
    func pause() {
        player?.pause()
    }
    func stop() {
        player?.pause()
        player = nil
        currentMessageId = nil
    }
    func currentTime() -> CMTime? {
        return player?.currentTime()
    }
    
    func seek(to time: CMTime) {
        player?.seek(to: time)
    }
    
    func isPlaying(messageId: String) -> Bool {
        return currentMessageId == messageId && player?.rate != 0
    }
}
