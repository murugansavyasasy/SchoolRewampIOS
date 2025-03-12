//
//  ParentChangePasswordVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MacMini2 on 04/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class ParentChangePasswordVC: UIViewController ,UITextFieldDelegate,UITextViewDelegate,Apidelegate{
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var ExistingPasswordText: UITextField!
    @IBOutlet weak var NewPasswordText: UITextField!
    @IBOutlet weak var VerifyNewPasswordText: UITextField!
    @IBOutlet weak var ShowExistingPswdButton: UIButton!
    @IBOutlet weak var ShowVerifyPswdButton: UIButton!
    @IBOutlet weak var ShowNewPswdButton: UIButton!
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var FloatExistingLabel: UILabel!
    @IBOutlet weak var FloatNewLabel: UILabel!
    @IBOutlet weak var FloatVerifyLabel: UILabel!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var UpdateButton: UIButton!
    
    let UtilObj = UtilClass()
    var hud : MBProgressHUD = MBProgressHUD()
    var UserMobileNo = String()
    var UserPassword = String()
    var strFrom = String()
    var strFromStaff = String()
    var LanguageDict = NSDictionary()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.layer.cornerRadius = 8
        mainView.clipsToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        UserMobileNo = UserDefaults.standard.object(forKey: USERNAME) as! String
        UserPassword =  UserDefaults.standard.object(forKey:USERPASSWORD) as? String ?? ""
        print("USERPASS \(UserPassword)")
        if(strFrom == "Logout"){
            self.title = "Logout"
            self.view.backgroundColor = UIColor.white
            mainView.isHidden = true
            self.showLogoutAlert()
        }else{
            mainView.isHidden = false
        }
    }
    
    //MARK: TEXTFIELD DELEGATE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.view.frame.origin.y = 0
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if(textField == self.VerifyNewPasswordText)
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
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        if(newLength == 21)
        {
            textField.resignFirstResponder()
        }
        // return string == numberFiltered
        return true
    }
    
    func DismissKEY()
    {
        NewPasswordText.resignFirstResponder()
        ExistingPasswordText.resignFirstResponder()
        VerifyNewPasswordText.resignFirstResponder()
    }
    
    // MARK: - Button Action
    
    @IBAction func actionUpdateChangePassword(_ sender: Any) {
        
        DismissKEY()
        if(ExistingPasswordText.text?.count == 0){
            Util.showAlert("",msg: ENTER_VALID_PASSWORD)
        }
        else if(NewPasswordText.text?.count == 0){
            Util.showAlert("",msg: ENTER_VALID_PASSWORD)
        }else if(VerifyNewPasswordText.text?.count == 0){
            Util.showAlert("",msg: ENTER_VALID_PASSWORD)
        }
        else if(ExistingPasswordText.text?.isEqual(UserPassword))!
        {
            if(NewPasswordText.text?.isEqual(VerifyNewPasswordText.text))!
            {
                
                if(Util .isNetworkConnected())
                {
                    if(self.strFromStaff == "Staff"){
                        self.CallStaffChangePasswordApi()
                    }else{
                        self.CallChangePasswordApi()
                    }
                }
                else
                {
                    Util .showAlert("", msg: strNoInternet)
                }
            }
            else
            {
                Util.showAlert("", msg: LanguageDict["password_missmatch"] as? String)
            }
        }
        else
        {
            Util.showAlert("", msg: LanguageDict["teacher_pop_password_hint_exist"] as? String)
        }
    }
    
    @IBAction func actionExistingPassword(_ sender: Any) {
        if(ExistingPasswordText.isSecureTextEntry == false)
        {
            ExistingPasswordText.isSecureTextEntry = true
            ShowExistingPswdButton.isSelected = false
        }
        else
        {
            ExistingPasswordText.isSecureTextEntry = false
            ShowExistingPswdButton.isSelected = true
        }
    }
    
    @IBAction func actionShowNewPassword(_ sender: Any) {
        
        if(NewPasswordText.isSecureTextEntry == false)
        {
            NewPasswordText.isSecureTextEntry = true
            ShowNewPswdButton.isSelected = false
        }
        else
        {
            NewPasswordText.isSecureTextEntry = false
            ShowNewPswdButton.isSelected = true
        }
    }
    
    @IBAction func actionShowVerifyPassword(_ sender: Any) {
        if(VerifyNewPasswordText.isSecureTextEntry == false)
        {
            VerifyNewPasswordText.isSecureTextEntry = true
            ShowVerifyPswdButton.isSelected = false
        }
        else
        {
            VerifyNewPasswordText.isSecureTextEntry = false
            ShowVerifyPswdButton.isSelected = true
        }
    }
    
    @IBAction func actionClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        // self.navigationController?.popViewController(animated: true)
    }
    
    func showLogoutAlert(){
        let alertController = UIAlertController(title: LanguageDict["txt_menu_logout"] as? String, message: LanguageDict["want_to_logut"] as? String, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: LanguageDict["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.logoutAction()
        }
        let cancelAction = UIAlertAction(title: LanguageDict["teacher_cancel"] as? String, style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            self.actionClose(self)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func logoutAction(){
        Childrens.deleteTables()
        UserDefaults.standard.set("Yes" as NSString, forKey: LOGOUT)
        if(self.strFromStaff == "Staff"){
            UserDefaults.standard.set("Yes" as NSString, forKey: FIRSTTIMELOGINAS)
        }
        UserDefaults.standard.removeObject(forKey: DefaultsKeys.getgroupHeadRole)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "BackToLoginSegue", sender: self)
        }
    }
    
    // MARK: - Api Calling
    
    func CallChangePasswordApi()
    {
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + CHANGEPASSWROD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["NewPassword": NewPasswordText.text! ,"OldPassword" : ExistingPasswordText.text!,"MobileNumber" : UserMobileNo, COUNTRY_CODE: strCountryCode]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "myString", printingValue: myString!)
        apiCall.nsurlConnectionFunction(requestString, myString, "ChangePassword")
    }
    
    
    func CallStaffChangePasswordApi()
    {
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + CHANGEPSWD_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNo, "NewPassword": NewPasswordText.text!,"OldPassword" : ExistingPasswordText.text!, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ChangePassword")
    }
    
    //MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        if(csData != nil || csData?.count == 0)
        {
            var dicResponse: NSDictionary = [:]
            guard let responseArray = csData else {
                return
            }
            for var i in 0..<responseArray.count
            {
                dicResponse = responseArray[i] as! NSDictionary
                
                let myalertstatus = String(describing: dicResponse["Status"]!)
                if(myalertstatus == "1"){
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    Util.showAlert("", msg: myalertstring)
                    UserDefaults.standard.set("Yes" as NSString, forKey: LOGOUT)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "BackToLoginSegue", sender: self)
                    }
                }else{
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    Util.showAlert("", msg: myalertstring)
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
        //print("Error")
        Util.showAlert("", msg: strSomething)
        
    }
    // MARK: - Loading
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
            TitleLabel.textAlignment = .right
            FloatNewLabel.textAlignment = .right
            FloatVerifyLabel.textAlignment = .right
            FloatExistingLabel.textAlignment = .right
            ExistingPasswordText.textAlignment = .right
            NewPasswordText.textAlignment = .right
            VerifyNewPasswordText.textAlignment = .right
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            TitleLabel.textAlignment = .left
            FloatNewLabel.textAlignment = .left
            FloatVerifyLabel.textAlignment = .left
            FloatExistingLabel.textAlignment = .left
            ExistingPasswordText.textAlignment = .left
            NewPasswordText.textAlignment = .left
            VerifyNewPasswordText.textAlignment = .left
        }
        
        TitleLabel.text = LangDict["pop_password_title"] as? String
        FloatExistingLabel.text = LangDict["pop_password_txt_exist"] as? String
        FloatVerifyLabel.text = LangDict["pop_password_txt_repeat"] as? String
        FloatNewLabel.text = LangDict["pop_password_txt_new"] as? String
        CancelButton.setTitle(LangDict["pop_password_btnCancel"] as? String, for: .normal)
        UpdateButton.setTitle(LangDict["pop_password_btnUpdate"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
}
