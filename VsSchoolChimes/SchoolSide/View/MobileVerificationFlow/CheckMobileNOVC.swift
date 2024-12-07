//
//  CheckMobileNOVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 16/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit


class CheckMobileNOVC: UIViewController,UITextFieldDelegate,Apidelegate{
    @IBOutlet weak var UserMobileNoText: UITextField!
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var FloatMobileLabel: UILabel!
    @IBOutlet weak var MobileView: UIView!
    
    var userName = String()
    var ApiMobileLength = 0
    var strAlert = String()
    var strApiFrom = String()
    var strOTPValue = String()
    var StudentIDString = String()
    var strCountryCode = String()
    var arrLibraryData: NSArray = []
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strCountryID = String()
    var strOtpNote = String()
    var strSomething = String()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CheckMobileNOVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let MobileLenghtStr : String = UserDefaults.standard.object(forKey: MOBILE_LENGTH) as! String
        ApiMobileLength = Int(MobileLenghtStr)! + 1
        
        UserMobileNoText.placeholder = "Enter " + MobileLenghtStr + " Digit Mobile Number"
        UtilObj.printLogKey(printKey: "MobileLenghtStr", printingValue: MobileLenghtStr)
        UtilObj.printLogKey(printKey: "ApiMobileLength", printingValue: ApiMobileLength)
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        UserMobileNoText.keyboardType = UIKeyboardType.numbersAndPunctuation
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        strCountryID = UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        self.BottonCornerDesign()
        self.callSelectedLanguage()
    }
    
    func BottonCornerDesign(){
        FloatMobileLabel.layer.cornerRadius = 2
        FloatMobileLabel.layer.masksToBounds = true
        FloatMobileLabel.backgroundColor = UtilObj.ORANGE_COLOR
        MobileView.layer.cornerRadius = 5
        MobileView.layer.borderWidth = 1
        MobileView.layer.borderColor = UtilObj.ORANGE_COLOR.cgColor
        MobileView.layer.masksToBounds = true
        NextButton.layer.cornerRadius = 5
        NextButton.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard(){
        UserMobileNoText.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        if(textField == self.UserMobileNoText){
            self.view.frame.origin.y -= 50
        }else{
            self.view.frame.origin.y = 0
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool{
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
        if(textField == UserMobileNoText){
            if(newLength == ApiMobileLength){
                textField.resignFirstResponder()
            }
        }
        return string == numberFiltered
    }
    
    @IBAction func actionNext(_ sender: Any){
        dismissKeyboard()
        userName = UserMobileNoText.text!
        
        if UserMobileNoText.text == ""{
            Util .showAlert("", msg: ALT_MOBILE)
        }else if(userName.count < ApiMobileLength - 1){
            Util.showAlert("", msg: ALT_VALID_MOBILE)
            
        }else{
            if(Util .isNetworkConnected()){
                self.CheckMobileNoINDBApiCalling()
            }else{
                Util .showAlert("", msg: INTERNET_ERROR)
            }
        }
    }
    
    //MARK: API CALLING
    func CheckMobileNoINDBApiCalling() {
        showLoading()
        strApiFrom = "otp"
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + CHECK_MOBILENO_UPDATE_BY_COUNTRYID
        
        print("CheckMobileNOVCrequestStringer",requestStringer)
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let strUDID : String = Util.str_deviceid()
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNoText.text!,"DeviceType" :  DEVICE_TYPE,COUNTRY_ID : strCountryID,"SecureID" : strUDID]
        print("CheckMobileNOVC",myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "otp")
        
    }
    
    
    //MARK: API RESPONSE DELEGATE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        hideLoading()
        
        if(csData != nil){
            var Message = String()
            var Status = String()
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if let CheckedArray = csData as? NSArray{
                if(CheckedArray.count > 0){
                    let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                    let strStatus = String(describing: dict["Status"]!)
                    strOtpNote = String(describing: dict["Message"]!)
                 
                   if(strStatus == "1") {
                    
                    let numberUpdate = String(describing: dict["isNumberExists"]!)
                    let passwordUpdate = String(describing: dict["isPasswordUpdated"]!)
                    let strOtp : String = String(describing: dict["redirect_to_otp"] ?? "")
                    appDelegate.redirectOTPDict = dict
                       print("desappDeledBind",appDelegate.isPasswordBind)
                       
                       var passwordGet = "1"
                       appDelegate.isPasswordBind = passwordGet
                       
                       print("desappDelegateisPasswordBind",appDelegate.isPasswordBind)
                       print("describing: dict[isNewVersion]")
//                
                    if(strStatus == "1" || strStatus == "0"){
                        UserDefaults.standard.set(UserMobileNoText.text! as NSString, forKey: USERNAME)
                        
                        if numberUpdate == "1" && passwordUpdate == "1" {
                            if strOtp == "1"{
                                print("strOtp == 1")
                                self.performSegue(withIdentifier: "CheckOTPSegue", sender: self)
                            }else if strOtp == "0"{
                                print("strOtp == 0")
                                self.performSegue(withIdentifier: "CheckPasswordSegue", sender: self)
                            }else{
                                self.performSegue(withIdentifier: "CheckPasswordSegue", sender: self)
                            }
                        }else if numberUpdate == "1" && passwordUpdate == "0"{
                            self.performSegue(withIdentifier: "CheckOTPSegue", sender: self)
                        }

                        
//                       
                    }else{
                        Util.showAlert("", msg: MOBILE_NOT_EXIST)
                    }
                }
                    else{
                        Util.showAlert("", msg: strOtpNote)
                    }
                
            }
                
                else{
                    Util.showAlert("", msg: SERVER_ERROR)
                }
            }else{
                Util.showAlert("", msg: SERVER_ERROR)
            }
        }else{
            Util.showAlert("", msg: SERVER_ERROR)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "CheckOTPSegue"){
            let segueid = segue.destination as! CheckOTPVC
            segueid.strOtpNote = strOtpNote
            
 
            
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
        let MobileLenghtStr : String = UserDefaults.standard.object(forKey: MOBILE_LENGTH) as! String
       
        
        FloatMobileLabel.text = MobileLenghtStr + " Digit"  + " Mobile Number"
        //        UserMobileNoText.placeholder = LangDict["hint_mobile"] as? String
        NextButton.setTitle(LangDict["teacher_txt_next"] as? String, for: .normal)
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
    }
    
}
