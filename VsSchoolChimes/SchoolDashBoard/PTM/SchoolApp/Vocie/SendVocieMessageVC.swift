
//
//  SendVocieMessageVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 18/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVFoundation

class SendVocieMessageVC: UIViewController,AVAudioRecorderDelegate, AVAudioPlayerDelegate,UICollectionViewDelegate,UICollectionViewDataSource, Apidelegate{
    
    
    @IBOutlet weak var StaffCollectionView: UICollectionView!
    
    @IBOutlet weak var StaffCollectionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var StaffViewHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var OtherView: UIView!
    @IBOutlet weak var StaffView: UIView!
    
    @IBOutlet weak var OthersViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var SelectSchoolCollectionView: UICollectionView!
    @IBOutlet weak var SendtoAllButton: UIButton!
    
    @IBOutlet weak var SendButton: UIButton!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var SelectSchoolButton: UIButton!
    
    var selectedSchool:Array = [String]()
    var didselectedSchool:Array = [String]()
    var CollectionselectedSchool:Array = [String]()
    var PerformAction = String()
    
    var StaffId = String()
    var SchoolId = String()
    var AlertSectionData = String()
    
    
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    
    var strApiFrom = NSString()
    var loginusername = String()
    var CallerTyepString = String()
    var loginAsName = String()
    var DetailsOfSelectedSchool: NSMutableArray = []
    var SelectedSectionArrayDetail = [String]()
    var SelectedGroupArrayDetail = [String]()
    var SelectedSectionCodeArray = [String]()
    var SelectedGroupCodeArray = [String]()
    var SectionArrayData:Array = [String]()
    var GroupArrayData:Array = [String]()
    var SectionCodeArrayData:Array = [String]()
    var GroupCodeArrayData:Array = [String]()
    var SectionGroupDetailDic:NSDictionary = [String:Any]() as NSDictionary
    
    var StaffSelectedStudentIdArray:Array = [String]()
    var StaffSelectedSectionDetailArray : NSMutableArray = []
    var StaffSelectedStudentIDDetailArray:Array = [Any]()
    var StaffSectionDetailArray:Array = [Any]()
    var AddtionalSectionDetail : NSMutableArray = []
    
    var StaffSubjectDetailArray: NSMutableArray = []
    var CollectionViewString = String()
    var StaffMessageArray = [Any]()
    var SelectedStaffSectionDic:NSDictionary = [String:Any]() as NSDictionary
    var FirstTimeStaffGettingDetail = String()
    var DumpDetailOfSection:NSMutableArray = []
    var pRemoveSelectedSectionDetailArray: NSMutableArray = []
    var pMainSelectedDetailsofSubjectArray: NSMutableArray = []
    
    var segueURL: URL?
    var urlData:URL?
    
    @IBOutlet weak var PlayVoiceButton: UIButton!
    @IBOutlet weak var SliderButton: UISlider!
    @IBOutlet weak var RemainingTimeLabel: UILabel!
    @IBOutlet weak var TotalDurationLabel: UILabel!
    
    
    @IBOutlet weak var ChooseReciptentsButton: UIButton!
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
    var TotaldurationFormat = String()
    var TotaldurationData = Int()
    var VoiceData : NSData? = nil
    var strCountryCode = String()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.isOpaque = false
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        StaffCollectionHeightConstraint.constant = 0
        StaffCollectionView.isHidden = true
        FirstTimeStaffGettingDetail = "FIRST"
        SelectSchoolCollectionView.alwaysBounceVertical =  true
        StaffCollectionView.alwaysBounceVertical =  true
        
        
        VoiceData = NSData(contentsOf: segueURL!)
        
        SelectSchoolCollectionView.isHidden = true
        
