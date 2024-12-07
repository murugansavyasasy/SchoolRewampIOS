//
//  StaffVoiceVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 25/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVFoundation
import FSCalendar

class StaffVoiceVC: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate,UITextFieldDelegate,Apidelegate, UITableViewDelegate, UITableViewDataSource,UIDocumentPickerDelegate, FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var voiceHistoryHeight: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var staffGroupBtnTop: NSLayoutConstraint!
    
    
    @IBOutlet weak var voiceRecordingVieww: UIView!
    
    @IBOutlet weak var cv: UICollectionView!
    
    @IBOutlet weak var cvTopConstain: NSLayoutConstraint!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var fsCaleView: FSCalendar!
    
    @IBOutlet weak var tvTopConstain: NSLayoutConstraint!
    @IBOutlet weak var calendarView: UIView!
    
    
    @IBOutlet weak var doneView: UIView!
    
    
    @IBOutlet weak var viewTopCon: NSLayoutConstraint!
    @IBOutlet weak var doNotCallLbl: UILabel!
    
    @IBOutlet weak var selectDateView: UIView!
    
    @IBOutlet weak var initiateCallLbl: UILabel!
    
    
    @IBOutlet weak var initiateCallView: UIView!
    
    @IBOutlet weak var doNotCallView: UIView!
    @IBOutlet weak var scheduleCallHeight: NSLayoutConstraint!
    @IBOutlet weak var sheduleCallListView: UIView!
    
    @IBOutlet weak var tv: UITableView!
    
    
    @IBOutlet weak var selectedDatesLbl: UILabel!
    
    
    @IBOutlet weak var pathImg: UIImageView!
    
    @IBOutlet weak var pathLbl: UILabel!
    
    @IBOutlet weak var instantImg: UIImageView!
    
    
    @IBOutlet weak var scheduleView: UIImageView!
    
    @IBOutlet weak var scheduleCallView: UIView!
    
    @IBOutlet weak var instantCallView: UIView!
    
    
    @IBOutlet weak var voiceView: UIViewX!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var PlayVoiceMsgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ChooseStandardSectionButton: UIButton!
    @IBOutlet weak var ChooseStandardStudentButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var TimeTitleLabel: UILabel!
    @IBOutlet weak var DescriptionText: UITextField!
    @IBOutlet weak var currentPlayTimeLabel: UILabel!
    @IBOutlet weak var AudioSlider: UISlider!
    @IBOutlet weak var playVoiceMessageView: UIView!
    @IBOutlet weak var VoiceRecordTimeLabel: UILabel!
    @IBOutlet weak var VocieRecordButton: UIButton!
    @IBOutlet weak var PlayVocieButton: UIButton!
    @IBOutlet weak var ListenVoiceMsgLabel: UILabel!
    @IBOutlet weak var RecordVoiceLabel: UILabel!
    
    @IBOutlet weak var StaffGroupButton: UIButton!
    //MARK: Voice History
    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var View3: UIView!
    
    @IBOutlet var voiceHistoryTableView: UITableView!
    @IBOutlet weak var voiceHistoryView: UIView!
    @IBOutlet weak var NewVoicerecordImage: UIImageView!
    @IBOutlet weak var VoiceHistoryImage: UIImageView!
    @IBOutlet weak var NewVoiceRecordingLabel: UILabel!
    @IBOutlet weak var SelectFromVoiceHistoryLabel: UILabel!
    
    
    @IBOutlet weak var voiceHistoryTop: NSLayoutConstraint!
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
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var voiceHistoryArray = NSMutableArray()
    var SelectedVoiceHistoryArray = NSMutableArray()
    var SelectedVoiceDict = NSDictionary()
    var languageDictionary = NSDictionary()
    var strApiFrom = NSString()
    var fromView = String()
    var strLanguage = String()
    var strCountryCode = String()
    var strCountryNAme = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var display_date : String!
    
    var url_time: String!
    
    var dateArr : [String] = []
    var timeId  = ""
    let rowId = "ScheduleCallCollectionViewCell"
    var school_type : String!
    override func viewDidLoad(){
        super.viewDidLoad()
        
        DefaultsKeys.dateArr.removeAll()

        DefaultsKeys.SelectInstantSchedule = 0
        
        print("DefaultsKeys222SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        pathLbl.text = ""
        pathImg.isHidden = true
        pathLbl.isHidden = true
        cv.isHidden  = true
        cv.delegate = self
        cv.dataSource = self
        
        cv.register(UINib(nibName: rowId, bundle: nil), forCellWithReuseIdentifier: rowId)
        
        sheduleCallListView.isHidden = true
        initiateCallView.isHidden = true
        doNotCallView.isHidden = true
        selectDateView.isHidden = true
        voiceRecordingVieww.isHidden = false
        
        fsCaleView.delegate = self
        fsCaleView.dataSource = self
        scheduleCallHeight.constant = 0
        
        viewTopCon.constant = -180
        voiceHistoryTop.constant = -100
        calendarView.isHidden  = true
        doneView.isHidden  = true
        fsCaleView.isHidden  = true
        staffGroupBtnTop.constant = 450
        cvTopConstain.constant = 0
        
        
        fsCaleView.allowsMultipleSelection = true
        pathImg.isHidden = true
        pathLbl.isHidden = true
        
        let doNotCallGes = StaffDateGesture(target: self, action: #selector(doNotCallAction))
        doNotCallGes.id = "2"
        doNotCallView.addGestureRecognizer(doNotCallGes)
        
        
        
        
        let initiateCallGes = StaffDateGesture(target: self, action: #selector(initiateCallAction))
        initiateCallGes.id = "1"
        initiateCallView.addGestureRecognizer(initiateCallGes)
        
        let instantGes  = UITapGestureRecognizer(target: self, action: #selector(instantAction))
        instantCallView.addGestureRecognizer(instantGes)
        
        
        let scheduleGes  = UITapGestureRecognizer(target: self, action: #selector(scheduleAction))
        scheduleCallView.addGestureRecognizer(scheduleGes)
        
        
        
        let calendarGes = UITapGestureRecognizer(target: self, action: #selector(calendarAction))
        
        selectDateView.addGestureRecognizer(calendarGes)
        
        let doneGes = UITapGestureRecognizer(target: self, action: #selector(doneActionVc))
        
        doneView.addGestureRecognizer(doneGes)
        view.isOpaque = false
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StaffVoiceVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
        
        StaffGroupButton.isHidden = false
        
        strCountryNAme = UserDefaults.standard.object(forKey: COUNTRY_Name) as? String ?? ""
        print(strCountryNAme)
        
        
        
        let userDefaults = UserDefaults.standard
        
        
        school_type = userDefaults.string(forKey: DefaultsKeys.school_type )
        
        
        print("schooltypedd",school_type)
        if school_type == "2" {
            scheduleCallView.isHidden = false
            scheduleCallHeight.constant = 40
        }else{
            scheduleCallView.isHidden = true
            scheduleCallHeight.constant  = 0
            
        }
        
        
        
        let voiceGes  = UITapGestureRecognizer(target: self, action: #selector(addFileAct))
        voiceView.addGestureRecognizer(voiceGes)
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    
    func enableButtonAction(){
        ChooseStandardSectionButton.isUserInteractionEnabled = true
        ChooseStandardSectionButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        StaffGroupButton.isUserInteractionEnabled = true
        StaffGroupButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        ChooseStandardStudentButton.isUserInteractionEnabled = true
        ChooseStandardStudentButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        
    }
    
    func disableButtonAction(){
        ChooseStandardSectionButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        ChooseStandardSectionButton.isUserInteractionEnabled = false
        StaffGroupButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        StaffGroupButton.isUserInteractionEnabled = false
        ChooseStandardStudentButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        ChooseStandardStudentButton.isUserInteractionEnabled = false
    }
    
    func checkRecordAction(){
        let strDurationString : NSString = durationString as NSString
        if(strDurationString.integerValue > 0){
            self.enableButtonAction()
            
        }else{
            playVoiceMessageView.isHidden = true
            PlayVoiceMsgViewHeight.constant = 0
            self.disableButtonAction()
        }
    }
    
    //MARK: TEXTFIELD DELEGATE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " "{
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
        
        return soundURL as NSURL?
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do{
            audioRecorder = try AVAudioRecorder(url: self.directoryURL()! as URL, settings: settings)
            urlData = audioRecorder.url
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            
        }catch{
            finishRecording(success: false)
        }
        do{
            try audioSession.setActive(true)
            audioRecorder.record()
        }catch{
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        if success {
            audioRecorder = nil
            self.enableButtonAction()
        } else {
            audioRecorder = nil
        }
    }
    
    // MARK: VOICE RECORDING BUTTON ACTION
    @IBAction func actionVoiceRecording(_ sender: UIButton){
        dismissKeyboard()
        self.playerDidFinishPlaying()
        
        
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            scheduleCallHeight.constant = 0
            cvTopConstain.constant = 0
            
            sheduleCallListView.isHidden = true
            scheduleCallHeight.constant = 0
            calendarView.isHidden  = true
            doneView.isHidden  = true
            fsCaleView.isHidden  = true
        }else{
            
            
            
        }
        
        
        
        
        
        pathImg.isHidden = true
        pathLbl.isHidden = true
        disableButtonAction()
        if audioRecorder == nil {
            self.disableButtonAction()
            self.TitleForStopRecord()
            self.VocieRecordButton.setBackgroundImage(UIImage(named:"VoiceRecordSelect"), for: UIControl.State.normal)
            playVoiceMessageView.isHidden = true
            PlayVoiceMsgViewHeight.constant = 0
            self.startRecording()
            self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(_:)), userInfo:nil, repeats:true)
        }else{
            self.funcStopRecording()
        }
    }
    
    func funcStopRecording(){
        self.TitleForStartRecord()
        self.VocieRecordButton.setBackgroundImage(UIImage(named:"VocieRecord"), for: UIControl.State.normal)
        self.finishRecording(success: true)
        playVoiceMessageView.isHidden = false
        calucalteDuration()
        if(UIDevice.current.userInterfaceIdiom == .pad){
            
            PlayVoiceMsgViewHeight.constant = 180
            
            self.durationLabel.text = TotaldurationFormat
            self.currentPlayTimeLabel.text = "00.00"
        }else{
            PlayVoiceMsgViewHeight.constant = 120
            
            self.durationLabel.text = TotaldurationFormat
            self.currentPlayTimeLabel.text = "00.00"
        }
        
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            self.ValidateField()
        }else{
            if initiateCallLbl.text != "Time" &&  doNotCallLbl.text != "Time"  && urlData != nil{
                
                self.ValidateField()
            }else{
                disableButtonAction()
                
            }
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @objc func updateSlider(){
        if self.player!.currentItem?.status == .readyToPlay{
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
        
        if(time == seconds){
            
            timer.invalidate()
            PlayVocieButton.isSelected = false
            AudioSlider.value = 0.0
        }
    }
    
    func actionPlayButton(){
        
        playerItem = AVPlayerItem(url: urlData!)
        player = AVPlayer(playerItem: playerItem!)
        
        if(strPlayStatus.isEqual(to: "close")){
            AudioSlider.value = 0.0
        }
        
        if(PlayVocieButton.isSelected){
            
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
                if(HomeWorkSecondStr < 60){
                    if(sec == ApiHomeWorkSecondInt){
                        self.funcStopRecording()
                    }
                }else{
                    if(min == ApiHomeWorkSecondInt){
                        self.funcStopRecording()
                    }
                }
            }
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
    
    func calucalteDuration() -> Void{
        playerItem = AVPlayerItem(url: urlData!)
        let duration : CMTime = playerItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        
        AudioSlider.maximumValue = Float(seconds)
        //let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let secondss = Int(seconds) % 60
        durationString = String(format:"%i",Int(seconds))
        
        TotaldurationFormat = String(format:"/ %02i:%02i", minutes, secondss)
        durationLabel.text = TotaldurationFormat
        
    }
    
    // MARK: Player close
    func playerDidFinishPlaying() {
        
        if(player != nil){
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
    @IBAction func actionPlayVoiceMessage(_ sender: UIButton){
        calucalteDuration()
        
        actionPlayButton()
        audioRecorder = nil
    }
    
    @IBAction func actionSliderButton(_ sender: UISlider) {
        playbackSliderValueChanged(playbackSlider: AudioSlider)
    }
    
    
    // MARK: BUTTON ACTION
    
    @IBAction func actionChooseStandardSectionButton(_ sender: UIButton) {
        dismissKeyboard()
        self.playerDidFinishPlaying()
        let StaffVC = self.storyboard?.instantiateViewController(withIdentifier: "StandardOrSectionVCStaff") as! StandardOrSectionVCStaff
        
        if( self.fromView == "Record"){
            StaffVC.SendedScreenNameStr = "StaffVoiceMessage"
            StaffVC.HomeTitleText = DescriptionText.text!
            StaffVC.durationString = durationString
            StaffVC.VoiceurlData = urlData
            StaffVC.fromView = self.fromView
            self.present(StaffVC, animated: false, completion: nil)
        }else{
            if(self.SelectedVoiceHistoryArray.count > 0){
                let Dict = self.SelectedVoiceHistoryArray[0] as! NSDictionary
                StaffVC.SendedScreenNameStr = "StaffVoiceMessage"
                StaffVC.HomeTitleText = String(describing: Dict["Description"]!)
                StaffVC.durationString = String(describing: Dict["Duration"]!)
                StaffVC.VoiceurlData =  NSURL(string: String(describing: Dict["URL"]!)) as URL?
                StaffVC.fromView = self.fromView
                StaffVC.voiceHistoryArray = SelectedVoiceHistoryArray
                self.present(StaffVC, animated: false, completion: nil)
            }else{
                Util.showAlert("", msg: languageDictionary["please_select_message"] as? String)
            }
        }
        
    }
    
    
    
    @IBAction func ActionStaffToGroups(_ sender: UIButton) {
        
        
        let vc =  StaffGroupVoiceViewController(nibName: nil, bundle: nil)
        if( self.fromView == "Record"){
            vc.modalPresentationStyle = .fullScreen
            vc.SendedScreenNameStr = "StaffVoiceMessage"
            vc.fromView = self.fromView
            vc.voiceDesc = DescriptionText.text!
            vc.SchoolId = SchoolId
            vc.StaffId = StaffId
            vc.voiceUrlData = urlData
            vc.voiceDurationString = durationString
            vc.selectType = "Voice"
            vc.sendToGroupType = "1"
            
            present(vc, animated: true, completion: nil)
        }else{
            if(self.SelectedVoiceHistoryArray.count > 0){
                let Dict = self.SelectedVoiceHistoryArray[0] as! NSDictionary
                vc.modalPresentationStyle = .fullScreen
                vc.SendedScreenNameStr = "StaffVoiceMessage"
                vc.voiceDesc = String(describing: Dict["Description"]!)
                vc.voiceDurationString = String(describing: Dict["Duration"]!)
                vc.voiceUrlData = NSURL(string: String(describing: Dict["URL"]!)) as URL?
                vc.fromView = self.fromView
                vc.SchoolId = SchoolId
                vc.StaffId = StaffId
                vc.selectType = "Voice"
                vc.voiceHistoryArray = SelectedVoiceHistoryArray
                vc.sendToGroupType = "2"
                self.present(vc, animated: false, completion: nil)
            }else{
                Util.showAlert("", msg: languageDictionary["please_select_message"] as? String)
            }
        }
        
    }
    
    
    @IBAction func actionChooseStandardStudentButton(_ sender: UIButton) {
        dismissKeyboard()
        self.playerDidFinishPlaying()
        let StaffStudent = self.storyboard?.instantiateViewController(withIdentifier: "StandardOrStudentsStaff") as! StandardOrStudentsStaff
        
        if( self.fromView == "Record"){
            StaffStudent.SenderScreenName = "StaffVoiceMessage"
            StaffStudent.HomeTitleText = DescriptionText.text!
            StaffStudent.durationString = durationString
            StaffStudent.urlData = urlData
            StaffStudent.fromView = self.fromView
            self.present(StaffStudent, animated: false, completion: nil)
        }else{
            if(self.SelectedVoiceHistoryArray.count > 0){
                let Dict = self.SelectedVoiceHistoryArray[0] as! NSDictionary
                StaffStudent.SenderScreenName = "StaffVoiceMessage"
                StaffStudent.HomeTitleText = String(describing: Dict["Description"]!)
                StaffStudent.durationString = String(describing: Dict["Duration"]!)
                StaffStudent.urlData = NSURL(string: String(describing: Dict["URL"]!)) as URL?
                StaffStudent.fromView = self.fromView
                StaffStudent.voiceHistoryArray = SelectedVoiceHistoryArray
                self.present(StaffStudent, animated: false, completion: nil)
            }else{
                Util.showAlert("", msg: languageDictionary["please_select_message"] as? String)
            }
        }
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        
        dismissKeyboard()
        self.playerDidFinishPlaying()
        dismiss(animated: false, completion: nil)
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
        let firstword : String = languageDictionary["listen"] as? String ??  "Listen"  //"Listen"
        let secondWord : String  = languageDictionary["voice"] as? String ?? " Voice " //" Voice "
        let thirdWord  : String = languageDictionary["message"] as? String ?? "Message"//"Message"
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
            ListenVoiceMsgLabel.textAlignment = .right
        }else{
            ListenVoiceMsgLabel.textAlignment = .left
        }
        ListenVoiceMsgLabel.attributedText = attributedText
        
    }
    
    func dismissKeyboard(){
        DescriptionText.resignFirstResponder()
    }
    
    @objc func catchNotification(notification:Notification) -> Void{
        print("Noti staff")
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: Voice History
    
    func ViewHideShow(SetBool : Bool){
        self.View1.isHidden = SetBool
        self.View2.isHidden = SetBool
        self.View3.isHidden = SetBool
        self.playVoiceMessageView.isHidden = SetBool
    }
    
    @IBAction func actionNewVoiceRecording(){
        self.fromView = "Record"
        voiceRecordingVieww.isHidden = false
        
        StaffGroupButton.isHidden = false
        self.ViewHideShow(SetBool: false)
        self.voiceHistoryView.isHidden = true
        self.NewVoicerecordImage.image = UIImage(named: "PurpleRadioSelect")
        self.VoiceHistoryImage.image = UIImage(named: "RadioNormal")
        self.checkRecordAction()
    }
    
    @IBAction func actionVoiceRecordingHistory(){
        self.fromView = "History"
        pathImg.isHidden = true
        voiceRecordingVieww.isHidden = true
        pathLbl.isHidden = true
        calendarView.isHidden  = true
        doneView.isHidden  = true
        fsCaleView.isHidden  = true
        
        
        self.ViewHideShow(SetBool: true)
        self.voiceHistoryView.isHidden = false
        self.NewVoicerecordImage.image = UIImage(named: "RadioNormal")
        self.VoiceHistoryImage.image = UIImage(named: "PurpleRadioSelect")
        self.callVoiceHistoryApi()
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            scheduleCallHeight.constant = 0
            cvTopConstain.constant = 0
        }else{
            
            staffGroupBtnTop.constant = 540
            scheduleCallHeight.constant = 135
            scheduleAction()
            if dateArr.count >= 6{
                
                cvTopConstain.constant = 200
            }else{
                
                cvTopConstain.constant = CGFloat(30*dateArr.count)
                
            }
            
        }
        
        
    }
    
    //MARK: Loading Indicator
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
        
        
        //G3
        
        hud.center = view.center
        hud.alpha = 1
        hud.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(hud)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.hud.transform = .identity
        })
        
        
        print("STaffVoiceVccfcfd")
        
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        popupLoading.dismiss(true)
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
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["StaffID" : self.StaffId,
                                          "SchoolId" : self.SchoolId, COUNTRY_CODE: strCountryCode,"isEmergency": "0"]
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        print("myDict:",myDict)
        print("VoiceHistory:",requestString)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "VoiceHistoryApi")
    }
    
    //MARK: Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        hideLoading()
        if(csData != nil){
            print(csData)
            if(strApiFrom == "VoiceHistoryApi"){
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
                        print("strSomethingstr4ertyuSomething",strSomething)
                        Util.showAlert("", msg: strSomething )
                    }
                }else{
                    print("strSomethingstrSomething",strSomething)
                    Util.showAlert("", msg: strSomething)
                    print("strSomethingstrSomething",strSomething)
                }
                voiceHistoryTableView.dataSource = self
                voiceHistoryTableView.delegate = self
                self.voiceHistoryTableView.reloadData()
                checkHistoryArray()
                print("voicehistoryArrayCount :", self.voiceHistoryArray.count)
                
                if voiceHistoryArray.count == 0 {
                    scheduleCallHeight.constant = 0
                }
                print("voicehistoryArray :", self.voiceHistoryArray)
            }
        }else{
            
            Util.showAlert("", msg: strSomething)
        }
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: strSomething);
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
    
    func checkHistoryArray(){
        if(self.SelectedVoiceHistoryArray.count > 0){
            self.enableButtonAction()
        }else{
            self.disableButtonAction()
        }
    }
    
    @objc func actionplayAudioButton(sender: UIButton){
        self.SelectedVoiceDict = self.voiceHistoryArray[sender.tag] as! NSDictionary
        print(self.SelectedVoiceDict)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "StaffVoiceHistoryToDetailSeg", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "StaffVoiceHistoryToDetailSeg"){
            let segueid = segue.destination as! VoiceDetailVC
            segueid.SenderName = "VoiceHistory"
            
            segueid.urlData = urlData
            segueid.selectedDictionary = self.SelectedVoiceDict
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
            self.ListenVoiceMsgLabel.textAlignment = .right
            self.DescriptionText.textAlignment = .right
            self.ListenVoiceMsgLabel.textAlignment = .right
            self.RecordVoiceLabel.textAlignment = .right
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            self.ListenVoiceMsgLabel.textAlignment = .left
            self.DescriptionText.textAlignment = .left
            self.ListenVoiceMsgLabel.textAlignment = .left
            self.RecordVoiceLabel.textAlignment = .left
        }
        self.NewVoiceRecordingLabel.text =  LangDict["record_new_voice_msg"] as? String
        self.SelectFromVoiceHistoryLabel.text =  LangDict["record_voice_history"] as? String
        self.RecordVoiceLabel.text = LangDict["voice_compose_msg"] as? String
        self.DescriptionText.placeholder =  LangDict["teacher_txt_onwhat"] as? String
        
        if (strCountryNAme.uppercased() == SELECT_COUNTRY){
            self.ChooseStandardSectionButton.setTitle( LangDict["teacher_staff_to_sections_usa"] as? String, for: .normal)
            self.ChooseStandardStudentButton.setTitle( LangDict["teacher_staff_to_students"] as? String, for: .normal)
        }
        else{
            self.ChooseStandardSectionButton.setTitle( LangDict["teacher_staff_to_sections"] as? String, for: .normal)
            self.ChooseStandardStudentButton.setTitle( LangDict["teacher_staff_to_students"] as? String, for: .normal)
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        self.TitleForListenVoice()
        let strSeconRecord : String = languageDictionary["teacher_txt_general_title"] as? String ?? "You can record general voice message upto "
        let strSeconds : String = languageDictionary["seconds"] as? String ?? " seconds "
        let strminutes : String = languageDictionary["minutes"] as? String ?? " minutes "
        
        HomeWorkSecondStr = Int(appDelegate.MaxGeneralVoiceDuartionString)!
        if(HomeWorkSecondStr < 60){
            UtilObj.printLogKey(printKey: "", printingValue: HomeWorkSecondStr)
            ApiHomeWorkSecondInt = HomeWorkSecondStr
            TimeTitleLabel.text = strSeconRecord + String(ApiHomeWorkSecondInt) + strSeconds
        }else{
            UtilObj.printLogKey(printKey: "", printingValue: HomeWorkSecondStr)
            ApiHomeWorkSecondInt = HomeWorkSecondStr/60
            TimeTitleLabel.text = strSeconRecord + String(ApiHomeWorkSecondInt) + strminutes
        }
        self.VoiceRecordTimeLabel.text = "00:00"
        playVoiceMessageView.isHidden = true
        PlayVoiceMsgViewHeight.constant = 0
        
        UtilObj.printLogKey(printKey: "ApiHomeWorkSecondInt", printingValue: ApiHomeWorkSecondInt)
        
        self.actionNewVoiceRecording()
        
        self.TitleForStartRecord()
        if(self.VoiceRecordTimeLabel.text != "00:00"){
            playVoiceMessageView.isHidden = false
        }else{
            playVoiceMessageView.isHidden = true
            PlayVoiceMsgViewHeight.constant = 0
            ChooseStandardSectionButton.layer.cornerRadius = 5
            ChooseStandardSectionButton.layer.masksToBounds = true
            StaffGroupButton.layer.cornerRadius = 5
            StaffGroupButton.layer.masksToBounds = true
            ChooseStandardStudentButton.layer.cornerRadius = 5
            ChooseStandardStudentButton.layer.masksToBounds = true
            disableButtonAction()
        }
        
        AudioSlider.value = 0.0
        audioRecorder = nil
        recordingSession = AVAudioSession.sharedInstance()
        do{
            if #available(iOS 11.0, *) {
                try recordingSession.setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)
            } else {
                try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            }
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed{
                        
                    }else{
                        
                    }
                }
            }
        }catch{
            
        }
        
        
        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey:2,
            AVLinearPCMBitDepthKey:16,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        let loginAsName : String = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        if(loginAsName == "Principal")
        {
            let userDefaults = UserDefaults.standard
            StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
            SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
            
        }else{
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }
        
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
            popoverController.sourceView = self.voiceView
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
        
        self.ValidateField()
        
        print("The file already exists at path")
        VoiceRecordTimeLabel.text = "00:00"
        pathImg.isHidden = false
        pathLbl.text = destinationUrl.path
        pathLbl.isHidden = false
        
        
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            staffGroupBtnTop.constant = 520
            self.ValidateField()
        }else{
            staffGroupBtnTop.constant = 695
            if initiateCallLbl.text != "Time" &&  doNotCallLbl.text != "Time" && urlData != nil {
                
                if dateArr.count == 0 {
                    
                    
                    disableButtonAction()
                }
                
                
                else{
                    
                    enableButtonAction()
                    
                }
            }else{
                disableButtonAction()
            }
        }
        
        playVoiceMessageView.isHidden = false
        
        calucalteDuration()
        if(UIDevice.current.userInterfaceIdiom == .pad){
            PlayVoiceMsgViewHeight.constant = 210
            self.durationLabel.text = TotaldurationFormat
            self.currentPlayTimeLabel.text = "00.00"
        }else{
            PlayVoiceMsgViewHeight.constant = 180
            
            self.durationLabel.text = TotaldurationFormat
            self.currentPlayTimeLabel.text = "00.00"
        }
        
        print("PlayVoif4f4f4ceMsgViewHeightconstant",PlayVoiceMsgViewHeight.constant)
        self.ValidateField()
        
        
    }
    
    func ValidateField()
    {
        
        if(durationString != "0")
        {
            enableButtonAction()
        }
        else{
            disableButtonAction()
        }
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date() // Today
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    }
    
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let result = formatter.string(from: date)
        if !dateArr.contains(result) {
            dateArr.append(result)

            DefaultsKeys.dateArr.append(result)
            viewTopCon.constant = -60
            
            if initiateCallLbl.text != "Time" &&  doNotCallLbl.text != "Time" {
                
                self.ValidateField()
            }else{
                disableButtonAction()
            }
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let result = formatter.string(from: date)
        
        if let index = dateArr.firstIndex(of: result) {
            dateArr.remove(at: index)
            print("didDeselectDate",result)
            print("index",index)
            DefaultsKeys.dateArr.remove(at: index)

            print("DefaultsKeysdateArrAfter",DefaultsKeys.dateArr)
        }
        

        
        
    }
    
    
    
    
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let today = Date()
        let thirtyDaysFromToday = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        
        if (date.isSameDay1(as: today) || (date >= today && date <= thirtyDaysFromToday)) {
            return true
        } else {
            return false
        }
    }
    
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let today = Date()
        let thirtyDaysFromToday = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        
        if date < today || date > thirtyDaysFromToday {
            return .gray
        } else {
            return nil
        }
    }
    
    
    
    @IBAction func selectDateAct() {
        
        calendarView.isHidden  = false
        doneView.isHidden  = false
        fsCaleView.isHidden  = false
        
    }
    
    @IBAction func calendarAction() {
        
        fsCaleView.isHidden = false
        calendarView.isHidden = false
        doneView.isHidden = false
        
    }
    
    
    @IBAction func initiateCallAction(ges : StaffDateGesture) {
        
        timeId = "1"
        
        timeSS()
        
    }
    
    
    func timeSS(){
        
        print("timeId1",timeId)
        RPickerTwo.selectDate(title: "Select time", cancelText: "Cancel", datePickerMode: .time, style: .Wheel, didSelectDate: {[weak self] (today_date) in
            
            
            self?.display_date = today_date.dateString("HH:mm")
            self?.url_time = today_date.dateString("a:mm:hh")
            
            if self!.timeId == "1" {
                
                self?.initiateCallLbl.text = self!.display_date
                DefaultsKeys.initialDisplayDate = self!.display_date
                
                
                if self?.initiateCallLbl.text != "Time" &&  self?.doNotCallLbl.text != "Time" && self?.urlData != nil {
                    
                    if self!.dateArr.count == 0 {
                        
                        
                        self?.disableButtonAction()
                    }
                    
                    
                    else{
                        
                        self!.enableButtonAction()
                        
                    }
                }else{
                    self?.disableButtonAction()
                }
                
            }
            else if self!.timeId == "2"{
                
                self?.doNotCallLbl.text = self!.display_date
                DefaultsKeys.doNotDialDisplayDate = self!.display_date
                
                var start1 = self?.initiateCallLbl.text
                var end1 = self?.doNotCallLbl.text
                
                if start1! > end1! {
                    Util.showAlert("Alert", msg:  "Please select dial beyond time is after the initial call time")
                    self?.doNotCallLbl.text = "Time"
                    print("futureTime is greater than currentTime")
                }else{
                    
                    
                    if self?.initiateCallLbl.text != "Time" &&  self?.doNotCallLbl.text != "Time"  && self?.urlData != nil {
                        
                        if self!.dateArr.count == 0 {
                            
                            
                            self?.disableButtonAction()
                        }
                        
                        
                        else{
                            
                            self!.enableButtonAction()
                            
                        }
                    }else{
                        self?.disableButtonAction()
                    }
                }
                
            }
            
        })
        
        
    }
    
    
    @IBAction func closeAction() {
        
        sheduleCallListView.isHidden = true
        initiateCallView.isHidden = true
        doNotCallView.isHidden = true
        selectDateView.isHidden = true
        
        scheduleCallHeight.constant = 0
    }
    
    
    @IBAction func deleteAction(ges: deleteGesture) {
        print("DefaultsKeys.dateArr",DefaultsKeys.dateArr)
        dateArr.remove(at: ges.id )
        DefaultsKeys.dateArr.remove(at: ges.id)
        print("DefaultsKeys.dateArrAfterDE",DefaultsKeys.dateArr)
        var dateFormat = "dd-MM-yyyy"
        
        
        let dateString = ges.datestring
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        if let dates = dateFormatter.date(from: dateString!) {
            print("Converted Date:", dates)
            self.fsCaleView.deselect(dates)
        } else {
            print("Failed to convert string to date.")
        }
        
        fsCaleView.isHidden  = true
        
        
        if DefaultsKeys.dateArr.count < 1 {
            
            if initiateCallLbl.text != "Time" &&  doNotCallLbl.text != "Time" {
                
                self.ValidateField()
            }else{
                Util .showAlert("", msg: "Please Select Schedule Time");
            }
        }else{
            disableButtonAction()
        }
        
        
        if dateArr.count >= 6{
            
            cvTopConstain.constant = 200
        }else{
            
            cvTopConstain.constant = CGFloat(30*dateArr.count)
            
        }
        



        cv.isHidden  = false
        cv.delegate = self
        cv.dataSource = self
        cv.reloadData()
        //
    }
    @IBAction func doneActionVc(_ sender: Any) {
        
        if dateArr.count == 0{
            calendarView.isHidden  = true
            cv.isHidden  = true
            cvTopConstain.constant = 0
        }
        else{
            
            print("urlDataertryu",urlData)
            
            if urlData == nil{
                
                if initiateCallLbl.text != "Time" && doNotCallLbl.text != "Time" && urlData != nil{
                    
                    enableButtonAction()
                }else{
                    disableButtonAction()
                    
                }
                
                
            }else{
                if initiateCallLbl.text != "Time" && doNotCallLbl.text != "Time" && urlData != nil{
                    
                    enableButtonAction()
                }else{
                    
                    disableButtonAction()
                }
                
            }
            
            
            calendarView.isHidden  = true
            cv.isHidden  = false
            cvTopConstain.constant = 200
            if  self.fromView == "History" {
                
                staffGroupBtnTop.constant = 580
            }else{
                staffGroupBtnTop.constant = 695
            }
            viewTopCon.constant = 10
            if dateArr.count >= 6{
                
                cvTopConstain.constant = 200
            }else{
                
                cvTopConstain.constant = CGFloat(30*dateArr.count)
                
            }
            
            cv.delegate = self
            cv.dataSource = self
            cv.reloadData()
        }
        
        
        
        
    }
    
    
    
    
    @IBAction func doNotCallAction() {
        
        timeId = "2"
        timeSS()
    }
    
    @IBAction func instantAction() {
        
        
        
        instantImg.image = UIImage(named: "PurpleRadioSelect")
        scheduleView.image = UIImage(named: "RadioNormal")
        DefaultsKeys.SelectInstantSchedule = 0
        
        sheduleCallListView.isHidden = true
        scheduleCallHeight.constant = 0
        initiateCallView.isHidden = true
        doNotCallView.isHidden = true
        cv.isHidden = true
        
        viewTopCon.constant = -190
        voiceHistoryTop.constant = -100
        staffGroupBtnTop.constant = 510
        calendarView.isHidden  = true
        doneView.isHidden  = true
        fsCaleView.isHidden  = true
        
        voiceHistoryHeight.constant = 400
        selectDateView.isHidden = true
        
    }
    
    @IBAction func scheduleAction() {
        instantImg.image = UIImage(named: "RadioNormal")
        scheduleView.image = UIImage(named: "PurpleRadioSelect")
        voiceHistoryTop.constant = 80
        voiceHistoryHeight.constant = 250
        sheduleCallListView.isHidden = false
        scheduleCallHeight.constant = 165
        initiateCallView.isHidden = false
        doNotCallView.isHidden = false
        DefaultsKeys.SelectInstantSchedule = 1
        staffGroupBtnTop.constant = 600
        
        calendarView.isHidden  = true
        doneView.isHidden  = true
        fsCaleView.isHidden  = true
        selectDateView.isHidden = false
        viewTopCon.constant = -80
        cv.isHidden = false
        
        if initiateCallLbl.text != "Time" && doNotCallLbl.text != "Time"  && urlData != nil{
            
            
            
            
            if dateArr.count != 0 {
                enableButtonAction()
            }else{
                disableButtonAction()
            }
        }else{
            disableButtonAction()
            
        }
        
        
        
        if  self.fromView == "History" {
            
            staffGroupBtnTop.constant = 540
        }else{
            
            
        }
        
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dateArr.count == 0{
            
            return 0
        }else{
            
            return dateArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        print("tableViewtableViewtableView")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rowId, for: indexPath) as! ScheduleCallCollectionViewCell
        cell.dateLbl.text = dateArr[indexPath.row]
        
        
        print("dateAre3r",dateArr)
        
        
        
        let deleteGes = deleteGesture(target: self, action: #selector(deleteAction))
        deleteGes.id = indexPath.row
        deleteGes.datestring = dateArr[indexPath.row]
        cell.deleteView.addGestureRecognizer(deleteGes)
        return cell
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2, height: 100)
    }
    
    
    
    
    
}

class StaffDateGesture : UITapGestureRecognizer {
    var id : String!
    var datestring : String!
}




extension Date {
    func isSameDay1(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: date)
    }
}
