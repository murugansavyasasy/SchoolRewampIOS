//
//  FeedbackVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 11/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class FeedbackVC: UIViewController,UIPopoverPresentationControllerDelegate,UITextFieldDelegate {
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var SchoolButton: UIButton!
    @IBOutlet weak var SchoolNameLbl: UILabel!
    @IBOutlet weak var SchoolView: UIView!
    @IBOutlet weak var FlaotEmailLabel: UILabel!
    @IBOutlet weak var FloatMobileNoLabel: UILabel!
    @IBOutlet weak var FloatNameLabel: UILabel!
    @IBOutlet weak var FloatSchoolNameLabel: UILabel!
    @IBOutlet weak var ContactPersonText: UITextField!
    @IBOutlet weak var ContactMobileNoText: UITextField!
    @IBOutlet weak var EmailIDText: UITextField!
    
    var ApiMobileLength = 0
    let UtilObj = UtilClass()
    var selectedSchoolDictionary = NSDictionary()
    var ApiRequestDict = NSMutableDictionary()
    var languageDict = NSDictionary()
    var strLanguage = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(FeedbackVC.UpdateGiftCode), name: NSNotification.Name(rawValue: "DropDownNotification"), object:nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.callSelectedLanguage()
        NextButton.layer.cornerRadius = 5
        NextButton.clipsToBounds = true
        let MobileLenghtStr : String = UserDefaults.standard.object(forKey: MOBILE_LENGTH) as! String
        
        ApiMobileLength = Int(MobileLenghtStr)! + 1
        
        
        SchoolView.layer.borderWidth = 0.3
        SchoolView.layer.cornerRadius = 5
        SchoolView.clipsToBounds = true
        SchoolView.layer.borderColor = UIColor.lightGray.cgColor
        
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - Loading
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if(textField == self.ContactMobileNoText || textField == self.EmailIDText)
        {
            
            self.view.frame.origin.y -= 100
            
            
        }
        else
        {
            self.view.frame.origin.y = 0
        }
        
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
        
        if(textField == ContactMobileNoText)
        {
            
            if(newLength == ApiMobileLength)
            {
                textField.resignFirstResponder()
            }
            return string == numberFiltered
        }
        else
        {
            return true
        }
    }
    @IBAction func actionNext(_ sender: Any) {
        dismissKeyboard()
        
        let ContactNo : String = ContactMobileNoText.text!
        if(SchoolNameLbl.text == "")
        {
            Util.showAlert("", msg: languageDict["select_school"] as? String)
        }else if(ContactPersonText.text == "")
        {
            Util.showAlert("", msg: languageDict["contact_person"] as? String)
        }
        else if(ContactMobileNoText.text == "")
        {
            Util.showAlert("", msg:  languageDict["contact_mobile"] as? String)
        }
        
        else if(ContactNo.count != (ApiMobileLength - 1))
        {
            Util.showAlert("", msg: languageDict["enter_valid_mobile"] as? String)
        }
        else if(EmailIDText.text == "")
        {
            Util.showAlert("", msg: languageDict["contact_mail_id"] as? String)
        }
        else if(!Util .validEmailAddress(EmailIDText.text!)){
            Util.showAlert("", msg: languageDict["valid_email_id"] as? String)
            
        }
        else{
            self.performSegue(withIdentifier: "ShowFeedbackQues", sender: self)
        }
        
        
    }
    func dismissKeyboard()
    {
        ContactPersonText.resignFirstResponder()
        ContactMobileNoText.resignFirstResponder()
        EmailIDText.resignFirstResponder()
        
    }
    
    @IBAction func actionChooseSchoolPopoup(sender : UIButton){
        
        showPopover(sender, Titletext: "")
        
    }
    // MARK: - Popover delegate  & Functions
    func showPopover(_ base: UIView, Titletext: String)
    {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DropDownVC") as? DropDownVC {
            
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .popover
            
            if let pctrl = navController.popoverPresentationController {
                pctrl.delegate = self
                
                pctrl.sourceView = base
                pctrl.sourceRect = base.bounds
                
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    // MARK: - Notificatin center funciton
    
    @objc func UpdateGiftCode(notification:Notification) -> Void
    {
        Constants.printLogKey("Notificaqtion", printValue: notification.object)
        selectedSchoolDictionary = notification.object as! NSDictionary
        SchoolNameLbl.text = String(describing: selectedSchoolDictionary["SchoolName"]!)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let SchoolID: String = String(describing: selectedSchoolDictionary["SchoolID"]!)
        ApiRequestDict = ["SchoolID" : SchoolID,"SchoolName" : SchoolNameLbl.text! , "ContactPerson" : ContactPersonText.text! , "ContactMobile" : ContactMobileNoText.text! , "EmailID" : EmailIDText.text!]
        UtilObj.printLogKey(printKey: "SelectedDict", printingValue: selectedSchoolDictionary)
        if (segue.identifier == "ShowFeedbackQues"){
            let segueid = segue.destination as! FeedbackQuesVC
            segueid.RequestDict = ApiRequestDict
        }
    }
    func navTitle(){
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        // titleLabel.textColor = UIColor (red:243.0/255.0, green: 191.0/255.0, blue: 145.0/255.0, alpha: 1)
        titleLabel.textColor = UIColor (red:166.0/255.0, green: 114.0/255.0, blue: 155.0/255.0, alpha: 1)
        let secondWord : String =  languageDict["feedback"] as? String ?? "Feedback"//"Feedback "
        let thirdWord : String  =  languageDict["to_voicesnap"] as? String ?? "to voicesnap"//"to voicesnap"
        let comboWord = secondWord + " " + thirdWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: secondWord)
        attributedText.addAttributes(attrs, range: range)
        titleLabel.attributedText = attributedText
        if(strLanguage == "ar"){
            titleLabel.textAlignment = .right
        }else{
            titleLabel.textAlignment = .left
        }
        self.navigationItem.titleView = titleLabel
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
            FloatNameLabel.textAlignment = .right
            FloatSchoolNameLabel.textAlignment = .right
            FloatMobileNoLabel.textAlignment = .right
            FlaotEmailLabel.textAlignment = .right
            ContactPersonText.textAlignment = .right
            ContactMobileNoText.textAlignment = .right
            EmailIDText.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            FloatNameLabel.textAlignment = .left
            FloatSchoolNameLabel.textAlignment = .left
            FloatMobileNoLabel.textAlignment = .left
            FlaotEmailLabel.textAlignment = .left
            ContactPersonText.textAlignment = .left
            ContactMobileNoText.textAlignment = .left
            EmailIDText.textAlignment = .left
        }
        FloatNameLabel.text = LangDict["yourname"] as? String
        FloatSchoolNameLabel.text = LangDict["schoolname"] as? String
        FloatMobileNoLabel.text = LangDict["alternate_mobile_number"] as? String
        FlaotEmailLabel.text = LangDict["email_id"] as? String
        NextButton.setTitle(LangDict["btn_next"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        navTitle()
    }
}
