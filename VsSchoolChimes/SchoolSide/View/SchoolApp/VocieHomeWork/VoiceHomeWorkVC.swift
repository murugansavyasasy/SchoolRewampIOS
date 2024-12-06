//
//  VoiceHomeWorkVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 12/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVFoundation


class VoiceHomeWorkVC: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var PlayVoiceMsgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ChooseStandardSectionButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var TimeTitleLabel: UILabel!
    @IBOutlet weak var DescriptionText: UITextField!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var AudioSlider: UISlider!
    @IBOutlet weak var playVoiceMessageView: UIView!
    @IBOutlet weak var VoiceRecordTimeLabel: UILabel!
    @IBOutlet weak var VocieRecordButton: UIButton!
    @IBOutlet weak var PlayVocieButton: UIButton!
    @IBOutlet weak var ComposeVoiceLabel: UILabel!
    @IBOutlet weak var ListenVoiceMessageLabel: UILabel!
    @IBOutlet weak var SubmissionDateLabel: UILabel!
    @IBOutlet weak var SubmissionView: UIView!
    @IBOutlet weak var submissionViewTopHeight: NSLayoutConstraint!
    @IBOutlet weak var submissionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var submissionDateButton: UIButton!
    
    var timer = Timer()
    var audioPlayer : AVAudioPlayer!
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var meterTimer:Timer!
    var recordingSession : AVAudioSession!
    var audioRecorder    : AVAudioRecorder!
    var settings         = [String : Int]()
    var strPlayStatus : NSString = ""
    var time : Float64 = 0;
    var sliderIndex : NSInteger = NSInteger()
    var urlData: URL?
    var TotaldurationFormat = String()
    var MaxMinutes = Int()
    var MaxSeconds = Int()
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    var durationString = String()
    var loginAsName = String()
    var SchoolId = String()
    var StaffId = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let UtilObj = UtilClass()
    var ApiHomeWorkSecondInt = Int()
    var HomeWorkSecondStr = Int()
    var languageDictionary = NSDictionary()
    var strLanguage = String()
    var strCountryCode = String()
    var strCountryName = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var strFrom = String()
    var strSubmissionDate = String()
    let dateView = UIView()
    var assignmentDict = NSMutableDictionary()
    var popupLoading : KLCPopup = KLCPopup()
    var checkSchoolId : String!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.isOpaque = false
        print("Voice SchoolDetailDict \(SchoolDetailDict)")
        print("checkSchoolId \(checkSchoolId)")
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool){
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        print(strCountryCode)
        strCountryName = UserDefaults.standard.object(forKey: COUNTRY_Name) as? String ?? ""
        print(strCountryName)
        self.callSelectedLanguage()
        if(strFrom == "Assignment"){
            
            let currentDate: NSDate = NSDate()
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            strSubmissionDate = dateFormatter.string(from: currentDate as Date)
            
            dateFormatter.dateFormat = "dd MMM yyyy"
            submissionDateButton.setTitle("  " + dateFormatter.string(from: currentDate as Date), for: .normal)
            SubmissionView.isHidden = false
            if(UIDevice.current.userInterfaceIdiom == .pad){
                submissionViewHeight.constant = 50
                submissionViewTopHeight.constant = 8
            }else{
                submissionViewHeight.constant = 40
                submissionViewTopHeight.constant = 4
            }
            
        }else{
            
            SubmissionView.isHidden = true
            submissionViewHeight.constant = 0
            submissionViewTopHeight.constant = 0
        }
        
        if(self.VoiceRecordTimeLabel.text != "00:00"){
            playVoiceMessageView.isHidden = false
        }else{
            playVoiceMessageView.isHidden = true
            PlayVoiceMsgViewHeight.constant = 0
            
            ChooseStandardSectionButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            ChooseStandardSectionButton.isUserInteractionEnabled = false
            ChooseStandardSectionButton.layer.cornerRadius = 5
            ChooseStandardSectionButton.layer.masksToBounds = true
            
        }
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        if(loginAsName == "Principal")
        {
            
            if checkSchoolId == "1" {
                print("IFCondition")
                SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
                StaffId = String(describing: SchoolDetailDict["StaffID"]!)
                print("SchoolIdSchoolId",SchoolId)
                print("StaffIdStaffId",StaffId)
            }else{
                let userDefaults = UserDefaults.standard
                StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
                SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
                
            }
        }else{
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }
        
        
        AudioSlider.value = 0.0
        audioRecorder = nil
        recordingSession = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 11.0, *) {
                try recordingSession.setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)
            } else {
                try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            }
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                    } else {
                    }
                }
            }
        } catch {
        }
        
        //Audio Setting
        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey:2,
            AVLinearPCMBitDepthKey:16,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
    }
    //MARK: TEXTFIELD DELEGATE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 0 && string == " " {
            return false
        }
        return true
        
    }
    
    //MARK: AUDIO DELEGATE
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
    }
    internal func audioPlayerBeginInterruption(_ player: AVAudioPlayer){
        
    }
    
    func directoryURL() -> NSURL? {
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("sample.mp4")
        // let soundURL = documentDirectory.appendingPathComponent("/\(dfString).mp4")
        UtilObj.printLogKey(printKey: "Recorded Audio", printingValue: soundURL!)
        return soundURL as NSURL?
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioRecorder = try AVAudioRecorder(url: self.directoryURL()! as URL,
                                                settings: settings)
            urlData = audioRecorder.url
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            
        } catch {
            finishRecording(success: false)
        }
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
        } catch {
        }
    }
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        if success {
            audioRecorder = nil
            ChooseStandardSectionButton.isUserInteractionEnabled = true
            ChooseStandardSectionButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        } else {
            audioRecorder = nil
        }
    }
    
    // MARK: VOICE RECORDING BUTTON ACTION
    @IBAction func actionVoiceRecording(_ sender: Any)
    
    {
        dismissKeyboard()
        self.playerDidFinishPlaying()
        
        if audioRecorder == nil {
            ChooseStandardSectionButton.isUserInteractionEnabled = false
            ChooseStandardSectionButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            
            self.TitleForStopRecord()
            self.VocieRecordButton.setBackgroundImage(UIImage(named:"VoiceRecordSelect"), for: UIControl.State.normal)
            playVoiceMessageView.isHidden = true
            PlayVoiceMsgViewHeight.constant = 0
            self.startRecording()
            self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                   target:self,
                                                   selector:#selector(self.updateAudioMeter(_:)),
                                                   userInfo:nil,
                                                   repeats:true)
        }else{
            self.funcStopRecording()
        }
    }
    
    func funcStopRecording()
    {
        self.TitleForStartRecord()
        
        self.VocieRecordButton.setBackgroundImage(UIImage(named:"VocieRecord"), for: UIControl.State.normal)
        
        self.finishRecording(success: true)
        playVoiceMessageView.isHidden = false
        calucalteDuration()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PlayVoiceMsgViewHeight.constant = 180
            self.durationLabel.text = TotaldurationFormat
            self.currentPlayTimeLabel.text = "00.00"
        }
        else
        {
            PlayVoiceMsgViewHeight.constant = 120
            self.durationLabel.text = TotaldurationFormat
            self.currentPlayTimeLabel.text = "00.00"
        }
        
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    @objc func updateSlider()
    {
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
            MaxSeconds = secondss
            let durationFormat = String(format:"%02i:%02i", minutes, secondss)
            currentPlayTimeLabel.text = durationFormat
            
        }
        
        if(time == seconds)
        {
            
            timer.invalidate()
            PlayVocieButton.isSelected = false
            AudioSlider.value = 0.0
        }
        
        
    }
    func actionPlayButton()
    {
        
        playerItem = AVPlayerItem(url: urlData!)
        
        player = AVPlayer(playerItem: playerItem!)
        
        if(strPlayStatus.isEqual(to: "close"))
        {
            AudioSlider.value = 0.0
        }
        
        
        if(PlayVocieButton.isSelected)
        {
            
            PlayVocieButton.isSelected = false
            
            let seconds1 : Int64 = Int64(AudioSlider.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            
            player!.seek(to: targetTime)
            strPlayStatus = "play"
            player?.pause()
        }else{
            
            PlayVocieButton.isSelected = true
            
            let seconds1 : Int64 = Int64(AudioSlider.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            player!.seek(to: targetTime)
            
            strPlayStatus = "play"
            player?.volume = 1
            player?.play()
            
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func updateAudioMeter(_ timer:Timer) {
        
        if let audioRecorder1 = self.audioRecorder {
            if audioRecorder1.isRecording {
                let min = Int(audioRecorder1.currentTime / 60)
                let sec = Int(audioRecorder1.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                let SecString = sec
                VoiceRecordTimeLabel.text = s
                audioRecorder1.updateMeters()
                
                if(HomeWorkSecondStr < 60)
                {
                    if(sec == ApiHomeWorkSecondInt)
                    {
                        self.funcStopRecording()
                    }
                }else{
                    if(min == ApiHomeWorkSecondInt)
                    {
                        self.funcStopRecording()
                    }
                }
                
                
            }
        }
    }
    
    func playbackSliderValueChanged(playbackSlider:UISlider)
    {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime : CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        if(player != nil){
            
            player!.seek(to: targetTime)
            
            
        }else{
            AudioSlider.value = playbackSlider.value
            
            
            
        }
        
    }
    
    
    func calucalteDuration() -> Void
    {
        
        print("urlData \(urlData!)")
        
        
        playerItem = AVPlayerItem(url: urlData!)
        let duration : CMTime = playerItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        
        AudioSlider.maximumValue = Float(seconds)
        //let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let secondss = Int(seconds) % 60
        durationString = String(format:"%i",Int(seconds))
        if(strLanguage == "ar"){
            TotaldurationFormat = String(format:" %02i:%02i/", minutes, secondss)
        }else{
            TotaldurationFormat = String(format:"/ %02i:%02i", minutes, secondss)
        }
        durationLabel.text = TotaldurationFormat
        
    }
    // MARK: Player close
    
    func playerDidFinishPlaying() {
        
        if(player != nil)
        {
            timer.invalidate()
            player?.pause()
            
            AudioSlider.value = 0.0
            player?.rate = 0.0
            currentPlayTimeLabel.text = "00.00"
            
            PlayVocieButton.isSelected = false
            strPlayStatus = "close"
            player = nil
            player =  AVPlayer.init()
            playerItem?.seek(to: CMTime.zero)
            time = CMTimeGetSeconds(self.player!.currentTime())
            
            
        }
    }
    
    //MARK:Play Audio BUTTON ACTION
    @IBAction func actionPlayVoiceMessage(_ sender: UIButton)
    {
        calucalteDuration()
        
        actionPlayButton()
        audioRecorder = nil
        
    }
    @IBAction func actionSliderButton(_ sender: UISlider) {
        
        playbackSliderValueChanged(playbackSlider: AudioSlider)
    }
    
    
    // MARK: BUTTON ACTION
    
    @IBAction func actionDateButton(_ sender: UIButton) {
        self.dismissKeyboard()
        self.congifureDatePicker()
    }
    
    @IBAction func actionChooseStandardSectionButton(_ sender: UIButton) {
        dismissKeyboard()
        self.playerDidFinishPlaying()
        if(strFrom == "Assignment"){
            
            assignmentDict = [
                "AssignmentId" : "0",
                "SchoolId" : SchoolId,
                "AssignmentType": "VOICE",
                "Title": self.DescriptionText.text! ,
                "content": "",
                "Duration": durationString ,
                "ProcessBy":StaffId,
                "isMultiple":"0" ,
                "processType":"add",
                "EndDate":strSubmissionDate,
                
            ]
            
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
            AddCV.SchoolDetailDict = SchoolDetailDict
            AddCV.sendAssignmentDict = self.assignmentDict
            AddCV.VoiceurlData = urlData
            AddCV.assignmentType = "StaffAssignment"
            self.present(AddCV, animated: false, completion: nil)
        }else{
            
            if checkSchoolId == "1" {
                print("IFCondition")
                SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
                StaffId = String(describing: SchoolDetailDict["StaffID"]!)
                print("SchoolIdSchoolId",SchoolId)
                print("StaffIdStaffId",StaffId)
                
                assignmentDict = [
                    "SchoolId" : SchoolId,
                    "StaffID" : StaffId,
                    "SchoolID" : SchoolId,
                    
                ]
                
                let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
                print("StaffAddNewClassVCSchoolId\(SchoolId)")
                AddCV.SchoolDetailDict = assignmentDict
                AddCV.HomeTitleText = DescriptionText.text!
                AddCV.durationString = durationString
                AddCV.VoiceurlData = urlData
                AddCV.SendedScreenNameStr = "VoiceHomeWork"
                AddCV.checkSchoolID = "1"
                self.present(AddCV, animated: false, completion: nil)
            }else{
                let userDefaults = UserDefaults.standard
                StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
                SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
                
                assignmentDict = [
                    "SchoolId" : SchoolId,
                    "StaffID" : StaffId,
                    "SchoolID" : SchoolId,
                    
                ]
                
                let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
                print("StaffAddNewClassVCSchoolId\(SchoolId)")
                AddCV.SchoolDetailDict = assignmentDict
                AddCV.HomeTitleText = DescriptionText.text!
                AddCV.durationString = durationString
                AddCV.VoiceurlData = urlData
                AddCV.SendedScreenNameStr = "VoiceHomeWork"
                self.present(AddCV, animated: false, completion: nil)
                
            }
            
            
            
        }
        
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        
        dismissKeyboard()
        self.playerDidFinishPlaying()
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: TITLE FOR START AND STOP RECORD
    func TitleForStartRecord()
    {
        let firstword : String =  languageDictionary["teacher_txt_start_record"] as? String ?? "Press the button to"
        let secondWord : String  =  languageDictionary["record"] as? String ?? " RECORD"
        let comboWord = firstword + secondWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        var attrs =  [NSAttributedString.Key : NSObject]()
        var attrfirst =  [NSAttributedString.Key : NSObject]()
        if(UIDevice.current.userInterfaceIdiom == .pad){
            attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        else
        {   attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
            
        }
        
        let range = NSString(string: comboWord).range(of: secondWord)
        let range2 = NSString(string: comboWord).range(of: firstword)
        attributedText.addAttributes(attrs, range: range)
        attributedText.addAttributes(attrfirst, range: range2)
        TitleLabel.attributedText = attributedText
        
    }
    
    func TitleForStopRecord()
    {
        let firstword : String =  languageDictionary["teacher_txt_start_record"] as? String ?? "Press the button to"
        let secondWord  : String =  languageDictionary["stop_record"] as? String ?? " STOP RECORD"
        let comboWord = firstword + secondWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        var attrs =  [NSAttributedString.Key : NSObject]()
        var attrfirst =  [NSAttributedString.Key : NSObject]()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {  attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        else
        {   attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
            
        }
        let range = NSString(string: comboWord).range(of: secondWord)
        let range2 = NSString(string: comboWord).range(of: firstword)
        attributedText.addAttributes(attrs, range: range)
        attributedText.addAttributes(attrfirst, range: range2)
        TitleLabel.attributedText = attributedText
        
    }
    func dismissKeyboard()
    {
        DescriptionText.resignFirstResponder()
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }else{
                    self.loadViewData()
                }
            } catch {
                self.loadViewData()
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            self.ComposeVoiceLabel.textAlignment = .right
            self.DescriptionText.textAlignment = .right
            self.ListenVoiceMessageLabel.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            self.ComposeVoiceLabel.textAlignment = .left
            self.DescriptionText.textAlignment = .left
            self.ListenVoiceMessageLabel.textAlignment = .left
        }
        if(strFrom == "Assignment"){
            ComposeVoiceLabel.text  = LangDict["compose_voice_msg"] as? String
            ChooseStandardSectionButton.setTitle("Choose Recipients", for: .normal)
            SubmissionDateLabel.text = LangDict["subission_date"] as? String
            
            DescriptionText.placeholder  =  LangDict["assignment_title"] as? String
            
        }else{
            self.ComposeVoiceLabel.text = LangDict["teacher_txt_Recordvoice"] as? String
            self.DescriptionText.placeholder =  LangDict["teacher_txt_onwhat"] as? String
            
            if (strCountryName.uppercased() == SELECT_COUNTRY){
                self.ChooseStandardSectionButton.setTitle( LangDict["teacher_staff_to_sections_usa"] as? String, for: .normal)
            } // Dhanush_Aug 2002
            else{
                self.ChooseStandardSectionButton.setTitle( LangDict["teacher_staff_to_sections"] as? String, for: .normal)
            }
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
        self.loadViewData()
        
    }
    
    func loadViewData(){
        HomeWorkSecondStr = Int(appDelegate.MaxHWVoiceDurationString)!
        let strSeconRecord : String = languageDictionary["teacher_txt_general_title"] as? String ?? "You can record upto "
        let strSeconds : String = languageDictionary["seconds"] as? String ?? " seconds "
        let strminutes : String = languageDictionary["minutes"] as? String ?? " minutes "
        if(HomeWorkSecondStr < 60)
        {
            UtilObj.printLogKey(printKey: "", printingValue: HomeWorkSecondStr)
            ApiHomeWorkSecondInt = HomeWorkSecondStr
            TimeTitleLabel.text = strSeconRecord + String(ApiHomeWorkSecondInt) + strSeconds
        }else{
            UtilObj.printLogKey(printKey: "", printingValue: HomeWorkSecondStr)
            ApiHomeWorkSecondInt = HomeWorkSecondStr/60
            TimeTitleLabel.text = strSeconRecord + String(ApiHomeWorkSecondInt) + strminutes
        }
        
        UtilObj.printLogKey(printKey: "ApiHomeWorkSecondInt", printingValue: ApiHomeWorkSecondInt)
        self.VoiceRecordTimeLabel.text = "00:00"
        playVoiceMessageView.isHidden = true
        PlayVoiceMsgViewHeight.constant = 0
        self.TitleForStartRecord()
    }
    
    //MARK: DatePicker
    func congifureDatePicker()
    {
        dateView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.actionClosePopup(_:)))
        dateView.addGestureRecognizer(tap)
        
        let doneButton = UIButton()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            doneButton.frame = CGRect(x: 0, y: self.view.frame.height - 250, width: self.dateView.frame.width, height: 50)
        }else
        {
            doneButton.frame = CGRect(x: 0, y: self.view.frame.height - 235, width: self.dateView.frame.width, height: 35)
        }
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        doneButton.addTarget(self, action: #selector(self.actionDoneButton(_:)), for: .touchUpInside)
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        let timeViews = UIView()
        timeViews.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        timeViews.backgroundColor = UIColor.white
        let currentDate: NSDate = NSDate()
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.minimumDate = currentDate as Date
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
        }
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        
        
        dateView.addSubview(timeViews)
        dateView.addSubview(doneButton)
        dateView.addSubview(datePicker)
        
        
        
        
        //        G3
        
        
        dateView.center = view.center
        dateView.alpha = 1
        dateView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(dateView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.dateView.transform = .identity
        })
        
        
        print("VoiceHomeVccccc")
        
        
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strSubmissionDate = dateFormatter.string(from: sender.date) as String
        submissionDateButton.setTitle("  " +  selectedDate + "   ", for: .normal)
        
    }
    
    @objc func actionDoneButton(_ sender: UIButton)
    {
        popupLoading.dismiss(true)
    }
    @objc func actionClosePopup(_ sender: UIButton)
    {
        popupLoading.dismiss(true)
    }
    
}
