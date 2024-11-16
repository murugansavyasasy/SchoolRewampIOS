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
    var audioRecorder: AVAudioRecorder?
    var delegate : reloadDelegate?
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var contentlbl: UILabel!
    @IBOutlet weak var sendedTime: UILabel!
    @IBOutlet weak var totaltime: UILabel!
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var playerView: WaveView!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var outerview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        outerview.layer.shadowColor = UIColor.black.cgColor
        outerview.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerview.layer.shadowRadius = 5
        outerview.layer.shadowOpacity = 0.3
        outerview.layer.cornerRadius = 20
        sendbtn.layer.cornerRadius = 4
        
        //            setupWaveBars()
    }
    func setupPlayer(with url: URL) {
        player = AVPlayer(url: url)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    @IBAction func play(_ sender: UIButton) {
        delegate?.reload(index: sender.tag)
    }
    
    @objc func playerDidFinishPlaying() {
        playBtn.setImage(UIImage(named: "play-button"), for: .normal)
        isPlaying = false
        audioRecorder?.updateMeters()
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160 // Default to -160 if no data
        let normalizedPower = max(0, (averagePower + 160) / 160)
        playerView.updateWithLevel(CGFloat(normalizedPower))
    }
    
    func updatePlayState(isPlaying: Bool, url: String) {
        if isPlaying {
            if player == nil {
                setupPlayer(with: URL(string: url)!)
            }
            player?.volume = 1
            player?.play()
            playBtn.setImage(UIImage(named: "pause-button"), for: .normal)
            audioRecorder?.updateMeters()
            let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160 // Default to -160 if no data
            let normalizedPower = max(1, (averagePower + 160) / 160)
            playerView.updateWithLevel(CGFloat(normalizedPower))
        } else {
            player?.pause()
            playBtn.setImage(UIImage(named: "play-button"), for: .normal)
            audioRecorder?.updateMeters()
            let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160 // Default to -160 if no data
            let normalizedPower = max(0, (averagePower + 160) / 160)
            playerView.updateWithLevel(CGFloat(normalizedPower))
        }
        self.isPlaying = isPlaying
    }
    
}
