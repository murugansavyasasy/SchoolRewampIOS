//
//  VoiceDetailVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll_IMac on 17/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceDetailVC: UIViewController,AVAudioPlayerDelegate {
    
    var selectedDictionary = NSDictionary()
    
    @IBOutlet var TextDateLabel: UILabel!
    @IBOutlet var TextTitleLabel: UILabel!
    @IBOutlet var PlayVoiceMsgLabel: UILabel!
    @IBOutlet weak var PlayAudioButton: UIButton!
    
    var strConfId : NSString = ""
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    weak var playbackSlider: UISlider?
    var timer = Timer()
    var time : Float64 = 0;
    var sliderIndex : NSInteger = NSInteger()
    var strFilePath : String = String()
    var SenderName = String()
    @IBOutlet weak var AudioSlider: UISlider!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    var urlData: URL?
    var strPlayStatus : NSString = ""
    var Screenheight = CGFloat()
    @IBOutlet weak var DiscriptionLbl: UILabel!
    
    @IBOutlet weak var ViewHeightConst: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callSelectedLanguage()
        Screenheight = self.view.frame.size.height
        
        print(selectedDictionary)
        
        if(SenderName == "HomeWorkVocie")
        {
            TextDateLabel.text = ""
            TextTitleLabel.text = String(describing: selectedDictionary["HomeworkSubject"]!)
            strFilePath =  String(describing: selectedDictionary["HomeworkContent"]!)
            
            let DiscriptionStr = String(describing: selectedDictionary["HomeworkTitle"]!)
            
            let CheckNilText : String = Util .checkNil(DiscriptionStr)
            if(CheckNilText != ""){
                DiscriptionLbl.text = CheckNilText
                let Stringlength : Int = CheckNilText.count
                
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    
                    let MuValue : Int = Stringlength/55
                    ViewHeightConst.constant  = 280 + (25 * CGFloat(MuValue))
                }else{
                    if(Screenheight > 580){
                        let MuValue : Int = Stringlength/50
                        ViewHeightConst.constant  = 211 + ( 18 * CGFloat(MuValue))
                        
                    }else{
                        let MuValue : Int = Stringlength/44
                        ViewHeightConst.constant  = 211 + ( 18 * CGFloat(MuValue))
                    }
                }
            }else{
                DiscriptionLbl.text = ""
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    ViewHeightConst.constant = 250
                }else{
                    ViewHeightConst.constant = 181
                }
            }
        }else if(SenderName == "FromStaff"){
            
            TextDateLabel.text = String(describing: selectedDictionary["Time"]!)
            TextTitleLabel.text = String(describing: selectedDictionary["Subject"]!)
            strFilePath =  String(describing: selectedDictionary["URL"]!)
            //changes by preethi remove
            urlData = URL(string: strFilePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            print(urlData)
            DiscriptionLbl.text = ""
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                ViewHeightConst.constant = 250
            }else{
                ViewHeightConst.constant = 181
            }
            
        }else if(SenderName == "VoiceHistory"){
            TextDateLabel.text = String(describing: selectedDictionary["SentOn"]!)
            TextTitleLabel.text = String(describing: selectedDictionary["Description"]!)
            strFilePath =  String(describing: selectedDictionary["URL"]!)
            //changes by preethi remove
            urlData = URL(string: strFilePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            print(urlData)
            DiscriptionLbl.text = ""
            if(UIDevice.current.userInterfaceIdiom == .pad){
                ViewHeightConst.constant = 250
            }else{
                ViewHeightConst.constant = 181
            }
        }else{
            TextDateLabel.text = String(describing: selectedDictionary["Time"]!)
            TextTitleLabel.text = String(describing: selectedDictionary["Subject"]!)
            strFilePath =  String(describing: selectedDictionary["URL"]!)
            
            let DiscriptionStr = String(describing: selectedDictionary["Description"]!)
            let CheckNilText : String = Util .checkNil(DiscriptionStr)
            if(CheckNilText != ""){
                DiscriptionLbl.text = CheckNilText
                let Stringlength : Int = CheckNilText.count
                
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    let MuValue : Int = Stringlength/55
                    ViewHeightConst.constant  = 280 + (25 * CGFloat(MuValue))
                }else{
                    if(Screenheight > 580){
                        let MuValue : Int = Stringlength/50
                        ViewHeightConst.constant  = 211 + ( 18 * CGFloat(MuValue))
                    }else{
                        let MuValue : Int = Stringlength/44
                        ViewHeightConst.constant  = 211 + ( 18 * CGFloat(MuValue))
                    }
                }
            }
            else{
                DiscriptionLbl.text = ""
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    ViewHeightConst.constant = 250
                }else{
                    ViewHeightConst.constant = 181
                }
            }
        }
        calucalteDuration()
    }
    
    @IBAction func actionBack(_ sender: Any){
        closePlayAudioFileButton()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    func calucalteDuration() -> Void{
        playerItem = AVPlayerItem(url: urlData!)
        let duration : CMTime = playerItem!.asset.duration
        guard playerItem!.asset.duration >= .zero, !playerItem!.asset.duration.seconds.isNaN else {
            return
        }
        let seconds : Float64 = CMTimeGetSeconds(duration)
        if(!seconds.isNaN){
            AudioSlider.maximumValue = Float(seconds)
            let minutes = Int(seconds) / 60 % 60
            let secondss = Int(seconds) % 60
            let durationFormat  = String(format:"/ %02i:%02i", minutes, secondss)
            durationLabel.text = durationFormat
        }
        
        
        
    }
    func actionPlayButton(sender: UIButton){
        
        playerItem = AVPlayerItem(url: urlData!)
        player = AVPlayer(playerItem: playerItem!)
        if self.player!.currentItem?.status == .readyToPlay{
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player!.currentItem)
        if(PlayAudioButton.isSelected)
        {
            PlayAudioButton.isSelected = false
            let seconds1 : Int64 = Int64(AudioSlider.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            //  print("pause AudioSlider:\(seconds1)")
            player!.seek(to: targetTime)
            strPlayStatus = "play"
            player?.pause()
            //  timer.invalidate()
        }else{
            PlayAudioButton.isSelected = true
            let seconds1 : Int64 = Int64(AudioSlider.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            player!.seek(to: targetTime)
            // print("play AudioSlider:\(seconds1)")
            strPlayStatus = "play"
            player?.volume = 1
            player?.play()
            
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateSlider(){
        if self.player!.currentItem?.status == .readyToPlay {
            
            time = CMTimeGetSeconds(self.player!.currentTime())
        }
        let duration : CMTime = playerItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        AudioSlider.maximumValue = Float(seconds)
        AudioSlider.minimumValue = 0.0
        AudioSlider.value = Float(time)
        
        if(time > 0){
            let minutes = Int(time) / 60 % 60
            let secondss = Int(time) % 60
            
            let durationFormat = String(format:"%02i:%02i", minutes, secondss)
            currentPlayTimeLabel.text = durationFormat
        }
        if(time == seconds){
            timer.invalidate()
            PlayAudioButton.isSelected = false
            AudioSlider.value = 0.0
        }
    }
    
    func playbackSliderValueChanged(playbackSlider:UISlider){
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime : CMTime = CMTimeMake(value: seconds, timescale: 1)
        if(player != nil){
            player!.seek(to: targetTime)
        }else{
            AudioSlider.value = playbackSlider.value
        }
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        timer.invalidate()
        AudioSlider.value = 0.0
        player?.pause()
        PlayAudioButton.isSelected = false
        playerItem?.seek(to: CMTime.zero)
        currentPlayTimeLabel.text = ""
    }
    
    @IBAction func actionSliderButton(_ sender: Any) {
        playbackSliderValueChanged(playbackSlider: AudioSlider)
    }
    
    @IBAction func actionPlayAudioButton(_ sender: Any) {
        actionPlayButton(sender: PlayAudioButton)
    }
    
    func closePlayAudioFileButton() {
        if(player != nil){
            timer.invalidate()
            player?.pause()
            AudioSlider.value = 0.0
            player?.rate = 0.0
            PlayAudioButton.isSelected = false
            player!.seek(to: CMTime.zero)
            playerItem?.seek(to: CMTime.zero)
            player = nil
            player =  AVPlayer.init()
            time = CMTimeGetSeconds(self.player!.currentTime())
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        let strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }
            } catch {
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        PlayVoiceMsgLabel.text = LangDict["hint_play_voice"] as? String
    }
    
}
