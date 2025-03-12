//
//  ParentHWImagePdfVoiceTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 08/11/23.
//  Copyright © 2023 Gayathri. All rights reserved.
//

import UIKit
import AVFAudio
import AVFoundation
import KRProgressHUD
import WebKit



class ParentHWImagePdfVoiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fullView: UIViewX!
    @IBOutlet weak var secondsTimeLabel1: UILabel!
    @IBOutlet weak var durationLbl1: UILabel!
    
    @IBOutlet weak var webView2: WKWebView!
    
    @IBOutlet weak var img3: UIImageView!
    
    
    @IBOutlet weak var img1: UIImageView!
    
    @IBOutlet weak var img2: UIImageView!
    
    
    @IBOutlet weak var webView1: WKWebView!
    @IBOutlet weak var btnName: UIButton!
    
    @IBOutlet weak var pdfViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var secondsTimeLabel: UILabel!
    @IBOutlet weak var subNameLbl: UILabel!
    @IBOutlet weak var image4View: UIViewX!
    
    @IBOutlet weak var voiceViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imgView: UIView!
    
    @IBOutlet weak var pdfView: UIView!
    @IBOutlet weak var voiceView: UIView!
    
    @IBOutlet weak var playView: UIView!
    
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var contentLbl: UILabel!
    
    @IBOutlet weak var topicLbl: UILabel!
    
    @IBOutlet weak var image3View: UIViewX!
    
    @IBOutlet weak var image2View: UIViewX!
    
    @IBOutlet weak var playbackSlider: UISlider!
    var audioFileURL: String!
    
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var durationLable : String!
    var secondsLabel  : String!
    
    var strPlayStatus : NSString = ""
    
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    //        weak var playbackSlider: UISlider?
    var timer = Timer()
    var time : Float64 = 0;
    var sliderIndex : NSInteger = NSInteger()
    var strFilePath : String = String()
    
    var messageId : String!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        secondsTimeLabel1.text = "00:00"
        //        secondsTimeLabel.text = "00:00"
        // Initialization code
        
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @objc func updateSlider1(){
        //
        
        if let audioURL = URL(string: audioFileURL) {
            getAudioDuration(from: audioURL) { [self] duration in
                if let duration = duration {
                    print("Audio duration: \(duration) seconds")
                    
                    time = duration
                    //
                    if(time > 0){
                        let minutes = Int(time) / 60 % 60
                        let secondss = Int(time) % 60
                        
                        let durationFormat = String(format:"%02i:%02i", minutes, secondss)
                        print("durationFormat",durationFormat)
                        durationLbl1.text = "/" + durationFormat
                        //
                    }
                } else {
                    print("Unable to determine audio duration.")
                }
            }
        } else {
            print("Invalid audio URL.")
        }
        
    }
    
    
    
    
    @IBAction func btnAction(_ sender: UIButton) {
        print("audioFileURL",audioFileURL)
        
        let audioUrl = URL(string: audioFileURL)
        //                            "https://voicesnap-school-files.s3.ap-south-1.amazonaws.com/VS_1700114970178.wav")
        
        
        
        getAudioDuration(from: audioUrl!) { [self] duration in
            if let duration = duration {
                print("Audio duration: \(duration) seconds")
                
                time = duration
                //
                if(time > 0){
                    let minutes = Int(time) / 60 % 60
                    let secondss = Int(time) % 60
                    
                    let durationFormat = String(format:"%02i:%02i", minutes, secondss)
                    print("durationFormat",durationFormat)
                    durationLbl1.text = "/" + durationFormat
                    //
                }
            } else {
                print("Unable to determine audio duration.")
            }
            
        }
        //
        var urls = URL(string: audioFileURL)
        
        playerItem = AVPlayerItem(url: urls!)
        player = AVPlayer(playerItem: playerItem!)
        if self.player!.currentItem?.status == .readyToPlay{
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player!.currentItem)
        if(btnName.isSelected)
        {
            btnName.isSelected = false
            let seconds1 : Int64 = Int64(playbackSlider.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            //  print("pause AudioSlider:\(seconds1)")
            player!.seek(to: targetTime)
            strPlayStatus = "play"
            player?.pause()
            
            btnName.setImage(UIImage(named: "hwPlay"), for: .normal)
            //  timer.invalidate()
            
            print("start")
        }else{
            btnName.isSelected = true
            let seconds1 : Int64 = Int64(playbackSlider.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            player!.seek(to: targetTime)
            // print("play AudioSlider:\(seconds1)")
            strPlayStatus = "play"
            player?.volume = 1
            player?.play()
            btnName.setImage(UIImage(named: "hwPauses"), for: .normal)
            createAndDownloadFile(fileNameUrl : audioFileURL)
            print("enddddd")
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
        
        
        
        do {        let str = try String(contentsOfFile: audioFileURL)
            print("lllllllll")    }
        
        catch {        print("The file could not be loaded : \(error)")    }
        
        
        
        
    }
    
    
    
    
    
    
    
    @objc func updateSlider(){
        if self.player!.currentItem?.status == .readyToPlay {
            
            time = CMTimeGetSeconds(self.player!.currentTime())
        }
        let duration : CMTime = playerItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        playbackSlider.maximumValue = Float(seconds)
        playbackSlider.minimumValue = 0.0
        playbackSlider.value = Float(time)
        
        if(time > 0){
            let minutes = Int(time) / 60 % 60
            let secondss = Int(time) % 60
            
            let durationFormat = String(format:"%02i:%02i", minutes, secondss)
            secondsTimeLabel1.text = durationFormat
            //
        }
        if(time == seconds){
            timer.invalidate()
            btnName.isSelected = false
            playbackSlider.value = 0.0
        }
    }
    func playbackSliderValueChanged(playbackSliders:UISlider){
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime : CMTime = CMTimeMake(value: seconds, timescale: 1)
        if(player != nil){
            player!.seek(to: targetTime)
        }else{
            playbackSlider.value = playbackSliders.value
        }
    }
    
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        timer.invalidate()
        playbackSlider.value = 0.0
        player?.pause()
        btnName.isSelected = false
        playerItem?.seek(to: CMTime.zero)
        secondsTimeLabel1.text = "00:00"
        btnName.setImage(UIImage(named: "hwPlay"), for: .normal)
    }
    
    
    
    
    func createAndDownloadFile(fileNameUrl : String) {
        
        KRProgressHUD.show()
        
        let strFilePath : String =  String(describing: fileNameUrl)
        
        let audioUrl = URL(string: strFilePath)
        
        if let audioUrl = URL(string: strFilePath) {
            
            
            let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
            
            let strpath = String(describing: messageId) + ".wav"
            //  print(strpath)
            let destinationUrl = documentsUrl.appendingPathComponent(strpath)
            
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                KRProgressHUD.dismiss()
                
            } else {
                
                
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                
                let request = URLRequest(url:audioUrl)
                
                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        // Success
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            KRProgressHUD.dismiss()
                            print("Successfully downloaded. Status code: \(statusCode)")
                            
                            
                        }
                        
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl, to: destinationUrl)
                            print("Success",tempLocalUrl)
                            print("Success1",destinationUrl)
                            
                            
                        } catch (let writeError) {
                            KRProgressHUD.dismiss()
                            print("Error creating a file \(destinationUrl) : \(writeError)")
                        }
                        
                    } else {
                        KRProgressHUD.dismiss()
                        print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
                    }
                }
                task.resume()
                
                
                
                
            }
        }
        
    }
    
    
    
    func showToast(message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        
        
        self.window?.rootViewController!.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    
    @objc func ordersFinishedPlaying( _ myNotification:NSNotification) {
        
        
        
        let selectedTime: CMTime = CMTimeMake(value: Int64(0 * 1000 as Float64), timescale: 1000)
        
        player?.seek(to: selectedTime)
        
        
        btnName.setImage(UIImage(named: "hwPlay"), for: .normal)
        print("Player finished")
        
        
        
    }
    
    func getAudioDuration(from url: URL, completion: @escaping (TimeInterval?) -> Void) {
        let asset = AVURLAsset(url: url)
        
        let duration = asset.duration.seconds
        if duration.isFinite {
            completion(duration)
        } else {
            completion(nil)
        }
    }
    
    
}
