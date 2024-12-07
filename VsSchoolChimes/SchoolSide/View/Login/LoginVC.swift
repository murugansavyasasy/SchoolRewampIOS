//
//  LoginVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 03/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit
import Crashlytics

class LoginVC: UIViewController,UITextFieldDelegate,Apidelegate,HTTPClientDelegate,UITableViewDelegate,UITableViewDataSource
{
    
    
    @IBOutlet weak var LoginAsTableview: UITableView!
    @IBOutlet weak var callPopupTableview: UITableView!
    
    @IBOutlet weak var ChooseLoginAsPopupView: UIView!
    
    @IBOutlet weak var OtpMessageLabel: UILabel!
    @IBOutlet var ForgotPopupView: UIView!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var UserMobileNoText: UITextField!
    @IBOutlet weak var ShowPassword: UIButton!
    @IBOutlet weak var UserPasswordText: UITextField!
    
    @IBOutlet weak var ShowExistingPswdButton: UIButton!
    @IBOutlet weak var ShowNewPswdButton: UIButton!
    @IBOutlet weak var VerifyNewPasswordText: UITextField!
    @IBOutlet weak var ShowVerifyPswdButton: UIButton!
    @IBOutlet weak var ExistingPasswordText: UITextField!
    @IBOutlet weak var NewPasswordText: UITextField!
    @IBOutlet var PopupChangePassword: UIView!
    
    @IBOutlet weak var EnterOTPLabel: UILabel!
    @IBOutlet weak var TitleChangePswdLabel: UILabel!
    @IBOutlet weak var NewPasswordLabel: UILabel!
    @IBOutlet weak var VerifyPasswordLabel: UILabel!
    @IBOutlet weak var UpdateButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    @IBOutlet weak var ForgotPasswordOkButton: UIButton!
    @IBOutlet weak var TitleForgotPswdLabel: UILabel!
    @IBOutlet weak var ForgotPasswordButton: UIButton!
    @IBOutlet weak var PasswordView: UIView!
    @IBOutlet weak var MobileView: UIView!
    @IBOutlet weak var FloatMobileLabel: UILabel!
    @IBOutlet var callPopupView: UIView!
    
    @IBOutlet weak var callClickHereButton: UIButton!
    @IBOutlet weak var callMobileNo2Label: UILabel!
    @IBOutlet weak var callMobileNo1Label: UILabel!
    @IBOutlet weak var callPopupTitleLabel: UILabel!
    
    @IBOutlet weak var SignInTitleLabel: UILabel!
    @IBOutlet weak var goToSigninView: UIView!
    var userName = String()
    var userPassword = String()
    var strAlertString = String()
    var arrUserData: NSArray = []
    var arrSchoolData: NSArray = []
    var arrayChooseLogin:Array = [String]()
    var popupLoginSelection : KLCPopup  = KLCPopup()
    var KlCpopupCall : KLCPopup  = KLCPopup()
    var ApiMobileLength = 0
    var arrayForgetDatas: NSArray = []
    var arrayForgetChangeDatas: NSArray = []
    var dicForget: NSDictionary = [:]
    var dicResponse: NSDictionary = [:]
    var popupForgetPassword : KLCPopup  = KLCPopup()
    var popupChangeForgetPassword : KLCPopup  = KLCPopup()
    var ParentDictDetail : NSDictionary = NSDictionary()
    var forgotPasswordResponseDict : NSDictionary = NSDictionary()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var strApiFrom = NSString()
    let UtilObj = UtilClass()
    var strCountryCode = String()
    var strCountryID = String()
    var languageDict = NSDictionary()
    var loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as? String
    
    var SelectedLoginAsIndexInt = 0
    var ParentSelectedLoginIndex = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var strOtpNote = String()
    var mobileArray = NSArray()
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        let MobileLenghtStr : String = UserDefaults.standard.object(forKey: MOBILE_LENGTH) as! String
        
