//
//  StaffChatDetailVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 12/06/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffChatDetailVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate,Apidelegate{
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var chatMessageView: UIView!
    @IBOutlet weak var chatViewHeight: NSLayoutConstraint!
    // @IBOutlet weak var chatMessageTextField: UITextField!
    
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var menuAnswerButton: UIButton!
    @IBOutlet weak var replayPrivateButton: UIButton!
    
    @IBOutlet weak var TextMessageView: UITextView!
    var KlCAnswerpopup : KLCPopup  = KLCPopup()
    let UtilObj = UtilClass()
    var strCountryCode = String()
    var apiFrom = String()
    var SchoolId  = String()
    var questionId  = String()
    var ReplyType  = String()
    var changeAnswer  = String()
    var StaffId  = String()
    var selectedSchoolDictionary = NSDictionary()
    var selectedChatDict = NSDictionary()
    var staffChatArray = NSMutableArray()
    var languageDictionary = NSDictionary()
    var SchoolDetailDict = NSDictionary()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var loginAsName = String()
    var strSomething = String()
    var MaxTextCount = Int()
    var pageNumber = 0
    var offSet = 0
    var limit = 0
    var chatCount = 0
    var strTextViewPlaceholder = "Type your answer.."
    
    var stralerMsg = String()
    
    var isNewDataLoading = false
    var hud : MBProgressHUD = MBProgressHUD()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Teacher Chat"
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        UtilObj.Shadowview(MyView: menuView)
        UtilObj.Shadowview(MyView: replayPrivateButton)
        UtilObj.Shadowview(MyView: replayButton)
        
        self.chatView.isHidden = true
        self.chatViewHeight.constant = 0
        chatMessageView.layer.borderColor = UIColor.lightGray.cgColor
        chatMessageView.layer.borderWidth = 1
        chatMessageView.layer.cornerRadius = 8
        self.myTableView.backgroundColor = UIColor.clear
        
        let SendTextmessageLength = String(appDelegate.MaxGeneralSMSCountString)
        MaxTextCount = Int(SendTextmessageLength)!
        callSelectedLanguage()
        TextMessageView.text = strTextViewPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        self.setupTextViewAccessoryView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageNumber = 0
        staffChatArray = []
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
        self.view.frame.origin.y -= 250
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
        closeTextField()
        if( TextMessageView.text == "" ||  TextMessageView.text!.count == 0 || ( TextMessageView.text!.trimmingCharacters(in: .whitespaces).count) == 0){
            TextMessageView.text = strTextViewPlaceholder
            TextMessageView.textColor = UIColor.lightGray
        }
        TextMessageView.resignFirstResponder()
    }
    
    // MARK: - Textfield delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.view.frame.origin.y -= 220
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        closeTextField()
        textField.resignFirstResponder()
        return true
    }
    
    func closeTextField(){
        if UIDevice.current.hasNotch {
            if(UIDevice.current.userInterfaceIdiom == .pad){
                self.view.frame.origin.y = 64
            }else{
                self.view.frame.origin.y = 86
            }
        } else {
            self.view.frame.origin.y = 64
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= MaxTextCount
    }
    
    // MARK: - TableView delegates
    // MARK: - TableView delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let Dict = staffChatArray[section] as! NSDictionary
        var cellCount = 0
        if(String(describing: Dict["AnsweredOn"]!) == ""){
            cellCount = 1
        }else{
            cellCount = 2
        }
        return cellCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return staffChatArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let Dict = staffChatArray[indexPath.section] as! NSDictionary
        if(indexPath.row == 0){
            let  cell = tableView.dequeueReusableCell(withIdentifier: "StudentChatTVCell", for: indexPath) as! StudentChatTVCell
            cell.backgroundColor = UIColor.clear
            cell.nameLable.text = String(describing: Dict["StudentName"]!)
            cell.timeLabel.text = String(describing: Dict["CreatedOn"]!)
            cell.messageLabel.text = String(describing: Dict["Question"]!)


            let staffView = String(describing: Dict["is_staff_viewed"]!)
            print("StudentChatTVCell",staffView)
            if staffView  == "0" {
                cell.unreadImg.isHidden = false
                cell.unreadImg.image = UIImage(named: "p25")
            }else{
                cell.unreadImg.isHidden = true
            }

            cell.menuButton.isHidden = true
            cell.menuButton.addTarget(self, action: #selector(menuButton(sender:)), for: .touchUpInside)
            cell.menuButton.tag = indexPath.section
            if(loginAsName == "Staff"){
                cell.menuButton.isHidden = false
                
            }
            return cell
            
        }else{
            let cell  = tableView.dequeueReusableCell(withIdentifier: "StaffChatTVCell", for: indexPath) as! StaffChatTVCell
            cell.backgroundColor = UIColor.clear
            //cell.nameLable.text = self.staffName
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

//            let staffView = String(describing: Dict["is_staff_viewed"]!)     
//            print("StaffChatTVCell",staffView)
//
//            if staffView  == "0" {
//                cell.staffUnreadImg.isHidden = false
//                cell.staffUnreadImg.image = UIImage(named: "p25")
//            }else{
//                cell.staffUnreadImg.isHidden = true
//            }
            return cell
        }
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = staffChatArray.count - 1
        
        if indexPath.row == lastElement {
            print(staffChatArray.count)
            if(chatCount >= staffChatArray.count ){
                if(!isNewDataLoading){
//                    self.GetStaffChatApiCalling()
                }
            }
            
        }
    }
    
    // MARK: - Button action
    @objc func menuButton(sender: UIButton)
    {
        let Dict = staffChatArray[sender.tag] as! NSDictionary
        questionId = String(describing: Dict["QuestionID"]!)
        
        if(String(describing: Dict["AnsweredOn"]!) == ""){
            changeAnswer = "0"
            menuAnswerButton.setTitle("Answer", for: .normal)
        }else{
            changeAnswer = "1"
            menuAnswerButton.setTitle("Update Answer", for: .normal)
        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            menuView.frame.size.height = 80
            menuView.frame.size.width = 250
        }
        
        //        G3
        menuView.center = view.center
        menuView.alpha = 1
        menuView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(menuView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.menuView.transform = .identity
        })
        
        
        print("StaffChatdetailVc")
        KlCAnswerpopup.isUserInteractionEnabled = true
        KlCAnswerpopup.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        
    }
    
    @IBAction func actionReplyAll(_ sender: Any) {
        closeTextField()
        TextMessageView.resignFirstResponder()
        ReplyType = "1"
        if(TextMessageView.text!.isEmpty || TextMessageView.text == strTextViewPlaceholder){
            self.showAlert(alert: "", message: "Please enter your answer")
        }else{
            StaffReplyAnswerApiCall()
            
        }
        
    }
    
    @IBAction func actionReplyPrivately(_ sender: Any) {
        closeTextField()
        TextMessageView.resignFirstResponder()
        ReplyType = "2"
        if(TextMessageView.text!.isEmpty || TextMessageView.text == strTextViewPlaceholder){
            self.showAlert(alert: "", message: "Please enter your answer")
        }else{
            StaffReplyAnswerApiCall()
            
        }
    }
    
    @IBAction func actionAnswer(_ sender: Any) {
        self.chatView.isHidden = false
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            self.chatViewHeight.constant = 200
        }else{
            self.chatViewHeight.constant = 180
        }
        
        KlCAnswerpopup.dismiss(true)
        
    }
    
    @objc func dismissOnTapOutside(){
        self.chatView.isHidden = true
        self.chatViewHeight.constant = 0
        
                    KlCAnswerpopup.dismiss(true)
              }
    
    
    
    //MARK: API CALLING
    
    func GetStaffChatApiCalling(){
        isNewDataLoading = true
        showLoading()
        apiFrom = "getDetail"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_STAFF_CHAT_MESSAGE
//        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        
//        requestStringer = baseReportUrlString! + GET_STAFF_CHAT_MESSAGE
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        print("requestString\(requestString)")
        
        let myDict:NSMutableDictionary = ["StaffID" : StaffId,
                                          "Offset":pageNumber,
                                          "SectionID" : String(describing: selectedChatDict["SectionId"]!),
                                          "SubjectID" : String(describing: selectedChatDict["SubjectID"]!),
                                          "isClassTeacher" : String(describing: selectedChatDict["isClassTeacher"] ?? "")]
        
        print("myDict34\(myDict)")
        let myString = Util.convertDictionary(toString: myDict)
        print("myStrin3333g\(myString)")
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStaffDetailApi")
    }
    
    func StaffReplyAnswerApiCall(){
        showLoading()
        apiFrom = "replyAnswer"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + POST_STAFF_ANSWER
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + POST_STAFF_ANSWER
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
        let myDict:NSMutableDictionary = ["StaffId" : StaffId,
                                          "ReplyType":  ReplyType,
                                          "QuestionID" : questionId,
                                          "Answer" : self.TextMessageView.text! == strTextViewPlaceholder ? "" :  self.TextMessageView.text!,
                                          "isChangeAnswer":changeAnswer
                                          
        ]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStaffDetailApi")
    }
    
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {

        print("CSDATE11",csData)
        hideLoading()
        if(csData != nil)
        {
            UtilObj.printLogKey(printKey: "CSData", printingValue: csData!)
            if let CheckedDict = csData as? NSArray
            {
                print("GETDETAIL",CheckedDict.count)
                if(CheckedDict.count > 0)
                {
                    if let Dict = CheckedDict[0] as? NSDictionary{
                        let status = String(describing: Dict["Status"]!)
                        let alrtMessage = Dict["Message"] as! String
                        if(status == "1"){
                            if(apiFrom == "getDetail"){
                                isNewDataLoading = false
                                staffChatArray.addObjects(from: CheckedDict as! [Any])
                                
                                offSet = Int(String(describing: Dict["Offset"]!)) ?? 0
                                limit = Int(String(describing: Dict["Limit"]!)) ?? 0
                                chatCount = Int(String(describing: Dict["ChatCount"]!)) ?? 0
                                
                                if(offSet == 0){
                                    if(staffChatArray.count >= limit){
                                        pageNumber = pageNumber + 1
                                    }else{
                                        pageNumber = 0
                                    }
                                    
                                }else{
                                    if( staffChatArray.count >= (offSet + 1) * limit){
                                        pageNumber = pageNumber + 1
                                    }
                                }
                                myTableView.reloadData()
                            }else{
                                
                                self.chatViewHeight.constant = 0
                                self.chatView.isHidden = true
                                
                                if let resultDict = Dict["result"] as? NSDictionary{
                                    
                                    let resultPredicate = NSPredicate(format: "%K == %i","QuestionID" , resultDict["QuestionID"] as! Int )
                                    let arrSearchResults = staffChatArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
                                    print(arrSearchResults)
                                    
                                    if(arrSearchResults.count > 0){
                                        let compareDict = arrSearchResults[0] as! NSDictionary
                                        if(staffChatArray.contains(compareDict)){
                                            staffChatArray.remove(compareDict)
                                            staffChatArray.add(resultDict)
                                        }else{
                                            staffChatArray.add(resultDict)
                                        }
                                    }
                                    
                                    
                                }
                                self.myTableView.reloadData()
                                // self.AlerMessage(alrtStr: alrtMessage)
                            }
                        }else{
                            print("alert64t74111")
                            self.AlerMessage(alrtStr: alrtMessage)
                        }
                        
                    }else{
                        print("alert1r4r4r11")
                        self.AlerMessage(alrtStr: strNoRecordAlert)
                    }
                    
                }else
                {
                    print("GEL",CheckedDict.count)
                    if(apiFrom == "getDetail"){
                        print("alergetDetailt111",offSet)
                        if(offSet == 0){
                            self.AlerMessage(alrtStr: strNoRecordAlert)
                        }
                        
                    }else{
                        print("alert111")
                        self.AlerMessage(alrtStr: strNoRecordAlert)
                    }
                    
                }
                
            }else
            {
                print("alert11145555")
                self.AlerMessage(alrtStr: strNoRecordAlert)
                
            }
            
        }
        else
        {
            print("alert112763u3255")
            Util.showAlert("", msg: strSomething)
        }
        hideLoading()
        
    }
    
    func AlerMessage(alrtStr : String){
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: alrtStr, preferredStyle: .alert)
        let okAction = UIAlertAction(title:languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
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
                    GetStaffChatApiCalling()
                }
            } catch {
                GetStaffChatApiCalling()
            }
        }
    }
    
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        GetStaffChatApiCalling()
    }
    
}

