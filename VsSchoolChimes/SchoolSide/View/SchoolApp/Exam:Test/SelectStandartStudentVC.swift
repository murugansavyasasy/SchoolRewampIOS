//
//  SelectStandartStudentVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 18/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SelectStandartStudentVC: UIViewController,Apidelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    @IBOutlet weak var SubjectNameLabel: UILabel!
    @IBOutlet weak var SectionNameLabel: UILabel!
    @IBOutlet weak var StandardNameLabel: UILabel!
    @IBOutlet var PopupChoosePickerView: UIView!
    @IBOutlet weak var MyPickerView: UIPickerView!
    @IBOutlet weak var PickerTitleLabel: UILabel!
    @IBOutlet weak var SubjectView: UIView!
    @IBOutlet weak var SectionView: UIView!
    @IBOutlet weak var StandardView: UIView!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var SelectStudentButton: UIButton!
    
    var strApiFrom = NSString()
    var StaffId = String()
    var SchoolId = String()
    var TableString = String()
    var pickerStandardArray = [String]()
    var pickerSubjectArray = [String]()
    var pickerSectionArray = [String]()
    
    var selectedStandardRow = 0;
    var selectedSubjectRow = 0;
    var selectedSectionRow = 0;
    
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    
    var StandarCodeArray:Array = [String]()
    var StandardNameArray:Array = [String]()
    var SubjectNameArray:Array = [String]()
    var DetailofSectionArray:Array = [Any]()
    var popupChooseStandard : KLCPopup  = KLCPopup()
    var SelectedStandardName = String()
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    var StandardSectionSubjectArray = NSArray()
    var SectionCodeArray:Array = [String]()
    var SubjectCodeArray:Array = [String]()
    var DetailedSubjectArray:Array = [Any]()
    var SelectedSectionDetail:NSDictionary = [String:Any]() as NSDictionary
    var SelectedSubjectDetail:NSDictionary = [String:Any]() as NSDictionary
    var SelectedSectionCodeArray = NSMutableArray()
    var SelectedStandardString = String()
    var SelectedSubjectString = String()
    var ExamTitleStr = String()
    var ExamTextViewStr = String()
    let UtilObj = UtilClass()
    var strCountryCode = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.isOpaque = false
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StandardOrStudentsStaff.catchNotification), name: NSNotification.Name(rawValue: "comeBack1"), object:nil)
        SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
        StaffId = String(describing: SchoolDetailDict["StaffID"]!)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.ButtonDesign()
        if(StandardSectionSubjectArray.count == 0)
        {
            if(UtilObj.IsNetworkConnected())
            {
                self.GetAllStandardSectionSubjectDetailApi()
                
            }
            else
            {
                Util.showAlert("", msg:INTERNET_ERROR )
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:PICKER VIEW
    public func numberOfComponents(in pickerView:  UIPickerView) -> Int
    {
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(TableString == "Standard")
        {
            return pickerStandardArray.count
            
        }
        else if(TableString == "Section")
        {
            return pickerSectionArray.count
        }
        else
        {
            return pickerSubjectArray.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(TableString == "Standard")
        {
            return pickerStandardArray[row]
            
        }
        else if(TableString == "Section")
        {
            
            return pickerSectionArray[row]
            
        }
        else
        {
            return pickerSubjectArray[row]
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(TableString == "Standard")
        {
            selectedStandardRow = row;
            
        }
        else if(TableString == "Section")
        {
            selectedSectionRow = row
        }
        else if(TableString == "Subject")
        {
            selectedSubjectRow = row
        }
        
    }
    
    
    //MARK: BUTTON ACTION
    
    @IBAction func actionSelectSection(_ sender: UIButton)
    {
        TableString = "Section"
        PickerTitleLabel.text = "Select Section"
        self.MyPickerView.reloadAllComponents()
        
        if((StandardNameLabel.text?.count)! > 0)
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PopupChoosePickerView.frame.size.height = 300
                
                PopupChoosePickerView.frame.size.width = 350
                
                
            }
            
            popupChooseStandard = KLCPopup(contentView: PopupChoosePickerView, showType: KLCPopupShowType.none , dismissType:KLCPopupDismissType.none,maskType: KLCPopupMaskType.dimmed , dismissOnBackgroundTouch:  false , dismissOnContentTouch: false )
            
            popupChooseStandard.show()
        }
        else
        {
            Util.showAlert("Alert", msg: STANDARD_FIRST)
        }
        
        
    }
    
    @IBAction func actionSelectStandard(_ sender: UIButton)
    {
        TableString = "Standard"
        PickerTitleLabel.text = "Select Standard"
        
        self.MyPickerView.reloadAllComponents()
        
        if(pickerStandardArray.count > 0)
        {
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PopupChoosePickerView.frame.size.height = 300
                PopupChoosePickerView.frame.size.width = 350
                
            }
            
            
            
            PopupChoosePickerView.center = view.center
            PopupChoosePickerView.alpha = 1
            PopupChoosePickerView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
            
            self.view.addSubview(PopupChoosePickerView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
                
                self.PopupChoosePickerView.transform = .identity
            })
            
            print("SELECTStandareStuedntVc")
            
            
        }
        else
        {
            Util.showAlert("Alert", msg: NO_STUDENT_FOUND)
            
        }
    }
    @IBAction func actionSelectSubject(_ sender: UIButton) {
        TableString = "Subject"
        PickerTitleLabel.text = "Select Subject"
        self.ChooseSubject()
    }
    
    @IBAction func actionSendButton(_ sender: UIButton)
    {
        if(StandardNameLabel.text?.count == 0)
        {
            Util.showAlert("", msg: SELECT_STANDARD_ALERT)
        }
        else if(SectionNameLabel.text?.count  == 0)
        {
            Util.showAlert("", msg: SELECT_SECTION_ALERT)
        }
        else if(SubjectNameLabel.text?.count  == 0)
        {
            Util.showAlert("", msg: SELECT_SUBJECT_ALERT)
        }
        else{
            if(UtilObj.IsNetworkConnected())
            {
                self.SendExamTestToAllStudent()
                
            }
            else
            {
                Util.showAlert("", msg:INTERNET_ERROR )
            }
        }
    }
    @IBAction func actionSelectStudentButton(_ sender: UIButton)
    {
        if(StandardNameLabel.text?.count  == 0)
        {
            Util.showAlert("", msg: SELECT_STANDARD_ALERT)
        }
        else if(SectionNameLabel.text?.count  == 0)
        {
            Util.showAlert("", msg: SELECT_SECTION_ALERT)
        }
        else if(SubjectNameLabel.text?.count  == 0)
        {
            Util.showAlert("", msg: SELECT_SUBJECT_ALERT)
        }
        else{
            
            UtilObj.printLogKey(printKey: "SelectedSectionDetail", printingValue: SelectedSectionDetail)
            
            let studentVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectstudentVC") as! SelectstudentVC
            studentVC.SenderNameString = "ExamTextVC"
            studentVC.SectionStandardName = StandardNameLabel.text! + " - " + SectionNameLabel.text!
            studentVC.SectionDetailDictionary = SelectedSectionDetail
            studentVC.SchoolId = SchoolId
            studentVC.StaffId = StaffId
            studentVC.SelectedSubjectDict = SelectedSubjectDetail
            studentVC.HomeTitleText = ExamTitleStr
            studentVC.HomeTextViewText = ExamTextViewStr
            self.present(studentVC, animated: false, completion: nil)
            
            
        }
        
    }
    
    @IBAction func actionAddClass(_ sender: UIButton)
    {
        if((StandardNameLabel.text?.count)! > 0 && (SectionNameLabel.text?.count)! > 0 && (SubjectNameLabel.text?.count)! > 0)
        {
            let myDict:NSDictionary = ["Class" : StandardNameLabel.text!,"ClassSecCode":SelectedSectionDetail["SecCode"]!,"Group":"","NoOfStudents":SelectedSectionDetail["TotalStudents"]!,"Section":SelectedSectionDetail["SecName"]!,"SubjectCode":SelectedSubjectDetail["SubCode"]!,"SubjectName":SelectedSubjectDetail["SubName"]!]
            
            let nc = NotificationCenter.default
            nc.post(name:Notification.Name(rawValue:"NewClassComeBack"),
                    object: nil,userInfo: ["NewSectionDetail":myDict,"actionkey":"ok"])
            self.dismiss(animated: false, completion: nil)
        }
        else
        {
            Util.showAlert("", msg: CHOOSE_ALL_FIELDS)
        }
    }
    @IBAction func actionOk(_ sender: UIButton) {
        if(TableString == "Standard")
        {
            SelectedSectionCodeArray.removeAllObjects()
            SelectedStandardString = pickerStandardArray[selectedStandardRow]
            StandardNameLabel.text = SelectedStandardString
            UtilObj.printLogKey(printKey: "pickerStandardArray", printingValue: pickerStandardArray)
            let sectionarray:Array = DetailofSectionArray[selectedStandardRow] as! [Any]
            let SubjectArray:Array = DetailedSubjectArray[selectedStandardRow] as! [Any]
            UtilObj.printLogKey(printKey: "sectionarray", printingValue: sectionarray)
            UtilObj.printLogKey(printKey: "SubjectArray", printingValue: SubjectArray)
            var sectionNameArray :Array = [String]()
            var SubjectNameArray :Array = [String]()
            if(sectionarray.count > 0)
            {
                for var i in 0..<sectionarray.count
                {
                    let dicResponse :NSDictionary = sectionarray[i] as! NSDictionary
                    sectionNameArray.append(dicResponse["SectionName"] as! String)
                    SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                }
                SelectedSectionDetail = sectionarray[0]  as! NSDictionary
                pickerSectionArray = sectionNameArray
                SectionNameLabel.text = String(sectionNameArray[0])
            }
            else
            {
                
                pickerSectionArray = []
                SectionNameLabel.text = ""
                
            }
            if(SubjectArray.count > 0)
            {
                for var i in 0..<SubjectArray.count
                {
                    let dicResponse :NSDictionary = SubjectArray[i] as! NSDictionary
                    SubjectNameArray.append(dicResponse["SubjectName"] as! String)
                    SubjectCodeArray.append(String(describing: dicResponse["SubjectId"]!))
                }
                pickerSubjectArray = SubjectNameArray
                SubjectNameLabel.text = String(SubjectNameArray[0])
                UtilObj.printLogKey(printKey: "SubjectArray", printingValue: SubjectArray)
                SelectedSubjectDetail = SubjectArray[0] as! NSDictionary
                UtilObj.printLogKey(printKey: "SelectedSubjectDetail", printingValue: SelectedSubjectDetail)
            }
            else{
                pickerSubjectArray = []
                SubjectNameLabel.text = ""
            }
            
        }
        else if(TableString == "Section")
        {
            UtilObj.printLogKey(printKey: "DetailedectionArray", printingValue: DetailofSectionArray)
            let DetailSectionArray = DetailofSectionArray[selectedStandardRow] as! NSArray
            if(DetailSectionArray.count > 0)
            {
                SelectedSectionDetail = DetailSectionArray[selectedSectionRow]  as! NSDictionary
                UtilObj.printLogKey(printKey: "SelectedSectionDetail", printingValue: SelectedSectionDetail)
                SectionNameLabel.text = pickerSectionArray[selectedSectionRow]
                UtilObj.printLogKey(printKey: "pickerSubjectArray[selectedSectionRow]", printingValue: pickerSectionArray[selectedSectionRow])
            }else
            {
                Util.showAlert("", msg: NO_SECTION_FOUND)
            }
            
        }
        
        else if(TableString == "Subject")
        {
            UtilObj.printLogKey(printKey: "DetailedectionArray", printingValue: DetailofSectionArray)
            UtilObj.printLogKey(printKey: "DetailedSubjectArray", printingValue: DetailedSubjectArray)
            
            
            let DetailSubjectArray = DetailedSubjectArray[selectedStandardRow] as! NSArray
            if(DetailSubjectArray.count > 0)
            {
                SelectedSubjectDetail = DetailSubjectArray[selectedSubjectRow]  as! NSDictionary
                UtilObj.printLogKey(printKey: "SelectedSubjectDetail", printingValue: SelectedSubjectDetail)
                SelectedSubjectString = pickerSubjectArray[selectedSubjectRow]
                SubjectNameLabel.text = SelectedSubjectString
            }else{
                Util.showAlert("", msg: NO_SUBJECT_FOUND)
            }
        }
        popupChooseStandard.dismiss(true)
    }
    
    @IBAction func actionCancel(_ sender: UIButton) {
        popupChooseStandard.dismiss(true)
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: FUNCTIONS
    
    func ChooseSubject()
    {
        if(pickerSubjectArray.count > 0)
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PopupChoosePickerView.frame.size.height = 300
                PopupChoosePickerView.frame.size.width = 350
                
            }
            self.MyPickerView.reloadAllComponents()
            popupChooseStandard = KLCPopup(contentView: PopupChoosePickerView, showType: KLCPopupShowType.none , dismissType:KLCPopupDismissType.none,maskType: KLCPopupMaskType.dimmed , dismissOnBackgroundTouch:  false , dismissOnContentTouch: false )
            
            popupChooseStandard.show()
        }
        else
        {
            Util.showAlert("Alert", msg: "No subject found")
        }
    }
    
    func ButtonDesign()
    {
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        
        SelectStudentButton.layer.cornerRadius = 5
        SelectStudentButton.layer.masksToBounds = true
        
        SubjectView.layer.cornerRadius = 5
        SubjectView.layer.masksToBounds = true
        
        SectionView.layer.cornerRadius = 5
        SectionView.layer.masksToBounds = true
        
        StandardView.layer.cornerRadius = 5
        StandardView.layer.masksToBounds = true
    }
    
    //MARK: API REQUEST CALLING
    func GetAllStandardSectionSubjectDetailApi()
    {
        showLoading()
        strApiFrom = "GetAllStandardSectionSubjectDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolId" : SchoolId,"StaffID" : StaffId, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetAllStandardSectionSubjectDetailApi")
    }
    func SendExamTestToAllStudent()
    {
        showLoading()
        strApiFrom = "SendExamTestToAllStudent"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + INSERT_EXAM_PARTICULARSTUDENT
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let SelectedSectionCode = String(describing: SelectedSectionDetail["SectionId"]!)
        let SelectedSubjectCode = String(describing: SelectedSubjectDetail["SubjectId"]!)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId, "StaffID" : StaffId,"SubCode" : SelectedSubjectCode,"SectionCode": SelectedSectionCode,"ExamName": ExamTitleStr,"ExamSyllabus": ExamTextViewStr,"IDS": [], COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendExamTestToAllStudent")
    }
    //MARK: API RESPONSE CALLING
    
    @objc func responestring(_ csData: NSMutableArray!, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual(to:"GetAllStandardSectionSubjectDetailApi"))
            {
                var dicResponse: NSDictionary = [:]
                var AlertString = String()
                if((csData?.count)! > 0)
                {
                    if let ResponseArray = csData as? NSArray
                    {
                        StandardSectionSubjectArray = ResponseArray
                        if(StandardSectionSubjectArray.count > 0)
                        {
                            for  i in 0..<StandardSectionSubjectArray.count
                            {
                                dicResponse = StandardSectionSubjectArray[i] as! NSDictionary
                                let CheckstdName = String(describing: dicResponse["Standard"]!)
                                let stdName = Util.checkNil(CheckstdName)
                                let stdcode = String(describing: dicResponse["StandardId"]!)
                                StandarCodeArray.append(stdcode)
                                AlertString = stdcode
                                if(stdName != "" && stdName != "0")
                                {
                                    StandardNameArray.append(stdName!)
                                    DetailofSectionArray.append(dicResponse["Sections"] as! [Any])
                                    DetailedSubjectArray.append(dicResponse["Subjects"] as! [Any])
                                    UtilObj.printLogKey(printKey: "DetailofSectionArray", printingValue: DetailofSectionArray)
                                    UtilObj.printLogKey(printKey: "DetailedSubjectArray", printingValue: DetailedSubjectArray)
                                    pickerStandardArray = StandardNameArray
                                    
                                    if let sectionarray = DetailofSectionArray[0] as? NSArray
                                    {
                                        
                                        var sectionNameArray :Array = [String]()
                                        if(sectionarray.count > 0)
                                        {
                                            for  i in 0..<sectionarray.count
                                            {
                                                let dicResponse : NSDictionary = sectionarray[i] as! NSDictionary
                                                sectionNameArray.append(String(describing: dicResponse["SectionName"]!))
                                                
                                                SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                                            }
                                            pickerSectionArray = sectionNameArray
                                            SelectedSectionDetail = sectionarray[0]  as! NSDictionary
                                            SectionNameLabel.text = String(sectionNameArray[0])
                                        }
                                        
                                        
                                    }
                                    if let SubjectArray = DetailedSubjectArray[0] as? NSArray
                                    {
                                        
                                        var SubjectNameArray :Array = [String]()
                                        if(SubjectArray.count > 0)
                                        {
                                            for  i in 0..<SubjectArray.count
                                            {
                                                let dicResponse : NSDictionary = SubjectArray[i] as! NSDictionary
                                                SubjectNameArray.append(String(describing: dicResponse["SubjectName"]!))
                                                
                                                SubjectCodeArray.append(String(describing: dicResponse["SubjectId"]!))
                                            }
                                            pickerSubjectArray = SubjectNameArray
                                            
                                            let dicResponse :NSDictionary = SubjectArray[0] as! NSDictionary
                                            SelectedSubjectDetail = dicResponse
                                            let SubjectName = String (describing: dicResponse["SubjectName"]!)
                                            
                                            StandardNameLabel.text = String(pickerStandardArray[0])
                                            SubjectNameLabel.text = SubjectName
                                        }
                                    }
                                }
                                else
                                {
                                    Util.showAlert("", msg: AlertString)
                                    dismiss(animated: false, completion: nil)
                                }
                            }
                        }
                        else
                        {
                            Util.showAlert("", msg: "No record found")
                            dismiss(animated: false, completion: nil)
                        }
                    }
                    
                }
                else
                {   Util.showAlert("", msg: "No Data Found")
                    dismiss(animated: false, completion: nil)
                    
                }
            }
            else if(strApiFrom.isEqual(to: "SendExamTestToAllStudent"))
            {
                var dicResponse: NSDictionary = [:]
                var AlertString = String()
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    
                    AlertString = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: AlertString)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        let nc = NotificationCenter.default
                        nc.post(name: NSNotification.Name(rawValue: "comeBackMenu"), object: nil)
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: AlertString)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
            }
            
        }
        else
        {
            Util.showAlert("", msg: SERVER_ERROR)
        }
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: SERVER_CONNECTION_FAILED);
        
    }
    
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
    }
    
    func catchNotification(notification:Notification) -> Void {
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBackMenu"), object: nil)
        
    }
    
    
}
