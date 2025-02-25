//
//  TextMessageVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 18/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class TextMessageVC: UIViewController,UITextViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,Apidelegate{
    
    @IBOutlet var HeaderView: UIView!
    @IBOutlet weak var TextMessageView: UITextView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var SendTextMessageLabel: UILabel!
    @IBOutlet weak var remainingCharactersLabel: UILabel!
    @IBOutlet weak var TextMessageTitle: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    
    //MARK :- Text History
    @IBOutlet var TextHistoryTableView: UITableView!
    @IBOutlet weak var TextHistoryView: UIView!
    @IBOutlet weak var ComposeTextImage: UIImageView!
    @IBOutlet weak var TextHistoryImage: UIImageView!
    @IBOutlet weak var ComposeTextLabel: UILabel!
    @IBOutlet weak var SelectFromTextHistoryLabel: UILabel!
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    var TextHistoryArray = NSMutableArray()
    var SelectedTextHistoryArray = NSMutableArray()
    var strApiFrom = NSString()
    var fromView = String()
    var strStaffID = String()
    var strSchoolID = String()
    var SchoolDict = NSDictionary()
    var strFromVC = String()
    var strTextViewPlaceholder = String()
    var languageDict = NSDictionary()
    var strCountryCode = String()
    var strLanguage = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var selectedSchoolDictionary = NSMutableDictionary()
    var ScreenWidth = CGFloat()
    var selectedSchoolID = NSString()
    var selectedStaffID = NSString()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var CallerTyepString = String()
    var selectedSchoolsArray = NSMutableArray()
    var schoolsArray = NSMutableArray()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var MaxTextCount = Int()
    var checkSchoolId : String!
    var checkMultipleType : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        
        
        print("TEXTMESSAGEVCCC")
        print("strSchoolID",strSchoolID)
        let userDefaults = UserDefaults.standard
        var staffDisplayRole : String!
        staffDisplayRole = userDefaults.string(forKey: DefaultsKeys.staffDisplayRole)
        if staffDisplayRole == "Principal" {
            strFromVC = "Principal"
        }
        if checkMultipleType == "1" {
            //            strSchoolID
            print("viewstrStaffID",strStaffID)
            print("viewstrSchoolID",strSchoolID)
        }else{
            
            let defaults = UserDefaults.standard
            strStaffID = userDefaults.string(forKey: DefaultsKeys.StaffID)!
            strSchoolID = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    
    func Config(){
        sendButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        sendButton.isUserInteractionEnabled = false
        let idGroupHead = appDelegate.idGroupHead as NSString
        if(idGroupHead .isEqual(to: "true")){
            sendButton.isHidden = false
            for  schoolDict in appDelegate.LoginSchoolDetailArray {
                let singleSchoolDictionary = schoolDict as? NSDictionary
                let schoolDic = NSMutableDictionary()
                schoolDic["SchoolId"] = singleSchoolDictionary?.object(forKey: "SchoolID")
                schoolDic["StaffID"] = singleSchoolDictionary?.object(forKey: "StaffID")
                schoolsArray.add(schoolDic)
                selectedSchoolsArray.add(schoolDic)
            }
            sendButton.setTitle(languageDict["teacher_Select_school"] as? String  , for: .normal)
            self.enableButtonAction()
        }
        else{
            sendButton.setTitle(languageDict["select_reciepients"] as? String, for: .normal)
        }
        
        if(schoolsArray.count > 0){
            let dict = schoolsArray[0] as! NSDictionary
            strStaffID = String(describing: dict["StaffID"]!)
            strSchoolID = String(describing: dict["SchoolID"]!)
        }
        
        self.actionComposeTextMessage()
        
    }
    
    func textviewEnableorDisable(){
        if(TextMessageView.text.count > 0 && TextMessageView.text != strTextViewPlaceholder){
            enableButtonAction()
        }else{
            disableButtonAction()
        }
    }
    // MARK: TEXTFIELD DELEGATE///
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 0 && string == " " {
            return false
        }
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.ConfigSendButton()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        if(TextMessageView.text.count > 0){
            enableButtonAction()
        }else{
            disableButtonAction()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
        if(TextMessageView.text == strTextViewPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
        self.ConfigSendButton()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupTextViewAccessoryView()
        
        if(TextMessageView.text == strTextViewPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
        self.ConfigSendButton()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        self.ConfigSendButton()
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
        
        
        
        
        remainingCharactersLabel.text = String (length)
        
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
        if( TextMessageView.text == "" ||  TextMessageView.text!.count == 0 || ( TextMessageView.text!.trimmingCharacters(in: .whitespaces).count) == 0){
            TextMessageView.text = strTextViewPlaceholder
            TextMessageView.textColor = UIColor.lightGray
        }
        TextMessageView.resignFirstResponder()
        textviewEnableorDisable()
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionNextButton(_ sender: UIButton) {
        self.dismissKeyboard()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "TextToPrincipalGroupSegue", sender: self)
            
        }
    }
    @IBAction func actionSendButton (_ sender: UIButton) {
        if(strFromVC == "Principal"){
            if(self.fromView == "Compose"){
                selectedSchoolDictionary["Description"] = descriptionTextField.text!
                selectedSchoolDictionary["Message"] = TextMessageView.text!
            }else{
                let Dict : NSDictionary = SelectedTextHistoryArray[0] as! NSDictionary
                selectedSchoolDictionary["Description"] =  String(describing: Dict["Description"]!)
                selectedSchoolDictionary["Message"] = String(describing: Dict["Content"]!)
            }
            selectedSchoolDictionary["SchoolID"] = strSchoolID as NSString
            selectedSchoolDictionary["StaffID"] = strStaffID as NSString
            
            self.performSegue(withIdentifier: "TextToPrincipalGroupSegue", sender: self)
            
        }else{
            self.performSegue(withIdentifier: "TextMessageToSchoolSelectionSegue", sender: self)
        }
        
        
    }
    
    @IBAction func actionComposeTextMessage(){
        self.fromView = "Compose"
        self.HeaderView.isHidden = false
        self.TextHistoryView.isHidden = true
        self.ComposeTextImage.image = UIImage(named: "PurpleRadioSelect")
        self.TextHistoryImage.image = UIImage(named: "RadioNormal")
        self.textviewEnableorDisable()
    }
    
    @IBAction func actionTextMessageHistory(){
        self.fromView = "History"
        self.HeaderView.isHidden = true
        self.TextHistoryView.isHidden = false
        self.ComposeTextImage.image = UIImage(named: "RadioNormal")
        self.TextHistoryImage.image = UIImage(named: "PurpleRadioSelect")
        self.callTextHistoryApi()
        
    }
    
    func enableButtonAction(){
        sendButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        sendButton.isUserInteractionEnabled = true
    }
    
    func disableButtonAction(){
        sendButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        sendButton.isUserInteractionEnabled = false
        
    }
    
    @objc func actionVoiceHistoryCheckboxButton(sender: UIButton){
        let dict = self.TextHistoryArray[sender.tag] as! NSDictionary
        if((self.SelectedTextHistoryArray.contains(dict))){
            self.SelectedTextHistoryArray.remove(dict)
        }else{
            self.SelectedTextHistoryArray.removeAllObjects()
            self.SelectedTextHistoryArray.add(dict)
        }
        HistoryButtonAction()
        self.TextHistoryTableView.reloadData()
    }
    
    func HistoryButtonAction(){
        if(self.SelectedTextHistoryArray.count > 0){
            enableButtonAction()
        }else{
            disableButtonAction()
        }
    }
    
    
    func dismissKeyboard()
    {
        TextMessageView.resignFirstResponder()
    }
    
    //MARK: TABLEVIEW DELEGATE
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 190
        }else{
            return 175
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.TextHistoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageHistoryTVCell", for: indexPath) as! TextMessageHistoryTVCell
        let dict = self.TextHistoryArray[indexPath.row] as! NSDictionary
        cell.SubjectLbl.text = String(describing: dict["Description"]!)
        cell.TextMessageLabel.text = String(describing: dict["Content"]!)
        cell.audioCheckBoxButton.tag = indexPath.row
        cell.audioCheckBoxButton.addTarget(self, action: #selector(actionVoiceHistoryCheckboxButton(sender:)), for: .touchUpInside)
        
        if(self.SelectedTextHistoryArray.contains(dict)){
            cell.audioCheckBoxButton.setImage(UIImage(named: "PurpleCheckBoxImage"), for: .normal)
        }else{
            cell.audioCheckBoxButton.setImage(UIImage(named: "UnChechBoxImage"), for: .normal)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
        
    }
    
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "TextToPrincipalGroupSegue")
        {
            
            print("1231",strSchoolID)
            
            if checkSchoolId == "1" {
                
                
                let segueid = segue.destination as! PrincipalGroupSelectionVC
                segueid.fromViewController = "TextToParents"
                segueid.SchoolID = strSchoolID as NSString
                segueid.StaffID = strStaffID as NSString
                print("strSchoolID as NSString",strSchoolID as NSString)
                segueid.selectedSchoolDictionary = selectedSchoolDictionary
            }
            else{
                
                let segueid = segue.destination as! PrincipalGroupSelectionVC
                segueid.fromViewController = "TextToParents"
                segueid.SchoolID = strSchoolID as NSString
                segueid.StaffID = strStaffID as NSString
                print("strSchoolID as NSString",strSchoolID as NSString)
                segueid.selectedSchoolDictionary = selectedSchoolDictionary
                
            }
            
            
        }else if (segue.identifier == "TextMessageToSchoolSelectionSegue"){
            let segueid = segue.destination as! SchoolSelectionVC
            print("456")
            if(self.fromView == "Compose"){
                print("1253")
                segueid.strMessage = TextMessageView.text!
                segueid.strDescription = descriptionTextField.text!
            }else{
                print("1234")
                let Dict : NSDictionary = SelectedTextHistoryArray[0] as! NSDictionary
                segueid.strDescription = String(describing: Dict["Description"]!)
                segueid.strMessage = String(describing: Dict["Content"]!)
            }
            print("789")
            segueid.strCallerType = self.CallerTyepString
            segueid.senderName = "GroupHeadText"
        }
    }
    
    //MARK: Api Calling
    func callSendSMSToEntireSchools()
    {
        showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        let requestStringer = baseUrlString! + SendSMSToEntireSchools
        
        let arrUserData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = [
            "Description" : descriptionTextField.text!,
            "CallerType" : CallerTyepString,
            "Message" : TextMessageView.text!,
            "School" : selectedSchoolsArray, COUNTRY_CODE: strCountryCode]
        
        arrUserData.add(myDict)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "TextToParents")
    }
    
    func callTextHistoryApi(){
        showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GetSMSHistory
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GetSMSHistory
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["StaffID" : self.strStaffID,
                                          "SchoolId" : self.strSchoolID,
                                          COUNTRY_CODE: strCountryCode]
        let apiCall = API_call.init()
        apiCall.delegate = self;
        print("TTTRTGTR",requestString)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "TextMessageHistoryApi")
    }
    
    //MARK: Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if((csData?.count)! > 0){
                let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                
                if let status = dicUser["Status"] as? NSString
                {
                    let Status = status
                    let Message = dicUser["Message"] as! NSString
                    
                    if(Status .isEqual(to: "1")){
                        self.TextHistoryArray = csData!
                        self.TextHistoryTableView.reloadData()
                        HistoryButtonAction()
                    }else{
                        alertWithAction(strAlert: Message as! String)
                    }
                }else{
                    Util.showAlert("", msg: strSomething)
                }
            }else{
                Util.showAlert("", msg: strSomething)
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
        
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
    }
    
    func ConfigSendButton()
    {
        if(TextMessageView.text.count > 0)
        {
            sendButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
            sendButton.isUserInteractionEnabled = true
        }
        else
        {
            sendButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            sendButton.isUserInteractionEnabled = false
        }
    }
    
    func alertWithAction(strAlert : String){
        let alertController = UIAlertController(title: "", message: strAlert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.actionComposeTextMessage()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
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
        languageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            TextMessageView.textAlignment = .right
            descriptionTextField.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            TextMessageView.textAlignment = .left
            descriptionTextField.textAlignment = .left
        }
        ComposeTextLabel.text = LangDict["text_new_msg"] as? String
        TextMessageTitle.text = LangDict["teacher_txt_composehwmsg"] as? String
        SelectFromTextHistoryLabel.text = LangDict["text_compose_history"] as? String
        descriptionTextField.placeholder = LangDict["teacher_txt_onwhat"] as? String
        strTextViewPlaceholder = LangDict["teacher_txt_typemsg"] as? String ?? "Content?"
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
    }
    func loadViewData(){
        TextMessageView.text = strTextViewPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        sendButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        sendButton.isUserInteractionEnabled = false
        sendButton.layer.cornerRadius = 5
        sendButton.layer.masksToBounds = true
        let SendTextmessageLength = String(appDelegate.MaxGeneralSMSCountString)
        MaxTextCount = Int(SendTextmessageLength)!
        if(strLanguage == "ar"){
            SendTextMessageLabel.text =  SendTextmessageLength + "/"
        }else{
            SendTextMessageLabel.text = "/" + SendTextmessageLength
        }
        
        textviewEnableorDisable()
        if(TextMessageView.text != strTextViewPlaceholder)
        {
            //TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
            
        }
        let idGroupHead = appDelegate.idGroupHead as NSString
        let isPrincipal = appDelegate.isPrincipal as NSString
        print("isPrincipalTextM",isPrincipal)
        print("isPrincipalisEqualTexm",isPrincipal .isEqual(to: "true"))
        
        if(isPrincipal .isEqual(to: "true")){
            CallerTyepString = "M"
            print(SchoolDict)
            strSchoolID = String(describing: SchoolDict["SchoolID"]!)
            strStaffID =  String(describing: SchoolDict["StaffID"]!)
        }
        else if(idGroupHead .isEqual(to: "true")){
            CallerTyepString = "A"
        }
        self.Config()
    }
    
}
