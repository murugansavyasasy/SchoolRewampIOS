//
//  SendAttendanceConfirmationVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 18/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit


class SendAttendanceConfirmationVC: UIViewController,UITableViewDataSource,UITableViewDelegate,Apidelegate {
    
    @IBOutlet weak var MyTableView: UITableView!
    @IBOutlet weak var MessageTitleLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var OkButton: UIButton!
    
    var popupLoading : KLCPopup = KLCPopup()
    var strApiFrom = NSString()
    var StaffId = String()
    var SchoolId = String()
    var SelectedDictforApi = [String:Any]() as NSDictionary
    let UtilObj = UtilClass()
    var SenderNameStr = String()
    var CheckAttendanceVCStr = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var DescriptionString = String()
    var MessageString = String()
    var SelectedSectiondict = [String:Any]() as NSDictionary
    var durationString = String()
    var urlData: URL?
    var uploadImageData : NSData? = nil
    var ExamTestDictforApi = NSMutableDictionary()
    var ExamTestApiDict : NSMutableDictionary = NSMutableDictionary()
    var StudentNameArray:Array = [String]()
    var StudentIDArray:Array = [Any]()
    var AdmissionNoArray:Array = [String]()
    //Histoty
    var fromView = String()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var voiceHistoryArray = NSMutableArray()
    var hud : MBProgressHUD = MBProgressHUD()
    var imagesArray = NSMutableArray()
    var pdfData : NSData? = nil
    var strFrom = String()
    var apicalled = "0"
    
    var sessionTypeList : String!
    var attendanceTypeList : String!
    
    var convertedImagesUrlArray = NSMutableArray()
    var currentImageCount = 0
    var totalImageCount = 0
    var imageUrlArray = NSMutableArray()
    var originalImagesArray = [UIImage]()
    var countryCoded : String!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.isOpaque = false
        