        ApiMobileLength = Int(MobileLenghtStr)! + 1
        
        
        UserMobileNoText.placeholder = "Enter " + MobileLenghtStr + " Digit Mobile Number"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        LoginButton.layer.cornerRadius = 5
        LoginButton.layer.masksToBounds = true
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        ButtonCornerDesign()
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        strCountryID = UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        
        UserDefaults.standard.set("Yes" as NSString, forKey: LOGOUT)
        UserDefaults.standard.set("No" as NSString, forKey: FIRSTTIMELOGINAS)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        UserMobileNoText.keyboardType = UIKeyboardType.numbersAndPunctuation
        UserPasswordText.keyboardType = UIKeyboardType.numbersAndPunctuation
        ExistingPasswordText.keyboardType = UIKeyboardType.numbersAndPunctuation
        NewPasswordText.keyboardType = UIKeyboardType.numbersAndPunctuation
        VerifyNewPasswordText.keyboardType = UIKeyboardType.numbersAndPunctuation
        self.callSelectedLanguage()
        
    }
    
    @objc func dismissKeyboard()
    {
        UserMobileNoText.resignFirstResponder()
        UserPasswordText.resignFirstResponder()
        // view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if(textField == self.UserPasswordText)
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
        
        if(textField == UserMobileNoText)
        {
            
            if(newLength == ApiMobileLength)
            {
                textField.resignFirstResponder()
            }
            return string == numberFiltered
        }
        else
        {
            if(newLength == 21)
            {
                textField.resignFirstResponder()
            }
            return true
            
        }
        
        
        
    }
    
    //MARK:BUTTON ACTION
    @IBAction func actionLogin(_ sender: Any)
    {
        
        dismissKeyboard()
        userName = UserMobileNoText.text!
        userPassword = UserPasswordText.text!
        if UserMobileNoText.text == ""
        {
            Util .showAlert("", msg: languageDict["hint_mobile"] as? String)
        }else if(userName.count < ApiMobileLength - 1)
        {
            Util.showAlert("", msg: languageDict["enter_valid_mobile"] as? String)
            
        }
        else if UserPasswordText.text == ""
        {
            Util .showAlert("", msg: languageDict["hint_password"] as? String)
        }
        else
        {
            if(Util .isNetworkConnected()){
                self.CheckMobileNoINDBApiCalling()
                
            }
            else
            {
                Util .showAlert("", msg: strNoInternet)
            }
        }
    }
    
    @IBAction func actionShowPassword(_ sender: Any)
    {
        if(UserPasswordText.isSecureTextEntry == false)
        {
            UserPasswordText.isSecureTextEntry = true
            ShowPassword.isSelected = false
        }else{
            UserPasswordText.isSecureTextEntry = false
            ShowPassword.isSelected = true
        }
    }
    
    @IBAction func actionShowExistingPassword(_ sender: Any) {
        if(ExistingPasswordText.isSecureTextEntry == false)
        {
            ExistingPasswordText.isSecureTextEntry = true
            ShowExistingPswdButton.isSelected = false
        }else{
            ExistingPasswordText.isSecureTextEntry = false
            ShowExistingPswdButton.isSelected = true
        }
    }
    
    @IBAction func actionShowNewPassword(_ sender: Any)
    {
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
    
    
    @IBAction func actionShowVerifyNewPassword(_ sender: Any) {
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
    
    
    
    @IBAction func actionCancelUpdatePassword(_ sender: Any)
    {    DissmissKEY()
        self.clearChangePassword()
        popupChangeForgetPassword.dismiss(true)
    }
    func DissmissKEY()
    {
        NewPasswordText.resignFirstResponder()
        ExistingPasswordText.resignFirstResponder()
        VerifyNewPasswordText.resignFirstResponder()
    }
    
    @IBAction func actionUpdateChangePassword(_ sender: Any)
    {
        DissmissKEY()
        if((ExistingPasswordText.text?.count)! > 0){
            if((NewPasswordText.text?.count)! > 0 && (VerifyNewPasswordText.text?.count)! > 0)
            {
                
                if(NewPasswordText.text?.isEqual(VerifyNewPasswordText.text))!
                {
                    
                    if(Util .isNetworkConnected())
                    {
                        // self.CallChangePasswordApi()
                        self.CallChangeForgotPasswordApi()
                    }
                    else
                    {
                        Util .showAlert("", msg: strNoInternet)
                    }
                    
                    
                }
                
                else
                {
                    Util.showAlert("", msg: languageDict["password_missmatch"] as? String)
                }
            }else
            {
                Util.showAlert("", msg: languageDict["hint_password"] as? String)
            }
        }else{
            
            Util.showAlert("", msg: languageDict["enter_your_otp"] as? String)
            
        }
        
    }
    
    
    @IBAction func actionForgotPassword(_ sender: Any)
    {
        dismissKeyboard()
        if(UserMobileNoText.text?.count == ApiMobileLength - 1)
        {
            if(Util .isNetworkConnected())
            {
                self.CallForgotPasswordApi()
            }
            else
            {
                Util .showAlert("", msg: strNoInternet)
            }
        }
        else
        {
            Util.showAlert("", msg: languageDict["registered_mobile"] as? String);
        }
    }
    
    @IBAction func closeForgotPasswordOkButton(_ sender: Any)
    {
        popupForgetPassword.dismiss(true)
        self.ChangePasswordPopup(sender: self)
    }
    
    func CallPopup(sender : Any) {
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            callPopupView.frame.size.height = 460
            callPopupView.frame.size.width = 400
        }
        //
        //        G3
        
        callPopupView.center = view.center
        callPopupView.alpha = 1
        callPopupView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(callPopupView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.callPopupView.transform = .identity
        })
        
        
        print("LoginccccVc")
        
        let attributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributedText = NSAttributedString(string: forgotPasswordResponseDict["MoreInfo"] as? String ?? "" , attributes: attributes)
        
        self.callClickHereButton.setAttributedTitle(attributedText, for: .normal)
        
        let mobileStr : String = forgotPasswordResponseDict["DialNumbers"] as? String ?? ""
        self.mobileArray = mobileStr.components(separatedBy: ",") as NSArray
        self.callPopupTitleLabel.text = forgotPasswordResponseDict["Message"] as? String
        self.callPopupTableview.reloadData()
        
        
        
        
    }
    
    @IBAction func actionMobileNo1(_ sender: Any) {
        if let url = NSURL(string: "tel://" + self.callMobileNo1Label.text!) {
            UIApplication.shared.openURL(url as URL)
        }
        exit(0);
    }
    
    @IBAction func actionMobileNo2(_ sender: Any) {
        if let url = NSURL(string: "tel://" + self.callMobileNo2Label.text!) {
            UIApplication.shared.openURL(url as URL)
        }
        exit(0);
    }
    
    @IBAction func actionClickHere(_ sender: Any) {
        KlCpopupCall.dismiss(true)
        if((UserDefaults.standard.object(forKey: FORGOT_PASSWORD_DICT)) != nil){
            let attributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            let attributedText = NSAttributedString(string: UserDefaults.standard.object(forKey: FORGOT_PASSWORD_DICT) as! String , attributes: attributes)
            SignInTitleLabel.attributedText = attributedText
        }else{
            SignInTitleLabel.text = ""
        }
        
        ChangePasswordPopup(sender: self)
        
    }
    
    @IBAction func actionGoToSign(_ sender: Any) {
        popupChangeForgetPassword.dismiss(true)
        
    }
    
    @IBAction func actionCloseCallPopup(_ sender: Any) {
        callPopupView.alpha = 0
    }
    
    //MARK:FUNCTIONS
    func ChangePasswordPopup(sender : Any)
    {
        
        print("CHANGEPOPUPWORKING")
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChangePassword.frame.size.height = 540
            
            PopupChangePassword.frame.size.width = 500
            
            
        }
        
        popupChangeForgetPassword = KLCPopup(contentView: PopupChangePassword, showType: KLCPopupShowType.none , dismissType:KLCPopupDismissType.none,maskType: KLCPopupMaskType.dimmed , dismissOnBackgroundTouch:  false , dismissOnContentTouch: false )
        popupChangeForgetPassword.show()
        self.clearChangePassword()
        
        
        
    }
    
    func clearChangePassword()
    {
        ExistingPasswordText.text = ""
        NewPasswordText.text = ""
        VerifyNewPasswordText.text = ""
        ExistingPasswordText.isSecureTextEntry = true
        ShowExistingPswdButton.isSelected = false
        VerifyNewPasswordText.isSecureTextEntry = true
        ShowVerifyPswdButton.isSelected = false
        NewPasswordText.isSecureTextEntry = true
        ShowNewPswdButton.isSelected = false
        
    }
    func ButtonCornerDesign()
    {
        MobileView.layer.cornerRadius = 5
        MobileView.layer.masksToBounds =  true
        PasswordView.layer.cornerRadius = 5
        PasswordView.layer.masksToBounds = true
        FloatMobileLabel.layer.cornerRadius = 2
        FloatMobileLabel.layer.masksToBounds = true
        MobileView.layer.borderColor = UtilObj.ORANGE_COLOR.cgColor
        FloatMobileLabel.backgroundColor = UtilObj.ORANGE_COLOR
        MobileView.layer.borderWidth = 1
        PasswordView.layer.borderColor = UIColor.lightGray.cgColor
        PasswordView.layer.borderWidth = 1
        PopupChangePassword.layer.cornerRadius = 8
        PopupChangePassword.layer.masksToBounds = true
        ForgotPopupView.layer.cornerRadius = 8
        ForgotPopupView.layer.masksToBounds = true
        ChooseLoginAsPopupView.layer.cornerRadius = 8
        ChooseLoginAsPopupView.layer.masksToBounds = true
        callPopupView.layer.cornerRadius = 8
        callPopupView.layer.masksToBounds = true
    }
    
    //MARK: API REQUEST DELEGATE
    
    func CheckMobileNoINDBApiCalling() {
        showLoading()
        
        strApiFrom = "otp"
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let strUDID : String = Util.str_deviceid()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + CHECK_MOBILENO_UPDATE_BY_COUNTRYID
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNoText.text!,COUNTRY_ID : strCountryID,"Password":UserPasswordText.text!,"DeviceType":DEVICE_TYPE,"SecureID":strUDID]
        print(myDict)
        
        let myString = Util.convertDictionary(toString: myDict)
        print("loginmyString",myString)
        apiCall.nsurlConnectionFunction(requestString, myString, "otp")
    }
    
    func CallLoginApi()
    {
        showLoading()
        strApiFrom = "login"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + LOGIN_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let strUDID : String = Util.str_deviceid()
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNoText.text!,"Password" : UserPasswordText.text!,"DeviceType" : DEVICE_TYPE,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
        print(myDict)
        print("CallLoginApi12")
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "login")
    }
    
    func CallForgotPasswordApi()
    {
        showLoading()
        strApiFrom = "ForgotPassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + FORGOTPSWD_METHOD_BY_COUNTRYID
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNoText.text!,COUNTRY_CODE : strCountryCode,COUNTRY_ID : strCountryID]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ForgotPassword")
    }
    
    func CallChangePasswordApi()
    {
        showLoading()
        strApiFrom = "ChangePassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + CHANGEPSWD_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNoText.text!, "NewPassword": NewPasswordText.text!,"OldPassword" : ExistingPasswordText.text!,COUNTRY_CODE : strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ChangePassword")
    }
    
    func CallChangeForgotPasswordApi() {
        showLoading()
        strApiFrom = "ChangePassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + RESET_FORGOT_PASSWORD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNoText.text!, "NewPassword": NewPasswordText.text!,"OTP" : ExistingPasswordText.text! ,COUNTRY_CODE : strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ChangePassword")
    }
    
    
    func CallManageParentApi()
    {
        
        
        showLoading()
        strApiFrom = "Parentlogin"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + PARENT_LOGIN_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let strUDID : String = Util.str_deviceid()
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNoText.text!,"Password" : UserPasswordText.text!,"DeviceType" : DEVICE_TYPE,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
        print(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "Parentlogin")
    }
    func CallParentDeviceTokenApi()
    {
        showLoading()
        strApiFrom = "deviceToken"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + DEVICETOKEN
        
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        var deviceToken = UserDefaults.standard.object(forKey:DEVICETOKEN) as! String
        if(deviceToken.count == 0){
            
            deviceToken = "1234"
        }
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNoText.text!,"DeviceToken": deviceToken,"DeviceType": DEVICE_TYPE,COUNTRY_CODE : strCountryCode]
        Constants.printLogKey("Device myDict", printValue: myDict)
        
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "deviceToken")
    }
    
    func CallPaymentInfoApi()
    {
        showLoading()
        strApiFrom = "deviceToken"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + GET_PAYMENT_URL
        
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["ChildID" : UserMobileNoText.text!,"SchoolID": ""]
        Constants.printLogKey("Device myDict", printValue: myDict)
        
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "deviceToken")
    }
    
    func CallValidatePasswordApi() {
        showLoading()
        strApiFrom = "ValidatePassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + VALIDATE_PASSWORD_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" :UserMobileNoText.text!, "Password": UserPasswordText.text!]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ValidatePassword")
    }
    
    //MARK: API RESPONSE DELEGATE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        hideLoading()
        print(csData)
        if(csData != nil){
            var Message = String()
            var Status = String()
            
            if(strApiFrom.isEqual(to: "login")){
                if((csData?.count)! > 0){
                    if (csData == nil){
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "LoginVC", sender: self)
                        }
                    }else{
                        if((csData?.count)! > 0){
                            let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                            Status = String(describing: dicUser["Status"]!)
                            Message = String(describing: dicUser["Message"]!)
                            strAlertString = Message
                            if(Status == "1"){
                                ParentDictDetail = dicUser
                                UserDefaults.standard.set(UserMobileNoText.text! as NSString, forKey: USERNAME)
                                
                                UserDefaults.standard.set(UserPasswordText.text! as NSString, forKey: USERPASSWORD)
                                
                                appDelegate.MaxGeneralSMSCountString =
                                String(describing: dicUser["MaxGeneralSMSCount"]!)
                                
                                appDelegate.MaxHomeWorkSMSCountString =
                                String(describing: dicUser["MaxHomeWorkSMSCount"]!)
                                
                                appDelegate.MaxEmergencyVoiceDurationString =
                                String(describing: dicUser["MaxEmergencyVoiceDuration"]!)
                                
                                appDelegate.MaxGeneralVoiceDuartionString =
                                String(describing: dicUser["MaxGeneralVoiceDuartion"]!)
                                
                                appDelegate.MaxHWVoiceDurationString =
                                String(describing: dicUser["MaxHWVoiceDuration"]!)
                                
                                
                                self.CallParentDeviceTokenApi()
                                
                                appDelegate.staffRole = String(describing: dicUser["staff_role"]!)
                                let defaults = UserDefaults.standard
                                defaults.set(appDelegate.staffRole, forKey: DefaultsKeys.StaffRole)
                                
                                
                                appDelegate.staffDisplayRole = String(describing: dicUser["staff_display_role"]!)
                                appDelegate.isParent = String(describing: dicUser["is_parent"]!)
                                appDelegate.isStaff = String(describing: dicUser["is_staff"]!)
                                UserDefaults.standard.set(String(describing: dicUser[IMAGE_COUNT]!), forKey: IMAGE_COUNT)
                                if(appDelegate.isStaff == "0"){
                                    UserDefaults.standard.set("Parent", forKey: LOGINASNAME)
                                    UserDefaults.standard.set("No", forKey: COMBINATION)
                                    
                                    self.LoadParentDetail()
                                }else{
                                    if (appDelegate.staffRole == "p1" && appDelegate.isParent == "1"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("GroupHead", forKey: LOGINASNAME)
                                        self.ParentSelectedLoginIndex = 0
                                        UserDefaults.standard.set("Yes", forKey: COMBINATION)
                                        self.LoadParentDetail()
                                    }
                                    else if (appDelegate.staffRole == "p2" && appDelegate.isParent == "1"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("Principal", forKey: LOGINASNAME)
                                        self.ParentSelectedLoginIndex = 1
                                        UserDefaults.standard.set("Yes", forKey: COMBINATION)
                                        self.LoadParentDetail()
                                    }
                                    else if (appDelegate.staffRole == "p3" && appDelegate.isParent == "1"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("Staff", forKey: LOGINASNAME)
                                        self.ParentSelectedLoginIndex = 2
                                        UserDefaults.standard.set("Yes", forKey: COMBINATION)
                                        self.LoadParentDetail()
                                    }
                                    else if (appDelegate.staffRole == "p4" && appDelegate.isParent == "1"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("OfficeStaff", forKey: LOGINASNAME)
                                        self.ParentSelectedLoginIndex = 3
                                        UserDefaults.standard.set("Yes", forKey: COMBINATION)
                                        self.LoadParentDetail()
                                        // self.updateDeviceToken()
                                    }
                                    else if (appDelegate.staffRole == "p5" && appDelegate.isParent == "1"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("NonOfficeStaff", forKey: LOGINASNAME)
                                        self.ParentSelectedLoginIndex = 4
                                        UserDefaults.standard.set("Yes", forKey: COMBINATION)
                                        self.LoadParentDetail()
                                    }
                                    
                                    
                                    else if (appDelegate.staffDisplayRole == "Group Head"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("GroupHead", forKey: LOGINASNAME)
                                        UserDefaults.standard.set("No", forKey: COMBINATION)
                                        self.SelectedLoginAsIndexInt = 0
                                        self.updateDeviceToken()
                                    }
                                    else if (appDelegate.staffDisplayRole == "Principal"){
                                        
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("Principal", forKey: LOGINASNAME)
                                        UserDefaults.standard.set("No", forKey: COMBINATION)
                                        self.SelectedLoginAsIndexInt = 1
                                        self.updateDeviceToken()
                                    }
                                    else if (appDelegate.staffDisplayRole == "Teaching Staff"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("Staff", forKey: LOGINASNAME)
                                        UserDefaults.standard.set("No", forKey: COMBINATION)
                                        self.SelectedLoginAsIndexInt = 2
                                        self.updateDeviceToken()
                                    }
                                    else if (appDelegate.staffDisplayRole == "Office Staff"){
                                        
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("OfficeStaff", forKey: LOGINASNAME)
                                        UserDefaults.standard.set("No", forKey: COMBINATION)
                                        self.SelectedLoginAsIndexInt = 3
                                        self.updateDeviceToken()
                                        
                                    }
                                    else if (appDelegate.staffDisplayRole == "Non Office Staff"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("NonOfficeStaff", forKey: LOGINASNAME)
                                        UserDefaults.standard.set("No", forKey: COMBINATION)
                                        self.SelectedLoginAsIndexInt = 4
                                        self.updateDeviceToken()
                                        //
                                    }
                                }
                                
                                
                                
                            }else if(Status == "RESET"){
                                
                                ChangePasswordPopup(sender: self)
                                
                            }else{
                                Util .showAlert("", msg: Message)
                            }
                        }
                    }
                }else{
                    Util.showAlert("", msg: Message as String?)
                }
            }
            
            else if(strApiFrom.isEqual(to: "Parentlogin")){
                var ResponseData = NSDictionary()
                if let CheckedArray = csData as? NSArray{
                    if(CheckedArray.count > 0){
                        ResponseData = CheckedArray[0] as! NSDictionary
                        let AlertString =  String(describing: ResponseData["Message"]!)
                        let Status = String(describing: ResponseData["Status"]!)
                        if(Status == "1"){
                            if let ChildDetailsArray = ResponseData["ChildDetails"] as? NSArray{
                                appDelegate.LoginParentDetailArray = ChildDetailsArray
                                arrUserData = ChildDetailsArray
                                Childrens.saveXhilsDetail(ChildDetailsArray as! [Any])
                                
                                self.updateDeviceToken()
                            }else{
                                Util.showAlert("", msg: AlertString)
                            }
                        }else if(Status == "RESET"){
                            self.ChangePasswordPopup(sender: self)
                        }else{
                            Util.showAlert("", msg: AlertString)
                        }
                    }else{
                        Util.showAlert("", msg: strSomething)
                    }
                }else{
                    Util.showAlert("", msg: strSomething)
                }
            }else if(strApiFrom.isEqual(to: "deviceToken")){
                let strCombination : String = UserDefaults.standard.object(forKey: COMBINATION) as! String
                let isParent : String = UserDefaults.standard.object(forKey: LOGINASNAME) as! String
                Constants.printLogKey("strCombination", printValue: strCombination)
                Constants.printLogKey("isParent", printValue: isParent)
                UserDefaults.standard.set(UserMobileNoText.text! as NSString, forKey: USERNAME)
                UserDefaults.standard.set(UserPasswordText.text! as NSString, forKey: USERPASSWORD)
                if(strCombination == "No"){
                    if(isParent == "Parent"){
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "ChildView", sender: nil)
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "MainSegueVc", sender: self)
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "ChildView", sender: nil)
                    }
                }
                
            }else if(strApiFrom.isEqual(to: "ForgotPassword")){
                if let CheckedArray = csData as? NSArray{
                    arrayForgetDatas = csData!
                    var dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    Status = String(describing: dicUser["Status"]!)
                    Message = String(describing: dicUser["Message"]!)
                    
                    if(Status == "1"){
                        forgotPasswordResponseDict = dicUser
                        UserDefaults.standard.set(true, forKey: FORGOT_PASSWORD_CLICKED)
                        UserDefaults.standard.set(UserMobileNoText.text! as NSString, forKey: USERNAME)
                        UserDefaults.standard.set(forgotPasswordResponseDict["ForgetOTPMesage"] as? String ?? "", forKey: FORGOT_PASSWORD_DICT)
                        
                        
                        let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "ForgetVC") as! ForgetVC
                        AddCV.forgotPasswordResponseDict = forgotPasswordResponseDict
                        AddCV.strUserMobile = UserMobileNoText.text ?? ""
                        self.present(AddCV, animated: false, completion: nil)
                    }else{
                        Util .showAlert("", msg: Message);
                    }
                    
                }else{
                    Util .showAlert("", msg: strSomething);
                }
            }
            else if (strApiFrom.isEqual("ValidatePassword")){
                if let CheckedArray = csData as? NSArray{
                    arrayForgetDatas = csData!
                    var dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    Status = String(describing: dicUser["Status"]!)
                    Message = String(describing: dicUser["Message"]!)
                    if Status == "1" {
                        self.CallLoginApi()
                        
                        
                    }else{
                        Util.showAlert("", msg: Message)
                    }
                }
            }
            else if(strApiFrom.isEqual(to: "otp")){
                
                if let CheckedArray = csData as? NSArray{
                    if(CheckedArray.count > 0){
                        userName = UserMobileNoText.text!
                        userPassword = UserPasswordText.text!
                        let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        let strStatus = String(describing: dict["Status"]!)
                        strOtpNote = String(describing: dict["Message"]!)
                        let numberUpdate = String(describing: dict["isNumberExists"] ?? "")
                        let passwordUpdate = String(describing: dict["isPasswordUpdated"] ?? "")
                        let strOtp : String = String(describing: dict["redirect_to_otp"] ?? "")
                        appDelegate.redirectOTPDict = dict
                        appDelegate.isPasswordBind = "1"
                        UserDefaults.standard.set(UserMobileNoText.text! as NSString, forKey: USERNAME)
                        UserDefaults.standard.set(UserPasswordText.text! as NSString, forKey: USERPASSWORD)
                        
                        
                        if(strStatus == "1"){
                            UserDefaults.standard.set(UserMobileNoText.text! as NSString, forKey: USERNAME)
                            if numberUpdate == "1" && passwordUpdate == "1" {
                                if strOtp == "1"{
                                    self.performSegue(withIdentifier: "LoginToOTPSegue", sender: self)
                                }
                                else if strOtp == "0"{
                                    self.CallLoginApi()
                                    
                                    
                                }else{
                                    
                                    self.CallLoginApi()
                                    
                                }
                            }else if numberUpdate == "1" && passwordUpdate == "0"{
                                self.performSegue(withIdentifier: "LoginToOTPSegue", sender: self)
                            }
                            appDelegate.isPasswordBind = "1"
                            
                        }else{
                            Util.showAlert("", msg: strOtpNote)
                        }
                    }else{
                        Util.showAlert("", msg: strSomething)
                    }
                }else{
                    Util.showAlert("", msg: strSomething)
                }
                
            }
            else{
                if let CheckedArray = csData as? NSArray{
                    arrayForgetDatas = csData!
                    var dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    Status = String(describing: dicUser["Status"]!)
                    Message = String(describing: dicUser["Message"]!)
                    if(Status == "1"){
                        Util.showAlert("", msg: Message)
                        popupChangeForgetPassword.dismiss(true)
                        
                    }else{
                        Util.showAlert("", msg: Message)
                    }
                }else{
                    Util .showAlert("", msg: strSomething);
                }
            }
        }else{
            Util .showAlert("", msg: strSomething);
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
    
    //MARK: HTTP RESPONSE
    @objc func httpClientDidSucceed(withResponse responseObject: Any!) {
        hideLoading()
        if(responseObject != nil){
            UtilObj.printLogKey(printKey: "csData", printingValue: responseObject!)
            if let CheckedArray = responseObject as? NSArray{
                if(CheckedArray.count > 0){
                    
                    let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                    let strStatus = String(describing: dict["Status"]!)
                    
                    if(strStatus == "1"){
                        UserDefaults.standard.set(UserMobileNoText.text! as NSString, forKey: USERNAME)
                        let strOtp : String = String(describing: dict["redirect_to_otp"]!)
                        
                        if(strOtp == "0"){
                            self.CallLoginApi()
                        }
                        
                        else{
                            self.performSegue(withIdentifier: "LoginToOTPSegue", sender: self)
                        }
                    }else{
                        Util.showAlert("", msg: languageDict["mobile_not_available"] as? String)
                        
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
    
    
    @objc func httpClientDidFailWithError(_ error: Error!) {
        hideLoading()
        Util .showAlert("", msg: strSomething);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "MainSegueVc"){
            let segueid = segue.destination as! MainVC
            segueid.ArraySchoolData = arrSchoolData
            segueid.pickerArray = arrayChooseLogin
            segueid.LoginAsIndexInt = SelectedLoginAsIndexInt
        }else if (segue.identifier == "ChildView"){
            let segueid = segue.destination as! ParentTableVC
            segueid.ArrayChildData = arrUserData
            Childrens.saveXhilsDetail(arrUserData as! [Any])
            segueid.SelectedLoginIndexInt = ParentSelectedLoginIndex
        }
        
        else if(segue.identifier == "LoginToOTPSegue"){
            
            let segueid = segue.destination as! CheckOTPVC
            segueid.strOtpNote = strOtpNote
            
            
            
        }
    }
    
    func LoadParentDetail(){
        if let ChildDetailsArray = ParentDictDetail["ChildDetails"] as? NSArray{
            if(ChildDetailsArray.count > 0){
                arrUserData = ChildDetailsArray
                Childrens.saveXhilsDetail(ChildDetailsArray as! [Any])
                appDelegate.LoginParentDetailArray = ChildDetailsArray
                self.updateDeviceToken()
            }else{
                Util.showAlert("", msg: strAlertString)
            }
        }else{
            Util.showAlert("", msg: strAlertString)
        }
        
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        let strLanguage : String = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDict = LangDict
        if(Language == "ar"){
            self.view.semanticContentAttribute = .forceLeftToRight
            UserMobileNoText.textAlignment = .right
            UserPasswordText.textAlignment = .right
        }else{
            self.view.semanticContentAttribute = .forceLeftToRight
            UserMobileNoText.textAlignment = .left
            UserPasswordText.textAlignment = .left
        }
        
        let MobileLenghtStr : String = UserDefaults.standard.object(forKey: MOBILE_LENGTH) as! String
        
        
        
        
        FloatMobileLabel.text = MobileLenghtStr + " Digit"  + " Mobile Number"
        UserPasswordText.placeholder = LangDict["hint_password"] as? String
        TitleForgotPswdLabel.text = LangDict["forgot_password"] as? String
        EnterOTPLabel.text = LangDict["enter_your_otp"] as? String
        NewPasswordLabel.text = LangDict["teacher_pop_password_txt_new"] as? String
        VerifyPasswordLabel.text = LangDict["teacher_pop_password_txt_repeat"] as? String
        TitleChangePswdLabel.text = LangDict["reset_password"] as? String
        
        LoginButton.setTitle(LangDict["btn_login"] as? String, for: .normal)
        ForgotPasswordButton.setTitle(LangDict["btn_forgot_password"] as? String, for: .normal)
        ForgotPasswordOkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        CancelButton.setTitle(LangDict["teacher_pop_password_btnCancel"] as? String, for: .normal)
        UpdateButton.setTitle(LangDict["teacher_pop_password_btnUpdate"] as? String, for: .normal)
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
    }
    
    func updateDeviceToken(){
        if(Util .isNetworkConnected()){
            DispatchQueue.main.async {
            }
        }else{
            Util.showAlert("", msg: NETWORK_ERROR)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 60
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "CallPopupTVCell", for: indexPath) as! CallPopupTVCell
        cell.backgroundColor = UIColor.clear
        cell.numberLabel.text = mobileArray[indexPath.row] as? String
        cell.callButton.addTarget(self, action: #selector(callButtonAction(sender:)), for: .touchUpInside)
        cell.callButton.tag = indexPath.row
        return cell
    }
    
    @objc func callButtonAction(sender: UIButton){
        let mobilrNumber  =  mobileArray[sender.tag] as? String
        if let url = NSURL(string: "tel://" + mobilrNumber!) {
            UIApplication.shared.openURL(url as URL)
        }else{
            Util.showAlert("Call error :", msg: mobilrNumber)
        }
        exit(0)
    }
}

