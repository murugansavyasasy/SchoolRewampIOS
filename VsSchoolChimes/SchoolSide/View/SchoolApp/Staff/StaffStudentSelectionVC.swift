//
//  StaffStudentSelectionVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 09/08/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffStudentSelectionVC: UIViewController,UITableViewDataSource,UITableViewDelegate,Apidelegate {
    
    @IBOutlet weak var StudentCountLabel: UILabel!
    @IBOutlet weak var TotalStudentLabel: UILabel!
    @IBOutlet weak var CheckBoxImage: UIImageView!
    @IBOutlet weak var SelectAllButton: UIButton!
    @IBOutlet weak var SectionNameLabel: UILabel!
    @IBOutlet weak var MyTableView: UITableView!
    @IBOutlet weak var SubjectNameLabel: UILabel!
    @IBOutlet weak var OkButton: UIButton!
    
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var strApiFrom = NSString()
    var StaffId = String()
    var SchoolId = String()
    var SectionCode = String()
    var arrayDataofStudent: NSArray = []
    var DetailedStudentDictionary:NSDictionary = [String:Any]() as NSDictionary
    var ChoosenSectionDictionary:NSDictionary = [String:Any]() as NSDictionary
    var StudentNameArray : Array = [String]()
    var SelectedStudentNameArray : Array = [String]()
    var ChoosenStudentIDArray : Array = [Any]()
    var MessageToAll = String()
    var SelectedStudentIDArray : Array = [String]()
    var SelectedStudentDetail:Array = [Any]()
    var StudentIDArray : Array = [String]()
    var StudentCount = Int()
    var SegueSelectedStudentArray = [Any]()
    var SegueSelectedStudentIDArray:  Array = [String]()
    var SectionStandardName = String()
    var SubjectName = String()
    var SectionDetailDictionary:NSDictionary = [String:Any]() as NSDictionary
    var SelectedSectionCode = String()
    var StudentAdmissionNoArray : Array = [String]()
    var SelectedSubjectDict:NSDictionary = [String:Any]() as NSDictionary
    var ExamTitleStr = String()
    var ExamTextViewStr = String()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    let UtilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MyTableView.allowsMultipleSelectionDuringEditing = true
        MyTableView.allowsMultipleSelection = true
        TotalStudentLabel.text = "0"
        OkButton.isUserInteractionEnabled = false
        SelectAllButton.isSelected = true
        self.loadDefaultSectionData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.callSelectedLanguage()
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        if(StudentNameArray.count == 0)
        {
            if(UtilObj.IsNetworkConnected())
            {
                self.GetAllStudendOfSectionAPICalling()
            }
            else
            {
                Util.showAlert("", msg: strNoInternet)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    //MARK: TABLEVIEW DELEGATE
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentNameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell1 = tableView.dequeueReusableCell(withIdentifier:"StaffSelectStudentTVCell", for: indexPath) as! StaffSelectStudentTVCell
        // cell1.StudentIdLabel.text = StudentIDArray[indexPath.row]
        cell1.StudentIdLabel.text = StudentAdmissionNoArray[indexPath.row]
        cell1.StudentNameLabel.text = StudentNameArray[indexPath.row]
        
        if(SelectedStudentIDArray.count > 0)
        {
            if(SelectedStudentIDArray.contains(StudentIDArray[indexPath.row]))
            {
                self.MyTableView.selectRow(at: indexPath, animated: false, scrollPosition:UITableView.ScrollPosition.none)
            }
            else{
                self.MyTableView.deselectRow(at: indexPath, animated: false)
            }
        }
        return cell1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        SegueSelectedStudentIDArray.removeAll()
        OkButton.isUserInteractionEnabled = true
        SelectedStudentIDArray.append(StudentIDArray[indexPath.row])
        SelectedStudentNameArray.append(StudentNameArray[indexPath.row])
        StudentCount = SelectedStudentIDArray.count
        StudentCountLabel.text = String(StudentCount)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        let deselecteddata = StudentIDArray[indexPath.row]
        if(SelectedStudentIDArray.contains(deselecteddata))
        {
            if let index = SelectedStudentIDArray.index(of: deselecteddata)
            {
                SelectedStudentIDArray.remove(at: index)
                SelectedStudentNameArray.remove(at: index)
            }
        }
        StudentCount = SelectedStudentIDArray.count
        StudentCountLabel.text = String(StudentCount)
        if(StudentCount == 0)
        {
            OkButton.isUserInteractionEnabled = false
            CheckBoxImage.image = UIImage(named: "UnChechBoxImage")
            SelectAllButton.isSelected = true
        }
        else{
            SelectAllButton.isSelected = false
        }
        
    }
    
    //MARK:BUTTON ACTION
    
    @IBAction func actionOkButton(_ sender: Any)
    {
        ChoosenStudentIDArray.removeAll()
        let confirmVC = self.storyboard?.instantiateViewController(withIdentifier: "SendAttendanceConfirmationVC") as! SendAttendanceConfirmationVC        
        confirmVC.SenderNameStr = "ExamTextVC"
        confirmVC.StudentNameArray = SelectedStudentNameArray
        for i in 0..<SelectedStudentIDArray.count
        {
            let mystring = SelectedStudentIDArray[i]
            let StudentDic:NSDictionary = ["ID" : mystring]
            ChoosenStudentIDArray.append(StudentDic)
        }     
        let SubjectCode = String(describing: SelectedSubjectDict["SubjectId"]!)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId, "StaffID" : StaffId,"SubCode" : SubjectCode,"SectionCode": SelectedSectionCode,"ExamName": ExamTitleStr,"ExamSyllabus": ExamTextViewStr,"IDS": ChoosenStudentIDArray]
        
        confirmVC.ExamTestDictforApi = myDict
        self.present(confirmVC, animated: false, completion: nil)
        
        
        
        
    }
    @IBAction func actionCancelButton(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func actionSelectAll(_ sender: Any)
    {
        if(SelectAllButton.isSelected == true)
        {
            StudentCount = StudentIDArray.count
            CheckBoxImage.image = UIImage(named: "CheckBoximage")
            MessageToAll = "T"
            SelectedStudentIDArray = StudentIDArray
            SelectedStudentNameArray = StudentNameArray
            StudentCountLabel.text = String(StudentCount)
            SelectAllButton.isSelected = false
            OkButton.isUserInteractionEnabled = true
            self.MyTableView.reloadData()
        }
        else
        {
            SegueSelectedStudentIDArray.removeAll()
            CheckBoxImage.image = UIImage(named: "UnChechBoxImage")
            MessageToAll = "F"
            StudentCountLabel.text = "0"
            SelectedStudentIDArray.removeAll()
            SelectedStudentDetail.removeAll()
            SelectedStudentNameArray.removeAll()
            SelectAllButton.isSelected = true
            OkButton.isUserInteractionEnabled = false
            self.MyTableView.reloadData()
        }
    }
    
    func loadDefaultSectionData()
    {
        UtilObj.printLogKey(printKey: "", printingValue: SectionDetailDictionary)
        StudentCountLabel.text = "0"
        SelectedSectionCode = String(describing: SectionDetailDictionary["SectionId"]!)
        UtilObj.printLogKey(printKey: "SelectedSubjectDict", printingValue: SelectedSubjectDict)
        SectionNameLabel.text = SectionStandardName
        SubjectNameLabel.text = SelectedSubjectDict["SubjectName"] as? String
    }
    
    //MARK: API CALLING    
    func GetAllStudendOfSectionAPICalling()
    {
        showLoading()
        strApiFrom = "GetStudentDetail"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + STUDENT_DETAIL
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + STUDENT_DETAIL
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId, "TargetCode" : SelectedSectionCode, COUNTRY_CODE: strCountryCode]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStudentDetail")
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
        let SubjectCode = String(describing: SelectedSubjectDict["SubjectId"]!)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId, "StaffID" : StaffId,"SubCode" : SubjectCode,"SectionCode": SelectedSectionCode, COUNTRY_CODE: strCountryCode,"ExamName": ExamTitleStr,"ExamSyllabus": ExamTextViewStr,"IDS": ChoosenStudentIDArray]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendExamTestForParticularStudentAPICalling")
    }
    // MARK: API RESPONSE
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        
        if(csData != nil)
        {
            var  arrayDatas: NSArray = []
            var dicResponse: NSDictionary = [:]
            
            var AlertString = String()
            
            if(strApiFrom.isEqual(to: "GetStudentDetail"))
            {
                arrayDatas = csData!
                StudentIDArray.removeAll()
                StudentNameArray.removeAll()
                StudentAdmissionNoArray.removeAll()
                if let CheckedArray = csData as? NSArray{
                    if((csData?.count)! > 0){
                        var dicUser : NSDictionary = [String:Any]() as NSDictionary
                        for i in 0..<(csData?.count)!
                        {
                            
                            dicUser = csData?.object(at: i) as! NSDictionary
                            if(dicUser != nil){
                                if(dicUser["StudentID"] != nil){
                                    let studentId : String = Util.checkNil(String( describing: dicUser["StudentID"]!))
                                    
                                    let AlertString = dicUser["StudentName"] as! String
                                    if(!studentId.isEmpty && studentId != "0" )
                                    {
                                        arrayDataofStudent = csData!
                                        
                                        StudentNameArray.append(String(describing: dicUser["StudentName"]!))
                                        StudentIDArray.append(String(describing: dicUser["StudentID"]!))
                                        
                                        StudentAdmissionNoArray.append(String(describing: dicUser["StudentAdmissionNo"]!))
                                        self.MyTableView.reloadData()
                                    }
                                    else
                                    {
                                        Util.showAlert("", msg: AlertString)
                                        dismiss(animated: false, completion: nil)
                                        
                                    }
                                }else{
                                    Util.showAlert("", msg: AlertString)
                                    dismiss(animated: false, completion: nil)
                                }
                            }else{
                                Util.showAlert("", msg: strNoRecordAlert)
                            }
                            
                        }
                        let TotalStudent = String(StudentIDArray.count)
                        TotalStudentLabel.text = "/" + TotalStudent
                        
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: strNoRecordAlert)
                    }
                }else{
                    Util.showAlert("", msg: strNoRecordAlert)
                }
                
            }
            else if(strApiFrom.isEqual(to: "SendExamTestForParticularStudentAPICalling"))
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                
                var dicResponse: NSDictionary = [:]
                
                if let arrayDatas = csData as? NSArray{
                    dicResponse = arrayDatas[0] as! NSDictionary
                    
                    AlertString = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1"){
                        Util.showAlert("", msg: AlertString)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        
                    }else{
                        Util.showAlert("", msg: AlertString)
                        dismiss(animated: false, completion: nil)
                        
                    }
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
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
}
