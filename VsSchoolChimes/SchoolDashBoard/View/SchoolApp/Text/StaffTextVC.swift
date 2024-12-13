//
//  StaffTextVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 25/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffTextVC:  UIViewController,UITextViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,Apidelegate{
    
    @IBOutlet weak var TextMessageView: UITextView!
    @IBOutlet weak var TitleText: UITextField!
    @IBOutlet weak var SendTextMessageLabel: UILabel!
    @IBOutlet weak var remainingCharactersLabel: UILabel!
    @IBOutlet weak var TextMesssageTitle: UILabel!
    @IBOutlet weak var ToStandardSection: UIButton!
    @IBOutlet weak var ToStandardStudent: UIButton!
    @IBOutlet weak var composeTextView: UIView!
    @IBOutlet var TextHistoryTableView: UITableView!
    @IBOutlet weak var TextHistoryView: UIView!
    @IBOutlet weak var ComposeTextImage: UIImageView!
    @IBOutlet weak var TextHistoryImage: UIImageView!
    @IBOutlet weak var ComposeTextLabel: UILabel!
    @IBOutlet weak var SelectFromTextHistoryLabel: UILabel!
    
    @IBOutlet weak var ToStaffGroups: UIButton!
    
    var strCountryCode = String()
    var strCountryName = String()
    var loginAsName = String()
    var SchoolId = String()
    var StaffId = String()
    var MaxTextCount = Int()
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let UtilObj = UtilClass()
    var hud : MBProgressHUD = MBProgressHUD()
    var TextHistoryArray = NSMutableArray()
    var SelectedTextHistoryArray = NSMutableArray()
    var strApiFrom = NSString()
    var fromView = String()
    var strTextViewPlaceholder = String()
    var languageDict = NSDictionary()
    var strLanguage = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StaffTextVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
        
        
        ToStaffGroups.isHidden = false
        ToStaffGroups.isHidden = true
        
        strCountryName = UserDefaults.standard.object(forKey: COUNTRY_Name) as? String ?? ""
        print(strCountryName)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    
    func textviewEnableorDisable(){
        if(TextMessageView.text.count > 0 && TextMessageView.text != strTextViewPlaceholder){
            enableButtonAction()
        }else{
            disableButtonAction()
        }
    }
    
    func enableButtonAction(){
        ToStandardSection.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        ToStandardSection.isUserInteractionEnabled = true
        ToStandardStudent.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        ToStandardStudent.isUserInteractionEnabled = true
        ToStaffGroups.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        ToStaffGroups.isUserInteractionEnabled = true
    }
    
    func disableButtonAction(){
        ToStandardSection.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        ToStandardSection.isUserInteractionEnabled = false
        ToStandardStudent.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        ToStandardStudent.isUserInteractionEnabled = false
        ToStaffGroups.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        ToStaffGroups.isUserInteractionEnabled = false
    }
    
    
    //MARK: TEXTFIELD DELEGATE
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " " {
            return false
        }
        return true
    }
    
    //MARK: TEXTVIEW DELEGATE
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(TextMessageView.text == strTextViewPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupTextViewAccessoryView()
        if(TextMessageView.text == strTextViewPlaceholder){
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView){
        if(TextMessageView.text.count > 0){
            enableButtonAction()
        }else{
            disableButtonAction()
        }
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
        }else if textView.text?.last == " "  && text == " "{
            return false
        }else {
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
    }
    
    //MARK:BUTTON ACTION
    
    @IBAction func actionToStaffGroups(_ sender: UIButton) {
        
        
        let vc =  StaffGroupVoiceViewController(nibName: nil, bundle: nil)
        
        
        
        if( self.fromView == "Compose"){
            vc.modalPresentationStyle = .fullScreen
            vc.MessageStr = TitleText.text!
            vc.DescStr = TextMessageView.text!
            vc.SchoolId = SchoolId
            vc.StaffId = StaffId
            print("SchoolId1",SchoolId)
            vc.selectType = "Text"
            
            present(vc, animated: true, completion: nil)
        }else{
            if(self.SelectedTextHistoryArray.count > 0){
                let Dict = self.SelectedTextHistoryArray[0] as! NSDictionary
                vc.modalPresentationStyle = .fullScreen
                
                vc.DescStr = String(describing: Dict["Description"]!)
                vc.MessageStr = String(describing: Dict["Content"]!)
                vc.selectType = "Text"
                vc.SchoolId = SchoolId
                vc.StaffId = StaffId
                
                present(vc, animated: true, completion: nil)
            }else{
                Util.showAlert("", msg: languageDict["please_select_message"] as? String)
            }
            
            
            
        }
        
    }
    
    @IBAction func actionComposeTextMessage(){
        self.fromView = "Compose"
        ToStaffGroups.isHidden = false
        self.composeTextView.isHidden = false
        self.TextHistoryView.isHidden = true
        self.ComposeTextImage.image = UIImage(named: "PurpleRadioSelect")
        self.TextHistoryImage.image = UIImage(named: "RadioNormal")
        self.textviewEnableorDisable()
    }
    
    @IBAction func actionTextMessageHistory(){
        self.fromView = "History"
        ToStaffGroups.isHidden = true
        self.composeTextView.isHidden = true
        self.TextHistoryView.isHidden = false
        self.ComposeTextImage.image = UIImage(named: "RadioNormal")
        self.TextHistoryImage.image = UIImage(named: "PurpleRadioSelect")
        self.callTextHistoryApi()
        
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
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionStandardOrSectionSelection(_ sender: UIButton) {
        dismissKeyboard()
        let StaffVC = self.storyboard?.instantiateViewController(withIdentifier: "StandardOrSectionVCStaff") as! StandardOrSectionVCStaff
        if( self.fromView == "Compose"){
            StaffVC.SendedScreenNameStr = "StaffTextMessage"
            StaffVC.HomeTitleText = TitleText.text!
            StaffVC.HomeTextViewText = TextMessageView.text!
            self.present(StaffVC, animated: false, completion: nil)
        }else{
            if(self.SelectedTextHistoryArray.count > 0){
                let Dict = self.SelectedTextHistoryArray[0] as! NSDictionary
                StaffVC.SendedScreenNameStr = "StaffTextMessage"
                StaffVC.HomeTitleText = String(describing: Dict["Description"]!)
                StaffVC.HomeTextViewText = String(describing: Dict["Content"]!)
                self.present(StaffVC, animated: false, completion: nil)
            }else{
                Util.showAlert("", msg: languageDict["please_select_message"] as? String)
            }
            
        }
    }
    
    @IBAction func actionStandardOrStudentSelection(_ sender: UIButton) {
        dismissKeyboard()
        let StaffStudent = self.storyboard?.instantiateViewController(withIdentifier: "StandardOrStudentsStaff") as! StandardOrStudentsStaff
        
        if( self.fromView == "Compose"){
            StaffStudent.SenderScreenName = "StaffTextMessage"
            StaffStudent.HomeTitleText = TitleText.text!
            StaffStudent.HomeTextViewText = TextMessageView.text!
            self.present(StaffStudent, animated: false, completion: nil)
        }else{
            if(self.SelectedTextHistoryArray.count > 0){
                let Dict = self.SelectedTextHistoryArray[0] as! NSDictionary
                StaffStudent.SenderScreenName = "StaffTextMessage"
                StaffStudent.HomeTitleText = String(describing: Dict["Description"]!)
                StaffStudent.HomeTextViewText = String(describing: Dict["Content"]!)
                self.present(StaffStudent, animated: false, completion: nil)
            }else{
                Util.showAlert("", msg: languageDict["please_select_message"] as? String)
            }
        }
    }
    
    func dismissKeyboard(){
        TextMessageView.resignFirstResponder()
        TitleText.resignFirstResponder()
    }
    
    @objc func catchNotification(notification:Notification) -> Void{
        print("Noti staff")
        dismiss(animated: false, completion: nil)
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
    
    func callTextHistoryApi(){
        showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GetSMSHistory
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GetSMSHistory
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["StaffID" : self.StaffId,
                                          "SchoolId" : self.SchoolId, COUNTRY_CODE: strCountryCode]
        let apiCall = API_call.init()
        print("TEXTSMS",requestString)
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "TextMessageHistoryApi")
    }
    
    //MARK: Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        hideLoading()
        if(csData != nil){
            if((csData?.count)! > 0){
                if((csData?.count)! > 0){
                    self.TextHistoryArray = csData!
                }
                self.TextHistoryTableView.reloadData()
                HistoryButtonAction()
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
            TitleText.textAlignment = .right
            TextMessageView.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            TitleText.textAlignment = .left
            TextMessageView.textAlignment = .left
        }
        ComposeTextLabel.text = LangDict["teacher_txt_composehwmsg"] as? String ?? ""
        SelectFromTextHistoryLabel.text = LangDict["text_compose_history"] as? String ?? ""
        TitleText.placeholder = LangDict["teacher_txt_onwhat"] as? String ?? ""
        strTextViewPlaceholder = LangDict["teacher_txt_typemsg"] as? String ?? "Content?"
        TextMesssageTitle.text = LangDict["teacher_txt_composehwmsg"] as? String ?? ""
        
        if (strCountryName.uppercased() == SELECT_COUNTRY){
            ToStandardSection.setTitle(LangDict["teacher_staff_to_sections_usa"] as? String, for: .normal)
            ToStandardStudent.setTitle(LangDict["teacher_staff_to_students"] as? String, for: .normal)
            
            
        }
        else{
            ToStandardSection.setTitle(LangDict["teacher_staff_to_sections"] as? String, for: .normal)
            ToStandardStudent.setTitle(LangDict["teacher_staff_to_students"] as? String, for: .normal)
            
            
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
    }
    
    func loadViewData(){
        TextMessageView.text = strTextViewPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        ToStandardSection.isUserInteractionEnabled = false
        ToStandardSection.layer.cornerRadius = 5
        ToStandardSection.layer.masksToBounds = true
        ToStandardStudent.isUserInteractionEnabled = false
        ToStandardStudent.layer.cornerRadius = 5
        ToStandardStudent.layer.masksToBounds = true
        
        ToStaffGroups.isUserInteractionEnabled = false
        ToStaffGroups.layer.cornerRadius = 5
        ToStaffGroups.layer.masksToBounds = true
        ToStandardSection.layer.cornerRadius = 5
        ToStandardSection.layer.masksToBounds = true
        ToStandardStudent.layer.cornerRadius = 5
        ToStandardStudent.layer.masksToBounds = true
        disableButtonAction()
        if(TextMessageView.text != strTextViewPlaceholder){
            TextMessageView.textColor = UIColor.black
        }
        textviewEnableorDisable()
        
        let SendTextmessageLength = String(appDelegate.MaxGeneralSMSCountString)
        MaxTextCount = Int(SendTextmessageLength)!
        if(strLanguage == "ar"){
            SendTextMessageLabel.text = SendTextmessageLength +  "/"
        }else{
            SendTextMessageLabel.text = "/" + SendTextmessageLength
        }
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        if(loginAsName == "Principal"){
            let userDefaults = UserDefaults.standard
            StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
            SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
            //
        }else{
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }
        self.actionComposeTextMessage()
    }
}
