//
//  HomeworkreportTV.swift
//  VsSchoolChimes
//
//  Created by Admin on 19/12/24.
//

import UIKit
import AVFoundation

class HomeworkreportTV: UITableViewCell {

    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var PlayerView: WaveView!
    @IBOutlet weak var DurationLbl: UILabel!
    @IBOutlet weak var PlayBtn: UIButton!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var HomeworkTitleLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    
    var AudioPlayUrl = "http://vs5.voicesnapforschools.com/nodejs/voice/VS_1718181818812.wav"
    var player: AVPlayer?
        var updateTimer: Timer?
        var isPlaying = false
    var totalsecont = "03.00"
    var lastPlayingduration = "00:00"
    var audioRecorder: AVAudioRecorder?
    var delegate : reloadDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOffset = CGSize(width: 0, height: 2)
        cellview.layer.shadowRadius = 5
        cellview.layer.shadowOpacity = 0.3
        cellview.layer.cornerRadius = 20
    
        HomeworkTitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        SubjectLbl.setFont(style: .title, size: FontSize.TitleSize)
        DurationLbl.setFont(style: .body, size: FontSize.BodySize)
        DateLbl.setFont(style: .body, size: FontSize.BodySize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupPlayer(with url: URL) {
        player = AVPlayer(url: url)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    @IBAction func PlayBtnAct(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        let play = sender.isSelected
        delegate?.reload(index: sender.tag)
    }
    
    @objc func playerDidFinishPlaying() {
        PlayBtn.setImage(ImageName.playbutton, for: .normal)
        isPlaying = false
        audioRecorder?.updateMeters()
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160 // Default to -160 if no data
        let normalizedPower = max(0, (averagePower + 160) / 160)
        PlayerView.updateWithLevel(CGFloat(normalizedPower))
    }
    func updatePlayState(isPlaying: Bool, url: String?) {
        if isPlaying {
            if player == nil {
                if let urlString = url, let url = URL(string: urlString) {
                    setupPlayer(with: url)
                } else if let fallbackURL = URL(string: "http://vs5.voicesnapforschools.com/nodejs/voice/VS_1718181818812.wav") {
                    setupPlayer(with: fallbackURL)
                }
            }
            
            // Start playback
            player?.volume = 1
            player?.play()
            PlayBtn.setImage(ImageName.pausebutton, for: .normal)
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
                    DurationLbl.text = "\(currentFormatted) / \(totalDurationFormatted)"
                }
                else {
                    let currentFormatted = formatTime(elapsedTime)
                    DurationLbl.text = "\(currentFormatted) /\(totalsecont)" // Default if time is unavailable
                }
            }
        } else {
            // Pause playback
            player?.pause()
            PlayBtn.setImage(ImageName.playbutton, for: .normal)
            updateAudioLevels(int: 0)
            // Update time
            if let currentItem = player?.currentItem, let currentTime = player?.currentTime() {
                let totalDuration = CMTimeGetSeconds(currentItem.duration)
                let elapsedTime = CMTimeGetSeconds(currentTime)
                
                if totalDuration.isFinite && elapsedTime.isFinite {
                    let totalDurationFormatted = formatTime(totalDuration)
                    let currentFormatted = formatTime(elapsedTime)
                    totalsecont = totalDurationFormatted
                    DurationLbl.text = "\(currentFormatted) / \(totalDurationFormatted)"
                }
                else {
                    let currentFormatted = formatTime(elapsedTime)
                    DurationLbl.text = "\(currentFormatted) /\(totalsecont)" // Default if time is unavailable
                }
            }
        }
        self.isPlaying = isPlaying
    }

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
        PlayerView.updateWithLevel(CGFloat(normalizedPower))
    }


    @objc func updateSlider() {
        guard let audioPlayer = player else { return }
        
        if audioPlayer.isPlaying {

            
            // Update playback time
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
                    DurationLbl.text = "\(lastPlayingduration) / \(totalDurationFormatted)"
                }
            }
        }else{
            var count = 0
            print(count += 1)
        }
    }
}
