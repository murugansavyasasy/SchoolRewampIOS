//
//  CheckPasswordVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 16/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class CheckPasswordVC: UIViewController ,Apidelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {
     @IBOutlet weak var callPopupTableview: UITableView!
    @IBOutlet weak var UserPassWordText: UITextField!
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var ShowPassword: UIButton!
    @IBOutlet var PopupChangePassword: UIView!
    @IBOutlet weak var ShowExistingPswdButton: UIButton!
    @IBOutlet weak var ShowNewPswdButton: UIButton!
    @IBOutlet weak var VerifyNewPasswordText: UITextField!
    @IBOutlet weak var ShowVerifyPswdButton: UIButton!
    @IBOutlet weak var ExistingPasswordText: UITextField!
    @IBOutlet weak var NewPasswordText: UITextField!
    @IBOutlet weak var ForgotPasswordButton: UIButton!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var EnterOTPLabel: UILabel!
        @IBOutlet weak var passwordBindLabel: UILabel!
    @IBOutlet weak var TitleChangePswdLabel: UILabel!
    @IBOutlet weak var NewPasswordLabel: UILabel!
    @IBOutlet weak var VerifyPasswordLabel: UILabel!
    @IBOutlet weak var UpdateButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet var callPopupView: UIView!
    @IBOutlet weak var goToSigninView: UIView!
    @IBOutlet weak var callClickHereButton: UIButton!
    @IBOutlet weak var callMobileNo2Label: UILabel!
    @IBOutlet weak var callMobileNo1Label: UILabel!
    @IBOutlet weak var callPopupTitleLabel: UILabel!
    
    @IBOutlet weak var SignInTitleLabel: UILabel!
      @IBOutlet weak var forgotPasswordButtonHeight: NSLayoutConstraint!
    
    var ParentDictDetail : NSDictionary = NSDictionary()
    var forgotPasswordResponseDict : NSDictionary = NSDictionary()
    var validatePasswordResponseDict : NSDictionary = NSDictionary()
    var arrayForgetDatas: NSArray = []
    var arrayForgetChangeDatas: NSArray = []
    var NumberOfCollectionCell = [4,14,9,2]
    var userName = String()
    var ApiMobileLength = 0
    var arrUserData: NSArray = []
    var arrSchoolData: NSArray = []
    var arrayChooseLogin:Array = [String]()
    var strMobileNo = String()
    var strAlertMsg = String()
    var strCountryCode = String()
    var strCountryID = String()
    var strOTPVerifed = String()
    var strApiFrom = String()
    var StudentIDString = String()
    var arrLibraryData: NSArray = []
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var KlCpopupChangedPassword : KLCPopup  = KLCPopup()
    var KlCpopupCall : KLCPopup  = KLCPopup()
    let UtilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var SelectedLoginAsIndexInt = 0
    var ParentSelectedLoginIndex = 0
    
    var mobileArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CheckPasswordVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let MobileLenghtStr : String = UserDefaults.standard.object(forKey: MOBILE_LENGTH) as! String
        ApiMobileLength = Int(MobileLenghtStr)! + 1
        SubmitButton.layer.cornerRadius = 5
        SubmitButton.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        ButtonCornerDesign()
        strMobileNo = UserDefaults.standard.object(forKey: USERNAME) as! String
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        strCountryID = UserDefaults.standard.object(forKey: COUNTRY_ID) as! String

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        UserPassWordText.keyboardType = UIKeyboardType.numbersAndPunctuation
     
        self.passwordBindLabel.isHidden = true
                   self.ForgotPasswordButton.isHidden = false
                  self.forgotPasswordButtonHeight.constant = 20
                  self.UserPassWordText.isUserInteractionEnabled = true
        self.callSelectedLanguage()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func dismissKeyboard() {
        UserPassWordText.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField == self.UserPassWordText){
            self.view.frame.origin.y -= 50
            
        }else{
            self.view.frame.origin.y = 0
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.view.frame.origin.y = 0
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        let currentCharacterCount = textField.text?.count ?? 0
        
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        if(newLength == 21){
            textField.resignFirstResponder()
        }
        //return string == numberFiltered
        return true
    }
    
    @IBAction func actionForgotPassword(_ sender: Any) {
        dismissKeyboard()
        if(strMobileNo.count == ApiMobileLength - 1) {
            if(Util .isNetworkConnected()) {
               

                self.CallForgotPasswordApi()
            }else {
                Util .showAlert("", msg: INTERNET_ERROR)
            }
        }else {
            Util.showAlert("", msg: REGISTERED_MOBILE_ALERT);
        }
    }
    
    @IBAction func actionShowPassword(_ sender: Any) {
        if(UserPassWordText.isSecureTextEntry == false) {
            UserPassWordText.isSecureTextEntry = true
            ShowPassword.isSelected = false
        }else{
            UserPassWordText.isSecureTextEntry = false
            ShowPassword.isSelected = true
        }
    }
    
    @IBAction func actionSubmitButton(_ sender: Any){
        dismissKeyboard()
        if UserPassWordText.text == ""{
            Util .showAlert("", msg: ENTER_PASSWORD_ALERT)
        }else{
            if(Util .isNetworkConnected()) {
                self.CallValidatePasswordApi()
            } else {
                Util .showAlert("", msg: INTERNET_ERROR)
            }
        }
    }
    
    //MARK: FUNCTIONS

    @IBAction func actionGoToSign(_ sender: Any) {
        KlCpopupChangedPassword.dismiss(true)
        self.performSegue(withIdentifier: "PasswordToLoginSegue", sender: self)
    }
    
    @IBAction func actionShowExistingPassword(_ sender: Any) {
        if(ExistingPasswordText.isSecureTextEntry == false) {
            ExistingPasswordText.isSecureTextEntry = true
            ShowExistingPswdButton.isSelected = false
        }else{
            ExistingPasswordText.isSecureTextEntry = false
            ShowExistingPswdButton.isSelected = true
        }
    }
    
    @IBAction func actionShowNewPassword(_ sender: Any) {
        if(NewPasswordText.isSecureTextEntry == false) {
            NewPasswordText.isSecureTextEntry = true
            ShowNewPswdButton.isSelected = false
        } else {
            NewPasswordText.isSecureTextEntry = false
            ShowNewPswdButton.isSelected = true
        }
    }
    
    @IBAction func actionShowVerifyNewPassword(_ sender: Any) {
        if(VerifyNewPasswordText.isSecureTextEntry == false) {
            VerifyNewPasswordText.isSecureTextEntry = true
            ShowVerifyPswdButton.isSelected = false
        } else{
            VerifyNewPasswordText.isSecureTextEntry = false
            ShowVerifyPswdButton.isSelected = true
        }
    }
    
    @IBAction func actionCancelUpdatePassword(_ sender: Any) {
        DissmissKEY()
        self.clearChangePassword()
        PopupChangePassword.alpha = 0
    }
    
    @IBAction func actionCloseCallPopup(_ sender: Any) {
        PopupChangePassword.alpha = 0
    }
    
    func DissmissKEY() {
        NewPasswordText.resignFirstResponder()
        ExistingPasswordText.resignFirstResponder()
        VerifyNewPasswordText.resignFirstResponder()
    }
    
    @IBAction func actionUpdateChangePassword(_ sender: Any) {
        DissmissKEY()
        if((ExistingPasswordText.text?.count)! > 0 ){
        if((NewPasswordText.text?.count)! > 0 && (VerifyNewPasswordText.text?.count)! > 0) {
            if(NewPasswordText.text?.isEqual(VerifyNewPasswordText.text))!{
                if(Util .isNetworkConnected()){
                    self.CallChangeForgotPasswordApi()
                    PopupChangePassword.alpha = 0
                }else {
                    Util .showAlert("", msg: INTERNET_ERROR)
                }
            }else{
                Util.showAlert("", msg: PASSWORD_MISMATCH)
            }
        }else {
            Util.showAlert("", msg: ENTER_PASSWORD_ALERT)
        }
    }
        else{
            Util.showAlert("", msg: ENTER_OTP)
        }
    }
    
    func ChangePasswordPopup(sender : Any) {
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            PopupChangePassword.frame.size.height = 540
            PopupChangePassword.frame.size.width = 500
        }
