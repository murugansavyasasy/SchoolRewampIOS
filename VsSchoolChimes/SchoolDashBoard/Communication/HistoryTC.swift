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
    
    var audioPlayUrl = "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/voice/2025-03-29/4351/VS_1743239103551.wav"
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var updateTimer: Timer?
    var isPlaying = false
    var totalsecont = "03:00"
    var lastPlayingduration = "00:00"
    var delegate: reloadDelegate?
    var ForwordDelegate : ForwordDelegate?
    @IBOutlet weak var NewImageView: UIView!
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
    var playIndex: Int? = nil
    weak var FinishPlayingdelegate: HistoryFinishPalyingDelegate?
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
        
        playerView.isHidden = true
        totaltime.isHidden = true
        NewImageView.isHidden = true
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
    
    func setupPlayer(with url: URL) {
        player = AVPlayer(url: url)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    @IBAction func play(_ sender: UIButton) {
        sender.isSelected.toggle()
               delegate?.reload(index: sender.tag)
    }
    
    func updatePlayState(isPlaying: Bool, url: String?) {
            if isPlaying {
                guard let urlString = url, let audioURL = URL(string: urlString) else { return }

                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch {
                    print("Audio session error: \(error.localizedDescription)")
                }

                playerItem = AVPlayerItem(url: audioURL)
                player = AVPlayer(playerItem: playerItem)
                player?.volume = 1.0
                player?.play()

                playBtn.setImage(ImageName.pausebutton, for: .normal)

                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(playerDidFinishPlaying),
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: player?.currentItem
                )

                updateTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                   target: self,
                                                   selector: #selector(updateSlider),
                                                   userInfo: nil,
                                                   repeats: true)
                updateTimeDisplay()
            } else {
                player?.pause()
                playBtn.setImage(ImageName.playbutton, for: .normal)
                updateTimer?.invalidate()
                updateTimeDisplay()
            }

            self.isPlaying = isPlaying
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
            return String(format: "%02d:%02d", minutes, seconds)
        }

    func configureShimmer() {
        outerview.removeShimmer()
        datelbl.removeShimmer()
        contentlbl.removeShimmer()
        PlayerFullview.removeShimmer()
        playBtn.removeShimmer()

        NewImageView.isHidden = false
        totaltime.isHidden = false
        playerView.isHidden = false
    }
    @IBAction func forword(_ sender: UIButton) {
        ForwordDelegate?.voiceforword(selectedIndex: sender.tag)
    }
    
}

