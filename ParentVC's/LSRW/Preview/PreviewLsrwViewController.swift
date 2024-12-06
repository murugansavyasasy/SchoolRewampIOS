//
//  PreviewLsrwViewController.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/21/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import AVFoundation
import WebKit
class PreviewLsrwViewController: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate,UITextViewDelegate{

    @IBOutlet weak var pdfView: UIView!
    
    @IBOutlet weak var pdfWebview: WKWebView!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var overallTimeLbl: UILabel!
    @IBOutlet weak var playView: UIView!
    
    @IBOutlet weak var plyImg: UIImageView!
    
    @IBOutlet weak var voiceHoleView: UIView!
    
    @IBOutlet weak var timeCountingLbl: UILabel!
    
    @IBOutlet weak var PlayVocieButton: UIButton!
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var imgView: UIView!
    
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var textView: UIView!
    
    
    @IBOutlet weak var backView: UIView!
    var attactType : String!
    var attactText : String!
    var videoId : String!
    var timer = Timer()
        var timeLabelForPlayVoice : String!
        var audioPlayer : AVAudioPlayer!
    var time : Float64 = 0;
        var isAudioRecordingGranted: Bool!
        var isRecording = false
        var isPlaying = false
    var strPlayStatus : NSString = ""
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var AudioPlayUrl : String!
    var audioRecorder    : AVAudioRecorder!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("attactType",attactType)
        if attactType == "TEXT" {
            textView.isHidden = false
            textLbl.isHidden = false
            textLbl.text = attactText
            
            
            
            voiceHoleView.isHidden = true
            imgView.isHidden = true
//            textView.isHidden = false
//            textLbl.isHidden = false
            pdfView.isHidden = true
            
            
            
        }else   if attactType == "IMAGE" {
            imgView.isHidden = false
//            img.isHidden = false
            pdfView.isHidden = true
            
            
            let pinch_gesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom_img))
            img.addGestureRecognizer(pinch_gesture)
            
            img.isUserInteractionEnabled = true
            
            self.img.sd_setImage(with: URL(string: attactText)!, placeholderImage: UIImage(named: "placeHolder.png"), options: SDWebImageOptions.refreshCached)
            voiceHoleView.isHidden = true
            textView.isHidden = true
            
        }else   if attactType == "PDF" {
            
            imgView.isHidden = true
//            img.isHidden = false
            
            let urlString = attactText!
            
            
            guard let url = URL(string: urlString) else {
                        return
                    }
                    
                    // Download and load the PDF
                    loadPDF(from: url)
//            guard let url = URL(string: urlString) else { return }
//                   
//                   // Load PDF into WKWebView
//                  
//            let requestObj = URLRequest(url: url)
//            pdfWebview.load(requestObj)
            
            pdfView.isHidden = false
            voiceHoleView.isHidden = true
            textView.isHidden = true
            
            
        }else   if attactType == "VOICE" {
            voiceHoleView.isHidden = false
//            sli.isHidden = false
            
            pdfView.isHidden = true
            AudioPlayUrl = attactText
            
            imgView.isHidden = true
            textView.isHidden = true
            
            
        }else   if attactType == "VIDEO" {
            pdfView.isHidden = false
                print("videoidbefore",videoId)
                let videoid = videoId
                print("videoid",videoid)
            if let yourVimeoLink = URL(string: "https://player.vimeo.com/video/\(videoid)")  {
                print("yourVimeoLink",yourVimeoLink)
                self.pdfWebview.backgroundColor = UIColor.black
                self.pdfWebview.isOpaque = false
                pdfWebview.contentMode = UIView.ContentMode.scaleToFill
                pdfWebview.load(URLRequest(url:yourVimeoLink))
                pdfWebview.contentMode = UIView.ContentMode.scaleToFill
            }
            
        }
        
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVc))
        backView.addGestureRecognizer(backGesture)
        
        // Do any additional setup after loading the view.
    }

