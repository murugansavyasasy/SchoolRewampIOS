
//  ViewController.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 03/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper


extension UIViewController {
    
    func moveToLogInScreen(strFromStaff : String){
        Childrens.deleteTables()
        UserDefaults.standard.set("Yes" as NSString, forKey: LOGOUT)
        if(strFromStaff == "Staff"){
            UserDefaults.standard.set("Yes" as NSString, forKey: FIRSTTIMELOGINAS)
        }
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController!.pushViewController(loginVC, animated: true)
    }
    
    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    func showAlert(alert: String?, message: String?){
        let alert = UIAlertController(title: alert, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,Apidelegate                        ,UIWebViewDelegate,UITextFieldDelegate{
    @IBOutlet weak var myLoginTableView: UITableView!
    @IBOutlet weak var PopupChooseLogin: UIView!
    @IBOutlet weak var CountryTable: UITableView!
    @IBOutlet var ChooseCountryPopupView: UIView!
    @IBOutlet weak var TermsConditionView: UIView!
    @IBOutlet weak var myWebView: UIWebView!
    
    @IBOutlet var PopupChangePassword: UIView!
    @IBOutlet weak var ShowExistingPswdButton: UIButton!
    @IBOutlet weak var ShowNewPswdButton: UIButton!
    @IBOutlet weak var VerifyNewPasswordText: UITextField!
    @IBOutlet weak var ShowVerifyPswdButton: UIButton!
    @IBOutlet weak var ExistingPasswordText: UITextField!
    @IBOutlet weak var NewPasswordText: UITextField!
    @IBOutlet weak var EnterOTPLabel: UILabel!
    @IBOutlet weak var TitleChangePswdLabel: UILabel!
    @IBOutlet weak var NewPasswordLabel: UILabel!
    @IBOutlet weak var VerifyPasswordLabel: UILabel!
    @IBOutlet weak var UpdateButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var SignInTitleLabel: UILabel!
    var strApiFrom = NSString()
    var strAlertString = String()
    var arrayCountryDatas: NSArray = []
    var arrUserData: NSArray = []
    var dicCountryName : NSDictionary = [:]
    var popupLoginSelection : KLCPopup  = KLCPopup()
    var KlCpopupChangedPassword : KLCPopup  = KLCPopup()
    var hud : MBProgressHUD = MBProgressHUD()
    var strBaseUrl = NSString()
    var myTablestring = NSString()
    var CountrySelect = NSString()
    var SelectedCountryID = String()
    var SelectedCountryCode = String()
    var selectCountryName = String()
    var popupCountrySelection : KLCPopup  = KLCPopup()
    var strCountryCode = String()
    var strCountryID = String()
    var parentIDArray : NSArray = NSArray()
    var staffIDArray : NSArray = NSArray()
    var groupHeadIDArray : NSArray = NSArray()
    var principleIDArray : NSArray = NSArray()
    var adminIDArray : NSArray = NSArray()
    var menuIDArray : NSArray = NSArray()
    var languageDict : NSDictionary = NSDictionary()
    var SelectedNumberofCellInt = Int()
    var checkCountry = "yes"
    
    var NumberOfCollectionCell = [4,14,9,2]
    var ParentDictDetail : NSDictionary = NSDictionary()
    
    var SelectedCellIconsArray = [String]()
    var SelectedCellLabelNameArray = [String]()
    var SelectedSegueArray = [String]()
    var SelectedLoginAsIndexInt = 0
    var ParentSelectedLoginIndex = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let loginusername = UserDefaults.standard.object(forKey:USERNAME) as? String ?? ""
    let loginpassword = UserDefaults.standard.object(forKey:USERPASSWORD) as? String ?? ""
    let LogOut = UserDefaults.standard.object(forKey:LOGOUT) as? String
    var StaffId = UserDefaults.standard.object(forKey: STAFFID) as? String
    var SchoolId = UserDefaults.standard.object(forKey: SCHOOLID) as? String
    var  QuestionData : [UpdateDetailsData]! = []
    var staffRole : String!
    override func viewDidLoad(){
        super.viewDidLoad()
        checkCountry = "yes"
        let userDefaults = UserDefaults.standard
        
        
        appDelegate.isPasswordBind =
        String(describing: 1)
        print("appDelegatePASS",appDelegate.isPasswordBind)
        staffRole = userDefaults.string(forKey: DefaultsKeys.StaffRole)
        print("staffRole",staffRole)
        print("stSchoolIdaffRole",SchoolId)
        print("VIEW1")
        
        StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)
        print("DefaultsKeys.StaffID",StaffId)
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(ViewController.callNotification), name: NSNotification.Name(rawValue: "PushNotification"), object:nil)
        
        
        
        
        isAppAlreadyLaunchedOnce()
        
        
    }
    
    
    
    func isAppAlreadyLaunchedOnce() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
            defaults.set(false, forKey: "isAppAlreadyLaunchedOnce")
            print("App1234567 already launched")
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App12345 launched first time")
            return false
        }
    }
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        
        
        
        self.TermsConditionView.isHidden = true
        self.callSelectedLanguage()
        if(UserDefaults.standard.object(forKey: COUNTRY_CODE) != nil){
            strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
            strCountryID = UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
            
        }else{
            strCountryCode = ""
            strCountryID = ""
            UserDefaults.standard.set("", forKey: COUNTRY_CODE)
            UserDefaults.standard.set("", forKey: COUNTRY_ID)
            UserDefaults.standard.set(false, forKey: FORGOT_PASSWORD_CLICKED)
            UserDefaults.standard.set(true, forKey: ACCEPT_TERMS_CONDITION)
            let emptyArray = NSArray()
            UserDefaults.standard.set(emptyArray, forKey: PARENT_ARRAY_INDEX)
            UserDefaults.standard.set(emptyArray, forKey: STAFF_ARRAY_INDEX)
            UserDefaults.standard.set(emptyArray, forKey: PRINCIPLE_ARRAY_INDEX)
            UserDefaults.standard.set(emptyArray, forKey: ADMIN_ARRAY_INDEX)
            UserDefaults.standard.set(emptyArray, forKey: GROUPHEAD_ARRAY_INDEX)
            UserDefaults.standard.set(emptyArray, forKey: LANGUAGE_ARRAY)
        }
        
        let  strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        if(strLanguage == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:true);
        UserDefaults.standard.set("No" as NSString, forKey: LOGOUT)
        self.ButtonCornerDesign()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        var CityPopupString = String()
        
        if(UserDefaults.standard.object(forKey:COUNTRYFIRST) != nil )
        {
            CityPopupString = String(describing: UserDefaults.standard.object(forKey:COUNTRYFIRST)!)
        }
        
        if(UserDefaults.standard.object(forKey:VERSION14) != nil )
        {
            if(CityPopupString == "Yes")
            {
                let strFirst : String = UserDefaults.standard.object(forKey: AT_VERY_FIRST_TIME) as! String
                if(strFirst == "No")
                {
                    DispatchQueue.main.async
                    {
                        self.performSegue(withIdentifier: "CheckMobileInDBSegue", sender: self)
                    }
                }
                else{
                    if(UserDefaults.standard.bool(forKey: FORGOT_PASSWORD_CLICKED)){
                        if(Util .isNetworkConnected())
                        {
                            self.CheckResetPasswordApiCalling()
                        }else{
                            Util.showAlert("", msg: INTERNET_ERROR)
                        }
                        
                    }else{
                        
                        self.checkLogout()
                    }
                }
            }
            else{
                callCountryApi()
            }
        }else{
            callCountryApi()
        }
    }
    
    func checkLogout(){
        if(LogOut == "Yes")
        {
            DispatchQueue.main.async
            {
                self.performSegue(withIdentifier: "LoginVC", sender: self)
            }
        }
        else
        {
            if(Util .isNetworkConnected())
            {
                
                
                self.CallVersionApi()
                
            }
            else
            {
                let strParent : String = String(describing: UserDefaults.standard.object(forKey: LOGINASNAME)!)
                Constants.printLogKey("strParent", printValue: strParent)
                let strcombination : String = UserDefaults.standard.object(forKey: COMBINATION) as! String
                appDelegate.LanguageArray = UserDefaults.standard.object(forKey: LANGUAGE_ARRAY) as! NSArray
                Constants.printLogKey("arraylanguage", printValue: appDelegate.LanguageArray)
                
                if(strParent == "Parent" || strcombination == "Yes")
                {
                    arrUserData =  Childrens.getChildromDB()! as NSArray
                    
                    if(arrUserData.count > 0)
                    {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "MenuToParentSegue", sender: self)
                        }
                    }else{
                        Util .showAlert("", msg: INTERNET_ERROR)
                    }
                    Constants.printLogKey("arrUserData", printValue: arrUserData)
                    
                }else{
                    Util .showAlert("", msg: INTERNET_ERROR)
                }
            }
        }
    }
    
    func callCountryApi(){
        if(UserDefaults.standard.bool(forKey: ACCEPT_TERMS_CONDITION)){
            self.TermsConditionView.isHidden = false
            loadWebURl()
        }else{
            self.TermsConditionView.isHidden = true
            if(Util .isNetworkConnected())
            {
                strCountryCode = ""
                self.CallCountryListApi()
            }
            else
            {
                Util .showAlert("", msg: INTERNET_ERROR)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func ButtonCornerDesign()
    {
        ChooseCountryPopupView.layer.cornerRadius = 8
        ChooseCountryPopupView.layer.masksToBounds = true
        PopupChooseLogin.layer.cornerRadius = 8
        PopupChooseLogin.layer.masksToBounds = true
        PopupChangePassword.layer.cornerRadius = 8
        PopupChangePassword.layer.masksToBounds = true
        
    }
    //MARK: TABLEVIEW DELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayCountryDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 45
        }else{
            return 35
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("SelectedCountryIDSelectedCountryID",SelectedCountryID)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseCountryTVCell", for: indexPath) as! ChooseCountryTVCell
        dicCountryName = arrayCountryDatas.object(at: indexPath.row) as! NSDictionary
        cell.CountryNameLabel.text = dicCountryName["CountryName"] as? String
        print("dicCountryName",dicCountryName["BaseUrl"])
        print("MobileNumberLength",dicCountryName["MobileNumberLength"])
        let CountryID: String = String(describing: dicCountryName[COUNTRY_ID]!)
        
        if(SelectedCountryID == CountryID)
        {
            let image = UIImage(named: "RadioSelect")! as UIImage
            cell.RadioButton.setImage(image, for: UIControl.State.normal)
        }else
        {
            let image = UIImage(named: "RadioNormal")! as UIImage
            cell.RadioButton.setImage(image, for: UIControl.State.normal)
        }        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        UserDefaults.standard.set("No" as NSString, forKey:COUNTRYFIRST)
        CountrySelect = "CountrySelected"
        
        let dicCountryUrl = arrayCountryDatas.object(at: indexPath.row) as! NSDictionary
        SelectedCountryID = String(describing: dicCountryUrl[COUNTRY_ID]!)
        
        print("didselect",SelectedCountryID)
        print("didselectdicCountryUrl",dicCountryUrl)
        
        let MobilelengthStr = String(describing: dicCountryUrl["MobileNumberLength"]!)
        UserDefaults.standard.set(MobilelengthStr, forKey: MOBILE_LENGTH)
        
        strBaseUrl = dicCountryUrl["BaseUrl"] as! NSString
        assignParentStaffIDS(selectedDict: dicCountryUrl)
        
        //
        print("UserDefaultsdicCountryUrl",strBaseUrl)
        print("dicCountryUrl",dicCountryUrl)
        CountryTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        let currentCell = tableView.cellForRow(at: indexPath) as! ChooseCountryTVCell
        let image = UIImage(named: "RadioNormal")! as UIImage
        currentCell.RadioButton.setImage(image, for: UIControl.State.normal)
    }
    
    //MARK: FUNCTIONS
    func popupCountryDetail(sender : Any)
    {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            let cellSize = CGFloat(160 + (arrayCountryDatas.count * 45))
            let viewSize = self.view.frame.height - 60
            if(viewSize > cellSize){
                ChooseCountryPopupView.frame.size.height = CGFloat(cellSize)
            }else{
                ChooseCountryPopupView.frame.size.height = CGFloat(viewSize)
            }
        }else{
            let cellSize = CGFloat(150 + (arrayCountryDatas.count * 35))
            let viewSize = self.view.frame.height - 60
            if(viewSize > cellSize){
                ChooseCountryPopupView.frame.size.height = CGFloat(cellSize)
            }else{
                ChooseCountryPopupView.frame.size.height = CGFloat(viewSize)
            }
        }
        ChooseCountryPopupView.frame.size.width = self.view.frame.width - 60
        //
        //
        //        G3
        
        ChooseCountryPopupView.center = view.center
        ChooseCountryPopupView.alpha = 1
        ChooseCountryPopupView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(ChooseCountryPopupView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.ChooseCountryPopupView.transform = .identity
        })
        
        print("VewControllerPopup>?")
        
        //
    }
    func popupChooseLoginType (sender : Any)
    {
        //
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChooseLogin.frame.size.height = 350
            PopupChooseLogin.frame.size.width = 380
            
        }
        popupLoginSelection = KLCPopup(contentView: PopupChooseLogin, showType: KLCPopupShowType.none , dismissType:KLCPopupDismissType.none,maskType: KLCPopupMaskType.dimmed , dismissOnBackgroundTouch:  false , dismissOnContentTouch: false )
        popupLoginSelection.show()
    }
    func callNormalFlow ()
    {
        let CityPopupString = UserDefaults.standard.object(forKey:COUNTRYFIRST) as? String
        if(CityPopupString == "Yes")
        {
            let strFirst : String = UserDefaults.standard.object(forKey: AT_VERY_FIRST_TIME) as! String
            if(strFirst == "No")
            {
                DispatchQueue.main.async
                {
                    self.performSegue(withIdentifier: "CheckMobileInDBSegue", sender: self)
                }
            }
            
            else{
                if(LogOut == "Yes")
                {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "LoginVC", sender: self)
                    }
                }
                else
                {
                    if(loginusername == nil || loginusername.count == 0 && loginpassword == nil || loginpassword.count == 0 )
                    {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "LoginVC", sender: self)
                        }
                    }else{
                        if(Util .isNetworkConnected())
                        {
                            CallLoginApi()
                        }
                        else{
                            Util .showAlert("", msg: NETWORK_ERROR)
                        }
                    }
                    
                }
            }
        }
    }
    
    func checkNormatFlow()
    {
        if(checkCountry == "yes")
        {
            self.callNormalFlow()
        }
        else
        {
            let strFirst : String = UserDefaults.standard.object(forKey: AT_VERY_FIRST_TIME) as! String
            if(strFirst == "No")
            {
                DispatchQueue.main.async
                {
                    self.performSegue(withIdentifier: "CheckMobileInDBSegue", sender: self)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LoginVC", sender: self)
                }
            }
        }
    }
    
    func callAppStore ()
    {
        UserDefaults.standard.set(true, forKey: ACCEPT_TERMS_CONDITION)
        UserDefaults.standard.set("No" as NSString, forKey: COUNTRYFIRST)
        UIApplication.shared.openURL(NSURL(string: LIVE_ITUNES)! as URL)
    }
    //MARK: Webview delegate
    
    func loadWebURl(){
        showLoading()

        let url = URL(string: TERMS_AND_CONDITION)
        print("urlurlurl",url)
        myWebView.loadRequest(URLRequest(url: url!))
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideLoading()
    }
    
    //MARK: BUTTON ACTION
    
    @IBAction func actionAgreeTermsandCondition(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: ACCEPT_TERMS_CONDITION)
        self.TermsConditionView.isHidden = true
        if(Util .isNetworkConnected())
        {
            self.CallTermsandConditionApi()
            
        }else
        {
            Util.showAlert("", msg: INTERNET_ERROR)
        }
        
    }
    
    @IBAction func actionOkLoginAS(_ sender: Any)
    {
        
        
        let ChooseLoginAs = UserDefaults.standard.object(forKey:FIRSTTIMELOGINAS) as? String
        if(ChooseLoginAs == "Yes")
        {   UserDefaults.standard.set("No" as NSString, forKey: FIRSTTIMELOGINAS)
            popupLoginSelection.dismiss(true)
            self.performSegue(withIdentifier: "DirectToMainViewSegue", sender: self)
        }
        else
        {
            Util.showAlert("", msg: "Choose LoginAs Name")
        }
    }
    
    @IBAction func actionCancelLoginAs(_ sender: Any)
    {
        UserDefaults.standard.set("No" as NSString, forKey: COUNTRYFIRST)
        exit(0)
    }
    
    @IBAction func actionCancelCountrySelection(_ sender: Any)
    {
        ChooseCountryPopupView.alpha = 0
        UserDefaults.standard.set("No" as NSString, forKey:COUNTRYFIRST)
        exit(0)
    }
    
    @IBAction func actionOkCountrySelection(_ sender: Any)
    {
        
        print("actionOkCountrySelection")
        UserDefaults.standard.set("Yes" as NSString, forKey:COUNTRYFIRST)
        UserDefaults.standard.set("2.6" as NSString, forKey:VERSION14)
        UserDefaults.standard.set(SelectedCountryID, forKey: COUNTRY_ID)
        UserDefaults.standard.set(SelectedCountryID, forKey: COUNTRY_CODE)
        
        UserDefaults.standard.set(selectCountryName, forKey: COUNTRY_Name)
        UserDefaults.standard.set(parentIDArray, forKey: PARENT_ARRAY_INDEX)
        UserDefaults.standard.set(staffIDArray, forKey: STAFF_ARRAY_INDEX)
        UserDefaults.standard.set(principleIDArray, forKey: PRINCIPLE_ARRAY_INDEX)
        UserDefaults.standard.set(adminIDArray, forKey: ADMIN_ARRAY_INDEX)
        UserDefaults.standard.set(groupHeadIDArray, forKey: GROUPHEAD_ARRAY_INDEX)
        UserDefaults.standard.set(menuIDArray, forKey: MENU_ARRAY_INDEX)
        
        if(CountrySelect == "CountrySelected")
        {
            checkCountry = "No"
            UserDefaults.standard.set(strBaseUrl as NSString, forKey:BASEURL)
            UserDefaults.standard.set(strBaseUrl as NSString, forKey:PARENTBASEURL)
            UserDefaults.standard.set(strBaseUrl as NSString, forKey: OLD_BASE_URL)
            popupCountrySelection.dismiss(true)
            ChooseCountryPopupView.alpha = 0
            if(Util .isNetworkConnected())
            {
                self.CallVersionApi()
            }
            else
            {
                Util .showAlert("", msg: INTERNET_ERROR)
            }
        }
        else
        {
            Util.showAlert("", msg: CHOOSE_COUNTRY_ALERT)
        }
    }
    //MARK: API REQUEST DELEGATE
    
    func CallLoginApi()
    {
        strApiFrom = "login"
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + LOGIN_METHOD
        print("requestStringer44",requestStringer)
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let strUDID : String = Util.str_deviceid()
        let myDict:NSMutableDictionary = ["MobileNumber" : loginusername,"Password" : loginpassword,"DeviceType" : DEVICE_TYPE,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
        print(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        print("deviceTypeViewController\(myString)")
        print("CallLoginApi34")
        
        apiCall.nsurlConnectionFunction(requestString, myString, "login")
    }
    
    func CallCountryListApi()
    {
        //()
        strApiFrom = "CountryList"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let requestStringer = LIVE_COUNTRY_LIST
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myCountryDict:NSMutableDictionary = ["AppID":"3",COUNTRY_CODE : strCountryCode]
        print("my country Dictionary data : \(requestStringer)")
        let myString = Util.convertDictionary(toString: myCountryDict)
        print("myd",myCountryDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "CountryList")
    }
    
    func CallVersionApi()
    {
        strApiFrom = "version"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer =  baseUrlString! + CHECK_UPDATE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["VersionCode": VERSION_VALUE, "AppID" : "3","DeviceType" : DEVICE_TYPE,COUNTRY_CODE : SelectedCountryCode,COUNTRY_ID : SelectedCountryID]
        let myString = Util.convertDictionary(toString: myDict)
        print(requestStringer)
        print("str",myString)
        apiCall.nsurlConnectionFunction(requestString, myString, "version")
    }
    
    func CallManageParentApi()
    {
        strApiFrom = "Parentlogin"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + PARENT_LOGIN_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let strUDID : String = Util.str_deviceid()
        let myDict:NSMutableDictionary = ["MobileNumber" : loginusername,"Password" : loginpassword,"DeviceType" : DEVICE_TYPE,COUNTRY_CODE : strCountryCode,"SecureID" : strUDID]
        print(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        print("CallManageParentApi")
        apiCall.nsurlConnectionFunction(requestString, myString, "Parentlogin")
    }
    
    func CheckResetPasswordApiCalling() {
        strApiFrom = "ResetPassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + PASSWORD_RESET_STATUS
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + PASSWORD_RESET_STATUS
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : loginusername,COUNTRY_CODE : strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        Constants.printLogKey("ResetPassword", printValue: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ResetPassword")
    }
    
    func CallTermsandConditionApi(){
        strApiFrom = "TermsCondition"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let requestStringer = ACCEPT_TERMS_AND_CONDITION
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let strUDID : String = Util.str_deviceid()
        print("strUDID",strUDID)
        let myDict:NSMutableDictionary = ["SecureID" : strUDID,"OtherDetails" : DEVICE_TYPE,"isAgreed" : "1"]
        let myString = Util.convertDictionary(toString: myDict)
        print("dictterms",myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "TermsCondition")
    }
    
    func CallChangeForgotPasswordApi() {
        showLoading()
        strApiFrom = "ChangePassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + RESET_FORGOT_PASSWORD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : loginusername, "NewPassword": NewPasswordText.text!,"OTP" : ExistingPasswordText.text! ,COUNTRY_CODE : strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "ChangePassword")
    }
    func CallDeviceTokenApi() {
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
        let myDict:NSMutableDictionary = ["MobileNumber" : loginusername,"DeviceToken": deviceToken,"DeviceType": DEVICE_TYPE ,COUNTRY_CODE : strCountryCode]
        Constants.printLogKey("Device myDict", printValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "deviceToken")
    }
    //MARK: API RESPONSE DELEGATE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {        
        Constants.printLogKey("csData", printValue: csData)
        print("csd",csData)
        if(csData != nil)
        {
            if(strApiFrom.isEqual(to: "CountryList"))
            {
                // print("cs data .....\(csData)")
                if((csData?.count)! > 0)
                {
                    guard let responseArray = csData else {
                        return
                    }
                    if(responseArray.count > 0)
                    {
                        CountrySelect = "CountrySelected"
                        arrayCountryDatas = responseArray
                        let dict = arrayCountryDatas[0] as! NSDictionary
                        SelectedCountryID = String(describing: dict[COUNTRY_ID]!)
                        selectCountryName = String(describing: dict[COUNTRY_Name]!)
                        let MobilelengthStr = String(describing: dict["MobileNumberLength"]!)
                        UserDefaults.standard.set(MobilelengthStr, forKey: MOBILE_LENGTH)
                        strBaseUrl = dict["BaseUrl"] as! NSString
                        //Get Parent and Staff Ids
                        assignParentStaffIDS(selectedDict: dict)
                        CountryTable.reloadData()
                        popupCountryDetail(sender: self);
                    }else{
                        Util.showAlert("", msg: "No data found")
                    }
                }
                else
                {
                    Util.showAlert("", msg: "No data found")
                }
            } else if(strApiFrom.isEqual(to: "ResetPassword"))
            {
                if((csData?.count)! > 0)
                {
                    let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    let Status = dicUser["Status"] as? String
                    let Message = dicUser["Message"] as? String
                    strAlertString = Message!
                    UserDefaults.standard.set(false, forKey: FORGOT_PASSWORD_CLICKED)
                    if(Status == "1"){
                        self.ChangePasswordPopup(sender: self)
                        
                    }else{
                        self.checkLogout()
                        
                    }
                }else{
                    Util.showAlert("", msg: SERVER_ERROR)
                }
            } else if(strApiFrom.isEqual(to: "ChangePassword"))
            {
                KlCpopupChangedPassword.dismiss(true)
                if((csData?.count)! > 0)
                {
                    let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    let Status = dicUser["Status"] as? String
                    let Message = dicUser["Message"] as? String
                    strAlertString = Message!
                    if(Status == "1"){
                        
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "LoginVC", sender: self)
                        }
                        
                    }else{
                        Util.showAlert("", msg: strAlertString)
                        
                    }
                }else{
                    Util.showAlert("", msg: SERVER_ERROR)
                }
            }else if(strApiFrom.isEqual(to: "TermsCondition")){
                callCountryApi()
            }else if(strApiFrom.isEqual(to: "Parentlogin"))
            {
                var ResponseData = NSDictionary()
                if let CheckedArray = csData as? NSArray
                {
                    if(CheckedArray.count > 0){
                        ResponseData = CheckedArray[0] as! NSDictionary
                        let AlertString =  String(describing: ResponseData["Message"]!)
                        let Status = String(describing: ResponseData["Status"]!)
                        if(Status == "1")
                        {
                            if let ChildDetailsArray = ResponseData["ChildDetails"] as? NSArray
                            {
                                
                                arrUserData = ChildDetailsArray
                                
                                appDelegate.LoginParentDetailArray = ChildDetailsArray
                                
                                print("arrUserData",arrUserData)
                                
                                print("arrUserDatacount",arrUserData.count)
                                //
                                
                                
                                Childrens.saveXhilsDetail(ChildDetailsArray as! [Any])
                                
                                
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "MenuToParentSegue", sender: self)
                                }
                            }
                            else{
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "LoginVC", sender: self)
                                }
                            }
                        }
                        
                        else{
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "LoginVC", sender: self)
                            }
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "LoginVC", sender: self)
                        }
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "LoginVC", sender: self)
                    }
                }
            } else if(strApiFrom.isEqual(to: "deviceToken")){
                
            }
            
            else if(strApiFrom.isEqual(to: "version"))
            {
                
                if((csData?.count)! > 0)
                {
                    let dict : NSDictionary = csData?.object(at: 0) as! NSDictionary
                    if(dict["UpdateAvailable"] != nil){
                        
                        //                        CallDeviceTokenApi()
                        
                        if let arrayLan = dict[LANGUAGES] as? NSArray{
                            let arraylanguage : NSArray = dict[LANGUAGES] as! NSArray
                            appDelegate.LanguageArray = arraylanguage
                            appDelegate.strOfferLink = dict["Offerslink"] as? String ?? ""
                            appDelegate.strProductLink = dict["NewProductLink"] as? String ?? ""
                            appDelegate.strProfileLink = dict["ProfileLink"] as? String ?? ""
                            appDelegate.strProfileTitle = dict["ProfileTitle"] as? String ?? ""
                            appDelegate.strUploadPhotoTitle = dict["UploadProfileTitle"] as? String ?? ""
                            appDelegate.Helplineurl = dict["helplineURL"] as? String ?? ""
                            appDelegate.FeePaymentGateway = dict["FeePaymentGateway"] as? String ?? ""
                            
                            Constants.printLogKey("arraylanguage", printValue: arraylanguage)
                            UserDefaults.standard.set(arraylanguage, forKey: LANGUAGE_ARRAY)
                        }
                        let updateAvail = String(describing: dict.object(forKey: "UpdateAvailable")!)
                        let forceUpdate = String(describing: dict.object(forKey: "ForceUpdate")!)
                        let isAlertAvailable = String(describing: dict.object(forKey: "isAlertAvailable")!)
                        let strAlertContent = String(describing: dict.object(forKey: "AlertContent")!)
                        let strAlerttitle = String(describing: dict.object(forKey: "AlertTitle")!)
                        
                        let newLinkReportBaseUrl : String = dict[NEWLINKREPORTBASEURL] as? String ?? ""
                        UserDefaults.standard.set(newLinkReportBaseUrl, forKey:NEWLINKREPORTBASEURL)
                        
                        
                        let VideoJson = String(describing: dict.object(forKey: VIDEOJSON)!)
                        let VideoSizeLimit = String(describing: dict.object(forKey: VIDEOSIZELIMIT)!)
                        let VideoSizeLimitAlert = String(describing: dict.object(forKey: VIDEOSIZELIMITALERT)!)
                        let AdTimerInterval = String(describing: dict.object(forKey: ADTIMERINTERVAL)!)
                        
                        appDelegate.VimeoToken = VideoJson
                        appDelegate.videoSize = VideoSizeLimit
                        appDelegate.videoSizeAlert = VideoSizeLimitAlert
                        appDelegate.AdTimerInterval = AdTimerInterval
                        
                        
                        UserDefaults.standard.set(VideoJson, forKey: VIDEOJSON)
                        UserDefaults.standard.set(VideoSizeLimit, forKey: VIDEOSIZELIMIT)
                        UserDefaults.standard.set(VideoSizeLimitAlert, forKey: VIDEOSIZELIMITALERT)
                        UserDefaults.standard.set(AdTimerInterval, forKey: ADTIMERINTERVAL)
                        print("isAlertAvailableisAlertAvailable",isAlertAvailable)
                        
                        if(isAlertAvailable == "1"){
                            // Util.showAlert("", msg: strAlertContent)
                            
                            let alert = UIAlertController(title: strAlerttitle, message: strAlertContent, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
                                if(updateAvail .isEqual("1") && forceUpdate .isEqual("0"))
                                {
                                    let alert = UIAlertController(title: UPDATE_TITLE, message: UPDATE_AVAIL_MESSAGE, preferredStyle: UIAlertController.Style.alert)
                                    alert.addAction(UIAlertAction(title: "Not Now", style: UIAlertAction.Style.default, handler: { action in self.callNormalFlow()}))
                                    alert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default, handler: { action in self.callAppStore()}))
                                    
                                    DispatchQueue.main.async{
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                                else if(forceUpdate .isEqual("1") )
                                {
                                    let alert = UIAlertController(title: UPDATE_TITLE, message: FORCE_UPDATE_AVAIL_MESSAGE , preferredStyle: UIAlertController.Style.alert)
                                    
                                    alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { action in self.callAppStore()}))
                                    
                                    DispatchQueue.main.async
                                    {
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                                else
                                {
                                    self.checkNormatFlow()
                                }
                                
                            }))
                            DispatchQueue.main.async
                            {
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }else{
                            if(updateAvail .isEqual("1") && forceUpdate .isEqual("0"))
                            {
                                let alert = UIAlertController(title: UPDATE_TITLE, message: UPDATE_AVAIL_MESSAGE, preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Not Now", style: UIAlertAction.Style.default, handler: { action in self.callNormalFlow()}))
                                alert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default, handler: { action in self.callAppStore()}))
                                
                                DispatchQueue.main.async{
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            else if(forceUpdate .isEqual("1") )
                            {
                                let alert = UIAlertController(title: UPDATE_TITLE, message: FORCE_UPDATE_AVAIL_MESSAGE , preferredStyle: UIAlertController.Style.alert)
                                
                                alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { action in self.callAppStore()}))
                                
                                DispatchQueue.main.async
                                {
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            else
                            {
                                self.checkNormatFlow()
                            }
                        }
                        
                        
                    }
                    else
                    {
                        self.checkNormatFlow()
                    }
                }
                else
                {
                    self.checkNormatFlow()
                }
            }
            else
            {
                if (csData == nil)
                {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "LoginVC", sender: self)
                    }
                }
                else
                {
                    if((csData?.count)! > 0)
                    {
                        let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                        let Status = dicUser["Status"] as? String
                        let Message = dicUser["Message"] as? String
                        strAlertString = Message!
                        if(dicUser["Status"] != nil){
                            if(Status == "1")
                            {
                                CallDeviceTokenApi()
                                ParentDictDetail = dicUser
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
                                
                                //
                                
                                appDelegate.staffRole = String(describing: dicUser["staff_role"]!)
                                appDelegate.staffDisplayRole = String(describing: dicUser["staff_display_role"]!)
                                print("appDelegate.staffDisplayRoleappDelegate.staffDisplayRole",appDelegate.staffDisplayRole)
                                var staffDisplayRole : String!
                                staffDisplayRole = String(describing: dicUser["staff_display_role"]!)
                                print("staffDisplayRolestaffDisplayRole", staffDisplayRole)
                                let defaults = UserDefaults.standard
                                defaults.set(appDelegate.staffRole, forKey: DefaultsKeys.StaffRole)
                                //
                                
                                defaults.set(staffDisplayRole as String, forKey: DefaultsKeys.getgroupHeadRole)
                                print("DefaultsKeys.DefaultsKeys.StaffRole", DefaultsKeys.StaffRole)
                                print("DefaultsKeys.getgroupHeadRole", DefaultsKeys.getgroupHeadRole)
                                
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
                                        self.LoadParentDetail()
                                        
                                    }
                                    else if (appDelegate.staffRole == "p2" && appDelegate.isParent == "1"){
                                        
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("Principal", forKey: LOGINASNAME)
                                        self.ParentSelectedLoginIndex = 1
                                        self.LoadParentDetail()
                                    }
                                    else if (appDelegate.staffRole == "p3" && appDelegate.isParent == "1"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("Staff", forKey: LOGINASNAME)
                                        self.ParentSelectedLoginIndex = 2
                                        self.LoadParentDetail()
                                    }
                                    else if (appDelegate.staffRole == "p4" && appDelegate.isParent == "1"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("OfficeStaff", forKey: LOGINASNAME)
                                        self.ParentSelectedLoginIndex = 3
                                        self.LoadParentDetail()
                                    }
                                    else if (appDelegate.staffRole == "p5" && appDelegate.isParent == "1"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("NonOfficeStaff", forKey: LOGINASNAME)
                                        self.ParentSelectedLoginIndex = 4
                                        self.LoadParentDetail()
                                    }
                                    
                                    else if (appDelegate.staffDisplayRole == "Group head"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("GroupHead", forKey: LOGINASNAME)
                                        self.SelectedLoginAsIndexInt = 0
                                        self.performSegue(withIdentifier: "DirectToMainViewSegue", sender: self)
                                    }
                                    else if (appDelegate.staffDisplayRole == "Principal"){
                                        
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("Principal", forKey: LOGINASNAME)
                                        self.SelectedLoginAsIndexInt = 1
                                        self.performSegue(withIdentifier: "DirectToMainViewSegue", sender: self)
                                    }
                                    else if (appDelegate.staffDisplayRole == "Teaching Staff"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("Staff", forKey: LOGINASNAME)
                                        self.SelectedLoginAsIndexInt = 2
                                        self.performSegue(withIdentifier: "DirectToMainViewSegue", sender: self)
                                    }
                                    else if (appDelegate.staffDisplayRole == "Office Staff"){
                                        
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        UserDefaults.standard.set("OfficeStaff", forKey: LOGINASNAME)
                                        self.SelectedLoginAsIndexInt = 3
                                        self.performSegue(withIdentifier: "DirectToMainViewSegue", sender: self)
                                        
                                    }
                                    else if (appDelegate.staffDisplayRole == "Non Office Staff"){
                                        appDelegate.LoginSchoolDetailArray = (dicUser["StaffDetails"] as? NSArray)!
                                        self.SelectedLoginAsIndexInt = 4
                                        UserDefaults.standard.set("NonOfficeStaff", forKey: LOGINASNAME)
                                        self.performSegue(withIdentifier: "DirectToMainViewSegue", sender: self)
                                    }
                                }
                                
                                
                            }
                            else if(Status == "RESET")
                            {
                                self.performSegue(withIdentifier: "LoginVC", sender: self)
                            }
                            else
                            {
                                Util .showAlert("", msg: Message)
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "LoginVC", sender: self)
                                }
                            }
                        }else{
                        }
                    }
                }
            }
        }else
        {
            if(strApiFrom.isEqual(to: "CountryList"))
            {
                if(csData == nil)
                {
                    let alertController = UIAlertController(title: "Alert", message: SERVER_ERROR, preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in
                        exit(0)
                    }
                    alertController.addAction(yesAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LoginVC", sender: self)
                }
                Util.showAlert("", msg: SERVER_ERROR)
            }
        }
    }
    @objc func failedresponse(_ pagename: Error!) {
        
        Util .showAlert("", msg: SERVER_CONNECTION_FAILED);
        if(strApiFrom.isEqual(to: "login"))
        {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "LoginVC", sender: self)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        print("THISvc")
        print("segue.identifier",segue.identifier)
        if (segue.identifier == "DirectToMainViewSegue")
        {
            let segueid = segue.destination as! MainVC
            segueid.LoginAsIndexInt = SelectedLoginAsIndexInt
            print("QuestionData123456",QuestionData.count)
            segueid.QuestionData = QuestionData
            
        }
        else if (segue.identifier == "MenuToParentSegue")
        {
            let segueid = segue.destination as! ParentTableVC
            segueid.ArrayChildData = arrUserData
            segueid.SelectedLoginIndexInt = ParentSelectedLoginIndex
        }
    }                                                                                                                                                                                                                                                                                                                           
    func assignParentStaffIDS(selectedDict : NSDictionary){
        SelectedCountryCode = String(describing: selectedDict[COUNTRY_CODE]!)
        
        
        
        let strMenuID  : String = String(describing: selectedDict[IS_MENU_ID] ?? "")
        menuIDArray = strMenuID.components(separatedBy: ",") as NSArray
        Constants.printLogKey("menuIDArray", printValue: menuIDArray)
        
    }
    
    
    
    func LoadParentDetail()
    {
        if let ChildDetailsArray = ParentDictDetail["ChildDetails"] as? NSArray
        {
            if(ChildDetailsArray.count > 0)
            {
                print("ChildDetailsArray data .....\(ChildDetailsArray)")
                appDelegate.LoginParentDetailArray = ChildDetailsArray
                arrUserData = ChildDetailsArray
                
                DispatchQueue.main.async {
                    
                    self.performSegue(withIdentifier: "MenuToParentSegue", sender: self)
                }
            }else{
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LoginVC", sender: self)
                }
            }
        }
        else{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "LoginVC", sender: self)
            }
        }
    }
    
    @objc func callNotification(notification:Notification) -> Void {
    }
    
    func showCustomNotificationVC()
    {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FullPopupVC") as? FullPopupVC {
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            if let pctrl = navController.presentationController {
                pctrl.delegate = (self as! UIAdaptivePresentationControllerDelegate)
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
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
        
        return true
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
        KlCpopupChangedPassword.dismiss(true)
        UserDefaults.standard.set("Yes" as NSString, forKey: LOGOUT)
        
        exit(0)
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
    
    @IBAction func actionGoToSign(_ sender: Any) {
        KlCpopupChangedPassword.dismiss(true)
        self.performSegue(withIdentifier: "LoginVC", sender: self)
    }
    
    func ChangePasswordPopup(sender : Any) {
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            PopupChangePassword.frame.size.height = 520
            PopupChangePassword.frame.size.width = 500
        }
        
        if((UserDefaults.standard.object(forKey: FORGOT_PASSWORD_DICT)) != nil){
            let attributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            let attributedText = NSAttributedString(string: UserDefaults.standard.object(forKey: FORGOT_PASSWORD_DICT) as! String , attributes: attributes)
            SignInTitleLabel.attributedText = attributedText
            
        }else{
            SignInTitleLabel.text = ""
        }
        KlCpopupChangedPassword = KLCPopup(contentView: PopupChangePassword, showType: KLCPopupShowType.none , dismissType:KLCPopupDismissType.none,maskType: KLCPopupMaskType.dimmed , dismissOnBackgroundTouch:  false , dismissOnContentTouch: false )
        KlCpopupChangedPassword.show()
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
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        var strLanguage : String = String()
        if(UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) != nil){
            strLanguage  = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        }else{
            strLanguage = "en"
            UserDefaults.standard.set("en", forKey: SELECTED_LANGUAGE)
        }
        
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
            PopupChangePassword.semanticContentAttribute = .forceLeftToRight
        }else{
            self.view.semanticContentAttribute = .forceLeftToRight
            PopupChangePassword.semanticContentAttribute = .forceLeftToRight
        }
        
        EnterOTPLabel.text = LangDict["enter_your_otp"] as? String
        NewPasswordLabel.text = LangDict["teacher_pop_password_txt_new"] as? String
        VerifyPasswordLabel.text = LangDict["teacher_pop_password_txt_repeat"] as? String
        TitleChangePswdLabel.text = LangDict["reset_password"] as? String
        CancelButton.setTitle(LangDict["teacher_pop_password_btnCancel"] as? String, for: .normal)
        UpdateButton.setTitle(LangDict["teacher_pop_password_btnUpdate"] as? String, for: .normal)
        
    }
    
    
    
    
    
    
    
}


