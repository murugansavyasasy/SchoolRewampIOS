//
//  HistoryTC.swift
//
//
//  Created by admin on 13/11/24.
//

import UIKit
import AVFoundation
import UniformTypeIdentifiers
import AVFAudio

class HistoryTC: UITableViewCell {
    var AudioPlayUrl = "http://vs5.voicesnapforschools.com/nodejs/voice/VS_1718181818812.wav"
    var player: AVPlayer?
    var updateTimer: Timer?
    var isPlaying = false
    var totalsecont = "03.00"
    var lastPlayingduration = "00:00"
    var audioRecorder: AVAudioRecorder?
    var playerItem : AVPlayerItem?
    var delegate : reloadDelegate?
    @IBOutlet weak var sentBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var sentBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var contentlbl: UILabel!
    @IBOutlet weak var totaltime: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var playerView: WaveView!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var outerview: UIView!
    var audioURL: String = "https://www.learningcontainer.com/wp-content/uploads/2020/02/Sample-OGG-File.ogg"
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
        
    }
    func setupPlayer(with url: URL) {
        player = AVPlayer(url: url)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    @IBAction func play(_ sender: UIButton) {
        sender.isSelected.toggle()
        let play = sender.isSelected
        delegate?.reload(index: sender.tag)
    }
    
    @objc func playerDidFinishPlaying() {
        playBtn.setImage(ImageName.playbutton, for: .normal)
        isPlaying = false
        audioRecorder?.updateMeters()
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160 // Default to -160 if no data
        let normalizedPower = max(0, (averagePower + 160) / 160)
        playerView.updateWithLevel(CGFloat(normalizedPower))
    }
    func updatePlayState(isPlaying: Bool, url: String?) {
        if isPlaying {
            if let audioUrl = URL(string: url ?? "") {
                playerItem = AVPlayerItem(url: audioUrl)
                player = AVPlayer(playerItem: playerItem)
            }
            
            // Start playback
            player?.volume = 1
            player?.play()
            playBtn.setImage(ImageName.pausebutton, for: .normal)
            updateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
            // Update player view
            updateAudioLevels(int: 1)
            
            // Update time
            if let currentItem = player?.currentItem, let currentTime = player?.currentTime() {
                let totalDuration = CMTimeGetSeconds(currentItem.duration)
                let elapsedTime = CMTimeGetSeconds(currentTime)
                
                if totalDuration.isFinite && elapsedTime.isFinite {
                    let totalDurationFormatted = formatTime(totalDuration)
                    let currentFormatted = formatTime(elapsedTime)
                    totalsecont = totalDurationFormatted
                    totaltime.text = "\(currentFormatted) / \(totalDurationFormatted)"
                }
                else {
                    let currentFormatted = formatTime(elapsedTime)
                    totaltime.text = "\(currentFormatted) /\(totalsecont)" // Default if time is unavailable
                }
            }
        } else {
            // Pause playback
            player?.pause()
            playBtn.setImage(ImageName.playbutton, for: .normal)
            updateAudioLevels(int: 0)
            // Update time
            if let currentItem = player?.currentItem, let currentTime = player?.currentTime() {
                let totalDuration = CMTimeGetSeconds(currentItem.duration)
                let elapsedTime = CMTimeGetSeconds(currentTime)
                
                if totalDuration.isFinite && elapsedTime.isFinite {
                    let totalDurationFormatted = formatTime(totalDuration)
                    let currentFormatted = formatTime(elapsedTime)
                    totalsecont = totalDurationFormatted
                    totaltime.text = "\(currentFormatted) / \(totalDurationFormatted)"
                }
                else {
                    let currentFormatted = formatTime(elapsedTime)
                    totaltime.text = "\(currentFormatted) /\(totalsecont)" // Default if time is unavailable
                }
            }
        }
        self.isPlaying = isPlaying
    }
//
    
    
//    func updatePlayState(isPlaying: Bool) {
//        if isPlaying {
//            if player == nil, let url = URL(string: audioURL) {
//                player = AVPlayer(url: url)
//            }
//            player?.play()
//            player?.volume = 1
//            playBtn.setImage(UIImage(named: "pausebutton"), for: .normal)
//        } else {
//            player?.pause()
//            updateAudioLevels(int: 0)
//            playBtn.setImage(UIImage(named: "playbutton"), for: .normal)
//        }
//    }
    
    // Helper to format time as mm:ss
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Helper to update audio levels
    private func updateAudioLevels(int:Float) {
        audioRecorder?.updateMeters()
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160 // Default to -160 if no data
        let normalizedPower = max(int, (averagePower + 160) / 160)
        playerView.updateWithLevel(CGFloat(normalizedPower))
    }
    
    
    @objc func updateSlider() {
        guard let audioPlayer = player else { return }
        
        if audioPlayer.isPlaying {
            if let currentItem = audioPlayer.currentItem {
                let totalDuration = CMTimeGetSeconds(currentItem.duration)
                if totalDuration.isFinite {
                    let totalMinutes = Int(totalDuration) / 60
                    let totalSeconds = Int(totalDuration) % 60
                    let totalDurationFormatted = String(format: "%02d:%02d", totalMinutes, totalSeconds)
                    // Get the current playback time
                    let elapsedTime = CMTimeGetSeconds(audioPlayer.currentTime())
                    let elapsedMinutes = Int(elapsedTime) / 60
                    let elapsedSeconds = Int(elapsedTime) % 60
                    let currentFormatted = String(format: "%02d:%02d", elapsedMinutes, elapsedSeconds)
                    lastPlayingduration = currentFormatted
                    // Update the label with current and total duration
                    totaltime.text = "\(lastPlayingduration) / \(totalDurationFormatted)"
                }
            }
        }
    }
}
