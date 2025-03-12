//
//  EmergencyVoiceVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 12/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVFoundation


class EmergencyVoiceVC: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate,UITextFieldDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,Apidelegate,UIDocumentPickerDelegate{
    
    @IBOutlet weak var pathImg: UIImageView!
    @IBOutlet weak var pathLbl: UILabel!
    @IBOutlet weak var addFileView: UIViewX!
    @IBOutlet weak var PlayVoiceMsgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var VoiceRecordTimeLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var AudioSlider: UISlider!
    @IBOutlet weak var playVoiceMessageView: UIView!
    @IBOutlet var voiceHistoryTableView: UITableView!
    @IBOutlet weak var voiceHistoryView: UIView!
    
    @IBOutlet weak var ListenVoiceMsglabel: UILabel!
    @IBOutlet weak var VoiceMessageLabel: UILabel!
    @IBOutlet weak var SelectSchoolButton: UIButton!
    @IBOutlet weak var VocieRecordButton: UIButton!
    @IBOutlet weak var PlayVocieButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var TimeTitleLabel: UILabel!
    @IBOutlet weak var NewVoicerecordImage: UIImageView!
    @IBOutlet weak var VoiceHistoryImage: UIImageView!
    @IBOutlet weak var NewVoiceRecordingLabel: UILabel!
    @IBOutlet weak var SelectFromVoiceHistoryLabel: UILabel!
    
