//
//  SchoolSelectionVC.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 17/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SchoolSelectionVC: UIViewController ,UITableViewDelegate,UITableViewDataSource,Apidelegate{
    
    @IBOutlet weak var SendButton: UIButton!
    
    
    var staffRole : String!
    @IBOutlet weak var SchoolSelectionTableView: UITableView!
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var schoolsArray = NSMutableArray()
    var selectedSchoolsArray = NSMutableArray()
    var voiceHistoryArray = NSMutableArray()
    var SelectedArray = NSArray()
    var strSchoolID = String()
    var strStaffID = String()
    var strDuration = String()
    var strCallerType = String()
    var strDescription = String()
    var fromView = String()
    var senderName = String()
    var urlData: URL?
    let UtilObj = UtilClass()
    let Const = Constants()
    var VoiceData : NSData? = nil
    var strEmergency = String()
    var strMessage = String()
    var fromVC = String()
    var selectedSchoolDict : NSDictionary = NSDictionary()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var getSchoolID : String!
    var biometricEnable : Int!
    var getStaffID : String!
    var sendHide : Int!
    var strLanguage : String!
    
    
    var duration : String!
    var desc : String!
    
    var selectedSchoolDictionary = NSMutableDictionary()
    var typeList : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        strSchoolID = defaults.string(forKey: DefaultsKeys.SchoolD)!
        
        print("fromVC",fromVC)
        print("typeList",typeList)
        
        print("typeListselectedSchoolDictionary",selectedSchoolDictionary)
        
        print("SCHOOLSELECTIONSEGUE11112")

        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        let userDefaults = UserDefaults.standard
        
        staffRole = userDefaults.string(forKey: DefaultsKeys.StaffRole)!
        print("staffRole",staffRole)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        
        print("appDelegateisPrincipal1",appDelegate.isPrincipal)
        
        let idGroupHead = appDelegate.idGroupHead as NSString
        let isPrincipal = appDelegate.isPrincipal as NSString
        
        print("isPrincipalSchool",isPrincipal)
        print("idGroupHead",idGroupHead)
        print("isPrincipalisEqualShool",isPrincipal .isEqual(to: "true"))
        self.SendButton.isHidden = true
        
        if(isPrincipal .isEqual(to: "true")){
            self.SendButton.isHidden = true
            strCallerType = "M"
        }
        else if(idGroupHead .isEqual(to: "true")){
            strCallerType = "A"
        }
        let loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        print("loginAsName \(loginAsName)")
        if(loginAsName == "Principal"){
            
            
            self.SendButton.isHidden = true
            
            strCallerType = "M"
        }else {
            strCallerType = "A"
        }
        
        
        
        self.SendButtonEnable()
        
        for  schoolDict in appDelegate.LoginSchoolDetailArray {
            let singleSchoolDictionary = schoolDict as? NSDictionary
            let schoolDic = NSMutableDictionary()
            schoolDic["SchoolID"] = singleSchoolDictionary?.object(forKey: "SchoolID")
            schoolDic["StaffID"] = singleSchoolDictionary?.object(forKey: "StaffID")
            schoolDic["SchoolId"] = singleSchoolDictionary?.object(forKey: "SchoolID")
            schoolsArray.add(schoolDic)
            selectedSchoolsArray.add(schoolDic)
            
        }
        SelectedArray = selectedSchoolsArray
        
        
        if (self.fromVC == "daily_collection_report") {
            //
        }
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        
        
        
    }
    
    func SendButtonEnable(){
        SendButton.isUserInteractionEnabled = true
        SendButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
    }
    func SendButtonDisable(){
        SendButton.isUserInteractionEnabled = false
        SendButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
    }
    
    //MARK: TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.LoginSchoolDetailArray.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 65
        }else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(senderName == "EmergencyVoice" || senderName == "GroupHeadVoice" || senderName == "GroupHeadText"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBoardTVCell", for: indexPath) as! NoticeBoardTVCell
            let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.row) as? NSDictionary
            cell.SchoolNameLbl.text = schoolDict?["SchoolName"] as? String
            let defaults = UserDefaults.standard
            var schoolNameReg  =  schoolDict?["SchoolNameRegional"] as? String

                    if schoolNameReg != "" && schoolNameReg != nil {

                        cell.SchoolNameRegionalLbl.text = schoolNameReg
                        cell.SchoolNameRegionalLbl.isHidden = false

    //                        cell.locationTop.constant = 4
                    }else{
                        cell.SchoolNameRegionalLbl.isHidden = true
            //            cell.SchoolNameRegional.backgroundColor = .red
                        cell.schoolNameTop.constant = 20

                    }
