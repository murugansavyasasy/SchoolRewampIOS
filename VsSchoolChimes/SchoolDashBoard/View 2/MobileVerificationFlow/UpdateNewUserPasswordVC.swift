//
//  UpdateNewUserPasswordVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 20/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class UpdateNewUserPasswordVC: UIViewController,Apidelegate,UITextFieldDelegate {
    @IBOutlet weak var ShowNewPswdButton: UIButton!
    @IBOutlet weak var NewPasswordText: UITextField!
    @IBOutlet weak var ShowConfirmPswdButton: UIButton!
    @IBOutlet weak var ConfirmPasswordText: UITextField!
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet var PopupChangePassword: UIView!
    @IBOutlet weak var ShowExistingPswdButton: UIButton!
    @IBOutlet weak var ExistingPasswordText: UITextField!
    @IBOutlet weak var ShowPswdButton: UIButton!
    @IBOutlet weak var VerifyNewPasswordText: UITextField!
    @IBOutlet weak var ShowVerifyPswdButton: UIButton!
    @IBOutlet weak var PasswordText: UITextField!
    @IBOutlet weak var CreatePswdLabel: UILabel!
    @IBOutlet weak var ConfirmPswdLabel: UILabel!
    
    var KlCpopupChangedPassword : KLCPopup  = KLCPopup()
    
    var strAlert = String()
    var strCountryCode = String()
    var strOTPValue = String()
    var StudentIDString = String()
    var strMobileNo = String()
    var arrUserData: NSArray = []
    var arrSchoolData: NSArray = []
    var arrayChooseLogin:Array = [String]()
    var strApiFrom = String()
    var arrLibraryData: NSArray = []
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var NumberOfCollectionCell = [4,14,9,2]
    var ParentDictDetail : NSDictionary = NSDictionary()
   
    var SelectedLoginAsIndexInt = 0
    var ParentSelectedLoginIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UpdateNewUserPasswordVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        SubmitButton.layer.cornerRadius = 5
        SubmitButton.layer.masksToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        strMobileNo = UserDefaults.standard.object(forKey: USERNAME) as! String
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        ButtonCornerDesign()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @objc func dismissKeyboard()
    {
        NewPasswordText.resignFirstResponder()
        ConfirmPasswordText.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if(textField == self.ConfirmPasswordText)
        {
            self.view.frame.origin.y -= 80
            
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
        
        
        if(textField == NewPasswordText || textField == ConfirmPasswordText )
        {
            if(newLength == 21)
            {
                textField.resignFirstResponder()
            }
        }
        
        return true
        
        
    }
    @IBAction func actionSubmitButton(_ sender: Any)
    {
        dismissKeyboard()
        if NewPasswordText.text == ""
        {
            Util .showAlert("", msg: NEW_PASSWORD)
        }
        else if ConfirmPasswordText.text == ""
        {
            Util .showAlert("", msg: CONFIRM_PASSWORD)
        }
        else if (NewPasswordText.text != ConfirmPasswordText.text)
        {
            Util .showAlert("", msg:PASSWORD_MISMATCH)
        }
        else
        {
            if(Util .isNetworkConnected())
            {
                if (NewPasswordText.text == ConfirmPasswordText.text)
                {
                    self.CallUpdateNewPasswordApi()
                }else
                {
                    Util .showAlert("", msg:PASSWORD_MISMATCH)
                }
            }
            else
            {
                Util .showAlert("", msg: INTERNET_ERROR)
            }
        }
    }
    //MARK: self FUNCTIONS
    @IBAction func actionShowNewPassword(_ sender: Any) {
        if(NewPasswordText.isSecureTextEntry == false)
        {
            NewPasswordText.isSecureTextEntry = true
            ShowNewPswdButton.isSelected = false
        }else{
            NewPasswordText.isSecureTextEntry = false
            ShowNewPswdButton.isSelected = true
        }
    }
    
    @IBAction func actionShowConfirmPassword(_ sender: Any)
    {
        if(ConfirmPasswordText.isSecureTextEntry == false)
        {
            ConfirmPasswordText.isSecureTextEntry = true
            ShowConfirmPswdButton.isSelected = false
        }
        else
        {
            ConfirmPasswordText.isSecureTextEntry = false
            ShowConfirmPswdButton.isSelected = true
        }
    }
    
    //MARK: API CALLING
    func CallUpdateNewPasswordApi()
    {
        showLoading()
        strApiFrom = "UpdateChangePassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + UPDATE_NEWPASSWORD_MEHTOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        var deviceToken = UserDefaults.standard.object(forKey:DEVICETOKEN) as! String
        if(deviceToken.count == 0){
            
            deviceToken = "1234"
        }
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo, "NewPassword": NewPasswordText.text!,"IMEINumber" : deviceToken ,COUNTRY_CODE : strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateChangePassword")
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
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo,"Password" : NewPasswordText.text!,"DeviceType" : DEVICE_TYPE ,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
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
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo,"DeviceToken": deviceToken,"DeviceType": DEVICE_TYPE ,COUNTRY_CODE : strCountryCode]
         Constants.printLogKey("Device myDict", printValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "deviceToken")
    }
    
    func CallLoginApiCalling()
    {
        showLoading()
        strApiFrom = "login"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + LOGIN_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
         let strUDID : String = Util.str_deviceid()
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo,"Password" : NewPasswordText.text!,"DeviceType" : DEVICE_TYPE ,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "login")
    }
    
    func CallNewLoginApiCalling()
    {
        showLoading()
        strApiFrom = "login"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + LOGIN_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
         let strUDID : String = Util.str_deviceid()
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo,"Password" : ConfirmPasswordText.text!,"DeviceType" : DEVICE_TYPE ,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
        let myString = Util.convertDictionary(toString: myDict)
        
        print("myDict",myDict)
        print("CallNewLoginApiCallingmyString",myString)
        print("CallNewLoginApiCallingrequestStringer",requestStringer)
        apiCall.nsurlConnectionFunction(requestString, myString, "login")
    }
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            
            var strAlertMsg = String()
            var Status = String()
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom.isEqual("UpdateChangePassword")){
                if let CheckedArray = csData as? NSArray
                {
                    if(CheckedArray.count > 0)
                    {
                        let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        
                        
                        let strStatus = String(describing: dict["Status"]!)
                        strAlertMsg = String(describing: dict["Message"]!)
                        strAlert = strAlertMsg
                        if(strStatus == "1")
                        {
                            AlerMessage(alrtString: strAlertMsg)
                            
                            
                        }
                            
                        else
                        {
                            Util.showAlert("", msg: strAlertMsg)
                            
                        }
                        
                    }else
                    {
                        Util.showAlert("", msg: SERVER_ERROR)
                    }
                    
                }else
                {
                    Util.showAlert("", msg: SERVER_ERROR)
                }
            }
            else if(strApiFrom.isEqual("login")){
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
                                UserDefaults.standard.set(strMobileNo as NSString, forKey: USERNAME)
                                
                                UserDefaults.standard.set(PasswordText.text! as NSString, forKey: USERPASSWORD)
                                
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
                                
                                
                            }
                            else if(Status == "RESET"){
                                
                                ChangePasswordPopup(sender: self)
                                
                            }
                            else{
                                Util .showAlert("", msg: strAlertMsg)
                            }
                        }
                    }
                }else{
                    Util.showAlert("", msg: strAlertMsg as String?)
                }
            }
            else if(strApiFrom.isEqual("Parentlogin"))
            {
                var ResponseData = NSDictionary()
                if let CheckedArray = csData as? NSArray
                {
                    if(CheckedArray.count > 0)
                    {
                        ResponseData = CheckedArray[0] as! NSDictionary
                        let AlertString =  String(describing: ResponseData["Message"]!)
                        let Status = String(describing: ResponseData["Status"]!)
                        if(Status == "1")
                        {
                            if let ChildDetailsArray = ResponseData["ChildDetails"] as? NSArray
                            {
                                appDelegate.LoginParentDetailArray = ChildDetailsArray
                                arrUserData = ChildDetailsArray
                                Childrens.saveXhilsDetail(ChildDetailsArray as! [Any])
                                 self.updateDeviceToken()
                            }
                            else{
                                Util.showAlert("", msg: AlertString)
                            }
                            
                            
                        }
                            
                        else
                        {
                            Util.showAlert("", msg: AlertString)
                        }
                    }
                    else{
                        Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
                    }
                }
                else{
                    Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
                }
                
            }
            else if(strApiFrom.isEqual("deviceToken"))
            {
                UserDefaults.standard.set(strMobileNo as NSString, forKey: USERNAME)
                UserDefaults.standard.set(NewPasswordText.text! as NSString, forKey: USERPASSWORD)
                let strCombination : String = UserDefaults.standard.object(forKey: COMBINATION) as! String
                let isParent : String = UserDefaults.standard.object(forKey: LOGINASNAME) as! String
                
                if(strCombination == "No"){
                    if(isParent == "Parent"){
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "UpdatedPswdToParentSegue", sender: nil)
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "UpdatedPswdToTeacherSegue", sender: self)
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "UpdatedPswdToParentSegue", sender: nil)
                    }
                }
            }
            else
            {
                if let CheckedArray = csData as? NSArray
                {
                    //arrayForgetDatas = csData!
                    var dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    Status = String(describing: dicUser["Status"]!)
                    let Message : String = String(describing: dicUser["Message"]!)
                    
                    if(Status == "1")
                    {
                        Util.showAlert("", msg: Message)
                        KlCpopupChangedPassword.dismiss(true)
                        CallNewLoginApiCalling()
                    }
                    else
                    {
                        Util.showAlert("", msg: Message)
                    }
                }
                else
                {
                    Util .showAlert("", msg: SERVER_ERROR);
                }
            }
            
            
        }
        else
        {
            Util.showAlert("", msg: SERVER_ERROR)
        }
        
    }
    
    
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        // print("Error")
        Util .showAlert("", msg: SERVER_CONNECTION_FAILED);
        
    }
    
    func AlerMessage(alrtString : String)
    {
        
        let alertController = UIAlertController(title: "Alert", message: alrtString, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            

            
            self.CallNewLoginApiCalling()
            
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "UpdatedPswdToTeacherSegue")
        {
            let segueid = segue.destination as! MainVC
            segueid.ArraySchoolData = arrSchoolData
            segueid.pickerArray = arrayChooseLogin
            segueid.LoginAsIndexInt = SelectedLoginAsIndexInt
            
           
        }
        else if (segue.identifier == "UpdatedPswdToParentSegue")
        {
            let segueid = segue.destination as! ParentTableVC
            segueid.ArrayChildData = arrUserData
            segueid.SelectedLoginIndexInt = ParentSelectedLoginIndex
        }
    }
    
    func LoadParentDetail()
    {
        //ParentDictDetail
        if let ChildDetailsArray = ParentDictDetail["ChildDetails"] as? NSArray
        {
            
            if(ChildDetailsArray.count > 0)
            {
                appDelegate.LoginParentDetailArray = ChildDetailsArray
                arrUserData = ChildDetailsArray
                Childrens.saveXhilsDetail(ChildDetailsArray as! [Any])
                 self.updateDeviceToken()
            }  else{
                Util.showAlert("", msg: strAlert)
            }
        }
        else{
            Util.showAlert("", msg: strAlert)
        }
    }
    
    //MARK:FUNCTIONS
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
    
    @IBAction func actionShowPassword(_ sender: Any)
    {
        if(PasswordText.isSecureTextEntry == false)
        {
            PasswordText.isSecureTextEntry = true
            ShowPswdButton.isSelected = false
        }
        else
        {
            PasswordText.isSecureTextEntry = false
            ShowPswdButton.isSelected = true
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
        KlCpopupChangedPassword.dismiss(true)
    }
    func DissmissKEY()
    {
        PasswordText.resignFirstResponder()
        ExistingPasswordText.resignFirstResponder()
        VerifyNewPasswordText.resignFirstResponder()
        
    }
    func clearChangePassword()
    {
        ExistingPasswordText.text = ""
        PasswordText.text = ""
        VerifyNewPasswordText.text = ""
        ExistingPasswordText.isSecureTextEntry = true
        ShowExistingPswdButton.isSelected = false
        VerifyNewPasswordText.isSecureTextEntry = true
        ShowVerifyPswdButton.isSelected = false
        PasswordText.isSecureTextEntry = true
        ShowPswdButton.isSelected = false
        
    }
    func ButtonCornerDesign()
    {
        PopupChangePassword.layer.cornerRadius = 8
        PopupChangePassword.layer.masksToBounds = true
        
    }
    func ChangePasswordPopup(sender : Any)
    {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChangePassword.frame.size.height = 520
            
            PopupChangePassword.frame.size.width = 500
            
            
        }

        
//        G3
        PopupChangePassword.center = view.center
        PopupChangePassword.alpha = 1
        PopupChangePassword.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)

         self.view.addSubview(PopupChangePassword)
         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
        
           self.PopupChangePassword.transform = .identity
         })
        
        print("UpdateNEwUserChangePAssword")
        self.clearChangePassword()
        
        
        
    }
    @IBAction func actionUpdateChangePassword(_ sender: Any)
    {
        DissmissKEY()
        if((ExistingPasswordText.text?.count)! > 0  && (PasswordText.text?.count)! > 0 && (VerifyNewPasswordText.text?.count)! > 0)
        {
            
            if(PasswordText.text?.isEqual(VerifyNewPasswordText.text))!
            {
                
                if(Util .isNetworkConnected())
                {
                    self.CallChangePasswordApi()
                }
                else
                {
                    Util .showAlert("", msg: INTERNET_ERROR)
                }
                
                
            }
                
            else
            {
                Util.showAlert("", msg: PASSWORD_MISMATCH)
            }
        }
        else
        {
            Util.showAlert("", msg: ENTER_VALID_PASSWORD)
        }
        
        
    }
    //MARK: API CALLING
    func CallChangePasswordApi()
    {
        showLoading()
        strApiFrom = "ChangePassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + CHANGEPSWD_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo, "NewPassword": PasswordText.text!,"OldPassword" : ExistingPasswordText.text!]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ChangePassword")
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
        CreatePswdLabel.text = LangDict["create_new_password"] as? String
        ConfirmPswdLabel.text = LangDict["confirm_password"] as? String
        PasswordText.placeholder = LangDict["hint_password"] as? String
        ConfirmPasswordText.placeholder = LangDict["hint_password"] as? String
        SubmitButton.setTitle(LangDict["btn_sign_submit"] as? String, for: .normal)
        
    }
    
    func updateDeviceToken(){
        if(Util .isNetworkConnected()){
            DispatchQueue.main.async {
                self.CallParentDeviceTokenApi()
            }
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
    }
    
    
}
