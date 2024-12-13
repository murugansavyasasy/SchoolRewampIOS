//
//  PrincipalAddRemoveSubjectVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 19/07/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class PrincipalAddRemoveSubjectVC: UIViewController,UITableViewDataSource,UITableViewDelegate,Apidelegate,UITextFieldDelegate {
    @IBOutlet var PopupChoosePickerView: UIView!
    @IBOutlet var PopupChooseTimeView: UIView!
    @IBOutlet var ANImageView: UIImageView!
    @IBOutlet var FNImageView: UIImageView!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var PickerTitleLabel: UILabel!
    @IBOutlet weak var DatePickerTitleLabel: UILabel!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var StudentSendButton: UIButton!
    @IBOutlet weak var SelectStudentButton: UIButton!
    @IBOutlet weak var pickerOkButton: UIButton!
    @IBOutlet weak var pickerCancelButton: UIButton!
    @IBOutlet weak var datePickerOkButton: UIButton!
    @IBOutlet weak var datePickerCancelButton: UIButton!
    
    @IBOutlet var AddSubjectTableView: UITableView!
    var strApiFrom = NSString()
    var StaffId = String()
    var SchoolId = String()
    var strLoginAs = String()
    var strSelectedTime = String()
    var strStandardSectionName = String()
    var SelectedIndexpath = IndexPath()
    var strCountryCode = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var selectedSchoolDictionary = NSMutableDictionary()
    var popupDate : KLCPopup  = KLCPopup()
    var popupTime : KLCPopup  = KLCPopup()
    var SubjectApiArray :NSMutableArray = NSMutableArray()
    // var EmptyDict :NSMutableDictionary = NSMutableDictionary()
    var EmptyDict = ""
    var SelectedSectionDeatil:NSDictionary = [String:Any]() as NSDictionary
    
    var SelectedSubjectArray :NSMutableArray = NSMutableArray()
    var DetailedSubjectArray:NSMutableArray = NSMutableArray()
    var SubjectNameArray:Array = [String]()
    var SubjectIDArray:Array = [String]()
    var strSenderFrom = String()
    @IBOutlet var StudentView: UIView!
    @IBOutlet var StandardView: UIView!
    var ExamTestApiDict : NSMutableDictionary = NSMutableDictionary()
    let UtilObj = UtilClass()
    var LanguageDict = NSDictionary()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        callSelectedLanguage()
        for  i in 0..<DetailedSubjectArray.count
        {
            
            SubjectApiArray.add(EmptyDict)
            
        }
        
        self.Shadowview(MyView: PopupChooseTimeView)
        self.Shadowview(MyView: PopupChoosePickerView)
        if(strSenderFrom == "Student")
        {
            StudentView.isHidden = false
            StandardView.isHidden = true
            
        }else
        {
            StudentView.isHidden = true
            StandardView.isHidden = false
        }
        SendButton.layer.cornerRadius = 5
        SendButton.clipsToBounds = true
        StudentSendButton.layer.cornerRadius = 5
        StudentSendButton.clipsToBounds = true
        SelectStudentButton.layer.cornerRadius = 5
        SelectStudentButton.clipsToBounds = true
        
        
        if(UtilObj.IsNetworkConnected())
        {
            
        }
        else
        {
            Util.showAlert("", msg:INTERNET_ERROR )
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        
        self.view.frame.origin.y -= 100
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        self.view.frame.origin.y = 0
        //dismissKeyboard()
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        
        let currentCharacterCount = textField.text?.count ?? 0
        
        if (range.length + range.location > currentCharacterCount)
        {
            return false
        }
        
        let newLength = currentCharacterCount + string.count - range.length
        
        
        if(newLength == 5)
        {
            textField.resignFirstResponder()
        }
        
        
        return string == numberFiltered
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let Dict: NSDictionary = DetailedSubjectArray[indexPath.row] as! NSDictionary
        if(SelectedSubjectArray.contains(Dict))
        {
            return 220
        }else
        {
            return 40
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DetailedSubjectArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrincipalAddSubjectTVCell", for: indexPath) as! PrincipalAddSubjectTVCell
        let Dict: NSDictionary = DetailedSubjectArray[indexPath.row] as! NSDictionary
        cell.SubjectNameLbl.text = String(describing: Dict["SubjectName"]!)
        cell.AddView.isHidden = true
        cell.RemoveView.isHidden = true
        cell.AddMarkTxt.resignFirstResponder()
        cell.AddButton.addTarget(self, action: #selector(CellADDButtonTapped(_sender:)), for: .touchUpInside)
        cell.AddButton.tag = indexPath.row
        
        cell.RemoveButton.addTarget(self, action: #selector(CellRemoveButtonTapped(_sender:)), for: .touchUpInside)
        cell.RemoveButton.tag = indexPath.row
        
        cell.CellSelectionButton.addTarget(self, action: #selector(CellSelectionButtonTapped(_sender:)), for: .touchUpInside)
        cell.CellSelectionButton.tag = indexPath.row
        
        cell.AddDateButton.addTarget(self, action: #selector(CellADDDateButtonTapped(_sender:)), for: .touchUpInside)
        cell.AddDateButton.tag = indexPath.row
        
        cell.AddTimeButton.addTarget(self, action: #selector(CellADDTimeButtonTapped(_sender:)), for: .touchUpInside)
        cell.AddTimeButton.tag = indexPath.row
        
        cell.FloatAddMarkTxt.text = LanguageDict["enter_maximum_mark"] as? String
        cell.FloatAddDateLbl.text = LanguageDict["select_date"] as? String
        cell.FloatAddTimeLbl.text = LanguageDict["select_session"] as? String
        
        cell.FloatRemoveMarkLbl.text = LanguageDict["max_mark"] as? String
        cell.FloatRemoveDateLbl.text = LanguageDict["subject_date"] as? String
        cell.FlaotRemoveTimeLbl.text = LanguageDict["subject_session"] as? String
        cell.AddButton.setTitle(LanguageDict["add"] as? String, for: .normal)
        cell.RemoveButton.setTitle(LanguageDict["remove"] as? String, for: .normal)
        
        if(SelectedSubjectArray.count > 0)
        {
            buttonEnable()
            if(SelectedSubjectArray.contains(Dict))
            {
                if let CheckDict = SubjectApiArray[indexPath.row] as? NSMutableDictionary
                {
                    cell.RemoveView.isHidden = false
                    cell.RemoveTimeLbl.text = String(describing: CheckDict["Session"]!)
                    cell.RemoveMarkLbl.text = String(describing: CheckDict["MaxMark"]!)
                    cell.RemoveDateLbl.text = String(describing: CheckDict["ExamDate"]!)
                    cell.RemoveSyllabusLbl.text = String(describing: CheckDict["Syllabus"]!)
                    
                }else{
                    cell.AddView.isHidden = false
                    cell.AddDateLbl.text = ""
                    cell.AddMarkTxt.text = ""
                    cell.AddTimeLbl.text = "FN"
                    
                }
                
                cell.SelectImg.image = UIImage(named: "CheckBoximage")
            }else
            {
                cell.SelectImg.image = UIImage(named: "UnChechBoxImage")
            }
            
        }else
        {
            buttonDisable()
            cell.SelectImg.image = UIImage(named: "UnChechBoxImage")
        }
        return cell
    }
    
    
    
    @objc func CellSelectionButtonTapped(_sender: UIButton)
    {
        print("SelectRowAt")
        let CellindexPath = IndexPath(row: _sender.tag, section: 0)
        let Dict: NSDictionary = DetailedSubjectArray[_sender.tag] as! NSDictionary
        if(SelectedSubjectArray.contains(Dict))
        {
            SelectedSubjectArray.remove(Dict)
        }else{
            SelectedSubjectArray.add(Dict)
        }
        SubjectApiArray[_sender.tag] = EmptyDict
        print(SubjectApiArray)
        AddSubjectTableView.reloadRows(at: [CellindexPath], with: UITableView.RowAnimation.top)
        
    }
    @objc func CellADDButtonTapped(_sender: UIButton)
    {
        
        let CellindexPath = IndexPath(row: _sender.tag, section: 0)
        let cell = AddSubjectTableView.cellForRow(at: CellindexPath) as! PrincipalAddSubjectTVCell
        cell.AddMarkTxt.resignFirstResponder()
        let Dict: NSDictionary = DetailedSubjectArray[_sender.tag] as! NSDictionary
        if(cell.AddMarkTxt.text == "" || cell.AddMarkTxt.text!.count == 0){
            
            Util.showAlert("", msg: LanguageDict["enter_mark_alert"] as? String)
            
            
        }else if ((cell.AddMarkTxt.text!.trimmingCharacters(in: .whitespaces).count) == 0){
            
            Util.showAlert("", msg: LanguageDict["enter_mark_alert"] as? String)
            
        }else if(cell.AddDateLbl.text == "" || cell.AddMarkTxt.text!.count == 0){
            
            Util.showAlert("", msg: LanguageDict["select_date_alert"] as? String)
            
            
        }
        else
        {
            
            cell.AddView.isHidden = true
            cell.RemoveView.isHidden = false
            cell.RemoveDateLbl.text = cell.AddDateLbl.text
            cell.RemoveTimeLbl.text = cell.AddTimeLbl.text
            cell.RemoveMarkLbl.text = cell.AddMarkTxt.text
            cell.RemoveSyllabusLbl.text = cell.AddSyllabusTxt.text
            
            let strSubjectCode : String = String(describing: Dict["SubjectId"]!)
            let ApiDict : NSMutableDictionary = ["Subcode": strSubjectCode,"ExamDate": cell.AddDateLbl.text!,"Session":cell.AddTimeLbl.text!, "MaxMark":cell.AddMarkTxt.text!,"Syllabus" : cell.AddSyllabusTxt.text! ]
            print(ApiDict)
            SubjectApiArray[_sender.tag] = ApiDict
            print(SubjectApiArray)
        }
        
        
        
    }
    @objc func CellADDTimeButtonTapped(_sender: UIButton)
    {
        SelectedIndexpath = IndexPath(row: _sender.tag, section: 0)
        
        let cell = AddSubjectTableView.cellForRow(at: SelectedIndexpath) as! PrincipalAddSubjectTVCell
        cell.AddMarkTxt.resignFirstResponder()
        if(cell.AddTimeLbl.text == "FN")
        {
            actionFNButton(self)
        }else
        {
            actionANButton(self)
        }
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChooseTimeView.frame.size.height = 300
            PopupChooseTimeView.frame.size.width = 400
        }
        
        //        G3
        
        PopupChooseTimeView.center = view.center
        PopupChooseTimeView.alpha = 1
        PopupChooseTimeView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(PopupChooseTimeView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.PopupChooseTimeView.transform = .identity
        })
        
        
        print("PrinciplAddRemoveSubject")
        
        
        
        
    }
    @objc func CellADDDateButtonTapped(_sender: UIButton)
    {
        SelectedIndexpath = IndexPath(row: _sender.tag, section: 0)
        
        let cell = AddSubjectTableView.cellForRow(at: SelectedIndexpath) as! PrincipalAddSubjectTVCell
        cell.AddMarkTxt.resignFirstResponder()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
        let currentDate = formatter.date(from: result)
        let SelectedDate = formatter.date(from: cell.AddDateLbl.text!)
        self.DatePicker.minimumDate = currentDate
        if #available(iOS 13.4, *) {
            self.DatePicker.preferredDatePickerStyle = .wheels
        } else {
        }
        if(cell.AddDateLbl.text == "")
        {
            self.DatePicker.date = currentDate!
        }else
        {
            self.DatePicker.date = SelectedDate!
        }
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChoosePickerView.frame.size.height = 300
            PopupChoosePickerView.frame.size.width = 400
        }
        
        
        
        //        G3
        
        PopupChoosePickerView.center = view.center
        PopupChoosePickerView.alpha = 1
        PopupChoosePickerView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(PopupChoosePickerView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.PopupChoosePickerView.transform = .identity
        })
        
        
        print("PrinciplAddRemoveSu11bject")
        
    }
    @objc func CellRemoveButtonTapped(_sender: UIButton)
    {
        
        SelectedIndexpath = IndexPath(row: _sender.tag, section: 0)
        
        let cell = AddSubjectTableView.cellForRow(at: SelectedIndexpath) as! PrincipalAddSubjectTVCell
        cell.AddMarkTxt.resignFirstResponder()
        let Dict: NSDictionary = DetailedSubjectArray[_sender.tag] as! NSDictionary
        if(SelectedSubjectArray.contains(Dict))
        {
            SelectedSubjectArray.remove(Dict)
        }else{
            SelectedSubjectArray.add(Dict)
        }
        SubjectApiArray[_sender.tag] = EmptyDict
        print(SubjectApiArray)
        AddSubjectTableView.reloadData()
    }
    
    //MARK: BUTTON ACTIONS
    @IBAction func actionANButton(_ sender: Any)
    {
        strSelectedTime = "AN"
        ANImageView.image = UIImage(named: "RadioSelect")
        FNImageView.image = UIImage(named: "RadioNormal")
    }
    @IBAction func actionFNButton(_ sender: Any)
    {
        strSelectedTime = "FN"
        FNImageView.image = UIImage(named: "RadioSelect")
        ANImageView.image = UIImage(named: "RadioNormal")
    }
    @IBAction func actionTimeCancelButton(_ sender: UIButton)
    {
        PopupChooseTimeView.alpha = 0
        
    }
    @IBAction func actionTimeOkButton(_ sender: UIButton)
    {
        let cell = AddSubjectTableView.cellForRow(at: SelectedIndexpath) as! PrincipalAddSubjectTVCell
        cell.AddTimeLbl.text = strSelectedTime
        PopupChooseTimeView.alpha = 0
    }
    @IBAction func actionSendButton(_ sender: UIButton)
    {
        let FilterArray : NSMutableArray = NSMutableArray()
        for i in 0..<SubjectApiArray.count
                
        {
            if let CheckDict = SubjectApiArray[i] as? NSMutableDictionary
            {
                FilterArray.add(CheckDict)
                
            }
        }
        print(FilterArray)
        if(UtilObj.IsNetworkConnected())
        {
            if(FilterArray.count > 0)
            {
                print(SubjectApiArray)
                ExamTestApiDict["Subjects"] = FilterArray
                print(ExamTestApiDict)
                SendExamTestToAllSection()
                
            }
            else{
                Util.showAlert("", msg:LanguageDict["select_subject_alert"] as? String )
            }
            
        }
        else
        {
            Util.showAlert("", msg:strNoInternet )
        }
        
        
    }
    
    @IBAction func actionStudentSendButton(_ sender: UIButton)
    {
        let FilterArray : NSMutableArray = NSMutableArray()
        for i in 0..<SubjectApiArray.count
                
        {
            if let CheckDict = SubjectApiArray[i] as? NSMutableDictionary
            {
                FilterArray.add(CheckDict)
                
            }
        }
        print(FilterArray)
        if(UtilObj.IsNetworkConnected())
        {
            if(FilterArray.count > 0)
            {
                print(SubjectApiArray)
                ExamTestApiDict["Subjects"] = FilterArray
                ExamTestApiDict["IDS"] = []
                SendExamTestToAllStudent()
                
            }
            else{
                Util.showAlert("", msg:LanguageDict["select_subject_alert"] as? String )
            }
            
        }
        else
        {
            Util.showAlert("", msg:strNoInternet )
        }
        
        
        
    }
    @IBAction func actionSelectStudentButton(_ sender: UIButton)
    {
        
        let FilterArray : NSMutableArray = NSMutableArray()
        for i in 0..<SubjectApiArray.count
                
        {
            if let CheckDict = SubjectApiArray[i] as? NSMutableDictionary
            {
                FilterArray.add(CheckDict)
                
            }
        }
        print(FilterArray)
        if(UtilObj.IsNetworkConnected())
        {
            if(FilterArray.count > 0)
            {
                print(SubjectApiArray)
                ExamTestApiDict["Subjects"] = FilterArray
                ExamTestApiDict["IDS"] = []
                let studentVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectstudentVC") as! SelectstudentVC
                studentVC.SenderNameString = "StudentExamTextVC"
                
                studentVC.SectionStandardName = strStandardSectionName
                studentVC.ExamTestApiDict = ExamTestApiDict
                studentVC.SectionDetailDictionary = SelectedSectionDeatil
                studentVC.SchoolId = SchoolId
                studentVC.StaffId = StaffId
                
                
                self.present(studentVC, animated: false, completion: nil)
                
            }
            else{
                Util.showAlert("", msg:LanguageDict["select_subject_alert"] as? String )
            }
            
        }
        else
        {
            Util.showAlert("", msg:strNoInternet )
        }
        
        
        
    }
    @IBAction func actionOk(_ sender: UIButton)
    {
        let cell = AddSubjectTableView.cellForRow(at: SelectedIndexpath) as! PrincipalAddSubjectTVCell
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        dateFormatter1.dateFormat = "dd/MM/yyyy"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let selectedDate : String = dateFormatter.string(from: DatePicker.date)
        print(selectedDate)
        cell.AddDateLbl.text = selectedDate
        PopupChoosePickerView.alpha = 0
        
    }
    @IBAction func actionCancel(_ sender: UIButton) {
        PopupChoosePickerView.alpha = 0
        
    }
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    //MARK: API CALLING
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
    
    func SendExamTestToAllSection()
    {
        showLoading()
        strApiFrom = "SendExamTestToAllSection"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_EXAM_HOMEWORK_SYLLABUS
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        ExamTestApiDict[COUNTRY_CODE] = strCountryCode
        let myString = Util.convertDictionary(toString: ExamTestApiDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendExamTestToAllSection")
    }
    func SendExamTestToAllStudent()
    {
        showLoading()
        strApiFrom = "SendExamTestToAllSection"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + INSERT_EXAM_PARTICULARSTUDENT_SYLLABUS
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        ExamTestApiDict[COUNTRY_CODE] = strCountryCode
        let myString = Util.convertDictionary(toString: ExamTestApiDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendExamTestToAllSection")
    }
    //MARK: API RESPONSE DELEGATE
    @objc func responestring(_ csData: NSMutableArray!, _ pagename: String!)
    {
        hideLoading()
        
        
        if(csData != nil)
        {UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            var dicResponse: NSDictionary = [:]
            var AlertString = String()
            if((csData?.count)! > 0)
            {
                if(strApiFrom == "GetAllStandardSectionSubjectDetailApi")
                {
                    
                    if let ResponseArray = csData as? NSArray
                    {
                        
                        if(ResponseArray.count > 0)
                        {
                            for  i in 0..<ResponseArray.count
                            {
                                
                                dicResponse = ResponseArray[i] as! NSDictionary
                                let CheckstdName = String(describing: dicResponse["Standard"]!)
                                let stdName = Util.checkNil(CheckstdName)
                                let stdcode = String(describing: dicResponse["StandardId"]!)
                                
                                AlertString = stdcode
                                if(stdName != "" && stdName != "0")
                                {
                                    
                                    
                                    if let SubjectArray = dicResponse["Subjects"] as! [Any] as? NSArray
                                    {
                                        
                                        
                                        if(SubjectArray.count > 0)
                                        {
                                            for  i in 0..<SubjectArray.count
                                            {
                                                let dicResponse : NSDictionary = SubjectArray[i] as! NSDictionary
                                                
                                                if(!DetailedSubjectArray.contains(dicResponse))
                                                {
                                                    DetailedSubjectArray.add(dicResponse)
                                                    SubjectApiArray.add(EmptyDict)
                                                }
                                                
                                                
                                            }
                                            
                                        }
                                        
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                                
                                
                                else
                                {
                                    Util.showAlert("", msg: AlertString)
                                    dismiss(animated: false, completion: nil)
                                }
                            }
                            AddSubjectTableView.reloadData()
                        }
                        else
                        {
                            Util.showAlert("", msg: strNoRecordAlert)
                            dismiss(animated: false, completion: nil)
                        }
                    }
                    else
                    {   Util.showAlert("", msg: strNoRecordAlert)
                        dismiss(animated: false, completion: nil)
                        
                    }
                }
                else if(strApiFrom == "SendExamTestToAllSection")
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
    
    func Shadowview(MyView : UIView)
    {
        MyView.layer.cornerRadius = 5
        MyView.layer.shadowOffset = CGSize(width: 0, height: 3)
        MyView.layer.shadowRadius = 10.0
        MyView.layer.shadowOpacity = 1.0
        let color : UIColor = UIColor(red: 20.0/255.0 , green: 20.0/255.0 , blue: 20.0/255.0 , alpha: 0.2)
        MyView.layer.shadowColor = color.cgColor
    }
    func buttonDisable()
    {
        SendButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        SendButton.isUserInteractionEnabled = false
        
        StudentSendButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        StudentSendButton.isUserInteractionEnabled = false
        SelectStudentButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        SelectStudentButton.isUserInteractionEnabled = false
    }
    func buttonEnable()
    {
        SendButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
        SendButton.isUserInteractionEnabled = true
        
        StudentSendButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
        StudentSendButton.isUserInteractionEnabled = true
        SelectStudentButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        SelectStudentButton.isUserInteractionEnabled = true
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
        PickerTitleLabel.text =  LangDict["select_session"] as? String
        DatePickerTitleLabel.textAlignment = .center
        DatePickerTitleLabel.text =  LangDict["select_date"] as? String
        self.SelectStudentButton.setTitle(LangDict["select_student_attedance"] as? String, for: .normal)
        self.SendButton.setTitle(LangDict["teacher_txt_send"] as? String, for: .normal)
        self.StudentSendButton.setTitle(LangDict["teacher_txt_send"] as? String, for: .normal)
        
        datePickerOkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        datePickerCancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        pickerOkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        pickerCancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        
    }
    
}