//

            //
            if((appDelegate.LoginSchoolDetailArray.count - 1) == indexPath.row){
                ValidateField()
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageTVCell", for: indexPath) as! TextMessageTVCell
            let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.row) as? NSDictionary
            cell.SchoolNameLbl.text = schoolDict?["SchoolName"] as? String
//
            var schoolNameReg  =  schoolDict?["SchoolNameRegional"] as? String

                    if schoolNameReg != "" && schoolNameReg != nil {

                        cell.SchoolNameRegionalLbl.text = schoolNameReg
                        cell.SchoolNameRegionalLbl.isHidden = false

//                        cell.locationTop.constant = 4
                    }else{
                        cell.SchoolNameRegionalLbl.isHidden = true
            //            cell.SchoolNameRegional.backgroundColor = .red
                        cell.schoolNameTop.constant = 20

                    }

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(senderName == "EmergencyVoice" || senderName == "GroupHeadVoice" || senderName == "GroupHeadText"){
            if(selectedSchoolsArray .contains(schoolsArray.object(at: indexPath.row))){
                selectedSchoolsArray.remove(schoolsArray.object(at: indexPath.row))
            }else{
                selectedSchoolsArray.add(schoolsArray.object(at: indexPath.row))
            }
            ValidateField()
        }else{
            selectedSchoolDict = schoolsArray[indexPath.row] as! NSDictionary
            print("selectedSchoolDict \(selectedSchoolDict)")
            
            print("fromVC12",fromVC)
            
            let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.row) as? NSDictionary
            getSchoolID = schoolDict!["SchoolID"] as! String
            getStaffID = schoolDict!["StaffID"] as! String
            biometricEnable = schoolDict!["biometricEnable"] as! Int
            print("SchoolID12",getSchoolID)
            print("voiceHistoryArray",voiceHistoryArray)
            print("typeListtypeList",typeList)
            print("biometricEnable",schoolDict!["biometricEnable"])
            let userDefaults = UserDefaults.standard
            
            DefaultsKeys.school_type.removeAll()
            userDefaults.set(schoolDict!["school_type"], forKey: DefaultsKeys.school_type)
            
            if typeList == "1"{
                let schoolVC  = self.storyboard?.instantiateViewController(withIdentifier: "StandardGroupSelectionVC") as! StandardGroupSelectionVC
                schoolVC.SchoolID = getSchoolID as! NSString
                schoolVC.strCountryCode = strCountryCode
                schoolVC.groupHeadType = "1"
                schoolVC.VoiceHistoryArray = voiceHistoryArray
                schoolVC.fromView = self.fromView
                schoolVC.urlData = urlData
                schoolVC.selectedSchoolDictionary = selectedSchoolDictionary
                schoolVC.fromViewController = "VoiceToParents"
                schoolVC.SchoolID = getSchoolID as! NSString
                schoolVC.staffId = getStaffID as! NSString
                
                schoolVC.duration = duration as! NSString
                schoolVC.desc = desc as! NSString
                
                schoolVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                self.present(schoolVC, animated: true, completion: nil)
            }
            if(self.fromVC == "p2"){
                let txtHomeVC  = self.storyboard?.instantiateViewController(withIdentifier: "TextMessageVC") as! TextMessageVC
                txtHomeVC.SchoolDict = selectedSchoolDict
                txtHomeVC.strFromVC = "Principal"
                txtHomeVC.checkSchoolId = "1"
                txtHomeVC.checkMultipleType = "1"
                txtHomeVC.strStaffID = getStaffID
                txtHomeVC.strSchoolID = getSchoolID
                txtHomeVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                self.present(txtHomeVC, animated: true, completion: nil)
            }else if(self.fromVC == "p24"){
                self.performSegue(withIdentifier: "SchoolSelectionToChatSegue", sender: self)
            }else if(self.fromVC == "p26"){
                let txtHomeVC  = self.storyboard?.instantiateViewController(withIdentifier: "OnlineMeetingVC") as! OnlineMeetingVC
                txtHomeVC.SchoolDetailDict = selectedSchoolDict
                txtHomeVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                self.present(txtHomeVC, animated: true, completion: nil)
            } else if(self.fromVC == "p28"){
                let vc = NewDailyCollectionViewController(nibName: nil, bundle: nil)
                vc.SchoolId = getSchoolID
                vc.type = 1
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
            
            else if(self.fromVC == "p29"){
                
                
                
                let vc = StudentReportViewController(nibName: nil, bundle: nil)
                vc.SchoolDetailDict = selectedSchoolDict
                vc.schoolType = "1"
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            } else if(self.fromVC == "p30"){
                
                
                print("getstaffRole",staffRole)
                print("getStaffID",getStaffID)
                print("getSchoolID",getSchoolID)
                
                if staffRole == "p2" {
                    
                    let vc = PrincipalLessonPlanViewController(nibName: nil, bundle: nil)
                    vc.SchoolDetailDict = selectedSchoolDict
                    vc.schoolType = "1"
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                    
                }
                else  if staffRole == "p3"{
                    let vc = LessonPlanViewController(nibName: nil, bundle: nil)
                    vc.SchoolId = getSchoolID
                    vc.StaffId = getStaffID
                    vc.schoolType = "MultipleSchool"
                    print("getStaffID",getStaffID)
                    print("getSchoolID",getSchoolID)
                    
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
                
                
                
                
                
                
            }else if(self.fromVC == "p31"){
                
                
                print("getstaffRole",staffRole)
                print("getStaffID",getStaffID)
                print("getSchoolID",getSchoolID)
                
                
                let vc = PendingFeeReportViewController(nibName: nil, bundle: nil)
                vc.SchoolId = getSchoolID
                vc.type = 1
                
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
                
            }
            
            
            else if(self.fromVC == "p34"){
                
                
                print("getstaffRole",staffRole)
                print("getStaffID",getStaffID)
                print("getSchoolID",getSchoolID)
                
                
                let vc = StaffPtmViewController(nibName: nil, bundle: nil)
                vc.type = 1
                vc.instituteId = Int(getSchoolID)!
                vc.staffId = Int(getStaffID)!
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            else if(self.fromVC == "p32"){
                
                
                print("getstaffRole",staffRole)
                print("getStaffID",getStaffID)
                print("getSchoolID",getSchoolID)
                
                
                let vc = LocationViewController(nibName: nil, bundle: nil)
                vc.type = 1
                vc.instituteId = Int(getSchoolID)
                vc.staffId = Int(getStaffID)
                vc.bioMatricEnable = biometricEnable
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            else if(self.fromVC == "p33"){
                
                
                print("getstaffRole",staffRole)
                print("getStaffID",getStaffID)
                print("getSchoolID",getSchoolID)
                
                
                let vc = LocationHistoryVc(nibName: nil, bundle: nil)
                vc.type = 1
                vc.instituteId = Int(getSchoolID)
                vc.staffId = Int(getStaffID)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            
            else if(self.fromVC == "p35"){
                
                
                print("getstaffRole",staffRole)
                print("getStaffID",getStaffID)
                print("getSchoolID",getSchoolID)
                
         
             
           
//                let storyboard = UIStoryboard(name: "staffNoticeBoard", bundle: nil)
//                                                let viewController = storyboard.instantiateInitialViewController() as! StaffnoticeBoardVcViewController
//                
//                
//                viewController.type = 1
//                viewController.instituteId = Int(getSchoolID)
//                viewController.staffId = Int(getStaffID)
//               
//                viewController.modalPresentationStyle = .fullScreen
//                                                self.present(viewController, animated: true)
////                
                
            }
            
            else{
                self.performSegue(withIdentifier: "SchoolSelectionToVoiceMessageSegue", sender: self)
            }
        }
    }
    
    
    


    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(senderName == "EmergencyVoice" || senderName == "GroupHeadVoice" || senderName == "GroupHeadText"){
            if(selectedSchoolsArray .contains(schoolsArray.object(at: indexPath.row))){
                selectedSchoolsArray.remove(schoolsArray.object(at: indexPath.row))
            }else{
                selectedSchoolsArray.add(schoolsArray.object(at: indexPath.row))
            }
            ValidateField()
        }else{
            
        }
    }
    
    func ValidateField(){
        SendButton.isHidden = false
        if( selectedSchoolsArray.count > 0){
            self.SendButtonEnable()
        }else{
            self.SendButtonDisable()
        }
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionSendButton(_ sender: UIButton){
        if(Util .isNetworkConnected()){
            if( strDuration != "0" && selectedSchoolsArray.count > 0){
                if(senderName == "EmergencyVoice"){
                    strEmergency = "1"
                    if( self.fromView == "Record"){
                        self.callSendVoiceApi()
                    }else{
                        self.callSendHistoryVoiceApi()
                    }
                }else  if(senderName == "GroupHeadVoice"){
                    strEmergency = "0"
                    if( self.fromView == "Record"){
                        self.callSendVoiceApi()
                    }else{
                        self.callSendHistoryVoiceApi()
                    }
                }else  if(senderName == "GroupHeadText"){
                    self.callSendSMSToEntireSchools()
                }
            }
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
    }
    
    //MARK: Api Calling
    
    func callSendVoiceApi()
    {
        showLoading()
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
            print("requestStringerSendVoiceToEntireSchools",requestStringer)
            
            let arrUserData : NSMutableArray = []
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["Description" : strDescription,
                                              "CallerType" : strCallerType,
                                              "Duration" : strDuration,
                                              "isEmergency": strEmergency,
                                              "School" : selectedSchoolsArray, COUNTRY_CODE: strCountryCode]
            arrUserData.add(myDict)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: myDict)
            UtilObj.printLogKey(printKey: "VoiceData", printingValue: VoiceData!)
            print("voiceMyString\(myString)")
            apiCall.callPassVoiceParms(requestString, myString, "EmergencyVoice", VoiceData as Data?)
        }else{
            let requestStringer = baseUrlString! + ScheduleSendVoiceToEntireSchools
            print("requestStringerScheduleSendVoiceToEntireSchools",requestStringer)
            
            let arrUserData : NSMutableArray = []
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["Description" : strDescription,
                                              "CallerType" : strCallerType,
                                              "Duration" : strDuration,
                                              "isEmergency": strEmergency,
                                              "School" : selectedSchoolsArray, COUNTRY_CODE: strCountryCode ,"StartTime" : initialTime , "EndTime" : doNotDial , "Dates" : DefaultsKeys.dateArr ]
            arrUserData.add(myDict)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: myDict)
            UtilObj.printLogKey(printKey: "VoiceData", printingValue: VoiceData!)
            print("voiceMyString\(myString)")
            apiCall.callPassVoiceParms(requestString, myString, "EmergencyVoice", VoiceData as Data?)
        }
    }
    
    func callSendHistoryVoiceApi() //SendVoiceToEntireSchool Api
    {
        showLoading()
        let voiceDict = voiceHistoryArray[0] as! NSDictionary
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime = DefaultsKeys.initialDisplayDate
        var doNotDial =  DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            let requestStringer = baseUrlString! + VOICE_HISTORY_ENTIRE_SCHOOL
            print("requestStringerVOICE_HISTORY_ENTIRE_SCHOOL",requestStringer)
            
            let arrUserData : NSMutableArray = []
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["Description" : String(describing: voiceDict["Description"]!),
                                              "CallerType" : strCallerType,
                                              "Duration" : String(describing: voiceDict["Duration"]!),
                                              "isEmergency": strEmergency,
                                              "School" : selectedSchoolsArray,
                                              COUNTRY_CODE: strCountryCode,
                                              "filepath" : String(describing: voiceDict["FilePath"]!)]
            arrUserData.add(myDict)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "HistoryEmergency")
            // apiCall.callPassVoiceParms(requestString, myString, "EmergencyVoice", VoiceData as Data!)
        }else{
            let requestStringer = baseUrlString! + SCHEDULE_VOICE_HISTORY_ENTIRE_SCHOOL
            print("requestStringerSCHEDULE_VOICE_HISTORY_ENTIRE_SCHOOL",requestStringer)
            
            let arrUserData : NSMutableArray = []
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["Description" : String(describing: voiceDict["Description"]!),
                                              "CallerType" : strCallerType,
                                              "Duration" : String(describing: voiceDict["Duration"]!),
                                              "isEmergency": strEmergency,
                                              "School" : selectedSchoolsArray,
                                              COUNTRY_CODE: strCountryCode,
                                              "filepath" : String(describing: voiceDict["FilePath"]!), "StartTime" : initialTime , "EndTime" : doNotDial , "Dates" : DefaultsKeys.dateArr ]
            arrUserData.add(myDict)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "HistoryEmergency")
        }
    }
    
    func callSendSMSToEntireSchools()
    {
        showLoading()
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        let requestStringer = baseUrlString! + SendSMSToEntireSchools
        
        let arrUserData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = [
            "Description" : strDescription,
            "CallerType" : strCallerType,
            "Message" : strMessage,
            "School" : selectedSchoolsArray,
            COUNTRY_CODE: strCountryCode]
        
        arrUserData.add(myDict)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "TextToParents")
    }
    
    
    //MARK: Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil){
            print(csData)
            if((csData?.count)! > 0)
            {
                let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                if let status = dicUser["Status"] as? NSString
                {
                    let Status = status
                    let Message = dicUser["Message"] as! NSString
                    
                    if(Status .isEqual(to: "1")){
                        Util.showAlert("", msg: Message as String?)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        dismiss(animated: false, completion: nil)
                    }else{
                        Util.showAlert("", msg: Message as String?)
                    }
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
        
        
        hud.center = view.center
        hud.alpha = 1
        hud.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(hud)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.hud.transform = .identity
        })
        
        print("SchoolSelectionVcaaaa")
        
        
        popupLoading.dimmedMaskAlpha =  0
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        popupLoading.dismiss(true)
    }
    
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        print("segueidentifier",segue.identifier)
        if (segue.identifier == "SchoolSelectionToVoiceMessageSegue"){
            
            print("selectedSchoolDict",selectedSchoolDict)
            print("123456789213456789213456789")
            let segueid = segue.destination as! VocieMessageVC
            segueid.SchoolDict = selectedSchoolDict
            segueid.checkSchoolId = "1"
            segueid.strFromVC = "Principal"
            segueid.checkMultipleType = "1"
            segueid.strSchoolID = getSchoolID
            segueid.strStaffID = getStaffID
            
        }else   if (segue.identifier == "SchoolSelectionToTextSegue"){
            let segueid = segue.destination as! TextMessageVC
            segueid.SchoolDict = selectedSchoolDict
            
            segueid.strFromVC = "Principal"
        }
        else   if (segue.identifier == "SchoolSelectionToChatSegue"){
            let segueid = segue.destination as! StaffChatInteractDetailVC
            segueid.SchoolDetailDict = selectedSchoolDict
        }
        else  if (segue.identifier == "MessageFromManagementSegue"){
            let segueid = segue.destination as! MsgFromMgmtVC
            segueid.SchoolDetailDict = selectedSchoolDict
            segueid.checkSchoolId = "1"
            print("selectedSchoolDictselectedSchoolDict",selectedSchoolDict)
            
        }
        
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        print("strLanguage",strLanguage)
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
        
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            
        }
        
        
        if (self.fromVC == "daily_collection_report") {
            
        }
        self.SendButton.setTitle(LangDict["teacher_pop_response_btn_send"] as? String, for: .normal)
        self.SendButton.setTitle(LangDict["teacher_pop_response_btn_send"] as? String, for: .normal)
        
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
    }
    
}