        countryCoded =  UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        callSelectedLanguage()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: TABLE VIEW
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return StudentNameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfiramationAttendanceTVC", for: indexPath) as! ConfiramationAttendanceTVC
        cell.SelectedStudentNameLabel.text = StudentNameArray[indexPath.row]
        return cell
    }
    // MARK: BUTTON ACTION
    
    
    @IBAction func actionCancelButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    @IBAction func actionOkButton(_ sender: Any) {
        
        if(UtilObj.IsNetworkConnected())
        {
            if(SenderNameStr == "StaffTextMessage"){
                self.SendTextMessageAsStaff()
            }else if(SenderNameStr == "StaffVoiceMessage"){
                if( self.fromView == "Record"){
                    self.SendStaffVoiceToStudentMessageApi()
                }else{
                    self.SendStaffHistoryVoiceMessageApi()
                }
            }else if(SenderNameStr == "StaffImageMessage"){
                self.getImageURL(images: self.imagesArray as! [UIImage])
                //self.SendImageToStudentAsStaffApi()
            }else if(SenderNameStr == "StudentExamTextVC"){
                self.SendExamTestForParticularStudentAPICalling()
            }else if(SenderNameStr == "ExamTextVC"){
                self.SendExamTestForParticularStudentAPICalling()
            }else if(SenderNameStr == "StaffMultipleImage"){
                if(self.strFrom == "Image"){
                    self.getImageURL(images: self.imagesArray as! [UIImage])
                }else{
                    self.uploadPDFFileToAWS(pdfData: pdfData!)
                }
            }else{
                self.SendAttendanceToSelecedStudentapi()
            }
        }else{
            Util.showAlert("", msg:strNoInternet )
        }
    }
    // MARK: API CALLING
    func StaffMultipleImageApiCall()
    {
        DispatchQueue.main.async {
            self.apicalled = "1"
            self.strApiFrom = "SendImageToStudentAsStaffApi"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_STUDENT_CLOUD //MULTIPLE_IMAGE_MESSAGE_STUDENT
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let Dict = self.appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            self.SchoolId = String(describing: Dict["SchoolID"]!)
            self.StaffId = String(describing: Dict["StaffID"]!)
            let SectionID = String(describing: self.SelectedSectiondict["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : self.SchoolId,"StaffID" : self.StaffId,"Description" : self.DescriptionString,"TargetCode" : SectionID,"IDS" : self.StudentIDArray, COUNTRY_CODE: self.strCountryCode,"isMultiple":"1","FileType":"IMG","FileNameArray" : self.convertedImagesUrlArray]
            let myString = Util.convertDictionary(toString: myDict)
            self.UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }
        
        
    }
    func StaffPdfApicall()
    {
        DispatchQueue.main.async {
            self.strApiFrom = "SendImageToStudentAsStaffApi"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_STUDENT_CLOUD //STAFF_SEND_IMAGE_MESSAGE_TO_STUDENT
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let Dict = self.appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            self.SchoolId = String(describing: Dict["SchoolID"]!)
            self.StaffId = String(describing: Dict["StaffID"]!)
            let SectionID = String(describing: self.SelectedSectiondict["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : self.SchoolId,"StaffID" : self.StaffId,"Description" : self.DescriptionString,"TargetCode" : SectionID,"IDS" : self.StudentIDArray, COUNTRY_CODE: self.strCountryCode,"isMultiple":"0","FileType":".pdf","FileNameArray" : self.convertedImagesUrlArray]
            let myString = Util.convertDictionary(toString: myDict)
            self.UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }
    }
    func SendAttendanceToSelecedStudentapi()
    {
        showLoading()
        strApiFrom = "SendAttendancetoSelecedStudent"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + MARK_ATTENDANCE
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        SchoolId = String(describing: SelectedDictforApi["SchoolID"]!)
        StaffId = String(describing: SelectedDictforApi["StaffID"]!)
        
        let ClassID = String(describing: SelectedDictforApi["ClassID"]!)
        
        let SectionID = String(describing: SelectedDictforApi["SectionID"]!)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId ,"ClassId":ClassID ,"SectionID": SectionID,"AllPresent" : "F","StudentID": StudentIDArray, COUNTRY_CODE: strCountryCode,"AttendanceType" : attendanceTypeList,"SessionType" : sessionTypeList,"AttendanceDate" : DefaultsKeys.SelectedDAte]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        
        
        print("MarkAllSelectStudAttendanceDict",requestString)
        print("MarkAllSelectAttendanceDict",myDict)
        print("Absentees",myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendAttendancetoSelecedStudent")
    }
    func SendTextMessageAsStaff()
    {
        showLoading()
        strApiFrom = "SendTextMessageAsStaff"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_TEXT_TO_STUDENT
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
        let Dict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
        SchoolId = String(describing: Dict["SchoolID"]!)
        StaffId = String(describing: Dict["StaffID"]!)
        let SectionID = String(describing: SelectedSectiondict["SectionId"]!)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId ,"Description":DescriptionString ,"Message" : MessageString,"TargetCode": SectionID,"IDS" : StudentIDArray, COUNTRY_CODE: strCountryCode]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendAttendancetoSelecedStudent")
    }
    
    func SendStaffVoiceToStudentMessageApi()
    {
        showLoading()
        strApiFrom = "SendStaffVoiceToStudentMessageApi"
        let VoiceData = NSData(contentsOf: self.urlData!)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime = DefaultsKeys.initialDisplayDate
        var doNotDial =  DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            let requestStringer = baseUrlString! + STAFF_SEND_VOICE_MESSAGE_TO_STUDENT
            print("requestStringerOL56ty3e43",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let Dict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: Dict["SchoolID"]!)
            StaffId = String(describing: Dict["StaffID"]!)
            let SectionID = String(describing: SelectedSectiondict["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : DescriptionString,"Duration": durationString ,"TargetCode" : SectionID,"IDS" : StudentIDArray, COUNTRY_CODE: strCountryCode]
            
            UtilObj.printLogKey(printKey: "VoiceData", printingValue: VoiceData!)
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.callPassVoiceParms(requestString, myString, "SendStaffVoiceToStudentMessageApi", VoiceData as Data?)
        }else{
            
            let requestStringer = baseUrlString! + SCHEDULE_STAFF_SEND_VOICE_MESSAGE_TO_STUDENT
            print("requestStringerOL5e3d3d6ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let Dict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: Dict["SchoolID"]!)
            StaffId = String(describing: Dict["StaffID"]!)
            let SectionID = String(describing: SelectedSectiondict["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : DescriptionString,"Duration": durationString ,"TargetCode" : SectionID,"IDS" : StudentIDArray, COUNTRY_CODE: strCountryCode, "StartTime" : initialTime , "EndTime" : doNotDial , "Dates" : DefaultsKeys.dateArr ]
            
            UtilObj.printLogKey(printKey: "VoiceData", printingValue: VoiceData!)
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.callPassVoiceParms(requestString, myString, "SendStaffVoiceToStudentMessageApi", VoiceData as Data?)
        }
    }
    
    func SendStaffHistoryVoiceMessageApi()
    {
        showLoading()
        let voiceDict = self.voiceHistoryArray[0] as! NSDictionary
        strApiFrom = "SendStaffVoiceToStudentMessageApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime = DefaultsKeys.initialDisplayDate
        var doNotDial =  DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            let requestStringer = baseUrlString! + VOICE_HISTORY_SPECIFIC_STUDENT
            print("requestStrid3d34ngerOL56ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let Dict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: Dict["SchoolID"]!)
            StaffId = String(describing: Dict["StaffID"]!)
            let SectionID = String(describing: SelectedSectiondict["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : DescriptionString,"Duration": durationString,"filepath" : String(describing: voiceDict["FilePath"]!) ,"TargetCode" : SectionID,"IDS" : StudentIDArray, COUNTRY_CODE: strCountryCode]
            
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendStaffVoiceHisotryToStudentMessageApi")
        }else{
            let requestStringer = baseUrlString! + SCHEDULE_VOICE_HISTORY_SPECIFIC_STUDENT
            print("requestStringedrfrfrvevrOL56ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let Dict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: Dict["SchoolID"]!)
            StaffId = String(describing: Dict["StaffID"]!)
            let SectionID = String(describing: SelectedSectiondict["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : DescriptionString,"Duration": durationString,"filepath" : String(describing: voiceDict["FilePath"]!) ,"TargetCode" : SectionID,"IDS" : StudentIDArray, COUNTRY_CODE: strCountryCode, "StartTime" : initialTime , "EndTime" : doNotDial , "Dates" : DefaultsKeys.dateArr ]
            
            
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendStaffVoiceHisotryToStudentMessageApi")
            
        }
    }
    
    
    func SendImageToStudentAsStaffApi()
    {
        DispatchQueue.main.async {
            self.strApiFrom = "SendImageToStudentAsStaffApi"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_STUDENT_CLOUD
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let Dict = self.appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            self.SchoolId = String(describing: Dict["SchoolID"]!)
            self.StaffId = String(describing: Dict["StaffID"]!)
            let SectionID = String(describing: self.SelectedSectiondict["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : self.SchoolId,"StaffID" : self.StaffId,"Description" : self.DescriptionString,"TargetCode" : SectionID,"IDS" : self.StudentIDArray, COUNTRY_CODE: self.strCountryCode ,"FileNameArray" : self.convertedImagesUrlArray]
            let myString = Util.convertDictionary(toString: myDict)
            self.UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }
    }
    
    func SendExamTestForParticularStudentAPICalling()
    {
        showLoading()
        strApiFrom = "SendExamTestForParticularStudentAPICalling"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + INSERT_EXAM_PARTICULARSTUDENT_SYLLABUS
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        ExamTestApiDict[COUNTRY_CODE] = strCountryCode
        UtilObj.printLogKey(printKey: "ExamTestApiDict", printingValue: ExamTestApiDict)
        let myString = Util.convertDictionary(toString: ExamTestApiDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendExamTestForParticularStudentAPICalling")
    }
    
    // MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        
        if(csData != nil)
        {
            var myalertstring = String()
            if(strApiFrom.isEqual(to: "SendAttendancetoSelecedStudent"))
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                
                var dicResponse: NSDictionary = [:]
                
                if let arrayDatas = csData as? NSArray
                {
                    
                    
                    for var i in 0..<arrayDatas.count
                    {
                        dicResponse = arrayDatas[i] as! NSDictionary
                    }
                    
                    myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        if(appDelegate.isPrincipal .isEqual("true")){
                            print("PRINCIPLETRUE")
                            self.presentingViewController!.presentingViewController!.presentingViewController!.presentingViewController?.dismiss(animated: false, completion: {})
                        }else
                        {
                            print("PRINCIPLEFALSE")
                            self.presentingViewController!.presentingViewController?.dismiss(animated: false, completion: {})
                        }
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
            }
            else if(strApiFrom.isEqual(to:"SendTextMessageAsStaff"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        //dismiss(animated: false, completion: nil)
                        
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        let nc = NotificationCenter.default
                        nc.post(name: NSNotification.Name(rawValue: "comeBack1"), object: nil)
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
                
                
            }
            else if(strApiFrom.isEqual(to:"SendStaffVoiceToStudentMessageApi"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        let nc = NotificationCenter.default
                        nc.post(name: NSNotification.Name(rawValue: "comeBack1"), object: nil)
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
                
                
            }
            //
            else if(strApiFrom.isEqual(to:"SendImageToStudentAsStaffApi"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")  {
                        if(self.strFrom == "Image"){
                            if(apicalled == "1"){
                                apicalled = "0"
                                Util.showAlert("", msg: myalertstring)
                                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                                let nc = NotificationCenter.default
                                nc.post(name: NSNotification.Name(rawValue: "comeBack1"), object: nil)
                            }
                        }else{
                            Util.showAlert("", msg: myalertstring)
                            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                            let nc = NotificationCenter.default
                            nc.post(name: NSNotification.Name(rawValue: "comeBack1"), object: nil)
                        }
                    } else  {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom.isEqual(to: "SendExamTestForParticularStudentAPICalling"))
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                
                var dicResponse: NSDictionary = [:]
                
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    
                    myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        if(appDelegate.isPrincipal .isEqual("true")){
                            self.presentingViewController!.presentingViewController!.presentingViewController!.presentingViewController!.presentingViewController?.dismiss(animated: false, completion: {})
                        }else{
                            self.presentingViewController!.presentingViewController!.presentingViewController!.presentingViewController?.dismiss(animated: false, completion: {})
                            
                        }
                    }else{
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                }
            }else{
                Util.showAlert("", msg: myalertstring)
                dismiss(animated: false, completion: nil)
                
            }
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        
        Util .showAlert("", msg: strSomething);
        
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
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
            TitleLabel.textAlignment = .right
            
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            TitleLabel.textAlignment = .left
            
        }
        MessageTitleLabel.textAlignment = .center
        TitleLabel.text = LangDict["confirmation"] as? String
        OkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        CancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
        if(CheckAttendanceVCStr == "AttendanceVC"){
            MessageTitleLabel.text = LangDict["absent_message"] as? String
        }else{
            MessageTitleLabel.text = LangDict["confirm_send_message"] as? String
        }
    }
    
    
    //MARK: AWS Upload
    
    func getImageURL(images : [UIImage]){
        showLoading()
        self.originalImagesArray = images
        self.totalImageCount = images.count
        if currentImageCount < images.count{
            self.uploadAWS(image: images[currentImageCount])
        }
    }
    
    func uploadAWS(image : UIImage){
        
        var bucketName = ""
                print("countryCoded",countryCoded)
                if countryCoded == "1" {
                   
                    bucketName = DefaultsKeys.bucketNameIndia
                }else  {
                     bucketName = DefaultsKeys.bucketNameBangkok
                }
        let S3BucketName = bucketName
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
        
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".png")
        
        
        let ext = imageName as String
        
        let fileName = imageNameWithoutExtension
        let fileType = ".png"
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        let data = image.jpegData(compressionQuality: 0.9)
        do {
            try data?.write(to: imageURL)
        }
        catch {}
        
        print(imageURL)
        
        let dateFormatter = DateFormatter()
              
              dateFormatter.dateFormat = "yyyy-MM-dd"
              
              let  currentDate =   dateFormatter.string(from: Date())
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key = "communication" + "/" + currentDate +  "/" + ext
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.contentType = "image/" + ext
        uploadRequest?.acl = .publicRead
        // upload
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
            
            if let error = task.error {
                self.hideLoading()
                print("Upload failed : (\(error))")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    let imageDict = NSMutableDictionary()
                    imageDict["FileName"] = absoluteString
                    self.imageUrlArray.add(imageDict)
                    self.currentImageCount = self.currentImageCount + 1
                    if self.currentImageCount < self.totalImageCount{
                        DispatchQueue.main.async {
                            self.getImageURL(images: self.originalImagesArray)
                        }
                    }else{
                        self.convertedImagesUrlArray = self.imageUrlArray
                        if(self.SenderNameStr == "StaffMultipleImage"){
                            self.StaffMultipleImageApiCall()
                        }else{
                            self.SendImageToStudentAsStaffApi()
                        }
                        
                    }
                }
            }
            else {
                self.hideLoading()
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    
    func uploadPDFFileToAWS(pdfData : NSData){
        self.showLoading()
        
        
        var bucketName = ""
               print("countryCoded",countryCoded)
               if countryCoded == "1" {
                  
                   bucketName = DefaultsKeys.bucketNameIndia
               }else  {
                    bucketName = DefaultsKeys.bucketNameBangkok
               }
               
        let S3BucketName = bucketName
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
        
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".pdf")
        
        
        
        let ext = imageName as String
        
        let fileName = imageNameWithoutExtension
        let fileType = ".pdf"
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        
        do {
            try pdfData.write(to: imageURL)
        }
        catch {}
        
        print(imageURL)
        
        let dateFormatter = DateFormatter()
               
               dateFormatter.dateFormat = "yyyy-MM-dd"
               
               let  currentDate =   dateFormatter.string(from: Date())
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key = "communication" + "/" + currentDate +  "/" + ext
        uploadRequest?.bucket = S3BucketName
        
        uploadRequest?.contentType = "application/pdf"
        uploadRequest?.acl = .publicRead
        
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
            
            if let error = task.error {
                print("Upload failed : (\(error))")
                self.hideLoading()
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    let imageDict = NSMutableDictionary()
                    imageDict["FileName"] = absoluteString
                    self.imageUrlArray.add(imageDict)
                    self.convertedImagesUrlArray = self.imageUrlArray
                    self.StaffPdfApicall()
                    
                }
            }
            else {
                self.hideLoading()
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    
}


