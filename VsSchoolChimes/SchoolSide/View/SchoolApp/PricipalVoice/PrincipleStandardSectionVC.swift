//
//  PrincipleStandardSectionVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 18/07/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class PrincipleStandardSectionVC: UIViewController ,Apidelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var PopupChoosePickerView: UIView!
    @IBOutlet var assignmentView: UIView!
    @IBOutlet weak var MyPickerView: UIPickerView!
    @IBOutlet weak var PickerTitleLabel: UILabel!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var SendAssignmentButton: UIButton!
    @IBOutlet weak var SubjectButtonButton: UIButton!
    @IBOutlet weak var StudentButtonButton: UIButton!
    @IBOutlet weak var pickerOkButton: UIButton!
    @IBOutlet weak var pickerCancelButton: UIButton!
    @IBOutlet var MyTableView: UITableView!
    var strApiFrom = NSString()
    var strAssigmentFrom = NSString()
    var StaffId = String()
    var SchoolId = String()
    var strAssignmentID = String()
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
    var DetailofSubjectArray:Array = [Any]()
    var popupChooseStandard : KLCPopup  = KLCPopup()
    var SelectedStandardName = String()
    var DetailedSubjectArray:Array = [Any]()
    var SelectedSectionDetail:NSDictionary = [String:Any]() as NSDictionary
    var SelectedSubjectDetail:NSDictionary = [String:Any]() as NSDictionary
    var SectionTitleArray = NSMutableArray()
    //  var SectionTitleArray = ["Standard","Section(s)"]
    var SelectedStandardString = String()
    var SelectedSubjectString = String()
    var SendedScreenNameStr = String()
    var HomeTitleText = String()
    var HomeTextViewText = String()
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    var StandardSectionSubjectArray = NSArray()
    var SectionCodeArray:Array = [String]()
    var SubjectCodeArray:Array = [String]()
    var SelectedSectionCodeArray = NSMutableArray()
    var strCountryCode = String()
    var durationString = String()
    var VoiceurlData: URL?
    var uploadImageData : NSData? = nil
    let UtilObj = UtilClass()
    var StandardSectionArray = NSArray()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedSchoolDictionary = NSMutableDictionary()
    var LanguageDict = NSDictionary()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var ExamTestApiDict : NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.isOpaque = false
        PopupChoosePickerView.isHidden = true
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        SubjectButtonButton.layer.cornerRadius = 5
        SubjectButtonButton.layer.masksToBounds = true
        SendAssignmentButton.layer.cornerRadius = 5
        SendAssignmentButton.layer.masksToBounds = true
        StudentButtonButton.layer.cornerRadius = 5
        StudentButtonButton.layer.masksToBounds = true
        
        self.SendButton.isHidden = true
        self.SubjectButtonButton.isHidden = false
        self.SendAssignmentButton.isHidden = true
        if(strAssigmentFrom == "principal" || strAssigmentFrom == "staff"){
            self.SendButton.isHidden = false
            self.SubjectButtonButton.isHidden = true
            self.SendAssignmentButton.isHidden = false
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        
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
        
        else
        {
            return pickerSectionArray.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(TableString == "Standard")
        {
            return pickerStandardArray[row]
            
        }
        else
        {
            return pickerSectionArray[row]
            
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
    //MARK: TABLEVIEW  DELEGATE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionTitleArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 1)
        {
            return pickerSectionArray.count
        }
        else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 55
        }else{
            return 40
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StaffAddNewClassTVCell", for: indexPath) as! StaffAddNewClassTVCell
        if(indexPath.section == 1)
        {
            cell.BorderImage.isHidden = true
            cell.SelectionImage.image = UIImage(named: "UnChechBoxImage")
            cell.SubjectView.layer.cornerRadius = 0
            cell.SubjectView.layer.masksToBounds = true
            cell.SubjectView.layer.shadowOpacity = 0.7
            cell.SubjectView.layer.shadowOffset = CGSize.zero
            cell.SubjectView.layer.shadowRadius = 4
            cell.SubjectView.layer.shadowColor = UIColor.black.cgColor
            cell.SchoolNameLbl.text = pickerSectionArray[indexPath.row]
            
        }else{
            
            
            cell.SchoolNameLbl.text = SelectedStandardString
            cell.BorderImage.isHidden = false
            cell.SubjectView.layer.cornerRadius = 3
            cell.SubjectView.layer.masksToBounds = true
            cell.SubjectView.layer.shadowOpacity = 0.7
            cell.SubjectView.layer.shadowOffset = CGSize.zero
            cell.SubjectView.layer.shadowRadius = 4
            cell.SubjectView.layer.shadowColor = UIColor.black.cgColor
            cell.SelectionImage.image = UIImage(named: "Downarrow")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        let headerLabel = UILabel()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            headerView.frame = CGRect(x: 0, y: 0, width:
                                        tableView.bounds.size.width, height: 30)
            headerLabel.frame = CGRect(x: 0, y: 10, width:
                                        tableView.bounds.size.width, height: 35)
            headerLabel.font = UIFont(name: "Verdana", size: 20)
        }
        else
        {
            
            headerView.frame = CGRect(x: 0, y: 0, width:
                                        tableView.bounds.size.width, height: 20)
            headerLabel.frame = CGRect(x: 0, y: 10, width:
                                        tableView.bounds.size.width, height: 25)
            headerLabel.font = UIFont(name: "Verdana", size: 15)
            
            
        }
        //headerLabel.font = UIFont(name: "Verdana", size: 20)
        headerLabel.textColor = UIColor.white
        headerLabel.text = SectionTitleArray[section] as! String
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 40
        }else{
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        if(indexPath.section == 0)
        {
            MyPickerView.selectRow(selectedStandardRow, inComponent: 0, animated: true)
            self.actionSelectStandard()
            
        }else if(indexPath.section == 1){
            cell.SelectionImage.image = UIImage(named: "CheckBoximage")
            
            
            SelectedSectionCodeArray.add(SectionCodeArray[indexPath.row])
            if(strAssigmentFrom == "principal" || strAssigmentFrom == "staff"){
                if(SelectedSectionCodeArray.count > 1){
                    self.assignmentView.isHidden = true
                }else{
                    self.assignmentView.isHidden = false
                }
                
            }
            
        }
        UtilObj.printLogKey(printKey: "SelectedSectionCodeArray", printingValue: SelectedSectionCodeArray)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        if(indexPath.section == 1)
        {
            cell.SelectionImage.image = UIImage(named: "UnChechBoxImage")
            let SectionCode = SectionCodeArray[indexPath.row]
            if(SelectedSectionCodeArray.contains(SectionCode))
            {
                SelectedSectionCodeArray.remove(SectionCode)
            }else{
                SelectedSectionCodeArray.add(SectionCode)
            }
            
            if(strAssigmentFrom == "principal" || strAssigmentFrom == "staff"){
                if(SelectedSectionCodeArray.count > 1){
                    self.assignmentView.isHidden = true
                }else{
                    self.assignmentView.isHidden = false
                }
                
            }
            
        }
        UtilObj.printLogKey(printKey: "SelectedSectionCodeArray", printingValue: SelectedSectionCodeArray)
    }
    
    //MARK: BUTTON ACTION FUNCTIONS
    
    
    func actionSelectStandard()
    {
        TableString = "Standard"
        PickerTitleLabel.text =  LanguageDict["select_standard"] as? String//"Select Standard"
        
        self.MyPickerView.reloadAllComponents()
        
        if(pickerStandardArray.count > 0)
        {
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PopupChoosePickerView.frame.size.height = 300
                PopupChoosePickerView.frame.size.width = 350
            }
            PopupChoosePickerView.isHidden = false
            
            popupChooseStandard.show()
        }
        else
        {
            Util.showAlert("Alert", msg: LanguageDict["no_students"] as? String)
        }
        
    }
    
    
    func UpdateStandardValue(StandardName : String)
    {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        cell.SchoolNameLbl.text = StandardName
        
        
    }
    
    
    //MARK: BUTTON ACTIONS
    @IBAction func actionSendButton(_ sender: UIButton){
        self.CallForwardAssignmentApi()
    }
    
    @IBAction func actionSubjectButton(_ sender: UIButton){
        
        if(strAssigmentFrom == "principal" || strAssigmentFrom == "staff"){
            if(SelectedSectionCodeArray.count > 0){
                let studentVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectstudentVC") as! SelectstudentVC
                studentVC.SenderNameString = "StaffAssignment"
                studentVC.SchoolId = SchoolId
                studentVC.StaffId = StaffId
                studentVC.assignmentID = strAssignmentID
                studentVC.SelectedSectionCode = SelectedSectionCodeArray[0] as! String
                //studentVC.HomeTitleText = HomeTitleText
                //studentVC.HomeTextViewText = HomeTextViewText
                self.present(studentVC, animated: false, completion: nil)
                
            }else{
                Util.showAlert("", msg: LanguageDict["alert_section"] as? String)
            }
        }else{
            
            var ChoosenSectionIDArray : Array = [Any]()
            if(SelectedSectionCodeArray.count > 0)
            {
                for i in 0..<SelectedSectionCodeArray.count
                {
                    let mystring = SelectedSectionCodeArray[i] as? String
                    let StudentDic:NSDictionary = ["TargetCode" : mystring!]
                    ChoosenSectionIDArray.append(StudentDic)
                    print(ChoosenSectionIDArray)
                    
                }
                
                let StaffVC = self.storyboard?.instantiateViewController(withIdentifier: "PrincipalAddRemoveSubjectVC") as! PrincipalAddRemoveSubjectVC
                
                ExamTestApiDict["Seccode"] = ChoosenSectionIDArray
                print("ExamTestApiDict\(ExamTestApiDict)")
                StaffVC.StaffId = StaffId
                StaffVC.SchoolId = SchoolId
                StaffVC.ExamTestApiDict = ExamTestApiDict
                let selectedSubject : NSArray = DetailedSubjectArray[selectedStandardRow] as! NSArray
                StaffVC.DetailedSubjectArray = NSMutableArray(array: selectedSubject)
                Constants.printLogKey("DetailedSubjectArray[selectedStandardRow]", printValue: selectedSubject)
                self.present(StaffVC, animated: false, completion: nil)
                
                
                
            }else{
                Util.showAlert("", msg: LanguageDict["alert_section"] as? String)
            }
        }
        
    }
    
    @IBAction func actionOk(_ sender: UIButton) {
        PopupChoosePickerView.isHidden = true
        if(TableString == "Standard")
        {
            SectionCodeArray.removeAll()
            SelectedSectionCodeArray.removeAllObjects()
            SelectedStandardString = pickerStandardArray[selectedStandardRow]
            UpdateStandardValue(StandardName: SelectedStandardString)
            
            let sectionarray:Array = DetailofSectionArray[selectedStandardRow] as! [Any]
            
            UtilObj.printLogKey(printKey: "sectionarray", printingValue: sectionarray)
            
            var sectionNameArray :Array = [String]()
            if(sectionarray.count > 0)
            {
                for var i in 0..<sectionarray.count
                {
                    let dicResponse :NSDictionary = sectionarray[i] as! NSDictionary
                    sectionNameArray.append(dicResponse["SectionName"] as! String)
                    SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                }
                pickerSectionArray = sectionNameArray
                
            }else{
                pickerSectionArray = []
            }
            MyTableView.reloadData()
        }
        else if(TableString == "Section")
        {
            
        }
        popupChooseStandard.dismiss(true)
        
    }
    @IBAction func actionCancel(_ sender: UIButton) {
        PopupChoosePickerView.isHidden = true
        popupChooseStandard.dismiss(true)
    }
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: API CALLING
    func GetAllSectionCodeapi()
    {
        showLoading()
        strApiFrom = "GetSectionCodeAttendance"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        //  let requestStringer = baseUrlString! + GETSTANDARD_SECTION
        var requestStringer = baseUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"SchoolId":"1302","StaffID":"7643"}
        // let myDict:NSMutableDictionary = ["SchoolId" : SchoolId]
        
        let myDict:NSMutableDictionary = ["SchoolId" : SchoolId,"StaffID" : StaffId, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSectionCodeAttendance")
    }
    
    func CallForwardAssignmentApi(){
        showLoading()
        strApiFrom = "forwardAssignmentApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let  sectionArrayString = SelectedSectionCodeArray.componentsJoined(by: "~")
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + FORWARD_ASSIGNMENT
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId, "FromAssignmentId":strAssignmentID,"receiverId" : sectionArrayString, "isentireSection":"1","ProcessBy":StaffId,COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendForwardAssignment")
    }
    
    
    
    @objc func responestring(_ csData: NSMutableArray!, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {  UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            var dicResponse: NSDictionary = [:]
            var AlertString = String()
            if((csData?.count)! > 0)
            {
                if let ResponseArray = csData as? NSArray{
                    print(ResponseArray)
                    if(strApiFrom == "GetSectionCodeAttendance")
                    {
                        StandardSectionSubjectArray = ResponseArray
                        if(StandardSectionSubjectArray.count > 0){
                            for  i in 0..<StandardSectionSubjectArray.count{
                                
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
                                            MyTableView.reloadData()
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
                                            //   print("SubjectName\(SubjectName)")
                                            //  print("pickerStandardArray[0]\(pickerStandardArray[0])")
                                            UpdateStandardValue(StandardName: String(pickerStandardArray[0]))
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
                            Util.showAlert("", msg: strNoRecordAlert)
                            dismiss(animated: false, completion: nil)
                        }
                    } else if(strApiFrom == "forwardAssignmentApi"){
                        if let CheckedDict = csData[0] as? NSDictionary{
                            let alertMessage = CheckedDict["Message"] as! String
                            if(String(describing: CheckedDict["Status"]!) == "1"){
                                Util.showAlert("", msg: alertMessage)
                                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                            }else{
                                Util.showAlert("", msg: alertMessage)
                            }
                        }else{
                            Util.showAlert("", msg: strSomething)
                        }
                        
                        
                    }
                }
                
            }
            else
            {   Util.showAlert("", msg: strNoRecordAlert)
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
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        PickerTitleLabel.textAlignment = .center
        self.SubjectButtonButton.setTitle(LangDict["select_student_attedance"] as? String, for: .normal)
        
        self.StudentButtonButton.setTitle(LangDict["select_subjects"] as? String, for: .normal)
        self.SendButton.setTitle(LangDict["teacher_confirm"] as? String, for: .normal)
        self.SendAssignmentButton.setTitle(LangDict["teacher_confirm"] as? String, for: .normal)
        
        let strSection : String = LangDict["teacher_atten_sections"] as? String ?? "Section(s)"
        let strStandard : String = LangDict["teacher_atten_standard"] as? String ?? "Standard"
        pickerOkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        pickerCancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        SectionTitleArray = [strStandard,strSection]
        if(StandardSectionSubjectArray.count == 0){
            if(UtilObj.IsNetworkConnected()){
                self.GetAllSectionCodeapi()
            }else{
                Util.showAlert("", msg:strNoInternet )
            }
        }
    }
    
    
}
