//
//  PrincipalStandardOrStudentVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 20/07/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class PrincipalStandardOrStudentVC: UIViewController,Apidelegate,UIPickerViewDelegate ,UIPickerViewDataSource{
    
    @IBOutlet weak var PickerTitleLabel: UILabel!
    @IBOutlet weak var SectionView: UIView!
    @IBOutlet weak var StandardView: UIView!
    @IBOutlet weak var MyPickerView: UIPickerView!
    @IBOutlet weak var PopupChooseStandardPickerView: UIView!
    @IBOutlet weak var SectionNameLbl: UILabel!
    @IBOutlet weak var StandardNameLbl: UILabel!
    @IBOutlet weak var SelectStudentButton: UIButton!
    @IBOutlet weak var SelectSubjectButton: UIButton!
    
    @IBOutlet weak var pickerOkButton: UIButton!
    @IBOutlet weak var pickerCancelButton: UIButton!
    @IBOutlet weak var SectionLabel: UILabel!
    @IBOutlet weak var StandardLabel: UILabel!
    var ExamTestApiDict : NSMutableDictionary = NSMutableDictionary()
    
    var strApiFrom = NSString()
    var StaffId = String()
    var SchoolId = String()
    var loginAsName = String()
    var TableString = String()
    var pickerStandardArray = [String]()
    var pickerSectionArray = [String]()
    var selectedStandardRow = 0;
    var selectedSectionRow = 0;
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var StandarCodeArray:Array = [String]()
    var SectionCodeArray:Array = [String]()
    var StandardNameArray:Array = [String]()
    var DetailofSectionArray:Array = [Any]()
    var popupChooseStandard : KLCPopup  = KLCPopup()
    var popupAttendance : KLCPopup  = KLCPopup()
    var SelectedStandardName = String()
    var SelectedSectionDeatil:NSDictionary = [String:Any]() as NSDictionary
    var SchoolDeatilDict:NSDictionary = [String:Any]() as NSDictionary
    let UtilObj = UtilClass()
    var StandardSectionArray = NSArray()
    var SelectedClassIDString = String()
    var senderName = String()
    var SelectedSectionIDString = String()
    var HomeTitleText = String()
    var HomeTextViewText = String()
    var SenderScreenName = String()
    var SelectedDictforApi = [String:Any]() as NSDictionary
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var durationString = String()
    var urlData: URL?
    var uploadImageData : NSData? = nil
    var DetailedSubjectArray:Array = [Any]()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var LanguageDict = NSDictionary()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        
        print("PopupChooseStandardPickerViewScreen")
        PopupChooseStandardPickerView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        self.ButtonCornerDesign()
        
        if(StandardSectionArray.count == 0)
        {
            if(UtilObj.IsNetworkConnected())
            {
                self.GetAllSectionCodeapi()
                
            }
            else
            {
                Util.showAlert("", msg:strNoInternet )
            }
        }
    }
    
    func ButtonCornerDesign()
    {
        PopupChooseStandardPickerView.layer.cornerRadius = 8
        PopupChooseStandardPickerView.layer.masksToBounds = true
        StandardView.layer.cornerRadius = 5
        StandardView.layer.masksToBounds = true
        SectionView.layer.cornerRadius = 5
        SectionView.layer.masksToBounds = true
        SelectSubjectButton.layer.cornerRadius = 5
        SelectSubjectButton.layer.masksToBounds = true
        
        
    }
    
    
    
    
    
    
    //MARK: PickerView
    
    public func numberOfComponents(in pickerView:  UIPickerView) -> Int  {
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(TableString == "Standard")
        {
            return pickerStandardArray.count
            
        }
        else
        {
            return pickerSectionArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(TableString == "Standard"){
            return pickerStandardArray[row]
            
        }else{
            return pickerSectionArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(TableString == "Standard"){
            selectedStandardRow = row;
        }else{
            selectedSectionRow = row
        }
    }
    
    // MARK: DONE PICKER ACTION
    @IBAction func actionDonePickerView(_ sender: UIButton)
    {
        PopupChooseStandardPickerView.isHidden = true
        
        if(TableString == "Standard")
        {
            StandardNameLbl.text = pickerStandardArray[selectedStandardRow]
            SelectedStandardName = pickerStandardArray[selectedStandardRow]
            UtilObj.printLogKey(printKey: "SelectedStandardName", printingValue: SelectedStandardName)
            let sectionarray:Array = DetailofSectionArray[selectedStandardRow] as! [Any]
            var sectionNameArray :Array = [String]()
            if(sectionarray.count > 0)
            {
                for i in 0..<sectionarray.count
                {
                    let dicResponse :NSDictionary = sectionarray[i] as! NSDictionary
                    sectionNameArray.append(String(describing: dicResponse["SectionName"]!))
                    SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                }
                SectionNameLbl.text = String(sectionNameArray[0])
                
                pickerSectionArray = sectionNameArray
                SelectedSectionDeatil = sectionarray[0] as! NSDictionary
                SelectedSectionIDString = String(describing: SelectedSectionDeatil["SectionId"]!)
            }
            else{
                pickerSectionArray = []
                SectionNameLbl.text = ""
                SelectedSectionIDString = ""
                Util.showAlert("", msg: LanguageDict["no_section"] as? String)
            }
            
            SelectedClassIDString = String(StandarCodeArray[selectedStandardRow])
            
            UtilObj.printLogKey(printKey: "SelectedSectionDeatil", printingValue: SelectedSectionDeatil)
            
        }
        else
        {
            
            let sectionarray:Array = DetailofSectionArray[selectedStandardRow] as! [Any]
            SelectedSectionDeatil = sectionarray[selectedSectionRow] as! NSDictionary
            UtilObj.printLogKey(printKey: "SelectedSectionDeatil", printingValue: SelectedSectionDeatil)
            SelectedSectionIDString = String(describing: SelectedSectionDeatil["SectionId"]!)
            UtilObj.printLogKey(printKey: "SelectedSectionDeatil", printingValue: SelectedSectionDeatil)
            SectionNameLbl.text = pickerSectionArray[selectedSectionRow]
            
            
        }
        
        popupChooseStandard.dismiss(true)
        
        
    }
    
    @IBAction func actionCancelPickerView(_ sender: UIButton) {
        popupChooseStandard.dismiss(true)
        PopupChooseStandardPickerView.isHidden = true
        
    }
    
    
    
    
    // MARK: CHOOSE STANDARD BUTTON ACTION
    
    @IBAction func actionChooseStandardButton(_ sender: UIButton) {
        print("PopupChooseStandardPickerViewWorking")
        TableString = "Standard"
        
        PickerTitleLabel.text = LanguageDict["select_standard"] as? String
        self.MyPickerView.reloadAllComponents()
        if(pickerStandardArray.count > 0)
        {
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PopupChooseStandardPickerView.frame.size.height = 300
                
                PopupChooseStandardPickerView.frame.size.width = 350
                
                
            }
            PopupChooseStandardPickerView.isHidden = false
            
            
            popupChooseStandard.show()
        }
        else
        {
            Util.showAlert("", msg: LanguageDict["no_students"] as? String)
            
        }
        
    }
    
    // MARK: CHOOSE SECTION BUTTON ACTION
    @IBAction func actionChooseSectionButton(_ sender: UIButton) {
        PopupChooseStandardPickerView.isHidden = false
        TableString = "Section"
        PickerTitleLabel.text = LanguageDict["select_section"] as? String
        self.MyPickerView.reloadAllComponents()
        if((StandardNameLbl.text?.count)! > 0)
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PopupChooseStandardPickerView.frame.size.height = 300
                
                PopupChooseStandardPickerView.frame.size.width = 350
                
                
            }
            PopupChooseStandardPickerView.isHidden = false
            
            
            popupChooseStandard.show()
        }
        else
        {
            Util.showAlert("", msg: LanguageDict["standard_first"] as? String)
        }
        
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func actionCancelAttendanceView(_ sender: UIButton) {
        popupAttendance.dismiss(true)
        
    }
    
    
    
    
    // MARK: SELECT STUDENT BUTTON ACTION
    @IBAction func actionSelectStudentButton(_ sender: UIButton) {
        if((StandardNameLbl.text?.count)! > 0 && (SectionNameLbl.text?.count)! > 0)
        {
            SelectedDictforApi = ["SchoolID":SchoolId,"StaffID": StaffId,"ClassID": SelectedClassIDString,"SectionID":SelectedSectionIDString]
            
            let studentVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectstudentVC") as! SelectstudentVC
            studentVC.SenderNameString = "ExamTextVC"
            
            studentVC.SectionStandardName = StandardNameLbl.text! + " - " + SectionNameLbl.text!
            studentVC.SectionDetailDictionary = SelectedSectionDeatil
            studentVC.SchoolId = SchoolId
            studentVC.StaffId = StaffId
            
            studentVC.HomeTitleText = HomeTitleText
            studentVC.HomeTextViewText = HomeTextViewText
            self.present(studentVC, animated: false, completion: nil)
            
        }
        else
        {
            Util.showAlert("", msg: LanguageDict["select_standard_section_alert"] as? String)
            
        }
        
    }
    @IBAction func actionSelectSubjectButton(_ sender: UIButton) {
        if((StandardNameLbl.text?.count)! > 0 && (SectionNameLbl.text?.count)! > 0)
        {
            if(UtilObj.IsNetworkConnected())
            {
                let StaffVC = self.storyboard?.instantiateViewController(withIdentifier: "PrincipalAddRemoveSubjectVC") as! PrincipalAddRemoveSubjectVC
                
                ExamTestApiDict["SectionCode"] = SelectedSectionIDString
                print("ExamTestApiDict\(ExamTestApiDict)")
                StaffVC.StaffId = StaffId
                StaffVC.SchoolId = SchoolId
                StaffVC.strSenderFrom = "Student"
                StaffVC.SelectedSectionDeatil = SelectedSectionDeatil
                
                StaffVC.strStandardSectionName = StandardNameLbl.text! + " - " + SectionNameLbl.text!
                StaffVC.ExamTestApiDict = ExamTestApiDict
                
                let selectedSubject : NSArray = DetailedSubjectArray[selectedStandardRow] as! NSArray
                StaffVC.DetailedSubjectArray = NSMutableArray(array: selectedSubject)
                Constants.printLogKey("DetailedSubjectArray[selectedStandardRow]", printValue: selectedSubject)
                self.present(StaffVC, animated: false, completion: nil)
                
            }
            else
            {
                Util.showAlert("", msg:strNoInternet )
            }
        }
        else
        {
            Util.showAlert("", msg: LanguageDict["select_standard_section_alert"] as? String)
            
        }
    }
    
    
    //MARK: API CALLING
    
    func GetAllSectionCodeapi()
    {
        showLoading()
        strApiFrom = "GetSectionCodeAttendance"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolId" : SchoolId,"StaffID" : StaffId,"isAttendance" : "0", COUNTRY_CODE: strCountryCode]
        
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSectionCodeAttendance")
    }
    
    
    
    func SendTextMessageToStudentAsStaff()
    {
        showLoading()
        strApiFrom = "SendTextMessageToStudentAsStaff"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + STAFF_SEND_TEXT_MESSAGE
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let SectionID = String(describing: SelectedSectionDeatil["SecCode"]!)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId, COUNTRY_CODE: strCountryCode ,"Description":HomeTitleText ,"Message" : HomeTextViewText,"Seccode": [["TargetCode":SectionID]]]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendTextMessageToStudentAsStaff")
    }
    func SendStaffVoiceMessageApi()
    {
        showLoading()
        strApiFrom = "SendStaffVoiceMessageApi"
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
            let requestStringer = baseUrlString! + STAFF_SEND_VOICE_MESSAGE
            print("requestStringerOL56ty6767676",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let SectionID = String(describing: SelectedSectionDeatil["SecCode"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId, COUNTRY_CODE: strCountryCode,"Description" : HomeTitleText,"Duration": durationString ,"Seccode" : [["TargetCode":SectionID]]]
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
        }else {
            let requestStringer = baseUrlString! + SCHEDULE_STAFF_SEND_VOICE_MESSAGE
            print("requestStringerOL56ty32433",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let SectionID = String(describing: SelectedSectionDeatil["SecCode"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId, COUNTRY_CODE: strCountryCode,"Description" : HomeTitleText,"Duration": durationString ,"Seccode" : [["TargetCode":SectionID]] , "StartTime" : initialTime , "EndTime" : doNotDial , "Dates" : DefaultsKeys.dateArr ]
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
        }
        
    }
    func SendImageAsStaff()
    
    {
        showLoading()
        strApiFrom = "SendImageAsStaff"
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + STAFF_SEND_IMAGE_MESSAGE
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let SectionID = String(describing: SelectedSectionDeatil["SecCode"]!)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId, COUNTRY_CODE: strCountryCode,"Description" : HomeTitleText,"Seccode" : [["TargetCode":SectionID]]]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.callPassImageParms(requestString, myString, "SendImageAsStaff", uploadImageData as Data?)
    }
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        
        hideLoading()
        if(csData != nil)        {
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom.isEqual(to:"GetSectionCodeAttendance"))
            {
                
                var dicResponse: NSDictionary = [:]
                var AlertString = String()
                if((csData?.count)! > 0)
                {
                    let ResponseArray = NSArray(array: csData!)
                    let Dict = ResponseArray[0] as! NSDictionary
                    if(Dict != nil)
                    {
                        if let CheckedArray = ResponseArray as? NSArray
                        {
                            StandardSectionArray = CheckedArray
                            if(StandardSectionArray.count > 0)
                            {
                                for  i in 0..<StandardSectionArray.count
                                {
                                    dicResponse = StandardSectionArray[i] as! NSDictionary
                                    
                                    let stdcode = String(describing: dicResponse["StandardId"]!)
                                    StandarCodeArray.append(stdcode)
                                    
                                    let CheckstdName = String(describing: dicResponse["Standard"]!)
                                    let stdName = Util.checkNil(CheckstdName)
                                    AlertString = stdcode
                                    if(stdName != "" && stdName != "0")
                                    {
                                        StandardNameArray.append(stdName!)
                                        DetailofSectionArray.append(dicResponse["Sections"] as! [Any])
                                        DetailedSubjectArray.append(dicResponse["Subjects"] as! [Any])
                                        pickerStandardArray = StandardNameArray
                                        StandardNameLbl.text = pickerStandardArray[0]
                                        SelectedClassIDString = String(StandarCodeArray[0])
                                        let sectionarray:Array = DetailofSectionArray[0] as! [Any]
                                        var sectionNameArray :Array = [String]()
                                        for  i in 0..<sectionarray.count
                                        {
                                            let dicResponse : NSDictionary = sectionarray[i] as! NSDictionary
                                            sectionNameArray.append(String(describing: dicResponse["SectionName"]!))
                                            SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                                        }
                                        SelectedSectionIDString = String(SectionCodeArray[0])
                                        pickerSectionArray = sectionNameArray
                                        let dicResponse :NSDictionary = sectionarray[0] as! NSDictionary
                                        SelectedSectionDeatil = dicResponse
                                        let SectionString = dicResponse["SectionName"] as! String
                                        SectionNameLbl.text = SectionString
                                    }
                                    else
                                    {
                                        Util.showAlert("", msg: AlertString)
                                        dismiss(animated: false, completion: nil)
                                    }
                                }
                            }
                        }
                        else{
                            Util.showAlert("", msg: strNoRecordAlert)
                        }                    }
                    
                }
                
                else
                {   Util.showAlert("", msg: strNoRecordAlert)
                    dismiss(animated: false, completion: nil)
                    
                }
            }
            else if(strApiFrom.isEqual(to:"SendTextMessageToStudentAsStaff"))
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
            else if(strApiFrom.isEqual(to:"SendStaffVoiceMessageApi"))
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
            else if(strApiFrom.isEqual(to:"SendImageAsStaff"))
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
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        // print("Error")
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
        LanguageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            StandardLabel.textAlignment = .right
            SectionLabel.textAlignment = .right
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            StandardLabel.textAlignment = .left
            SectionLabel.textAlignment = .left
            
        }
        PickerTitleLabel.textAlignment = .center
        self.SelectSubjectButton.setTitle(LangDict["select_subjects"] as? String, for: .normal)
        StandardLabel.text = LangDict["teacher_atten_standard"] as? String
        SectionLabel.text = LangDict["teacher_atten_sections"] as? String
        pickerOkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        pickerCancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
    
    
}
