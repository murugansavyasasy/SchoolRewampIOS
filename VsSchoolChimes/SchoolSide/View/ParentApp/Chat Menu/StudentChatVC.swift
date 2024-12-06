//
//  StudentChatVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 12/06/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit
extension UIDevice {
    
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        }
        return false
    }
}

class StudentChatVC: UIViewController ,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,Apidelegate,UITextViewDelegate{
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var TextMessageView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    let UtilObj = UtilClass()
    var strCountryCode = String()
    var apiCallFrom = String()
    var SchoolId  = String()
    var StaffId  = String()
    var ChildId  = String()
    var selectedSchoolDictionary = NSDictionary()
    var stdSubjectArray = NSMutableArray()
    var languageDictionary = NSDictionary()
    var SchoolDetailDict = NSDictionary()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var subjectName = String()
    var strSomething = String()
    var strClassTeacher = String()
    var subjectId = String()
    var sectionId = String()
    var staffName = String()
    var MaxTextCount = Int()
    var pageNumber = 0
    var offSet = 0
    var limit = 0
    var chatCount = 0
    var strTextViewPlaceholder = "Type your question.."
    var studentChatId = 0 

    var isNewDataLoading = false
    var hud : MBProgressHUD = MBProgressHUD()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        self.title = "Student Chat"
        print("StaffIntreACT")
        super.viewDidLoad()
        myTableView.backgroundColor = UIColor.clear
        chatView.layer.borderColor = UIColor.lightGray.cgColor
        chatView.layer.borderWidth = 1
        chatView.layer.cornerRadius = 8
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        self.nameLabel.text = staffName
        self.sectionLabel.text = subjectName
        let SendTextmessageLength = String(appDelegate.MaxGeneralSMSCountString)
        MaxTextCount = Int(SendTextmessageLength)!
        callSelectedLanguage()
        TextMessageView.text = strTextViewPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        self.setupTextViewAccessoryView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageNumber = 0
        stdSubjectArray = []
    }
    
    //MARK: TEXTVIEW DELEGATE DELEGATE
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(TextMessageView.text == strTextViewPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if UIDevice.current.hasNotch {
            self.view.frame.origin.y -= 350
        } else {
            self.view.frame.origin.y -= 290
        }
        
        if(TextMessageView.text == strTextViewPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentCharacterCount = TextMessageView.text?.count ?? 0
        
        if (range.length + range.location > currentCharacterCount){
            
            return false
        }
        
        let newLength = currentCharacterCount + text.count - range.length
        
        let length : integer_t
        
        length = integer_t(MaxTextCount) - Int32(newLength)
        
        if(length <= 0){
            
            return false
        }
        else if textView.text?.last == " "  && text == " "
        {
            return false
        }
        else {
            let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
            return newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
        }
    }
    
    func setupTextViewAccessoryView() {
        
        let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        let flexsibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(didPressDoneButton))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        toolBar.items = [flexsibleSpace, doneButton]
        TextMessageView.inputAccessoryView = toolBar
    }
    
    @objc func didPressDoneButton(button: UIButton) {
        if UIDevice.current.hasNotch {
            if(UIDevice.current.userInterfaceIdiom == .pad){
                self.view.frame.origin.y = 64
            }else{
                self.view.frame.origin.y = 86
            }
        } else {
            self.view.frame.origin.y = 64
            
        }
        if( TextMessageView.text == "" ||  TextMessageView.text!.count == 0 || ( TextMessageView.text!.trimmingCharacters(in: .whitespaces).count) == 0){
            TextMessageView.text = strTextViewPlaceholder
            TextMessageView.textColor = UIColor.lightGray
        }
        TextMessageView.resignFirstResponder()
    }
    
    
    // MARK: - Textfield delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if UIDevice.current.hasNotch {
            self.view.frame.origin.y -= 300
        } else {
            self.view.frame.origin.y -= 230
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if UIDevice.current.hasNotch {
            if(UIDevice.current.userInterfaceIdiom == .pad){
                self.view.frame.origin.y = 64
            }else{
                self.view.frame.origin.y = 86
            }
        } else {
            self.view.frame.origin.y = 64
            
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= MaxTextCount
    }
    // MARK: - TableView delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let Dict = stdSubjectArray[section] as! NSDictionary
        var cellCount = 0
        if(String(describing: Dict["AnsweredOn"]!) == ""){
            cellCount = 1
        }else{
            cellCount = 2
        }
        return cellCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stdSubjectArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let Dict = stdSubjectArray[indexPath.section] as! NSDictionary
        if(indexPath.row == 0){
            let  cell = tableView.dequeueReusableCell(withIdentifier: "StudentChatTVCell", for: indexPath) as! StudentChatTVCell
            cell.backgroundColor = UIColor.clear
            
            cell.timeLabel.text = String(describing: Dict["CreatedOn"]!)
            cell.messageLabel.text = String(describing: Dict["Question"]!)
            return cell
            
        }else{
            let cell  = tableView.dequeueReusableCell(withIdentifier: "StaffChatTVCell", for: indexPath) as! StaffChatTVCell
            cell.backgroundColor = UIColor.clear
            cell.nameLable.text = self.staffName
            cell.timeLabel.text = String(describing: Dict["CreatedOn"]!)
            cell.messageLabel.text = String(describing: Dict["Answer"]!)
            let daysCount = UtilObj.daysBetween(strDate: String(describing: Dict["AnsweredOn"]!))
            if(daysCount == "0"){
                
                cell.daysLabel.text =  "Today"
            }else if(daysCount == "1"){
                cell.daysLabel.text = daysCount + " day"
            }else{
                cell.daysLabel.text =  daysCount + " days"
            }

            print("studentChatId",studentChatId)


            if studentChatId == 1 {

                let staffView = String(describing: Dict["is_staff_viewed"]!)
                print("StudentChatTVCell",staffView)
                if staffView  == "0" {
                    cell.staffUnreadImg.isHidden = false
                    cell.staffUnreadImg.image = UIImage(named: "p25")
                }else{
                    cell.staffUnreadImg.isHidden = true
                }
            }

                else{
                    cell.staffUnreadImg.isHidden = true
                }


            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = stdSubjectArray.count - 1
        if indexPath.section == lastElement {
            print(stdSubjectArray.count)
            if(chatCount >= stdSubjectArray.count ){
                if(!isNewDataLoading){
                    self.GetStaffSubiectApiCalling()
                }
            }
            
        }
    }
    
    @IBAction func actionSendQuestion(_ sender: Any) {
        if UIDevice.current.hasNotch {
            if(UIDevice.current.userInterfaceIdiom == .pad){
                self.view.frame.origin.y = 64
            }else{
                self.view.frame.origin.y = 86
            }
        } else {
            self.view.frame.origin.y = 64
            
        }
        TextMessageView.resignFirstResponder()
        if(TextMessageView.text!.isEmpty || TextMessageView.text == strTextViewPlaceholder){
            self.showAlert(alert: "", message: "Please enter your question")
        }else{
            postQuestionApiCalling()
            
        }
        
    }
    
    
    //MARK: API CALLING
    func postQuestionApiCalling(){
        showLoading()
        apiCallFrom = "question"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + POST_STUDENT_QUESTION
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["StaffID" : StaffId,
                                          "StudentID" : ChildId,
                                          "SchoolID":SchoolId,
                                          "SectionID":sectionId,
                                          "SubjectID":subjectId,
                                          "isClassTeacher" : strClassTeacher,
                                          "Question" : TextMessageView.text! == strTextViewPlaceholder ? "" : TextMessageView.text! ]
        let myString = Util.convertDictionary(toString: myDict)
        print("myString",myString)
        print("mrequestStringyString",requestString)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStaffDetailApi")
    }
    
    
    func GetStaffSubiectApiCalling(){
        isNewDataLoading = true
        showLoading()
        apiCallFrom = "chat"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        let requestStringer =  baseUrlString! + GET_STUDENT_CHAT_MESSAGE
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        print("requestString\(requestString)")
        
        let myDict:NSMutableDictionary = ["StaffID" : StaffId,
                                          "StudentID" : ChildId,
                                          "SectionID":sectionId,
                                          "SubjectID":subjectId,
                                          "isClassTeacher" : strClassTeacher,
                                          "Offset" : pageNumber]
        let myString = Util.convertDictionary(toString: myDict)
        
        print("staffdetailmyString",myString)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStaffDetailApi")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        
        hideLoading()
        if(csData != nil)
        {
            UtilObj.printLogKey(printKey: "CSData", printingValue: csData!)
            if let CheckedDict = csData as? NSArray
            {
                if(CheckedDict.count > 0)
                {
                    if let Dict = CheckedDict[0] as? NSDictionary{
                        let status = String(describing: Dict["Status"]!)
                        let alrtMessage = Dict["Message"] as! String
                        if(status == "1"){
                            if(apiCallFrom == "chat"){
                                isNewDataLoading = false
                                stdSubjectArray.addObjects(from: CheckedDict as! [Any])
                                
                                offSet = Int(String(describing: Dict["Offset"]!)) ?? 0
                                limit = Int(String(describing: Dict["Limit"]!)) ?? 0
                                chatCount = Int(String(describing: Dict["ChatCount"]!)) ?? 0
                                
                                if(offSet == 0){
                                    if(stdSubjectArray.count >= limit){
                                        pageNumber = pageNumber + 1
                                    }else{
                                        pageNumber = 0
                                    }
                                    
                                }else{
                                    if( stdSubjectArray.count >= (offSet + 1) * limit){
                                        pageNumber = pageNumber + 1
                                    }
                                }
                                
                                myTableView.reloadData()
                            }else{
                                self.TextMessageView.text = ""
                                if let resultDict = Dict["result"] as? NSDictionary{
                                    stdSubjectArray.add(resultDict)
                                }
                                self.myTableView.reloadData()
                                //self.GetStaffSubiectApiCalling()
                                //  self.showAlert(alert: "", message: alrtMessage)
                            }
                        }else{
                            if(apiCallFrom == "chat"){
                            }else{
                                self.showAlert(alert: "", message: alrtMessage)
                            }
                        }
                    }else{
                        self.AlerMessage(alrtStr: strNoRecordAlert)
                    }
                    
                }else
                {
                    if(apiCallFrom == "chat"){
                    }else{
                        self.AlerMessage(alrtStr: strNoRecordAlert)
                    }
                    
                }
                
            }else
            {
                self.AlerMessage(alrtStr: strNoRecordAlert)
            }
            
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        hideLoading()
        
    }
    
    func AlerMessage(alrtStr : String){
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: alrtStr, preferredStyle: .alert)
        let okAction = UIAlertAction(title:languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
                }else{
                    self.GetStaffSubiectApiCalling()
                }
            } catch {
                self.GetStaffSubiectApiCalling()
            }
        }
    }
    
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            
        }
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
        GetStaffSubiectApiCalling()
    }
    
    
}