//
        
//        G3
        
        PopupChangePassword.center = view.center
        PopupChangePassword.alpha = 1
        PopupChangePassword.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)

         self.view.addSubview(PopupChangePassword)
         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
       
           self.PopupChangePassword.transform = .identity
         })
        
        
        print("CheckPAssword?POpup")
        self.clearChangePassword()
    }
    
    func clearChangePassword(){
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
    
    func CallPopup(sender : Any) {
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            callPopupView.frame.size.height = 380
            callPopupView.frame.size.width = 400
        }
        KlCpopupCall = KLCPopup(contentView: callPopupView, showType: KLCPopupShowType.none , dismissType:KLCPopupDismissType.none,maskType: KLCPopupMaskType.dimmed , dismissOnBackgroundTouch:  false , dismissOnContentTouch: false )
        
        let attributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributedText = NSAttributedString(string: forgotPasswordResponseDict["MoreInfo"] as! String , attributes: attributes)
        
        self.callClickHereButton.setAttributedTitle(attributedText, for: .normal)
        
        let mobileStr = forgotPasswordResponseDict["DialNumbers"] as! String
        self.mobileArray = mobileStr.components(separatedBy: ",") as NSArray
        self.callPopupTitleLabel.text = forgotPasswordResponseDict["Message"] as? String
        self.callPopupTableview.reloadData()
        KlCpopupCall.show()
        
      
    }
    
    func ButtonCornerDesign() {
        PopupChangePassword.layer.cornerRadius = 8
        PopupChangePassword.layer.masksToBounds = true
        callPopupView.layer.cornerRadius = 8
        callPopupView.layer.masksToBounds = true
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
    
    //MARK: API CALLING
    func CallChangePasswordApi() {
        showLoading()
        strApiFrom = "ChangePassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + CHANGEPSWD_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo, "NewPassword": NewPasswordText.text!,"OldPassword" : ExistingPasswordText.text! ,COUNTRY_CODE : strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ChangePassword")
    }
    
    func CallValidatePasswordApi() {
            showLoading()
            strApiFrom = "ValidatePassword"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + VALIDATE_PASSWORD_METHOD
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo, "Password": UserPassWordText.text!]
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "ValidatePassword")
        }
    
    
    func CallChangeForgotPasswordApi() {
        showLoading()
        strApiFrom = "ChangePassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + RESET_FORGOT_PASSWORD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo, "NewPassword": NewPasswordText.text!,"OTP" : ExistingPasswordText.text! ,COUNTRY_CODE : strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ChangePassword")
    }
    
    
    
    func CallManageParentApi(){
        showLoading()
        strApiFrom = "Parentlogin"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + PARENT_LOGIN_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let strUDID : String = Util.str_deviceid()
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo,"Password" : UserPassWordText.text!,"DeviceType" : DEVICE_TYPE ,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
        let myString = Util.convertDictionary(toString: myDict)
        print("deviceTypeCheckPasword\(myString)")
        apiCall.nsurlConnectionFunction(requestString, myString, "Parentlogin")
    }
    
    func CallParentDeviceTokenApi() {
        showLoading()
        strApiFrom = "deviceToken"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + DEVICETOKEN
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        var deviceToken = UserDefaults.standard.object(forKey:DEVICETOKEN) as? String ?? ""
        if(deviceToken.count == 0){
            deviceToken = "1234"
        }
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo,"DeviceToken": deviceToken,"DeviceType": DEVICE_TYPE ,COUNTRY_CODE : strCountryCode]
        Constants.printLogKey("Device myDict", printValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "deviceToken")
    }
    
    func CallForgotPasswordApi() {
        showLoading()
        strApiFrom = "ForgotPassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + FORGOTPSWD_METHOD_BY_COUNTRYID
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo ,COUNTRY_CODE : strCountryCode,COUNTRY_ID : strCountryID]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ForgotPassword")
    }
    func CallLoginApiCalling() {
        showLoading()
        strApiFrom = "login"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + LOGIN_METHOD
        print("requestStringer",requestStringer)
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let strUDID : String = Util.str_deviceid()
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo,"Password" : UserPassWordText.text!,"DeviceType" : DEVICE_TYPE ,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
        print(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "login")
    }
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil){
            var Message = String()
            var Status = String()
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom.isEqual("login")){
                if((csData?.count)! > 0){
                    if (csData == nil){
                        Util .showAlert("", msg: SERVER_CONNECTION_FAILED);
                    }else{
                        if((csData?.count)! > 0){
                            let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                            let Status : String = String(describing: dicUser["Status"]!)
                            strAlertMsg = String(describing: dicUser["Message"]!)
                            if(Status == "1"){
                                ParentDictDetail = dicUser
                                UserDefaults.standard.set(strMobileNo, forKey: USERNAME)
                                UserDefaults.standard.set(UserPassWordText.text! as NSString, forKey: USERPASSWORD)
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
                               
                                
                                var staffDisplayRole : String!
                                staffDisplayRole = String(describing: dicUser["staff_display_role"]!)
                                
                                defaults.set(staffDisplayRole as String, forKey: DefaultsKeys.getgroupHeadRole)
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
                                }
                                else if (appDelegate.staffRole == "p5" && appDelegate.isParent == "1"){
                                    
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
                                    
                                    UserDefaults.standard.set("NonOfficeStaff", forKey: LOGINASNAME)
                                    UserDefaults.standard.set("No", forKey: COMBINATION)
                                    
                                    self.updateDeviceToken()
                                }
                                }
                                
                               
                              
                            }else if(Status == "RESET"){
                                
                                ChangePasswordPopup(sender: self)
                                
                            }else{
                                Util .showAlert("", msg: strAlertMsg)
                            }
                        }
                    }
                }else{
                    Util.showAlert("", msg: strAlertMsg as String?)
                }
            }else if(strApiFrom.isEqual("Parentlogin")){
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
                        Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
                    }
                }else{
                    Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
                }
            }else if(strApiFrom.isEqual("deviceToken")){
                
                UserDefaults.standard.set(strMobileNo as NSString, forKey: USERNAME)
                UserDefaults.standard.set(UserPassWordText.text! as NSString, forKey: USERPASSWORD)
                let strCombination : String = UserDefaults.standard.object(forKey: COMBINATION) as! String
                let isParent : String = UserDefaults.standard.object(forKey: LOGINASNAME) as! String
                
                if(strCombination == "No"){
                    if(isParent == "Parent"){
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "FirstTimeParentSegue", sender: nil)
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "FirstTimeTeacherSegue", sender: self)
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "FirstTimeParentSegue", sender: nil)
                    }
                }
            }
            else if(strApiFrom.isEqual("ForgotPassword")){
                if let CheckedArray = csData as? NSArray{
                    var dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    let Status : String = String(describing: dicUser["Status"]!)
                    let Message : String = String(describing: dicUser["Message"]!)
                    if(Status == "1"){
                        forgotPasswordResponseDict = dicUser
                        UserDefaults.standard.set("Yes", forKey: AT_VERY_FIRST_TIME)
                        UserDefaults.standard.set(true, forKey: FORGOT_PASSWORD_CLICKED)
                        UserDefaults.standard.set(strMobileNo, forKey: USERNAME)
                    UserDefaults.standard.set(forgotPasswordResponseDict["ForgetOTPMesage"] as! String, forKey: FORGOT_PASSWORD_DICT)
                        CallPopup(sender: self)
                    }else{
                         self.AlerMessage(alrtStr: Message)
                    }
                   
                }else{
                    Util .showAlert("", msg: SERVER_ERROR);
                }
            }else if (strApiFrom.isEqual("ValidatePassword")){
                if let CheckedArray = csData as? NSArray{
                                    arrayForgetDatas = csData!
                                    var dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                                    Status = String(describing: dicUser["Status"]!)
                                    Message = String(describing: dicUser["Message"]!)
                    if Status == "1" {
                        self.CallLoginApiCalling()
                        
                        
                    }else{
                        Util.showAlert("", msg: Message)
                    }
                }
            }else{
                if let CheckedArray = csData as? NSArray{
                    arrayForgetDatas = csData!
                    var dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    Status = String(describing: dicUser["Status"]!)
                    Message = String(describing: dicUser["Message"]!)
                    if(Status == "1"){
                        Util.showAlert("", msg: Message)
                        KlCpopupChangedPassword.dismiss(true)
                    }else{
                        Util.showAlert("", msg: Message)
                    }
                }else{
                    Util .showAlert("", msg: SERVER_ERROR);
                }
            }
        }else{
            Util.showAlert("", msg: SERVER_ERROR)
        }
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: SERVER_CONNECTION_FAILED);
    }
    
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "FirstTimeTeacherSegue"){
            let segueid = segue.destination as! MainVC
            segueid.ArraySchoolData = arrSchoolData
            segueid.pickerArray = arrayChooseLogin
            segueid.LoginAsIndexInt = SelectedLoginAsIndexInt
            print("FirstTimeTeacherSegue")
            
        }else if (segue.identifier == "FirstTimeParentSegue"){
            let segueid = segue.destination as! ParentTableVC
            segueid.ArrayChildData = arrUserData
            segueid.SelectedLoginIndexInt = ParentSelectedLoginIndex
            print("FirstTimeParentSegue")
        }
    }
    func AlerMessage(alrtStr : String){
        let alertController = UIAlertController(title: "Alert", message: alrtStr, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.ChangePasswordPopup(sender: self)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func LoadParentDetail(){
        if let ChildDetailsArray = ParentDictDetail["ChildDetails"] as? NSArray{
            if(ChildDetailsArray.count > 0){
                appDelegate.LoginParentDetailArray = ChildDetailsArray
                arrUserData = ChildDetailsArray
                Childrens.saveXhilsDetail(ChildDetailsArray as! [Any])
                self.updateDeviceToken()
            }  else{
                self.updateDeviceToken()
                Util.showAlert("", msg: strAlertMsg)
            }
        }else{
            Util.showAlert("", msg: strAlertMsg)
        }
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        let strLanguage : String = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        print(strLanguage)
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
        
        if(Language == "ar"){
            self.view.semanticContentAttribute = .forceLeftToRight
        }else{
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        PasswordLabel.text = LangDict["enter_your_passworddd"] as? String
        UserPassWordText.placeholder = LangDict["hint_password"] as? String
        SubmitButton.setTitle(LangDict["btn_sign_submit"] as? String, for: .normal)
        CancelButton.setTitle(LangDict["teacher_pop_password_btnCancel"] as? String, for: .normal)
        UpdateButton.setTitle(LangDict["teacher_pop_password_btnUpdate"] as? String, for: .normal)
        
        EnterOTPLabel.text = LangDict["enter_your_otp"] as? String
        NewPasswordLabel.text = LangDict["teacher_pop_password_txt_new"] as? String
        VerifyPasswordLabel.text = LangDict["teacher_pop_password_txt_repeat"] as? String
        TitleChangePswdLabel.text = LangDict["reset_password"] as? String
        self.passwordBindLabel.text = LangDict["password_bind"] as? String
        
    }
    
    func updateDeviceToken(){
        if(Util .isNetworkConnected()){
            DispatchQueue.main.async {
            }
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
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
            }
            exit(0);
        }
    }