    @IBOutlet weak var RecordVoiceView: UIView!
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
    var audioDuration = String()
    var strApiFrom = NSString()
    var CallerTyepString = String()
    var loginAsName = String()
    var strLanguage = String()
    var MaxMinutes = Int()
    var MaxSeconds = Int()
    var count = Int()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var VoiceData : NSData? = nil
    var schoolsArray = NSMutableArray()
    var selectedSchoolsArray = NSMutableArray()
    var ApiEmergencySecondInt = Int()
    var HomeWorkSecondStr = Int()
    var SelectedArray = NSArray()
    var voiceHistoryArray = NSMutableArray()
    var SelectedVoiceHistoryArray = NSMutableArray()
    var SelectedVoiceDict = NSDictionary()
    var languageDictionary = NSDictionary()
    var DetailVoiceArray = NSMutableArray()
    var strSchoolID = String()
    var strStaffID = String()
    var MessageId = String()
    var SenderType = String()
    var fromView = String()
    var strCountryCode = String()
    let UtilObj = UtilClass()
    let Const = Constants()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var id = 0
    var timer1: Timer?
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        pathLbl.text = ""
        pathLbl.isHidden = true
        pathImg.isHidden = true
        print("emerge123")
        view.isOpaque = false
        playVoiceMessageView.isHidden = true
        PlayVoiceMsgViewHeight.constant = 0
        count = 0
        headerViewHeight.constant = headerViewHeight.constant - 110
        HomeWorkSecondStr = Int(appDelegate.MaxEmergencyVoiceDurationString)!
        
        
        let voiceGes  = UITapGestureRecognizer(target: self, action: #selector(addFileAct))
        addFileView.addGestureRecognizer(voiceGes)
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool){
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    
    
    //MARK: TextField Delegates
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimer()
        PlayVocieButton.isSelected = false
        AudioSlider.value = 0
        currentPlayTimeLabel.text = formatTime(time: 0)
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
        return soundURL as NSURL?
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioRecorder = try AVAudioRecorder(url: self.directoryURL()! as URL,
                                                settings: settings)
            urlData = audioRecorder.url
            selectedSchoolsArray = NSMutableArray(array: SelectedArray)
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
            
            
        } else {
            audioRecorder = nil
        }
    }
    
    // MARK: VOICE RECORDING BUTTON ACTION
    func funcStopRecording()
    {
        self.TitleForStartRecord()
        self.VocieRecordButton.setBackgroundImage(UIImage(named:"VocieRecord"), for: UIControl.State.normal)
        
        self.finishRecording(success: true)
        playVoiceMessageView.isHidden = false
        calucalteDuration()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PlayVoiceMsgViewHeight.constant = 200
            
            if(headerViewHeight.constant <= 558)
            {
                headerViewHeight.constant = headerViewHeight.constant + 300
            }
            
            
            count = appDelegate.LoginSchoolDetailArray.count
            self.durationLabel.text = TotaldurationFormat
            self.currentPlayTimeLabel.text = "00.00"
        }
        else
        {
            PlayVoiceMsgViewHeight.constant = 110
            if(headerViewHeight.constant <= 358)
            {
                headerViewHeight.constant = headerViewHeight.constant + 110
            }
            count = appDelegate.LoginSchoolDetailArray.count
            self.durationLabel.text = TotaldurationFormat
            self.currentPlayTimeLabel.text = "00.00"
        }
        self.ValidateField()
        
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
    func formatTime(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        timer1 = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider1), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer1!.invalidate()
        timer1 = nil
    }
    
    
    @objc func updateSlider1() {
        AudioSlider.value = Float(audioPlayer?.currentTime ?? 0)
        currentPlayTimeLabel.text = formatTime(time: audioPlayer?.currentTime ?? 0)
    }
    func actionPlayButton()
    {
        if id == 0 {
            
            
            
            if(PlayVocieButton.isSelected){
                print("strPlayStatus4")
                PlayVocieButton.isSelected = false
                
                audioPlayer?.pause()
                
            }else{
                
                print("strPlayStatus3")
                PlayVocieButton.isSelected = true
                
                
                playAudio(url: urlData!)
            }
            
            
        }
        
        else{
            Constants.printLogKey("urlData params", printValue: urlData)
            
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
    }
    
    
    
    func playAudio(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            AudioSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
            durationLabel.text = formatTime(time: audioPlayer?.duration ?? 0)
            
            startTimer()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    
    @objc func updateAudioMeter(_ timer:Timer) {
        
        if let audioRecorder1 = self.audioRecorder {
            if audioRecorder1.isRecording {
                let min = Int(audioRecorder1.currentTime / 60)
                let sec = Int(audioRecorder1.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                
                VoiceRecordTimeLabel.text = s
                
                audioRecorder1.updateMeters()
                if(HomeWorkSecondStr < 60)
                {
                    if(sec == ApiEmergencySecondInt)
                    {
                        self.funcStopRecording()
                    }
                }else{
                    if(min == ApiEmergencySecondInt)
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
    
    func calucalteDuration() -> Void{
        
        playerItem = AVPlayerItem(url: urlData!)
        
        let duration : CMTime = playerItem!.asset.duration
        
        let seconds : Float64 = CMTimeGetSeconds(duration)
        AudioSlider.maximumValue = Float(seconds)
        //let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let secondss = Int(seconds) % 60
        audioDuration = String(format:"%i", secondss)
        
        
        TotaldurationFormat = String(format:"/ %02i:%02i", minutes, secondss)
        durationLabel.text = TotaldurationFormat
    }
    
    // MARK: Player DidFinishPlaying
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
    
    // MARK: BUTTON ACTION
    
    @IBAction func actionVoiceRecording(_ sender: UIButton)
    {
        descriptionTextField.resignFirstResponder()
        self.playerDidFinishPlaying()
        self.disableButton()
        
        pathImg.isHidden = true
        pathLbl.isHidden = true
        
        if audioRecorder == nil {
            self.TitleForStopRecord()
            self.VocieRecordButton.setBackgroundImage(UIImage(named:"VoiceRecordSelect"), for: UIControl.State.normal)
            playVoiceMessageView.isHidden = true
            PlayVoiceMsgViewHeight.constant = 0
            count = 0
            if(UIDevice.current.userInterfaceIdiom == .pad){
                if(headerViewHeight.constant >= 448){
                    headerViewHeight.constant = headerViewHeight.constant - 300
                }
            }else{
                if(headerViewHeight.constant >= 348)
                {
                    headerViewHeight.constant = headerViewHeight.constant - 110
                }
            }
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
    
    @IBAction func actionSelectSchoolButton(_ sender: UIButton){
        self.playerDidFinishPlaying()
        self.performSegue(withIdentifier: "EmergencyToSelectSchoolSegue", sender: self)
    }
    
    @IBAction func actionPlayVoiceMessage(_ sender: UIButton){
        
        print("HelloEmere")
        
        calucalteDuration()
        actionPlayButton()
        audioRecorder = nil
    }
    
    @IBAction func actionSliderButton(_ sender: UISlider) {
        playbackSliderValueChanged(playbackSlider: AudioSlider)
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        self.playerDidFinishPlaying()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionNewVoiceRecording(){
        self.fromView = "Record"
        self.RecordVoiceView.isHidden = false
        self.voiceHistoryView.isHidden = true
        self.NewVoicerecordImage.image = UIImage(named: "PurpleRadioSelect")
        self.VoiceHistoryImage.image = UIImage(named: "RadioNormal")
        checkRecordAction()
    }
    
    @IBAction func actionVoiceRecordingHistory(){
        disableButton()
        self.fromView = "History"
        self.RecordVoiceView.isHidden = true
        self.voiceHistoryView.isHidden = false
        self.NewVoicerecordImage.image = UIImage(named: "RadioNormal")
        self.VoiceHistoryImage.image = UIImage(named: "PurpleRadioSelect")
        self.callVoiceHistoryApi()
    }
    
    func checkRecordAction(){
        let strDurationString : NSString = audioDuration as NSString
        if(strDurationString.integerValue > 0){
            self.enableButton()
            
        }else{
            playVoiceMessageView.isHidden = true
            PlayVoiceMsgViewHeight.constant = 0
            self.disableButton()
        }
    }
    
    func checkHistoryArray(){
        if(self.SelectedVoiceHistoryArray.count > 0){
            self.enableButton()
        }else{
            self.disableButton()
        }
    }
    
    
    // MARK: TITLE FOR START AND STOP RECORD
    func TitleForStartRecord(){
        let firstword : String =  languageDictionary["teacher_txt_start_record"] as? String ?? "Press the button to"
        let secondWord : String  =  languageDictionary["record"] as? String ?? " RECORD"
        let comboWord = firstword + secondWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        var attrs =  [NSAttributedString.Key : NSObject]()
        var attrfirst =  [NSAttributedString.Key : NSObject]()
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.black]
            
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.black]
        }else{
            attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        
        let range = NSString(string: comboWord).range(of: secondWord)
        let range2 = NSString(string: comboWord).range(of: firstword)
        
        attributedText.addAttributes(attrs, range: range)
        attributedText.addAttributes(attrfirst, range: range2)
        TitleLabel.attributedText = attributedText
        TitleLabel.textAlignment = .center
        
    }
    
    func TitleForStopRecord(){
        
        let firstword : String =  languageDictionary["teacher_txt_start_record"] as? String ?? "Press the button to"
        let secondWord  : String =  languageDictionary["stop_record"] as? String ?? " STOP RECORD"
        let comboWord = firstword + secondWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        var attrs =  [NSAttributedString.Key : NSObject]()
        var attrfirst =  [NSAttributedString.Key : NSObject]()
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.black]
        }else{
            attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
            
        }
        let range = NSString(string: comboWord).range(of: secondWord)
        let range2 = NSString(string: comboWord).range(of: firstword)
        attributedText.addAttributes(attrs, range: range)
        attributedText.addAttributes(attrfirst, range: range2)
        TitleLabel.attributedText = attributedText
        TitleLabel.textAlignment = .center
        
    }
    
    func TitleForListenVoice(){
        let firstword : String = languageDictionary["listen"] as? String ??  "Listen"
        let secondWord : String  = languageDictionary["voice"] as? String ?? " Voice "
        let thirdWord  : String = languageDictionary["message"] as? String ?? "Message"
        let comboWord = firstword  + secondWord  + thirdWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        var attrs =  [NSAttributedString.Key : NSObject]()
        var attrfirst =  [NSAttributedString.Key : NSObject]()
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.black]
        }else{
            attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        
        let range = NSString(string: comboWord).range(of: secondWord)
        let range2 = NSString(string: comboWord).range(of: firstword)
        attributedText.addAttributes(attrs, range: range)
        attributedText.addAttributes(attrfirst, range: range2)
        if(strLanguage == "ar"){
            ListenVoiceMsglabel.textAlignment = .right
        }else{
            ListenVoiceMsglabel.textAlignment = .left
        }
        ListenVoiceMsglabel.attributedText = attributedText
        
    }
    
    //MARK: TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.voiceHistoryArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 190
        }else{
            return 175
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmergencyVoiceHistoryTVCell", for: indexPath) as! EmergencyVoiceHistoryTVCell
        let dict = self.voiceHistoryArray[indexPath.row] as! NSDictionary
        cell.DateLbl.text = String(describing: dict["SentOn"]!)
        cell.SubjectLbl.text = String(describing: dict["Description"]!)
        cell.playAudioButton.addTarget(self, action: #selector(actionplayAudioButton(sender:)), for: .touchUpInside)
        cell.playAudioButton.tag = indexPath.row
        cell.PressThePlayButtonLabel.text = languageDictionary["hint_play_voice"] as? String
        cell.playAudioButton.setTitle(languageDictionary["teacher_btn_voice_play"] as? String, for: .normal)
        cell.audioCheckBoxButton.tag = indexPath.row
        cell.audioCheckBoxButton.addTarget(self, action: #selector(actionVoiceHistoryCheckboxButton(sender:)), for: .touchUpInside)
        
        if(self.SelectedVoiceHistoryArray.contains(dict)){
            cell.audioCheckBoxButton.setImage(UIImage(named: "PurpleCheckBoxImage"), for: .normal)
        }else{
            cell.audioCheckBoxButton.setImage(UIImage(named: "UnChechBoxImage"), for: .normal)
        }
        return cell
    }
    
    
    //MARK: Api Calling
    
    func callSendVoiceApi() //SendVoiceToEntireSchool Api
    {
        showLoading()
        strApiFrom = "SendVoiceApi"
        VoiceData = NSData(contentsOf: urlData!)
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime =  DefaultsKeys.initialDisplayDate
        var doNotDial =  DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            let requestStringer = baseUrlString! + SendVoiceToEntireSchools
            print("requestStr6ty",requestStringer)
            
            let arrUserData : NSMutableArray = []
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["Description" : descriptionTextField.text!,
                                              "CallerType" : CallerTyepString,
                                              "Duration" : audioDuration,
                                              "isEmergency": "1",
                                              "School" : selectedSchoolsArray, COUNTRY_CODE: strCountryCode]
            arrUserData.add(myDict)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: myDict)
            UtilObj.printLogKey(printKey: "VoiceData", printingValue: VoiceData!)
            
            print("myString",myString)
            apiCall.callPassVoiceParms(requestString, myString, "EmergencyVoice", VoiceData as Data?)
        }else{
            let requestStringer = baseUrlString! + ScheduleSendVoiceToEntireSchools
            print("requestStringerOL5632r5tty",requestStringer)
            
            let arrUserData : NSMutableArray = []
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["Description" : descriptionTextField.text!,
                                              "CallerType" : CallerTyepString,
                                              "Duration" : audioDuration,
                                              "isEmergency": "1",
                                              "School" : selectedSchoolsArray, COUNTRY_CODE: strCountryCode, "StartTime" : initialTime , "EndTime" : doNotDial , "Dates" : DefaultsKeys.dateArr ]
            
            arrUserData.add(myDict)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: myDict)
            UtilObj.printLogKey(printKey: "VoiceData", printingValue: VoiceData!)
            
            print("myString",myString)
            apiCall.callPassVoiceParms(requestString, myString, "EmergencyVoice", VoiceData as Data?)
        }
    }
    func callVoiceHistoryApi(){
        showLoading()
        strApiFrom = "VoiceHistoryApi"
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GetVoiceHistory
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GetVoiceHistory
        }
        
        let idArray : NSMutableArray = NSMutableArray()
        let schoolidArray : NSMutableArray = NSMutableArray()
        
        
        for i in 0..<appDelegate.LoginSchoolDetailArray.count{
            let Dict : NSDictionary =  appDelegate.LoginSchoolDetailArray[i] as! NSDictionary
            idArray.add(String(describing: Dict["StaffID"]!))
            schoolidArray.add(String(describing: Dict["SchoolID"]!))
            
            
        }
        
        let strStaffIDs = idArray.componentsJoined(by: "~")
        let strSchoolIDs = schoolidArray.componentsJoined(by: "~")
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
        print("RRRRRRRR",requestString)
        let myDict:NSMutableDictionary = ["StaffID" : strStaffIDs,
                                          "SchoolId" : strSchoolIDs,
                                          "isEmergency": "1"]
        
        
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "VoiceHistoryApi")
    }
    
    //MARK: Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            print(csData)
            if(strApiFrom.isEqual(to: "SendVoiceApi"))
            {
                if((csData?.count)! > 0)
                {
                    let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    if let status = dicUser["Status"] as? NSString
                    {
                        let Status = status
                        let Message = dicUser["Message"] as! NSString
                        
                        if(Status .isEqual(to: "1")){
                            Util.showAlert("", msg: Message as String?)
                            self.playerDidFinishPlaying()
                            dismiss(animated: false, completion: nil)
                        }else{
                            Util.showAlert("", msg: Message as String?)
                        }
                    }
                }
                
            }else if(strApiFrom == "VoiceHistoryApi"){
                if((csData?.count)! > 0){
                    
                    let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    if let status = dicUser["Status"] as? NSString
                    {
                        let Status = status
                        let Message = dicUser["Message"] as! NSString
                        
                        if(Status .isEqual(to: "1")){
                            self.voiceHistoryArray = csData!
                        }else{
                            self.alertWithAction(strAlert: Message as String)
                        }
                    }else{
                        Util.showAlert("", msg: strSomething )
                    }
                }else{
                    Util.showAlert("", msg: strSomething)
                }
                self.voiceHistoryTableView.reloadData()
                self.checkHistoryArray()
                print("voicehistoryArray :", self.voiceHistoryArray)
            } else if(strApiFrom == "UpdateReadStatus"){
                if((csData?.count)! > 0){
                    
                }
            }
        }else{
            Util.showAlert("", msg: strSomething)
        }
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: strSomething);
        
    }
    
    //MARK: Loading Indicator
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
        
        //        G3
        
        hud.center = view.center
        hud.alpha = 1
        hud.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(hud)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.hud.transform = .identity
        })
        
        
        print("EmergenctVoiceVccccc")
        
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        popupLoading.dismiss(true)
    }
    
    func ValidateField()
    {
        SelectSchoolButton.isHidden = false
        if(audioDuration != "0")
        {
            enableButton()
        }
        else{
            disableButton()
        }
    }
    
    func enableButton(){
        SelectSchoolButton.isUserInteractionEnabled = true
        SelectSchoolButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
    }
    func disableButton(){
        SelectSchoolButton.isUserInteractionEnabled = false
        SelectSchoolButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
    }
    
    @objc func actionVoiceHistoryCheckboxButton(sender: UIButton){
        let dict = self.voiceHistoryArray[sender.tag] as! NSDictionary
        if((self.SelectedVoiceHistoryArray.contains(dict))){
            self.SelectedVoiceHistoryArray.remove(dict)
        }else{
            self.SelectedVoiceHistoryArray.removeAllObjects()
            self.SelectedVoiceHistoryArray.add(dict)
        }
        self.voiceHistoryTableView.reloadData()
        checkHistoryArray()
    }
    
    @objc func actionplayAudioButton(sender: UIButton){
        SelectedVoiceDict = self.voiceHistoryArray[sender.tag] as! NSDictionary
        print(SelectedVoiceDict)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "VoiceHistoryToDetailSeg", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //  print(detailsDict)
        if (segue.identifier == "VoiceHistoryToDetailSeg"){
            let segueid = segue.destination as! VoiceDetailVC
            segueid.SenderName = "VoiceHistory"
            segueid.urlData = urlData
            segueid.selectedDictionary = SelectedVoiceDict
        }else if (segue.identifier == "EmergencyToSelectSchoolSegue"){
            let segueid = segue.destination as! SchoolSelectionVC
            segueid.urlData = urlData
            segueid.fromView = self.fromView
            segueid.strDuration = audioDuration
            segueid.strDescription = descriptionTextField.text!
            segueid.voiceHistoryArray = SelectedVoiceHistoryArray
            segueid.senderName = "EmergencyVoice"
        }
    }
    
    func alertWithAction(strAlert : String){
        let alertController = UIAlertController(title: "", message: strAlert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.actionNewVoiceRecording()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
            self.VoiceMessageLabel.textAlignment = .right
            self.descriptionTextField.textAlignment = .right
            self.ListenVoiceMsglabel.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            self.VoiceMessageLabel.textAlignment = .left
            self.descriptionTextField.textAlignment = .left
            self.ListenVoiceMsglabel.textAlignment = .left
        }
        self.NewVoiceRecordingLabel.text =  LangDict["record_new_voice_msg"] as? String
        self.SelectFromVoiceHistoryLabel.text =  LangDict["record_voice_history"] as? String
        self.VoiceMessageLabel.text = LangDict["voice_compose_msg"] as? String
        self.descriptionTextField.placeholder =  LangDict["teacher_txt_onwhat"] as? String
        self.SelectSchoolButton.setTitle( LangDict["teacher_Select_school"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        TitleForListenVoice()
        
        let strSeconRecord : String = languageDictionary["teacher_txt_emergency_title"] as? String ?? "You can record emergency voice message upto "
        let strSeconds : String = languageDictionary["seconds"] as? String ?? " seconds "
        let strminutes : String = languageDictionary["minutes"] as? String ?? " minutes "
        
        if(HomeWorkSecondStr < 60)
        {
            UtilObj.printLogKey(printKey: "", printingValue: HomeWorkSecondStr)
            ApiEmergencySecondInt = HomeWorkSecondStr
            TimeTitleLabel.text = strSeconRecord + String(ApiEmergencySecondInt) +  strSeconds
        }else{
            UtilObj.printLogKey(printKey: "", printingValue: HomeWorkSecondStr)
            ApiEmergencySecondInt = HomeWorkSecondStr/60
            TimeTitleLabel.text = strSeconRecord + String(ApiEmergencySecondInt) +  strminutes
        }
        self.actionNewVoiceRecording()
        self.TitleForStartRecord()
        let idGroupHead = appDelegate.idGroupHead as NSString
        let isPrincipal = appDelegate.isPrincipal as NSString
        
        print("isPrincipalEmergne",isPrincipal)
        print("isPrincipalisEqualemer",isPrincipal .isEqual(to: "true"))
        
        if(isPrincipal .isEqual(to: "true")){
            CallerTyepString = "M"
            
        }
        else if(idGroupHead .isEqual(to: "true")){
            CallerTyepString = "A"
        }
        
        for  schoolDict in appDelegate.LoginSchoolDetailArray {
            let singleSchoolDictionary = schoolDict as? NSDictionary
            let schoolDic = NSMutableDictionary()
            schoolDic["SchoolId"] = singleSchoolDictionary?.object(forKey: "SchoolID")
            schoolDic["StaffID"] = singleSchoolDictionary?.object(forKey: "StaffID")
            schoolsArray.add(schoolDic)
            selectedSchoolsArray.add(schoolDic)
        }
        
        if(schoolsArray.count > 0){
            let singleSchoolDictionary = schoolsArray[0] as! NSDictionary
            self.strSchoolID = singleSchoolDictionary.object(forKey: "SchoolId") as! String
            self.strStaffID = singleSchoolDictionary.object(forKey: "StaffID") as! String
        }
        
        
        SelectedArray = selectedSchoolsArray
        self.disableButton()
        SelectSchoolButton.layer.cornerRadius = 5
        SelectSchoolButton.layer.masksToBounds = true
        
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
        
        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey:2,
            AVLinearPCMBitDepthKey:16,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
    }
    
    
    @IBAction func addFileAct () {
        var documentPicker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            let supportedTypes: [UTType] = [UTType.audio]
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        } else {
            documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: UIDocumentPickerMode.import)
        }
        documentPicker.delegate = self
        if let popoverController = documentPicker.popoverPresentationController {
            popoverController.sourceView = self.addFileView //set your view name here
        }
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let _ = url.startAccessingSecurityScopedResource()
        let asset = AVURLAsset(url: url)
        guard asset.isComposable else {
            print("Your music is Not Composible")
            return
        }
        urlData = url
        addAudio(audioUrl: url)
    }
    
    func addAudio(audioUrl: URL) {
        
        
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        var str = destinationUrl.lastPathComponent
        
        
        destinationUrl.deleteLastPathComponent()
        destinationUrl.appendPathComponent("sample.mp4")
        
        
        
        print("hegwd",destinationUrl)
        
        VoiceRecordTimeLabel.text = "00:00"
        pathImg.isHidden = false
        pathLbl.text = destinationUrl.path
        pathLbl.isHidden = false
        
        
        playVoiceMessageView.isHidden = false
        calucalteDuration()
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            //calucalteDuration()
            PlayVoiceMsgViewHeight.constant = 200
            if(headerViewHeight.constant <= 558)
            {
                headerViewHeight.constant = headerViewHeight.constant + 300
            }
            count = appDelegate.LoginSchoolDetailArray.count
            self.durationLabel.text = TotaldurationFormat
            currentPlayTimeLabel.text = TotaldurationFormat
            
            self.currentPlayTimeLabel.text = "00.00"
        }else{
            PlayVoiceMsgViewHeight.constant = 110
            if(headerViewHeight.constant <= 358)
            {
                headerViewHeight.constant = headerViewHeight.constant + 110
            }
            count = appDelegate.LoginSchoolDetailArray.count
            self.durationLabel.text = TotaldurationFormat
            currentPlayTimeLabel.text = TotaldurationFormat
            
            self.currentPlayTimeLabel.text = "00.00"
        }
        ValidateField()
    }
    
    
    
}
