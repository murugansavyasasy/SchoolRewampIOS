//
//  StaffDetailsVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 14/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffDetailsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,Apidelegate,UISearchBarDelegate {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var ClassTeacherNameLabel: UILabel!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var interactButton: UIButton!
    
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var StaffDetailTableView: UITableView!
    
    @IBOutlet weak var AdView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var search_bar: UISearchBar!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var AlertString = String()
    var ChildIDString = String()
    var SchoolIDString = String()
    
    var staffName = String()
    var ClassTeacherID = String()
    var StaffId = String()
    var strLanguage = String()
    var subjectName = String()
    var subjectId = String()
    var sectionId = String()
    var StaffDetailArray : NSArray = NSArray()
    var languageDictionary = NSDictionary()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var strClassTeacher = String()
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    
    
    weak var timer: Timer?
    
    var menuId : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search_bar.delegate = self
        
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        print("StaffDetailsVC1122")
        async {
            // 1
            await AdConstant.AdRes(memId: ChildIDString, memType: "student", menu_id: AdConstant.getMenuId as String, school_id: SchoolIDString)
            print("menu_id:\(AdConstant.getMenuId)")
            menuId = AdConstant.getMenuId as String
            
            
        }
        
        
        
        
        print("search_bar")
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StaffDetailsVC.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        //
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        //        stopTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //         startTimer()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func viewWillAppear(_ animated: Bool) {
        self.callSelectedLanguage()
    }
    
    // MARK: DATAVIEW DELEAGATE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("StaffDetetailArraycounailArraycount",StaffDetailArray.count)
        
        return StaffDetailArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 130
        }else{
            return 96
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StaffDetailsTVCell", for: indexPath) as! StaffDetailsTVCell
        cell.backgroundColor = UIColor.clear
        let Dict = StaffDetailArray[indexPath.row] as! NSDictionary
        let StaffName : String = String(describing: Dict["staffname"]!)
        if(strLanguage == "ar"){
            cell.cellView.semanticContentAttribute = .forceRightToLeft
            cell.StaffNameLabel.textAlignment = .right
            cell.SubjectfNameLabel.textAlignment = .right
            //cell.FloatStaffNameLabel.textAlignment = .right
            // cell.FloatSubjectfNameLabel.textAlignment = .right
            cell.StaffNameLabel.text =  StaffName +  " : " + " Name"
            cell.SubjectfNameLabel.text =  String(describing: Dict["subjectname"]!) +  " : " + " Sub"
        }else{
            cell.StaffNameLabel.textAlignment = .left
            cell.SubjectfNameLabel.textAlignment = .left
            // cell.FloatStaffNameLabel.textAlignment = .left
            // cell.FloatSubjectfNameLabel.textAlignment = .left
            cell.cellView.semanticContentAttribute = .forceLeftToRight
            cell.StaffNameLabel.text =  "Name " + " : "  + StaffName
            cell.SubjectfNameLabel.text = "Sub " + " : " + String(describing: Dict["subjectname"]!)
        }
        //  cell.FloatStaffNameLabel.text = languageDictionary["staffname"] as? String
        //  cell.FloatSubjectfNameLabel.text = languageDictionary["subjectname"] as? String
        
        if(String(describing: Dict["StaffID"]!) == "0"){
            cell.interactButton.isHidden = true
        }else{
            cell.interactButton.isHidden = false
        }

        let getUnreadCount = Dict["unread_count"] ?? "0"
        print("getUnreadCount",getUnreadCount)
        
        if getUnreadCount as! String > "0" {

            cell.unReadCountView.isHidden = false
            cell.unreadCountLbl.isHidden = false
            cell.unreadCountLbl.text = getUnreadCount as! String
        }else{
            cell.unReadCountView.isHidden = true
            cell.unreadCountLbl.isHidden = true

        }

        
        cell.interactButton.addTarget(self, action: #selector(actionInteract(sender:)), for: .touchUpInside)
        cell.interactButton.tag = indexPath.row
        return cell
    }
    
    // MARK: - TAB BUTTON ACTION
    
    @objc func actionInteract(sender: UIButton){
        let Dict = StaffDetailArray[sender.tag] as! NSDictionary
        StaffId = String(describing: Dict["StaffID"]!)
        subjectName = String(describing: Dict["subjectname"]!)
        subjectId = String(describing: Dict["SubjectID"]!)
        staffName =  String(describing: Dict["staffname"]!)
        strClassTeacher = "0"
        self.performSegue(withIdentifier: "StudentChatScreenSegue", sender: nil)
    }
    
    @IBAction func actionClassTeacherInteract(_ sender: Any) {
        StaffId = ClassTeacherID
        strClassTeacher = "1"
        staffName = self.ClassTeacherNameLabel.text!
        self.performSegue(withIdentifier: "StudentChatScreenSegue", sender: nil)
    }
    
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
        changePasswordVC.strFromStaff = "Child"
        changePasswordVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(changePasswordVC, animated: true, completion: nil)
    }
    
    @IBAction func actionFAQ(_ sender: Any) {
        let faqVC  = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
        faqVC.fromVC = "Parent"
        self.navigationController?.pushViewController(faqVC, animated: true)
    }
    
    @IBAction func actionTabLogout(_ sender: Any) {
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFrom = "Logout"
        changePasswordVC.strFromStaff = "Child"
        UserDefaults.standard.removeObject(forKey: DefaultsKeys.getgroupHeadRole)
        changePasswordVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(changePasswordVC, animated: true, completion: nil)
    }
    //MARK: API CALLING
    
    func GetStaffDetailApiCalling(){
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_STAFF_DETAIL
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_STAFF_DETAIL_CHAT_SCREEN
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["memberid" : ChildIDString, COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber , SCHOOLIID : SchoolIDString]
        let myString = Util.convertDictionary(toString: myDict)
        print("STAFFDETYAILVC",requestString)
        apiCall.nsurlConnectionFunction(requestString, myString, "getStaffDetailsForChat")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            UtilObj.printLogKey(printKey: "CSData", printingValue: csData!)
            if let CheckedDict = csData as? NSArray
            {
                if(CheckedDict.count > 0)
                {
                    if let dict =  CheckedDict.mutableCopy() as? NSDictionary {
                        if let val =  dict["ClassTeacherID"] {
                            let strVal:String = String(describing: val)
                            AlertString  = String(describing: dict["classteacher"]!)
                            if(strLanguage == "ar"){
                                self.ClassTeacherNameLabel.text = String(describing: dict["classteacher"]!) +  " : " + " Name"
                            }else{
                                self.ClassTeacherNameLabel.text = "Name " + " : "  + String(describing: dict["classteacher"]!)
                            }
                            
                            if let subjectArray =  dict["subjectdetails"]  as? NSArray
                            {
                                if(subjectArray.count > 0)
                                {
                                    
                                    self.sectionId = String(describing: dict["SectionID"]!)
                                    self.ClassTeacherID = String(describing: dict["ClassTeacherID"]!)
                                    StaffDetailArray = subjectArray
                                    
                                    StaffDetailTableView.reloadData()
                                }else
                                {
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
                        
                    }else
                    {
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
    
    func navTitle(){
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        //titleLabel.textColor = UIColor (red:128.0/255.0, green:205.0/255.0, blue: 244.0/255.0, alpha: 1)
        titleLabel.textColor = UIColor (red:0.0/255.0, green:183.0/255.0, blue: 190.0/255.0, alpha: 1)
        let secondWord =  languageDictionary["Staff"] as? String
        let thirdWord   = languageDictionary["details"] as? String
        let comboWord = (secondWord ?? "Staff" ) + " " + (thirdWord ?? "Details")
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: (secondWord ?? "Details"))
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
            self.StaffDetailTableView.semanticContentAttribute = .forceRightToLeft
            BottomView.semanticContentAttribute = .forceRightToLeft
            mainView.semanticContentAttribute = .forceRightToLeft
            self.ClassTeacherNameLabel.textAlignment = .right
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.StaffDetailTableView.semanticContentAttribute = .forceLeftToRight
            BottomView.semanticContentAttribute = .forceLeftToRight
            mainView.semanticContentAttribute = .forceLeftToRight
            self.ClassTeacherNameLabel.textAlignment = .left
            
            
        }
        HomeLabel.text = LangDict["home"] as? String
        //        LanguageLabel.text = LangDict["txt_language"] as? String
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
        self.loadViewData()
        
    }
    
    func loadViewData(){
        navTitle()
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.mainView.layer.cornerRadius = 5
        self.mainView.layer.masksToBounds = true
        self.interactButton.layer.cornerRadius = 5
        self.interactButton.clipsToBounds = true
        
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        if(Util .isNetworkConnected()){
            self.GetStaffDetailApiCalling()
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
        StaffDetailTableView.reloadData()
    }
    
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void {
        self.callSelectedLanguage()
    }
    
    func loadApiData(strTeacherName : String){
        if(strLanguage == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.StaffDetailTableView.semanticContentAttribute = .forceRightToLeft
            mainView.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.StaffDetailTableView.semanticContentAttribute = .forceLeftToRight
            mainView.semanticContentAttribute = .forceLeftToRight
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "StudentChatScreenSegue"){
            let segueid = segue.destination as! StudentChatVC
            segueid.StaffId = StaffId
            segueid.strClassTeacher = self.strClassTeacher
            segueid.subjectName = self.subjectName
            segueid.studentChatId = 1
            segueid.subjectId = self.subjectId
            segueid.sectionId = self.sectionId
            segueid.staffName = self.staffName
        }
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            StaffDetailArray
            self.StaffDetailTableView.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "%K CONTAINS[c] %@","subjectname", searchText)
            let arrSearchResults = StaffDetailArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            StaffDetailArray = NSMutableArray(array: arrSearchResults)
            if(StaffDetailArray.count > 0){
                self.StaffDetailTableView.reloadData()
                print("DetailVoiceArray.count > 0")
            }else{
                print("noDataLabel.isHidden = false")
            }
            //            CallDetailSeeMoreEmergencyVocieApi()
            self.StaffDetailTableView.reloadData()
        }
        
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_bar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
}