func loadPDF(from url: URL) {
        // Create a URLSession data task to download the file
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to download file: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Save the PDF locally in the app's temporary directory
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.pdf")
            
            do {
                try data.write(to: tempURL)
                DispatchQueue.main.async {
                    // Load the PDF in the WKWebView
                    self.pdfWebview.loadFileURL(tempURL, allowingReadAccessTo: tempURL)
                }
            } catch {
                print("Error saving file locally: \(error)")
            }
        }
        
        task.resume()
    }
    
    @IBAction func playVoiceBtnAction(_ sender: UIButton) {
        
        audioRecorder = nil

        

        

        

        var urls = URL(string: AudioPlayUrl)

        

        playerItem = AVPlayerItem(url: urls!)

        player = AVPlayer(playerItem: playerItem!)

        

        if self.player!.currentItem?.status == .readyToPlay{

        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)),

                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,

                                               object: player!.currentItem)

        if(PlayVocieButton.isSelected)

        {

            PlayVocieButton.isSelected = false

            let seconds1 : Int64 = Int64(slider.value)

            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)

            

            player!.seek(to: targetTime)

            strPlayStatus = "PlayIcon"

            player?.pause()

            

            PlayVocieButton.setImage(UIImage(named: "PlayIcon"), for: .normal)

            

            

            

        }else{

            PlayVocieButton.isSelected = true

            let seconds1 : Int64 = Int64(slider.value)

            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)

            player!.seek(to: targetTime)

            

            strPlayStatus = "play"

            player?.volume = 1

            player?.play()

            PlayVocieButton.setImage(UIImage(named: "PauseIcon"), for: .normal)

            

            print("enddddd")

        }

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlidersss), userInfo: nil, repeats: true)

    }
    
    
    @objc func updateSlidersss(){

        if self.player!.currentItem?.status == .readyToPlay {

            

            time = CMTimeGetSeconds(self.player!.currentTime())

        }

        let duration : CMTime = playerItem!.asset.duration

        let seconds : Float64 = CMTimeGetSeconds(duration)

        slider.maximumValue = Float(seconds)

        slider.minimumValue = 0.0

        slider.value = Float(time)

        

        if(time > 0){

            let minutes = Int(time) / 60 % 60

            let secondss = Int(time) % 60

            

            let durationFormat = String(format:"%02i:%02i", minutes, secondss)

            timeCountingLbl.text = durationFormat

        }

        if(time == seconds){

            timer.invalidate()

            PlayVocieButton.isSelected = false

            slider.value = 0.0

        }

    }

    func startSlider() {

        slider.value = 0

        slider.maximumValue = 10

        

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] (timer) in

            print("Slider at: \(self?.slider.value)")

            guard self?.slider.isTracking == false else { return }

            self?.updateSlider(to: self!.slider.value + 0.1)

        }

    }
    
    @objc private func updateSlider(to value: Float) {

        slider.value = value

    }


    @objc func playerDidFinishPlaying(sender: Notification) {

        timer.invalidate()

        slider.value = 0.0

        player?.pause()

        PlayVocieButton.isSelected = false

        playerItem?.seek(to: CMTime.zero)

        timeCountingLbl.text = "00:00"

        PlayVocieButton.setImage(UIImage(named: "PlayIcon"), for: .normal)

    }
    
    @objc func updateAudioMeter(timer: Timer)

    {

        if audioRecorder.isRecording

        {

            let hr = Int((audioRecorder.currentTime / 60) / 60)

            let min = Int(audioRecorder.currentTime / 60)

            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))

            let totalTimeString = String(format: "%02d:%02d", min, sec)

            let time  = String(format: "%02d",sec)

            

//            audioSeconds = time

            print("klllllllfedsaz",time,sec)

            

            timeLabelForPlayVoice = totalTimeString

          

            

            audioRecorder.updateMeters()

            

            

            

        }

    }

    

//    func finishAudioRecording(success: Bool)

//

    

    @IBAction func zoom_img( _ sender : UIPinchGestureRecognizer){
            print("img gesture")
      
        
        print("img gesture")
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
        sender.scale = 1.0
        
          }
    
    
    
    @IBAction func backVc() {
        dismiss(animated: true)
    }
    
}
