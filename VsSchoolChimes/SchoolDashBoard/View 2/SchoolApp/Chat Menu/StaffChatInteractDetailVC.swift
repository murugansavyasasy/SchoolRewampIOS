//
//  StaffChatInteractDetailVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 12/06/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffChatInteractDetailVC: UIViewController ,UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate,Apidelegate{
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var BottomViewHeight: NSLayoutConstraint!
    
    let UtilObj = UtilClass()
    var strCountryCode = String()
    var SchoolId  = String()
    var StaffId  = String()
    var selectedSchoolDictionary = NSDictionary()
    var selectedChatDict = NSDictionary()
    var stdSubjectArray = NSMutableArray()
    var languageDictionary = NSDictionary()
    var SchoolDetailDict = NSDictionary()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var hud : MBProgressHUD = MBProgressHUD()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Teacher Login"
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.myTableView.backgroundColor = UIColor.clear
        let loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        if(loginAsName == "Principal")
        {
            let userDefaults = UserDefaults.standard
            BottomView.isHidden = true
            BottomViewHeight.constant = 0
            print("SchoolDetailDic12",SchoolDetailDict)
            print("SchoolDetailDict[SchoolID]",SchoolDetailDict["SchoolID"])
            print("SchoolDetailDict[StaffID]",SchoolDetailDict["StaffID"])

            if(SchoolDetailDict["SchoolID"] != nil){
                SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            }else{
                SchoolId =  userDefaults.string(forKey: DefaultsKeys.SchoolD)!
            }
            if(SchoolDetailDict["StaffID"] != nil){
                StaffId = String(describing: SchoolDetailDict["StaffID"]!)
            }else{
                StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
            }

            
        }else{
            BottomView.isHidden = true
            if(UIDevice.current.userInterfaceIdiom == .pad){
                BottomViewHeight.constant = 0
            }else{
                BottomViewHeight.constant = 0
            }
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }

        print("StaffIDD",StaffId)
        print("SchoolIdDD",SchoolId)
        print("loginAsName",loginAsName)

        callSelectedLanguage()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StaffChatInteractDetailVC.UpdateLogoutSelection), name: NSNotification.Name(rawValue: "SettingNotification"), object:nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - TableView delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stdSubjectArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 90
        }else{
            return 60
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageTVCell", for: indexPath) as! TextMessageTVCell
        cell.backgroundColor = UIColor.clear
        let Dict = stdSubjectArray[indexPath.row] as! NSDictionary
        cell.SchoolNameLbl.text = String(describing: Dict["Standard"]!) + "-" +  String(describing: Dict["Section"]!) + " " +  String(describing: Dict["SubjectName"]!)

        let getUnreadCount = Dict["unread_count"] as! String
        print("getUnreadCount",getUnreadCount)
        if getUnreadCount > "0" {

            cell.unreadCountView.isHidden = false
            cell.unreadCountView.isHidden = false
            cell.unreadCountLbl.text = getUnreadCount
        }else{
            cell.unreadCountView.isHidden = true
            cell.unreadCountLbl.isHidden = true

        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChatDict = stdSubjectArray[indexPath.row] as! NSDictionary
        print("selectedChatDict \(selectedChatDict)")
        self.performSegue(withIdentifier: "showInteractDetail", sender: self)
    }
    
    //MARK: API CALLING
    
    func GetStaffSubiectApiCalling(){
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_STAFF_CLASSES_CHAT
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        print("baseReportUrlString\(baseReportUrlString)")
        requestStringer = baseReportUrlString! + GET_STAFF_CLASSES_CHAT
        print("requestStringer\(requestStringer)")
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

        let myDict:NSMutableDictionary = ["StaffId" : StaffId,MOBILE_NUMBER : appDelegate.strMobileNumber , SCHOOLIID : SchoolId]
        
        let myString = Util.convertDictionary(toString: myDict)
        print("myString\(myString)")
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStaffDetailApi")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        print(csData)
        hideLoading()
        if(csData != nil)
        {
            UtilObj.printLogKey(printKey: "CSData", printingValue: csData!)
            if let CheckedDict = csData as? NSArray
            {
                if(CheckedDict.count > 0)
                {
                    if let Dict = CheckedDict[0] as? NSDictionary{
                        let stdID = String(describing: Dict["StandardId"]!)
                        let alrtMessage = Dict["Standard"] as! String
                        let getUnreadCount = Dict["unread_count"] as! String
                        if(stdID != "0"){
                            stdSubjectArray = NSMutableArray(array: CheckedDict)
                            myTableView.reloadData()
                        }else{
                            self.AlerMessage(alrtStr: alrtMessage)
                        }
                    }else{
                        self.AlerMessage(alrtStr: strNoRecordAlert)
                    }
                    
                }else
                {
                    self.AlerMessage(alrtStr: strNoRecordAlert)
                }
                
            }else
            {
                self.AlerMessage(alrtStr: strNoRecordAlert)
            }
            
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        hideLoading()
        
    }
    
    func AlerMessage(alrtStr : String){
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: alrtStr, preferredStyle: .alert)
        let okAction = UIAlertAction(title:languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        // print("Error")
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
    
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        let strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }else{
                    GetStaffSubiectApiCalling()
                }
            } catch {
                GetStaffSubiectApiCalling()
            }
        }
    }
    
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        
        
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        GetStaffSubiectApiCalling()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showInteractDetail"){
            let segueid = segue.destination as! StaffChatDetailVC
            segueid.selectedChatDict = selectedChatDict
            segueid.StaffId = self.StaffId
            segueid.SchoolId = self.SchoolId
            
        }
    }
    
    // MARK: - TAB BUTTON ACTION
    
    @IBAction func actionTabHome(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionTabLanguage(_ sender: Any) {
        let languageVC  = self.storyboard?.instantiateViewController(withIdentifier: "ChooseLanguageVC") as! ChooseLanguageVC
        languageVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(languageVC, animated: true, completion: nil)
    }
    
    @IBAction func actionTabChangePassword(_ sender: Any) {
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFrom = "ChangePassword"
        changePasswordVC.strFromStaff = "Staff"
        changePasswordVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(changePasswordVC, animated: true, completion: nil)
    }
    
    @IBAction func actionFAQ(_ sender: Any) {
        let faqVC  = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
        faqVC.fromVC = "Staff"
        self.navigationController?.pushViewController(faqVC, animated: true)
    }
    
    @IBAction func actionTabLogout(_ sender: UIButton) {
        self.showPopover(sender, Titletext: "")
    }
    func callLogoutAction(){
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFromStaff = "Staff"
        changePasswordVC.strFrom = "Logout"
        self.navigationController?.pushViewController(changePasswordVC, animated: true)
    }
    
    // MARK: - Popover delegate  & Functions
    func showPopover(_ base: UIView, Titletext: String)
    {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DropDownVC") as? DropDownVC {
            
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .popover
            viewController.fromVC = "setting"
            
            if let pctrl = navController.popoverPresentationController {
                pctrl.delegate = self
                pctrl.sourceView = base
                pctrl.permittedArrowDirections = .down
                pctrl.sourceRect = base.bounds
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func UpdateLogoutSelection(notification:Notification) -> Void
    {
        print("staff")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() )
        {
            self.showLogoutAlert()
        }
        
    }
    
    func showLogoutAlert(){
        let alertController = UIAlertController(title: languageDictionary["txt_menu_logout"] as? String, message: languageDictionary["want_to_logut"] as? String, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.moveToLogInScreen(strFromStaff: "Child")
        }
        let cancelAction = UIAlertAction(title: languageDictionary["teacher_cancel"] as? String, style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
