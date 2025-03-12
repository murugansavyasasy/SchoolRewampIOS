//
//  LibraryVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 12/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class LibraryVC: UIViewController, UITableViewDelegate, UITableViewDataSource,Apidelegate,UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var LibraryTableView: UITableView! 
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var BottomView: UIView!
    var strApiFrom = String()
    var StudentIDString = String()
    var strLanguage = String()
    var languageDictionary = NSDictionary()
    var arrLibraryData: NSArray = []
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var strCountryCode = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(LibraryVC.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        
        nc.addObserver(self,selector: #selector(LibraryVC.UpdateLogoutSelection), name: NSNotification.Name(rawValue: "SettingNotification"), object:nil)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        
        self.callSelectedLanguage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLibraryData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 0
        if(UIDevice.current.userInterfaceIdiom == .pad){
            height =  200
        }else{
            height =  152
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryTVCell", for: indexPath) as! LibraryTVCell
        cell.backgroundColor = UIColor.clear
        let dict:NSDictionary = arrLibraryData[indexPath.row] as! NSDictionary
        
        cell.FloatBookIdLbl.text = languageDictionary["book_id"] as? String
        cell.FloatBookNameLbl.text = languageDictionary["bookname"] as? String
        cell.FloatDueDateLbl.text = languageDictionary["due_date"] as? String
        cell.FloatIssueDateLbl.text = languageDictionary["issued_date"] as? String
        if(strLanguage == "ar"){
            cell.MainView.semanticContentAttribute = .forceRightToLeft
            cell.BookIdLbl.textAlignment = .right
            cell.BookNameLbl.textAlignment = .right
            cell.DueDateLbl.textAlignment = .right
            cell.IssueDateLbl.textAlignment = .right
            cell.FloatBookIdLbl.textAlignment = .right
            cell.FloatBookNameLbl.textAlignment = .right
            cell.FloatDueDateLbl.textAlignment = .right
            cell.FloatIssueDateLbl.textAlignment = .right
            cell.BookIdLbl.text = String(describing: dict["RefBookID"]!) + " : "
            cell.BookNameLbl.text = String(describing: dict["BookName"]!)  + " : "
            cell.DueDateLbl.text = String(describing: dict["DueDate"]!)  + " : "
            cell.IssueDateLbl.text = String(describing: dict["IssuedOn"]!)  + " : "
        }else{
            cell.BookIdLbl.textAlignment = .left
            cell.BookNameLbl.textAlignment = .left
            cell.DueDateLbl.textAlignment = .left
            cell.IssueDateLbl.textAlignment = .left
            cell.FloatBookIdLbl.textAlignment = .left
            cell.FloatBookNameLbl.textAlignment = .left
            cell.FloatDueDateLbl.textAlignment = .left
            cell.FloatIssueDateLbl.textAlignment = .left
            cell.MainView.semanticContentAttribute = .forceLeftToRight
            cell.BookIdLbl.text = " : " + String(describing: dict["RefBookID"]!)
            cell.BookNameLbl.text = " : " + String(describing: dict["BookName"]!)
            cell.DueDateLbl.text = " : " + String(describing: dict["DueDate"]!)
            cell.IssueDateLbl.text = " : " + String(describing: dict["IssuedOn"]!)
        }
        return cell
        
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
        print("lib")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() )
        {
            self.showLogoutAlert()
        }
        
    }
    
    func showLogoutAlert(){
        let alertController = UIAlertController(title: languageDictionary["txt_menu_logout"] as? String, message: languageDictionary["want_to_logut"] as? String, preferredStyle: .alert)
        
       
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
    //MARK: API CALLING
    func GetStudentLibraryApiCalling()
    {
        showLoading()
        strApiFrom = "GetStudentLibraryApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + PARENT_LIBRARY_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["StudentID" : StudentIDString,"Option" : OPTION_LIBRARY_METHOD, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStudentLibraryApi")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual("GetStudentLibraryApi"))
                
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                if let CheckedArray = csData as? NSArray
                {
                    if(CheckedArray.count > 0)
                    {
                        let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        if let val =  dict["RefBookID"] {
                            let strVal:String = String(describing: val)
                            
                            if(strVal == "-2")
                            {
                                if let alrtValue =  dict["BookName"] {
                                    self.AlerMessage(alrtMessage: alrtValue as? String ?? strNoRecordAlert)
                                }else{
                                    self.AlerMessage(alrtMessage: strNoRecordAlert)
                                }
                                
                            }else{
                                self.AlerMessage(alrtMessage: strNoRecordAlert)
                            }
                            
                        }else
                        {
                            arrLibraryData = CheckedArray
                            LibraryTableView.reloadData()
                        }
                        
                    }else
                    {
                        self.AlerMessage(alrtMessage: strNoRecordAlert)
                    }
                    
                }else
                {
                    self.AlerMessage(alrtMessage: strNoRecordAlert)
                }
            }
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
    }
    
    func AlerMessage(alrtMessage : String)
    {
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: alrtMessage, preferredStyle: .alert)
        
        
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
       
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
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
    func navTitle()
    {
        
        let titleLabel = UILabel()
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        titleLabel.textColor = UIColor (red:166.0/255.0, green: 114.0/255.0, blue: 155.0/255.0, alpha: 1)
        let secondWord =  languageDictionary["library"] as? String
        let thirdWord   = languageDictionary["details"] as? String
        let comboWord = (secondWord ?? "Library" ) + " " + (thirdWord ?? "Details")
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: (secondWord ?? "Library"))
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
        self.navigationController?.navigationBar.barTintColor = UtilObj.SCHOOL_NAV_BAR_COLOR
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }else{
                    self.loadViewData()
                }
            } catch {
                self.loadViewData()
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.LibraryTableView.semanticContentAttribute = .forceRightToLeft
            BottomView.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.LibraryTableView.semanticContentAttribute = .forceLeftToRight
            BottomView.semanticContentAttribute = .forceLeftToRight
            
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        HomeLabel.text = LangDict["home"] as? String
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        self.loadViewData()
        
    }
    
    func loadViewData(){
        if(appDelegate.LoginSchoolDetailArray.count > 0)
        {
            let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            StudentIDString = String(describing: dict["StaffID"]!)
            if(Util .isNetworkConnected())
            {
                self.GetStudentLibraryApiCalling()
            }
            else
            {
                Util.showAlert("", msg: NO_INTERNET)
            }
        }
        navTitle()
        LibraryTableView.reloadData()
    }
    
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void {
        self.callSelectedLanguage()
    }
    
}