        loginusername = UserDefaults.standard.object(forKey:USERNAME) as! String
        StaffId = UserDefaults.standard.object(forKey: STAFFID) as! String
        SchoolId = UserDefaults.standard.object(forKey: SCHOOLID) as! String       
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            OthersViewHeight.constant = 190
            
        }
        else
        {
            OthersViewHeight.constant = 160
            
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(SendVocieMessageVC.catchNotification), name: NSNotification.Name(rawValue: "comeBack"), object:nil)
        nc.addObserver(self,selector: #selector(SendVocieMessageVC.catchNotificationSection), name: NSNotification.Name(rawValue: "comeBackSection"), object:nil)
        nc.addObserver(self,selector: #selector(SendVocieMessageVC.StaffCatchNotification), name: NSNotification.Name(rawValue: "StaffSectionComeback"), object:nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        urlData = segueURL!
        
        calucalteTotalTimeDuration()
        
        TotalDurationLabel.text = TotaldurationFormat
        SliderButton.value = 0.0
        
        ButtonCornerDesign()
        
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        
        if(loginAsName == "Staff")
        {
            OtherView.isHidden = true
            OthersViewHeight.constant = 0
            
        }
        else
        {
            StaffView.isHidden = true
            StaffViewHeightConst.constant = 0
            self.checkCollectionArrayDataCount()
            
        }
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        if(loginAsName == "Principal"){
            CallerTyepString = "M"
        }else{
            CallerTyepString = "A"
        }
        
        
        
        
    }
    //MARK: UPDATE SLIDER
    
    @objc func updateSlider()
    {
        if self.player!.currentItem?.status == .readyToPlay {
            
            time = CMTimeGetSeconds(self.player!.currentTime())
        }
        
        
        let duration : CMTime = playerItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        SliderButton.maximumValue = Float(seconds)
        SliderButton.minimumValue = 0.0
        
        SliderButton.value = Float(time)
        
        if(time > 0){
            let minutes = Int(time) / 60 % 60
            let secondss = Int(time) % 60
            
            let durationFormat = String(format:"%02i:%02i", minutes, secondss)
            RemainingTimeLabel.text = durationFormat
        }
        
        
        
        
        if(time == seconds)
        {
            
            timer.invalidate()
            PlayVoiceButton.isSelected = false
            SliderButton.value = 0.0
        }
        
    }
    
    //MARK: PLAYBACK SLIDER
    func playbackSliderValueChanged(playbackSlider:UISlider)
    {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime : CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        if(player != nil){
            player!.seek(to: targetTime)
        }else{
            
            SliderButton.value = playbackSlider.value
            
            
        }
        
        
    }
    
    func calucalteTotalTimeDuration() -> Void
    {
        playerItem = AVPlayerItem(url: urlData!)
        let duration : CMTime = playerItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        
        SliderButton.maximumValue = Float(seconds)
        
        
        let minutes = Int(seconds) / 60 % 60
        let secondss = Int(seconds) % 60
        
        
        TotaldurationData = Int(seconds)
        
        TotaldurationFormat = String(format:"/ %02i:%02i", minutes, secondss)
        TotalDurationLabel.text = TotaldurationFormat
        
    }
    
    // MARK: PLAY BUTTON ACTION
    
    @IBAction func actionPlayButton(_ sender: Any) {
        
        
        actionPlayButton(sender: PlayVoiceButton)
        
    }
    // MARK: SLIDER BUTTON ACTION
    
    
    @IBAction func actionSlider(_ sender: Any) {
        playbackSliderValueChanged(playbackSlider: SliderButton)
    }
    // MARK: CLOSE VIEW
    @IBAction func actionCloseVeiw(_ sender: Any) {
        playerDidFinishPlaying()
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: PLAY ACTION
    func actionPlayButton(sender: UIButton)
    {
        
        
        
        playerItem = AVPlayerItem(url: urlData!)
        
        
        player = AVPlayer(playerItem: playerItem!)
        
        
        if(strPlayStatus.isEqual(to: "close")){
            SliderButton.value = 0.0
        }
        
        
        if(PlayVoiceButton.isSelected)
        {
            PlayVoiceButton.isSelected = false
            
            let seconds1 : Int64 = Int64(SliderButton.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            
            player!.seek(to: targetTime)
            strPlayStatus = "play"
            player?.pause()
            
        }
        else
        {
            PlayVoiceButton.isSelected = true
            
            
            let seconds1 : Int64 = Int64(SliderButton.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            player!.seek(to: targetTime)
            
            strPlayStatus = "play"
            player?.volume = 1
            player?.play()
            
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
    }
    
    
    func playerDidFinishPlaying() {
        
        // Do Something
        if(player != nil){
            timer.invalidate()
            player?.pause()
            
            SliderButton.value = 0.0
            player?.rate = 0.0
            
            PlayVoiceButton.isSelected = false
            strPlayStatus = "close"
            player = nil
            player =  AVPlayer.init()
            playerItem?.seek(to: CMTime.zero)
            time = CMTimeGetSeconds(self.player!.currentTime())
            
            RemainingTimeLabel.text = ""
        }
    }
    
    
    
    @IBAction func actionSelectSchool(_ sender: Any) {
        let svc = self.storyboard?.instantiateViewController(withIdentifier: "SelectSchoolVC") as! SelectSchoolVC
        
        svc.SegueSelectedSchoolDetailArray = DetailsOfSelectedSchool
        self.present(svc, animated: false, completion: nil)
        
    }
    //MARK: COLLECTION VIEW
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(CollectionViewString == "Staff")
        {
            return 1
        }
        else
        {
            return DetailsOfSelectedSchool.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(CollectionViewString == "Staff")
        {
            return StaffSelectedSectionDetailArray.count
        }
        else
        {
            return 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if(CollectionViewString == "Staff")
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StaffSendMessageCVCell", for: indexPath) as! StaffSendMessageCVCell
            cell.layer.cornerRadius = 5
            cell.layer.masksToBounds = true
            SelectedStaffSectionDic = StaffSelectedSectionDetailArray[indexPath.row] as! NSDictionary
            let SectionName = SelectedStaffSectionDic["Class"] as! String
            let Section = SelectedStaffSectionDic["Section"] as! String
            cell.SectionNameLabel.text = SectionName + " - " + Section
            cell.SubjectNameLabel.text = SelectedStaffSectionDic["SubjectName"] as? String
            return cell
            
            
        }
        else
        {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectSchoolCVCell", for: indexPath) as! SelectSchoolCVCell
            cell.layer.cornerRadius = 5
            cell.layer.masksToBounds = true
            
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                cell.frame.size.width = 590
                
            }
            else
            {
                cell.frame.size.width = 270
                
            }
            if(loginAsName == "Group Head")
            {
                cell.EditButton.isHidden = true
                
            }
            cell.EditButton.layer.cornerRadius = 5
            cell.EditButton.layer.borderWidth = 1
            cell.EditButton.layer.borderColor = UIColor.gray.cgColor
            cell.EditButton.layer.masksToBounds = true
            let DictioanryData = DetailsOfSelectedSchool[indexPath.row] as! NSDictionary
            cell.SelectedSchoolNameLabel.text = DictioanryData["SchoolName"] as? String
            cell.EditButton.addTarget(self, action: #selector(actionEditView(sender:)), for: .touchUpInside)
            cell.EditButton.tag = indexPath.section
            cell.DeleteButton?.layer.setValue(indexPath.section, forKey: "delete")
            cell.DeleteButton.addTarget(self, action: #selector(actionDeleteItemInCollectionView(sender:)), for: .touchUpInside)
            
            return cell
        }
        
    }
    @objc func actionEditView(sender:UIButton)
    {
        let Buttontag = sender.tag
        let sectionSelection = self.storyboard?.instantiateViewController(withIdentifier: "SelectSectionVC") as! SelectSectionVC
        sectionSelection.SchoolDetailArrayData.append(DetailsOfSelectedSchool[Buttontag])
        sectionSelection.SegueSelectedSectionArray = SelectedSectionArrayDetail
        sectionSelection.SegueSelectedSectionCodeArray = SelectedSectionCodeArray
        sectionSelection.SegueSelectedGroupArray = SelectedGroupArrayDetail
        sectionSelection.SegueSelectedGroupCodeArray = SelectedGroupCodeArray
        
        self.present(sectionSelection, animated: false, completion: nil)    }
    @objc func actionDeleteItemInCollectionView(sender: UIButton)
    {
        
        let i : Int = (sender.layer.value(forKey: "delete")) as! Int
        
        DetailsOfSelectedSchool.removeObject(at: i)
        
        self.SelectSchoolCollectionView.reloadData()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            collectionviewheightIpad()
            
        }
        else
        {
            collectionviewheight()
        }
        self.checkCollectionArrayDataCount()
        
        
    }
    func checkCollectionArrayDataCount()
    {
        if(DetailsOfSelectedSchool.count > 0)
        {
            SendButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
            SendButton.isUserInteractionEnabled = true
            
            
        }
        else
        {
            SendButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            SendButton.isUserInteractionEnabled = false
            
            
        }
    }
    
    
    func collectionviewheightIpad()
    {
        let height = DetailsOfSelectedSchool.count
        
        if(height < 5)
        {
            let heightconst = SelectSchoolCollectionView.collectionViewLayout.collectionViewContentSize.height
            
            
            if(height == 1)
            {
                
                OthersViewHeight.constant = 240
                
            }
            if(height == 2)
            {
                
                OthersViewHeight.constant = 280
                
                
            }
            if(height == 3)
            {
                OthersViewHeight.constant = 330
                
                
                
            }
            if(height == 4)
            {
                OthersViewHeight.constant = 375
                
                
            }
            if(height == 0)
            {
                
                OthersViewHeight.constant = 190
                collectionViewHeight.constant = 0
                
            }
            
            collectionViewHeight.constant = heightconst
            
        }
        else
        {
            
            OthersViewHeight.constant = 380
            collectionViewHeight.constant = 200
            
            
        }
        
    }
    //MARK: COLLECTION VIEW HEIGHT
    
    func collectionviewheight()
    {
        let height = DetailsOfSelectedSchool.count
        //print(height)
        if(height < 3)
        {
            let heightconst = SelectSchoolCollectionView.collectionViewLayout.collectionViewContentSize.height
            
            
            if(height == 1)
            {
                
                OthersViewHeight.constant = 200
                
            }
            if(height == 2)
            {
                
                OthersViewHeight.constant =  245
                
                
            }
            if(height == 0)
            {
                OthersViewHeight.constant =  160
                collectionViewHeight.constant = 0
                
                
            }
            
            collectionViewHeight.constant = heightconst
            
        }
        else
        {
            
            OthersViewHeight.constant = 250
            collectionViewHeight.constant = 100
            
            
        }
    }
    //MARK: SECTION SELECTION COMEBACK
    
    @objc func catchNotificationSection(notification:Notification) -> Void
    {
        PerformAction = notification.userInfo?["actionkey"] as! String
        
        if(PerformAction == "ok")
        {
            SelectedSectionArrayDetail = notification.userInfo?["SectionDetailArray"] as! [String]
            
            SelectedSectionCodeArray = notification.userInfo?["SectionCodeArray"] as! [String]
            
            
            SelectedGroupArrayDetail = notification.userInfo?["GroupDetailArray"] as! [String]
            
            SelectedGroupCodeArray = notification.userInfo?["GroupCodeArray"] as! [String]
            
        }
        else
        {
            
            SelectedSectionArrayDetail = notification.userInfo?["SectionDetailArray"] as! [String]
            
            SelectedSectionCodeArray = notification.userInfo?["SectionCodeArray"] as! [String]
            
            
            SelectedGroupArrayDetail = notification.userInfo?["GroupDetailArray"] as! [String]
            
            SelectedGroupCodeArray = notification.userInfo?["GroupCodeArray"] as! [String]
            
            
        }
        
        
    }
    //MARK: STAFF SECTION SELECTION COMEBACK
    
    @objc func StaffCatchNotification(notification:Notification) -> Void
    {
        CollectionViewString = "Staff"
        //print("staff notification")
        PerformAction = notification.userInfo?["actionkey"] as! String
        
        if(PerformAction == "ok")
        {
            FirstTimeStaffGettingDetail = "Second"
            
            
            StaffCollectionView.isHidden = false
            SendButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
            SendButton.isUserInteractionEnabled = true
            
            
            StaffSectionDetailArray = notification.userInfo?["SectionDetail"] as! [Any]
            StaffSelectedSectionDetailArray = notification.userInfo?["SelectedSectionDetail"] as! NSMutableArray
            DumpDetailOfSection = notification.userInfo?["MainSelectedSectionDetail"] as! NSMutableArray
            AddtionalSectionDetail = notification.userInfo?["AddtionalSectionDetail"] as! NSMutableArray
            
            
            StaffCollectionHeightConstraint.constant = 80
            StaffViewHeightConst.constant = 130
            self.StaffCollectionView.reloadData()
        }
        else
        {
            FirstTimeStaffGettingDetail = "Second"
            StaffSectionDetailArray = notification.userInfo?["SectionDetail"] as! [Any]
            StaffSelectedSectionDetailArray = notification.userInfo?["SelectedSectionDetail"] as! NSMutableArray
            DumpDetailOfSection = notification.userInfo?["MainSelectedSectionDetail"] as! NSMutableArray
            AddtionalSectionDetail = notification.userInfo?["AddtionalSectionDetail"] as! NSMutableArray
            
            StaffCollectionView.isHidden = true
            StaffCollectionHeightConstraint.constant = 0
            StaffViewHeightConst.constant = 45
            
            
        }
        
        
    }
    
    //MARK: SELECT SCHOOL COMEBACK
    
    @objc func catchNotification(notification:Notification) -> Void {
        
        
        PerformAction = notification.userInfo?["actionkey"] as! String
        
        if(PerformAction == "ok")
        {
            DetailsOfSelectedSchool = notification.userInfo?["SchoolDetail"] as! NSMutableArray
            
            for i in 0..<DetailsOfSelectedSchool.count
            {
                SectionGroupDetailDic = DetailsOfSelectedSchool[i] as! NSDictionary
                
                let Groupcode = SectionGroupDetailDic["GrpCode"] as! NSArray
                let SecCode = SectionGroupDetailDic["StdCode"] as! NSArray
                for i in 0..<Groupcode.count
                {
                    let mygroupdic:NSDictionary = Groupcode.object(at: i) as! NSDictionary
                    let mystring = mygroupdic["GroupName"] as! String
                    let groupid = mygroupdic["GroupCode"] as! String
                    GroupArrayData.append(mystring)
                    GroupCodeArrayData.append(groupid)
                }
                for i in 0..<SecCode.count
                {
                    let mygroupdic:NSDictionary = SecCode.object(at: i) as! NSDictionary
                    let mystring = mygroupdic["Stdname"] as! String
                    let mystdid = mygroupdic["StdId"] as! String
                    SectionArrayData.append(mystring)
                    SectionCodeArrayData.append(mystdid)
                    
                }
                SelectedSectionCodeArray = SectionCodeArrayData
                SelectedGroupCodeArray = GroupCodeArrayData
            }
            
            SelectSchoolCollectionView.isHidden = false
            self.SelectSchoolCollectionView.reloadData()
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                collectionviewheightIpad()
                
            }
            else
            {
                collectionviewheight()
            }
        }
        else
        {
            DetailsOfSelectedSchool = notification.userInfo?["SchoolDetail"] as! NSMutableArray
            if(DetailsOfSelectedSchool.count > 0)
            {   SelectSchoolCollectionView.isHidden = false
                self.SelectSchoolCollectionView.reloadData()
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    collectionviewheightIpad()
                    
                }
                else
                {
                    collectionviewheight()
                }
                
            }
            else
            {
                SelectSchoolCollectionView.isHidden = true
                collectionViewHeight.constant = 5
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    OthersViewHeight.constant = 190
                    
                }
                else
                {
                    OthersViewHeight.constant = 160
                }
                
            }
        }
        
        
        
        
    }
    
    
    // MARK: SEND VOICE MESSAGE BUTTON ACTION 
    @IBAction func actionSendVoiceMessageToAll(_ sender: Any) {
        SendVoiceToAllAsPrincipalapi()
    }
    
    
    @IBAction func actionSendVoiceToSelectedClass(_ sender: Any) {
        
        
        if(loginAsName == "Staff")
        {
            self.SendVoiceAsStaffapi()
        }
        else
        {
            self.SendImageAToSelectedStandardGroupASPrincipalapi()
        }
        
    }
    
    
    //MARK: SEND VOICE MESSAGE API CALLING
    
    func SendVoiceAsStaffapi()
    {
        showLoading()
        strApiFrom = "SendVoiceAsStaff"
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        let arrUserData : NSMutableArray = []
        let arrTargetCodeData : NSMutableArray = []
        
        for i in 0..<StaffSelectedSectionDetailArray.count
        {
            SelectedStaffSectionDic = StaffSelectedSectionDetailArray[i] as! NSDictionary
            let myTargetCodeDict:NSMutableDictionary = ["TargetCode" : SelectedStaffSectionDic["ClassSecCode"]!,"SubCode" : SelectedStaffSectionDic["SubjectCode"]! ,"MessageToAll" : SelectedStaffSectionDic["MsgToAll"]!, COUNTRY_CODE: strCountryCode ,"IDS" : SelectedStaffSectionDic["StudentIdArrayData"]!]
            arrTargetCodeData.add(myTargetCodeDict)
        }
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Duration" : TotaldurationData,"Seccode":arrTargetCodeData]
        
        arrUserData.add(myDict)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.callPassVoiceStaff(baseUrlString, myString, "SendVoiceAsStaff", VoiceData as Data?)
    }
    
    func GetSubjectDetailAsStaffapi()
    {
        showLoading()
        strApiFrom = "GetSubjectDetail"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SUBJECT_DETAIL
        
        let arrUserData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId, COUNTRY_CODE: strCountryCode]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSubjectDetail")
    }
    
    
    
    
    func SendVoiceToAllAsPrincipalapi()
    {
        showLoading()
        strApiFrom = "VoiceToAllPrincipal"
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let arrUserData : NSMutableArray = []
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"CallerType" : CallerTyepString,"CallerID": loginusername,"Duration" : TotaldurationData, COUNTRY_CODE: strCountryCode]
        arrUserData.add(myDict)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.callPassVoiceParms(baseUrlString, myString, "VoiceToAllPrincipal", VoiceData as Data?)
    }
    
    
    func SendImageAToSelectedStandardGroupASPrincipalapi()
    {
        showLoading()
        strApiFrom = "SendVoiceAsPrincipalToSelectedClass"
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        [Constants.printLogKey("Request Url", printValue: baseUrlString)]
        let arrUserData : NSMutableArray = []
        let arrGroupCodeData : NSMutableArray = []
        let arrSectionCodeData : NSMutableArray = []
        
        for i in 0..<SelectedSectionCodeArray.count
        {
            let mystring = SelectedSectionCodeArray[i]
            let SectionDic:NSDictionary = ["TargetCode" : mystring]
            arrSectionCodeData.add(SectionDic)
            
            
        }
        for i in 0..<SelectedGroupCodeArray.count
        {
            let mystring = SelectedGroupCodeArray[i]
            let GroupDic:NSDictionary = ["TargetCode" : mystring]
            arrGroupCodeData.add(GroupDic)
            
        }
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Duration" : TotaldurationData,"Seccode" : arrSectionCodeData,"GrpCode":arrGroupCodeData, COUNTRY_CODE: strCountryCode]
        arrUserData.add(myDict)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: myDict)
        print(myString!)
        apiCall.callVoiceParams(baseUrlString, myString, "SendVoiceAsPrincipalToSelectedClass", VoiceData as Data?)
        
        
    }
    // MARK: API  RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        
        if(csData != nil)
        {
            if(strApiFrom.isEqual(to: "VoiceToAllPrincipal"))
            {
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                for var i in 0..<arrayDatas.count
                {
                    dicResponse = arrayDatas[i] as! NSDictionary
                }
                
                let myalertstring = dicResponse["Message"] as! String
                
                if let mystatus = dicResponse["Status"] as? String {
                    
                    if(mystatus == "y")
                    {
                        Util.showAlert("", msg: myalertstring)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                    else
                    {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                }
            }
            else if(strApiFrom.isEqual(to: "SendVoiceAsPrincipalToSelectedClass"))
            {
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                
                for var i in 0..<arrayDatas.count
                {
                    dicResponse = arrayDatas[i] as! NSDictionary
                }
                let myalertstring = dicResponse["Message"] as! String
                var mystatus = String()
                guard let status = dicResponse["Status"] as? String else {
                    Util.showAlert("", msg: myalertstring)
                    return
                }
                mystatus = status
                if(mystatus == "y")
                {
                    Util.showAlert("", msg: myalertstring)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                else
                {
                    Util.showAlert("", msg: myalertstring)
                    dismiss(animated: false, completion: nil)
                }
                
                
            }
            else if(strApiFrom.isEqual(to: "SendVoiceAsStaff"))
            {
                
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                for var i in 0..<arrayDatas.count
                {
                    dicResponse = arrayDatas[i] as! NSDictionary
                }
                
                let myalertstring = dicResponse["Message"] as! String
                //print(myalertstring)
                let mystatus = dicResponse["Status"] as! String
                
                
                
                if(mystatus == "y")
                {
                    Util.showAlert("", msg: myalertstring)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    
                }
                else
                {
                    Util.showAlert("", msg: myalertstring)
                    dismiss(animated: true, completion: nil)
                }
            }
            
            else if(strApiFrom.isEqual(to: "GetSubjectDetail"))
            {
                if((csData?.count)! > 0)
                {
                    StaffSubjectDetailArray = csData!
                    actionMoveToSectionSelectionAsStaff()
                    
                    
                }
                else
                {
                    Util.showAlert("", msg: "No Record Found")
                    dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
            
            
        }
        else
        {
            Util.showAlert("", msg: "Server Response Failed")
        }
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        // print("Error")
        Util .showAlert("", msg: "Server connection failed!");
        
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
    }
    
    // MARK: CHOOSE RECIPENTS BUTTON ACTION
    @IBAction func actionChooseRecipients(_ sender: Any) {
        
        if(FirstTimeStaffGettingDetail == "FIRST")
        {
            GetSubjectDetailAsStaffapi()
        }
        else
        {
            if(StaffSectionDetailArray.count > 0)
            {
                let SectionVC = self.storyboard?.instantiateViewController(withIdentifier: "StaffSectionSelectionVC") as! StaffSectionSelectionVC
                SectionVC.DetailsofSubjectArray = StaffSectionDetailArray as! Array
                SectionVC.AddtionalDetailsofSubjectArray = AddtionalSectionDetail
                SectionVC.SelectedSectionDetailArray = StaffSelectedSectionDetailArray
                SectionVC.SelectedDetailsofSubjectArray = DumpDetailOfSection as! NSMutableArray
                self.present(SectionVC, animated: false, completion: nil)
            }
            else
            {
                self.actionMoveToSectionSelectionAsStaff()
            }
            
            
        }
    }
    
    
    func actionMoveToSectionSelectionAsStaff()
    {
        let SectionVC = self.storyboard?.instantiateViewController(withIdentifier: "StaffSectionSelectionVC") as! StaffSectionSelectionVC
        SectionVC.SegueDetailsofSubjectArray = StaffSubjectDetailArray as! Array
        
        self.present(SectionVC, animated: false, completion: nil)
    }
    
    
    func ButtonCornerDesign()
    {
        ChooseReciptentsButton.layer.cornerRadius = 5
        ChooseReciptentsButton.layer.masksToBounds = true
        SendtoAllButton.layer.cornerRadius = 5
        SendtoAllButton.layer.masksToBounds = true
        
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        
        
        SelectSchoolButton.layer.cornerRadius = 5
        SelectSchoolButton.layer.masksToBounds = true
    }
    func ToCallNoSectionDatainApi()
    {
        let alertController = UIAlertController(title: "Warning", message: AlertSectionData, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            
            self.actionMoveToSectionSelectionAsStaff()
        }
        
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
}
