//
//  AssignmentVideoDetailVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 01/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVFoundation

class AssignmentVideoDetailVC: UIViewController ,AVAudioPlayerDelegate,Apidelegate {
    
    @IBOutlet weak var PlayAudioButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var nodataLabel: UILabel!
    @IBOutlet weak var AudioSlider: UISlider!
    var strConfId : NSString = ""
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    weak var playbackSlider: UISlider?
    var timer = Timer()
    var time : Float64 = 0;
    var sliderIndex : NSInteger = NSInteger()
    var strFilePath : String = String()
    var SenderName = String()
    var selectedDictionary = NSDictionary()
    var DetailTextArray = NSMutableArray()
    var urlData: URL?
    var strPlayStatus : NSString = ""
    var strNoInternet  : String = ""
    var Screenheight = CGFloat()
    var strNoRecordAlert = String()
    var strSomething = String()
    var strCountryCode = String()
    var ChildId = String()
    var isStaff = String()
    
    var hud : MBProgressHUD = MBProgressHUD()
    
    
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var bIsArchive = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callSelectedLanguage()
        if(isStaff == "false"){
            ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        videoView.isHidden = true
        nodataLabel.isHidden =  true
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        bIsArchive = appDelegate.SchoolDetailDictionary["is_Archive"] as? Bool ?? false
        if(Util .isNetworkConnected()){
            self.CallAssignmentMessageApi()
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
    }
    
    @IBAction func actionBack(_ sender: Any){
        closePlayAudioFileButton()
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "NotificationFromSubmitAssigment"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
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
            player!.seek(to: targetTime)
            strPlayStatus = "play"
            player?.pause()
        }else{
            PlayAudioButton.isSelected = true
            let seconds1 : Int64 = Int64(AudioSlider.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            player!.seek(to: targetTime)
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
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        nodataLabel.text = strNoRecordAlert
    }
    
    // MARK:- Api Calling
    func CallAssignmentMessageApi() {
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_VIEW_STUDENT_ASSIGNMENT
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + POST_VIEW_STUDENT_ASSIGNMENT
        }
        
        
        if(bIsArchive){
            requestStringer = baseReportUrlString! + POST_VIEW_STUDENT_ASSIGNMENT_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ProcessBy": ChildId,
                                          "Type" : "0",
                                          "AssignmentId" : String(describing: selectedDictionary["AssignmentId"]!),
                                          "FileType" : String(describing: selectedDictionary["Type"]!),
                                          COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailAssignmentMessage")
    }
    
    
    
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        if(csData != nil){
            utilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if let CheckedArray = csData as? NSArray{
                if(CheckedArray.count > 0){
                    DetailTextArray = NSMutableArray(array: CheckedArray)
                    let Dict : NSDictionary  = DetailTextArray[0] as! NSDictionary
                    let urlString =  String(describing: Dict["Content"]!)
                    
                    urlData = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
                    videoView.isHidden = false
                }else{
                    nodataLabel.isHidden = false
                    DetailTextArray = []
                    Util.showAlert("", msg: NO_RECORD_MESSAGE)
                }
            }
            else{
                nodataLabel.isHidden = false
                Util.showAlert("", msg: strSomething)
            }
        }
        else
        {
            nodataLabel.isHidden = false
            Util.showAlert("", msg: strSomething)
        }
        
        hideLoading()
        
    }
    
    
    
    @objc func failedresponse(_ pagename: Error!) {
        nodataLabel.isHidden = false
        hideLoading()
        Util.showAlert("", msg: strSomething)
        
    }
    
    // MARK: - Loading
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
    }
    
}
