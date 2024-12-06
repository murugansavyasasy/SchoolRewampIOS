//
//  CheckOTPVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 19/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class CheckOTPVC: UIViewController,Apidelegate,UITextFieldDelegate,HTTPClientDelegate{
    
    @IBOutlet weak var OTPText: UITextField!
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var ResendOTPButton: UIButton!
    @IBOutlet weak var OTPLabel: UILabel!
    
    @IBOutlet weak var OTPNoteLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel1 : UILabel!
    @IBOutlet weak var mobileNumberLabel2 : UILabel!
    @IBOutlet weak var otpTableView:UITableView!
    
    var strOtpNote = String()
    var userName = String()
    var ApiMobileLength = 0
    var strAlert = String()
    var StudentIDString = String()
    var strMobileNo = String()
    var strApiFrom = String()
    var strCountryCode = String()
    var arrLibraryData: NSArray = []
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    let appelegate = UIApplication.shared.delegate as! AppDelegate
    var mobileNumbers = [String]()
    
    
    var arrUserData: NSArray = []
    var arrSchoolData: NSArray = []
    var arrayChooseLogin:Array = [String]()
   
    var SelectedLoginAsIndexInt = 0
    var ParentSelectedLoginIndex = 0
    var ParentDictDetail : NSDictionary = NSDictionary()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let loginpassword = UserDefaults.standard.object(forKey:USERPASSWORD) as? String ?? ""



    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CheckOTPVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        SubmitButton.layer.cornerRadius = 5
        SubmitButton.layer.masksToBounds = true
        mobileNumbers = appelegate.otpMobileNumber.components(separatedBy: ",")
        //OTPNoteLabel.text = strOtpNote
        OTPText.textContentType = .oneTimeCode
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        callResendTimer()
        strMobileNo = UserDefaults.standard.object(forKey: USERNAME) as! String
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        OTPText.keyboardType = UIKeyboardType.numbersAndPunctuation
        callSelectedLanguage()
        print(mobileNumbers)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func dismissKeyboard()
    {
        OTPText.resignFirstResponder()
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if(textField == self.OTPText)
        {
            self.view.frame.origin.y -= 50
            
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
        
        return string == numberFiltered
        
    }
    
    @IBAction func actionSubmit(_ sender: Any)
    {
        print("SubmitAction")
        dismissKeyboard()
        
        if OTPText.text == ""
        {
            Util .showAlert("", msg: ALT_MOBILE)
        }
        else
        {
            if(Util .isNetworkConnected())
            {
                self.CheckOTPApiCalling()
            }else
            {
                Util .showAlert("", msg: INTERNET_ERROR)
            }
        }
    }
    
    func callResendTimer(){
        self.ResendOTPButton.isHidden = true
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(CheckOTPVC.enableButton), userInfo: nil, repeats: false)
    }
    
    @IBAction func actionResendOTP(_ sender: Any)
    {
        dismissKeyboard()
        callResendTimer()
        
        if(Util .isNetworkConnected())
        {
            self.CheckMobileNoINDBApiCalling()
        }else
        {
            Util .showAlert("", msg: INTERNET_ERROR)
        }
    }
    
    @objc func enableButton() {
        self.ResendOTPButton.isHidden = false
    }
    //MARK: API CALLING
    func CheckOTPApiCalling()
    { strApiFrom = "otp"
        print("CheckOTPApiCalling")

        showLoading()
        let strMobileNo : String = UserDefaults.standard.object(forKey: USERNAME) as! String
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + VALIDATE_OTP_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo ,"OTP" : OTPText.text! ,COUNTRY_CODE : strCountryCode]
        print("OTPRequest",myDict)
        print("requestString",requestString)

        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "CheckOTPBApi")
    }
    
    func CallLoginApi()
       {
           showLoading()
           strApiFrom = "login"
           let apiCall = API_call.init()
           apiCall.delegate = self;
           let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
           let requestStringer = baseUrlString! + LOGIN_METHOD
           print("requestStringer12",requestStringer)

           let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
           let strUDID : String = Util.str_deviceid()
           let myDict:NSMutableDictionary = ["MobileNumber" :strMobileNo,"Password" : loginpassword,"DeviceType" : DEVICE_TYPE,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
           print(myDict)
           let myString = Util.convertDictionary(toString: myDict)
           print("deviceTypeCheckOtp\(myString)")
           apiCall.nsurlConnectionFunction(requestString, myString, "login")
       }
    
    func CheckMobileNoINDBApiCalling() {
        strApiFrom = "mobilenoupdate"
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + CHECK_MOBILENO_UPDATE_BY_COUNTRYID
        print("requestStringer",requestStringer)
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let strUDID : String = Util.str_deviceid()
        let myDict:NSMutableDictionary = ["MobileNumber" : strMobileNo ,"DeviceType" :  DEVICE_TYPE,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
        print("myDict",myDict)
        

        
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "mobilenoupdate")
        
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        callResendTimer()
        if(csData != nil)
        {
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if let CheckedArray = csData
            {
                if(strApiFrom.isEqual("mobilenoupdate"))
                {
                    if(CheckedArray.count > 0)
                    {
                        let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        let strStatus:String =  String(describing: dict["Status"]!)
                        strAlert =  String(describing: dict["Message"]!)
                        let numberUpdate = String(describing: dict["isNumberExists"]!)
                        let passwordUpdate = String(describing: dict["isPasswordUpdated"]!)
                        let strOtp : String = String(describing: dict["redirect_to_otp"] ?? "")
                       if(strStatus == "1" || strStatus == "0"){
                           if numberUpdate == "1" && passwordUpdate == "1" {
                               print("!23")
                               print("!strOtp",strOtp)
                               if strOtp == "1"{
                                   print("2345")
//
                                   
                               }else if strOtp == "0"{
                                  print( "otploginpassword.count",loginpassword.count )
                                   if(loginpassword.count == 0 || loginpassword == nil){
                                       DispatchQueue.main.async {
                                           print("loginpasswordCount56")
                                           self.performSegue(withIdentifier: "CheckPasswordSegue", sender: self)
                                       }
                                    }
                                   else{
                                       print("CallLoginApi")
                                       CallLoginApi()

                                   }
                               }
                               
                           }else if numberUpdate == "1" && passwordUpdate == "0"{
                               self.performSegue(withIdentifier: "OTPVerifiedToUpdatePswdSegue", sender: self)
                           }
                           appDelegate.isPasswordBind = "1"
//
                        }else
                        {
                            Util.showAlert("", msg: strAlert)
                        }
                    }else
                    {
                        Util.showAlert("", msg: SERVER_ERROR)
                    }
                } else if(strApiFrom.isEqual("login")){
                    var Message = String()
                    if((csData?.count)! > 0){
                        if (csData == nil){
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "LoginVC", sender: self)
                            }
                        }else{
                            if((csData?.count)! > 0){
                                let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                                let strStatus:String =  String(describing: dicUser["Status"]!)
                                Message = String(describing: dicUser["Message"]!)
                                if(strStatus == "1"){
                                    
                                    
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
                                    
                                    ParentDictDetail = dicUser
                                    appelegate.staffRole = String(describing: dicUser["staff_role"]!)
                                    let defaults = UserDefaults.standard
                                            defaults.set(appDelegate.staffRole, forKey: DefaultsKeys.StaffRole)

                                    
                                    appelegate.staffDisplayRole = String(describing: dicUser["staff_display_role"]!)
                                    appelegate.isStaff = String(describing: dicUser["is_staff"]!)
                                    appelegate.isParent = String(describing: dicUser["is_parent"]!)
                                    if(appelegate.isStaff == "0"){
                                        UserDefaults.standard.set("Parent", forKey: LOGINASNAME)
                                        UserDefaults.standard.set("No", forKey: COMBINATION)
                                        
                                        self.LoadParentDetail()
                                    }else{
                                    if (appelegate.staffRole == "p1" && appelegate.isParent == "1"){
                                        appelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                                      UserDefaults.standard.set("GroupHead", forKey: LOGINASNAME)
                                                      self.ParentSelectedLoginIndex = 0
                                                      UserDefaults.standard.set("Yes", forKey: COMBINATION)
                                                      self.LoadParentDetail()
                                                    }
                                                    else if (appelegate.staffRole == "p2" && appelegate.isParent == "1"){
                                                        appelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                                      UserDefaults.standard.set("Principal", forKey: LOGINASNAME)
                                                      self.ParentSelectedLoginIndex = 1
                                                      UserDefaults.standard.set("Yes", forKey: COMBINATION)
                                                      self.LoadParentDetail()
                                                    }
                                                    else if (appelegate.staffRole == "p3" && appelegate.isParent == "1"){
                                                        appelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                                      UserDefaults.standard.set("Staff", forKey: LOGINASNAME)
                                                      self.ParentSelectedLoginIndex = 2
                                                      UserDefaults.standard.set("Yes", forKey: COMBINATION)
                                                      self.LoadParentDetail()
                                                    }
                                                    else if (appelegate.staffRole == "p4" && appelegate.isParent == "1"){
                                                        appelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                                      UserDefaults.standard.set("OfficeStaff", forKey: LOGINASNAME)
                                                      self.ParentSelectedLoginIndex = 3
                                                      UserDefaults.standard.set("Yes", forKey: COMBINATION)
                                                      self.LoadParentDetail()
                                                    }
                                        else if (appelegate.staffRole == "p5" && appelegate.isParent == "1"){
                                            appelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                            UserDefaults.standard.set("NonOfficeStaff", forKey: LOGINASNAME)
                                            self.ParentSelectedLoginIndex = 4
                                            UserDefaults.standard.set("Yes", forKey: COMBINATION)
                                            self.LoadParentDetail()
                                            //
                                        }

                                        else if (appelegate.staffDisplayRole == "Group Head"){
                                            appelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                            UserDefaults.standard.set("GroupHead", forKey: LOGINASNAME)
                                            UserDefaults.standard.set("No", forKey: COMBINATION)
                                            self.SelectedLoginAsIndexInt = 0
                                        }
                                        else if (appelegate.staffDisplayRole == "Principal"){
                                            
                                            appelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                            UserDefaults.standard.set("Principal", forKey: LOGINASNAME)
                                            UserDefaults.standard.set("No", forKey: COMBINATION)
                                            self.SelectedLoginAsIndexInt = 1
                                        }
                                        else if (appelegate.staffDisplayRole == "Teaching Staff"){
                                            appelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                            UserDefaults.standard.set("Staff", forKey: LOGINASNAME)
                                            UserDefaults.standard.set("No", forKey: COMBINATION)
                                            self.SelectedLoginAsIndexInt = 2
                                        }
                                    else if (appelegate.staffDisplayRole == "Office Staff"){
                                        
                                        appelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("OfficeStaff", forKey: LOGINASNAME)
                                        UserDefaults.standard.set("No", forKey: COMBINATION)
                                        self.SelectedLoginAsIndexInt = 3
                                     
                                    }
                                    else if (appelegate.staffDisplayRole == "Non Office Staff"){
                                        appelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("NonOfficeStaff", forKey: LOGINASNAME)
                                        UserDefaults.standard.set("No", forKey: COMBINATION)
                                        self.SelectedLoginAsIndexInt = 4
                                      
                                    }
                                    }
                                    let strCombination : String = UserDefaults.standard.object(forKey: COMBINATION) as! String
                                    let isParent : String = UserDefaults.standard.object(forKey: LOGINASNAME) as! String
                                    
                                    if(strCombination == "No"){
                                        if(isParent == "Parent"){
                                            DispatchQueue.main.async {
                                                self.performSegue(withIdentifier: "otpToParentSeg", sender: nil)
                                            }
                                        }else{
                                            DispatchQueue.main.async {
                                                self.performSegue(withIdentifier: "otpToTeacherSeg", sender: self)
                                            }
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            self.performSegue(withIdentifier: "otpToParentSeg", sender: nil)
                                        }
                                    }
                                   
                                }else{
                                    Util .showAlert("", msg: Message)
                                }
                            }
                        }
                    }else{
                        Util.showAlert("", msg: Message as String?)
                    }
                }
                else{
                    if(CheckedArray.count > 0)
                    {
                        let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        let strStatus:String =  String(describing: dict["Status"]!)
                        strAlert =  String(describing: dict["Message"]!)
                        if(strStatus == "1")
                        {
                            
                            
//                            MOBILE CONDITION ITHULA VARUTHU
                            
                            
//
                            
                            let numberUpdate = String(describing: appelegate.redirectOTPDict["isNumberExists"]!)
                            let passwordUpdate = String(describing: appelegate.redirectOTPDict["isPasswordUpdated"]!)
                            let strOtp : String = String(describing: appelegate.redirectOTPDict["redirect_to_otp"] ?? "")
                            print("getStrOtp",strOtp)
                               if numberUpdate == "1" && passwordUpdate == "1" {
                                   if strOtp == "1"{
//                                       CallLoginApi()
                                       
                                       print( "numberUpdatepassword.count",loginpassword.count )
                                       if(loginpassword.count == 0 || loginpassword == nil){
                                           DispatchQueue.main.async {
                                               print("loginpasswordCount12")
                                               self.performSegue(withIdentifier: "CheckPasswordSegue", sender: self)
                                           }
                                        }
                                       else{
                                           print("CallLoginApi")
                                           CallLoginApi()

                                       }
                                       
                                   }else if strOtp == "0"{
                                       
                                       if(loginpassword.count == 0 || loginpassword == nil){
                                           DispatchQueue.main.async {
                                               print("loginpasswordCount34")
                                               self.performSegue(withIdentifier: "CheckPasswordSegue", sender: self)
                                           }
                                        }
                                       else{
                                           print("CallLoginApi")
                                           CallLoginApi()

                                       }
                                   }
                                   
                               }else if numberUpdate == "1" && passwordUpdate == "0"{
                                   self.performSegue(withIdentifier: "OTPVerifiedToUpdatePswdSegue", sender: self)
                               }
                        }else
                        {
                          
                            Util.showAlert("", msg: strAlert)
                        }
                    }else
                    {
                        Util.showAlert("", msg: SERVER_ERROR)
                    }
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
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        callResendTimer()
        // print("Error")
        Util .showAlert("", msg: SERVER_CONNECTION_FAILED);
    }
    func LoadParentDetail(){
        if let ChildDetailsArray = ParentDictDetail["ChildDetails"] as? NSArray{
            if(ChildDetailsArray.count > 0){
                arrUserData = ChildDetailsArray
              //  Childrens.saveXhilsDetail(ChildDetailsArray as! [Any])
                appelegate.LoginParentDetailArray = ChildDetailsArray
               // self.updateDeviceToken()
            }else{
                Util.showAlert("", msg: "")
            }
        }else{
            Util.showAlert("", msg: "")
        }
        
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    
    //MARK: API RESPONSE
    @objc func httpClientDidSucceed(withResponse responseObject: Any!) {
        hideLoading()
        if(responseObject != nil)
        {
            UtilObj.printLogKey(printKey: "csData", printingValue: responseObject!)
            if let CheckedArray = responseObject as? NSArray
            {
                if(CheckedArray.count > 0)
                {
                    let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                    let strStatus = String(describing: dict["Status"]!)
                    if(strStatus == "1")
                    {
                        Util.showAlert("", msg: "OTP send successfully")
                        
                    }else
                    {
                        Util.showAlert("", msg: MOBILE_NOT_EXIST)
                    }
                }else
                {
                    Util.showAlert("", msg: SERVER_ERROR)
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
    
    @objc func httpClientDidFailWithError(_ error: Error!) {
        
        hideLoading()
        Util .showAlert("", msg: SERVER_CONNECTION_FAILED);
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
        OTPLabel.text = LangDict["enter_your_otp"] as? String
        OTPText.placeholder = LangDict["enter_your_otp"] as? String
        ResendOTPButton.setTitle(LangDict["resend_otp"] as? String, for: .normal)
        SubmitButton.setTitle(LangDict["btn_sign_submit"] as? String, for: .normal)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "otpToTeacherSeg")
        {
            let segueid = segue.destination as! MainVC
            segueid.ArraySchoolData = arrSchoolData
            segueid.pickerArray = arrayChooseLogin
            segueid.LoginAsIndexInt = SelectedLoginAsIndexInt
        
        }
        else if (segue.identifier == "otpToParentSeg")
        {
            let segueid = segue.destination as! ParentTableVC
            segueid.ArrayChildData = arrUserData
            segueid.SelectedLoginIndexInt = ParentSelectedLoginIndex
        }
    }
  
}

extension CheckOTPVC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OTPTablevViewCell", for: indexPath) as! OTPTablevViewCell
        cell.mobileNumberLabel.text = mobileNumbers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
    }
    
    
}
