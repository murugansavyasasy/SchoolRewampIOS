//
//  ExamTestVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 12/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit


class ExamTestVC: UIViewController,UITextViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var TextMessageView: UITextView!
    @IBOutlet weak var SendTextMessageLabel: UILabel!
    @IBOutlet weak var ToSelectStandardSectionButton: UIButton!
    @IBOutlet weak var ToSelectSectionStudentButton: UIButton!
    @IBOutlet weak var remainingCharactersLabel: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var ExamTestTitle: UITextField!
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let UtilObj = UtilClass()
    var loginAsName = String()
    var SchoolId = String()
    var StaffId = String()
    var MaxTextCount = Int()
    var strTextViewPlaceholder = String()
    var languageDict = NSDictionary()
    var strCountryCode = String()
    var strCountryName = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var strLanguage = String()
    
    var name : String?
    var checkSchoolId : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(ExamTestVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
        
        if name != nil {
            print (name)
        }else{
            print("namae has nil value")
        }
        
        strCountryName = UserDefaults.standard.object(forKey: COUNTRY_Name) as? String ?? ""
        print(strCountryName)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        callSelectedLanguage()
        
        ToSelectStandardSectionButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        ToSelectSectionStudentButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        ToSelectStandardSectionButton.isUserInteractionEnabled = false
        ToSelectStandardSectionButton.layer.cornerRadius = 5
        ToSelectStandardSectionButton.layer.masksToBounds = true
        ToSelectSectionStudentButton.isUserInteractionEnabled = false
        ToSelectSectionStudentButton.layer.cornerRadius = 5
        ToSelectSectionStudentButton.layer.masksToBounds = true
        
        
        let SendTextmessageLength = String(appDelegate.MaxGeneralSMSCountString)
        MaxTextCount = Int(SendTextmessageLength)!
        if(strLanguage == "ar"){
            SendTextMessageLabel.text =  SendTextmessageLength  + "/"
        }else{
            SendTextMessageLabel.text = "/" + SendTextmessageLength
        }
        
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        if(loginAsName == "Principal")
        {
            
            
            if checkSchoolId == "1" {
                SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
                StaffId = String(describing: SchoolDetailDict["StaffID"]!)
            }else{
                let userDefaults = UserDefaults.standard
                StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
                SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
            }
        }else{
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }
        
    }
    
    //MARK: TEXTFIELD DELEGATE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // validateAllFields()
        if range.location == 0 && string == " " {
            return false
        }
        return true
        
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
        
        setupTextViewAccessoryView()
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
    func textViewDidChange(_ textView: UITextView)
    {
        self.validateAllFields()
        
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
    }
    
    //MARK: BUTTON ACTION
    @IBAction func actionCloseView(_ sender: UIButton) {
        
        dismiss(animated: false, completion: nil)
    }    
    
    @IBAction func actionStandardOrSectionSelection(_ sender: UIButton) {
        dismissKeyboard()
        
        if((ExamTestTitle.text?.count)! > 0)
        {
            
            let ExamDict : NSMutableDictionary = [
                "SchoolID" : SchoolId,
                "StaffID" : StaffId,
                "ExamName" : ExamTestTitle.text!,
                "ExamSyllabus" : TextMessageView.text!]
            
            
            
            let StaffVC = self.storyboard?.instantiateViewController(withIdentifier: "PrincipleStandardSectionVC") as! PrincipleStandardSectionVC
            
            StaffVC.SendedScreenNameStr = "StaffTextMessage"
            StaffVC.StaffId = StaffId
            StaffVC.SchoolId = SchoolId
            StaffVC.ExamTestApiDict = ExamDict
            
            self.present(StaffVC, animated: false, completion: nil)
            
            
            
            
        }else{
            Util.showAlert("", msg: languageDict["exam_title_alert"] as? String)
        }
    }
    @IBAction func actionSectionOrStudentSelection(_ sender: UIButton) {
        dismissKeyboard()
        if((ExamTestTitle.text?.count)! > 0)
        {
            
            let ExamDict : NSMutableDictionary = [
                "SchoolID" : SchoolId,
                "StaffID" : StaffId,
                "ExamName" : ExamTestTitle.text!,
                "ExamSyllabus" : TextMessageView.text!]
            let StudentVC = self.storyboard?.instantiateViewController(withIdentifier: "PrincipalStandardOrStudentVC") as! PrincipalStandardOrStudentVC
            StudentVC.ExamTestApiDict = ExamDict
            StudentVC.SchoolId = SchoolId
            StudentVC.StaffId = StaffId
            self.present(StudentVC, animated: false, completion: nil)
        }else{
            Util.showAlert("", msg: languageDict["exam_title_alert"] as? String)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "SendTextMessageSegue")
        {
            let segueid = segue.destination as! SendTextMessageVC
            segueid.SegueText = TextMessageView.text
            
        }
    }
    func dismissKeyboard()
    {
        
        TextMessageView.resignFirstResponder()
        ExamTestTitle.resignFirstResponder()
    }
    
    @objc func catchNotification(notification:Notification) -> Void
    {
        dismiss(animated: false, completion: nil)
        
    }
    func validateAllFields()
    {
        if(TextMessageView.text.count > 0 && (ExamTestTitle.text?.count)! > 0 && TextMessageView.text != strTextViewPlaceholder)
        {
            ToSelectStandardSectionButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            ToSelectStandardSectionButton.isUserInteractionEnabled = true
            ToSelectSectionStudentButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            ToSelectSectionStudentButton.isUserInteractionEnabled = true
        }
        else
        {
            ToSelectStandardSectionButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            ToSelectStandardSectionButton.isUserInteractionEnabled = false
            ToSelectSectionStudentButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            ToSelectSectionStudentButton.isUserInteractionEnabled = false
        }
        
    }
    
    @IBAction func actionValueChanged(_ sender: UITextField) {
        validateAllFields()
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
            ExamTestTitle.textAlignment = .right
            TextMessageView.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            ExamTestTitle.textAlignment = .left
            TextMessageView.textAlignment = .left
        }
        TitleLabel.text = LangDict["teacher_txt_composeExammsg"] as? String
        ExamTestTitle.placeholder = LangDict["teacher_txt_exam_title"] as? String
        strTextViewPlaceholder = LangDict["teacher_txt_typemsg"] as? String ?? "Exam Syllabus"
        
        if (strCountryName.uppercased() == SELECT_COUNTRY){
            self.ToSelectStandardSectionButton.setTitle( LangDict["teacher_staff_to_sections_usa"] as? String, for: .normal)
            self.ToSelectSectionStudentButton.setTitle( LangDict["teacher_staff_to_students"] as? String, for: .normal)
        }
        
        else{
            self.ToSelectStandardSectionButton.setTitle( LangDict["teacher_staff_to_sections"] as? String, for: .normal)
            self.ToSelectSectionStudentButton.setTitle( LangDict["teacher_staff_to_students"] as? String, for: .normal)
        }
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    func loadViewData(){
        TextMessageView.text = strTextViewPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        if(TextMessageView.text != strTextViewPlaceholder)
        {
            TextMessageView.textColor = UIColor.black
        }
        validateAllFields()
    }
    
}
