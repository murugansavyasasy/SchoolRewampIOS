//
//  AttendanceVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 01/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper


class AttendanceVC: UIViewController,UITableViewDelegate, UITableViewDataSource,Apidelegate,UIPopoverPresentationControllerDelegate,UISearchBarDelegate{
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    var strLanguage = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var strCountryCode = String()
    var DetailAttendanceArray = NSMutableArray()
    var languageDictionary = NSDictionary()
    var altSting = String()
    var bIsSeeMore = Bool()
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    
    
    weak var timer: Timer?
    
    var getadID : Int!
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var AttendanceTableView: UITableView!
    
    @IBOutlet weak var imageView: UIImageView!
    var hud : MBProgressHUD = MBProgressHUD()
    
    
    
    var menuId : String!
    @IBOutlet weak var AdView: UIView!
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        search_bar.delegate = self
        HiddenLabel.isHidden = true
        bIsSeeMore = false
        if(appDelegate.isPasswordBind == "0"){
            bIsSeeMore = true
        }
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        AttendanceTableView.reloadData()
        
        
        async {
            do {
                //
                menuId = AdConstant.getMenuId as String
                print("menu_id:\(AdConstant.getMenuId)")
                
                
                
                let AdModal = AdvertismentModal()
                AdModal.MemberId = ChildId
                AdModal.MemberType = "student"
                if AdConstant.mgmtVoiceType == "1" {
                    AdModal.MenuId = "0"
                }
                AdModal.MenuId = menuId
                AdModal.SchoolId = SchoolId
                
                
                let admodalStr = AdModal.toJSONString()
                
                
                print("admodalStr2222",admodalStr)
                AdvertismentRequest.call_request(param: admodalStr!) { [self]
                    
                    (res) in
                    
                    let adModalResponse : [AdvertismentResponse] = Mapper<AdvertismentResponse>().mapArray(JSONString: res)!
                    
                    
                    
                    for i in adModalResponse {
                        if i.Status.elementsEqual("1") {
                            print("AdConstantadDataListtt",AdConstant.adDataList.count)
                            
                            
                            
                            
                            AdConstant.adDataList.removeAll()
                            AdConstant.adDataList = i.data
                            
                            startTimer()
                            
                        }else{
                            
                        }
                        
                    }
                    
                    print("admodalStr_count", AdConstant.adDataList .count)
                    
                    
                    
                }
                
                
            } catch {
                print("Error fetching data: \(error)")
            }
        }
        
        
        let imgTap = AdGesture (target: self, action: #selector(viewTapped))
        AdView.addGestureRecognizer(imgTap)
        
        
    }
    
    func startTimer() {
        if AdConstant.adDataList.count > 0 {
            
            let url : String =  AdConstant.adDataList[0].contentUrl!
            self.imgaeURl = AdConstant.adDataList[0].redirectUrl!
            self.AdName = AdConstant.adDataList[0].advertisementName!
            self.getadID = AdConstant.adDataList[0].id!
            self.imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
            
            AdView.isHidden = false
            adViewHeight.constant = 80
            
            if(self.firstImage == 0){
                self.imageCount =  1
            }
            else{
                self.imageCount =  0
            }
            
            let minC : Int = UserDefaults.standard.integer(forKey: ADTIMERINTERVAL)
            print("minC",minC)
            var AdSec = String(minC / 1000)
            print("minutesBefore",AdSec)
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(AdSec)!, repeats: true) { [weak self] _ in
                
                
                if(AdConstant.adDataList.count == self!.imageCount){
                    self!.imageCount = 0
                    self!.firstImage = 1
                }
                
                self!.imageCount = self!.imageCount + 1
                
                let url : String =  AdConstant.adDataList[self!.imageCount-1].contentUrl!
                self!.imgaeURl = AdConstant.adDataList[self!.imageCount-1].redirectUrl!
                self!.AdName = AdConstant.adDataList[self!.imageCount-1].advertisementName!
                self!.getadID = AdConstant.adDataList[self!.imageCount-1].id!
                
                self!.imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
            }
        }else {
            AdView.isHidden = true
            adViewHeight.constant = 0
        }
    }
    
    func stopTimer() {
        print("Stopped timer")
        timer?.invalidate()
    }
    
    @IBAction func viewTapped() {
        
        
        if imgaeURl.isEmpty != true {
            let vc = AdRedirectViewController(nibName: nil, bundle: nil)
            
            
            vc.advertisement_Name = AdName
            vc.redirect_urls = imgaeURl
            vc.adIdget = getadID
            vc.getMenuID = menuId
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            
            
            
        }else{
            print("isEmpty")
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(AttendanceVC.UpdateLogoutSelection), name: NSNotification.Name(rawValue: "SettingNotification"), object:nil)
        nc.addObserver(self,selector: #selector(AttendanceVC.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DetailAttendanceArray.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 94
        }else{
            return 80
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceTVCell", for: indexPath) as! AttendanceTVCell
        cell.backgroundColor = UIColor.clear
        let dict = DetailAttendanceArray[indexPath.row] as! NSDictionary
        cell.DayLbl.text = String(describing: dict["Day"]!)
        cell.DateLbl.text = String(describing: dict["Date"]!)
        cell.AbsentLbl.text = languageDictionary["absent"] as? String
        if(strLanguage == "ar"){
            cell.MainView.semanticContentAttribute = .forceRightToLeft
            cell.DayLbl.textAlignment = .right
            cell.DateLbl.textAlignment = .right
        }else{
            cell.DayLbl.textAlignment = .left
            cell.DateLbl.textAlignment = .left
            cell.MainView.semanticContentAttribute = .forceLeftToRight
            
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
        changePasswordVC.strFromStaff = "Child"
        changePasswordVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(changePasswordVC, animated: true, completion: nil)
    }
    
    @IBAction func actionFAQ(_ sender: Any) {
        let faqVC  = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
        faqVC.fromVC = "Parent"
        self.navigationController?.pushViewController(faqVC, animated: true)
    }
    
    @IBAction func actionTabLogout(_ sender: UIButton) {
        self.showPopover(sender, Titletext: "")
    }
    
    func callLogoutAction(){
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFrom = "Logout"
        changePasswordVC.strFromStaff = "Child"
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
        print("Attan")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now())
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
    
    // MARK:- Api Calling
    func CallAttendanceDetailMessageApi() {
        // showLoading()
        strApiFrom = "CallAttendanceDetailMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_ABSENTENCE_DATE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_ABSENTENCE_DATE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"ChildID":"731241","SchoolID":"2010"}
        print("requestStringrequestString",requestString)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallAttendanceDetailMessage")
    }
    func CallSeeMoreAttendanceDetailMessageApi() {
        // showLoading()
        strApiFrom = "CallSeeMoreAttendanceDetailMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_ABSENTENCE_DATE_SEEMORE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_ABSENTENCE_DATE_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"ChildID":"731241","SchoolID":"2010"}
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreAttendanceDetailMessage")
    }
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom == "CallAttendanceDetailMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    DetailAttendanceArray.removeAllObjects()
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Date = String(describing: dict["Date"]!)
                        
                        let Day = String(describing: dict["Day"]!)
                        if(Date != "0")
                        {
                            DetailAttendanceArray.add(dict)
                            MainDetailTextArray.add(dict)
                        }else{
                            
                            // altSting = Day
                            AlertMessage(alrString: Day)
                            
                        }
                    }
                    
                    
                    DetailAttendanceArray =  MainDetailTextArray
                    
                    Childrens.saveAttendanceReportDetail(DetailAttendanceArray as! [Any] , ChildId)
                    
                    utilObj.printLogKey(printKey: "DetailAttendanceArray", printingValue: DetailAttendanceArray)
                    AttendanceTableView.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom == "CallSeeMoreAttendanceDetailMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    DetailAttendanceArray.removeAllObjects()
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Date = String(describing: dict["Date"]!)
                        
                        let Day = String(describing: dict["Day"]!)
                        if(Date != "0")
                        {
                            DetailAttendanceArray.add(dict)
                        }else{
                            
                            AlertMessage(alrString: Day)
                            
                        }
                    }
                    DetailAttendanceArray =  MainDetailTextArray
                    
                    Childrens.saveAttendanceReportDetail(DetailAttendanceArray as! [Any] , ChildId)
                    
                    utilObj.printLogKey(printKey: "DetailAttendanceArray", printingValue: DetailAttendanceArray)
                    AttendanceTableView.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        
        hideLoading()
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: strSomething);
        
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
    func AlertMessage(alrString:String)
    {
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: alrString, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
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
            self.DescriptionLabel.textAlignment = .right
            self.BottomView.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.DescriptionLabel.textAlignment = .left
            self.BottomView.semanticContentAttribute = .forceLeftToRight
        }
        HomeLabel.text = LangDict["home"] as? String
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        self.title = languageDictionary["attedance"] as? String
        self.DescriptionLabel.text = languageDictionary["hint_attendance"] as? String
        if(Util .isNetworkConnected()){
            self.CallAttendanceDetailMessageApi()
        }else{
            DetailAttendanceArray = Childrens.getAttendanceReport(fromDB: ChildId)
            if(DetailAttendanceArray.count > 0)
            {
                AttendanceTableView.reloadData()
                
            }else{
                Util .showAlert("", msg: strNoInternet)
            }
        }
        AttendanceTableView.reloadData()
    }
    
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void {
        self.callSelectedLanguage()
    }
    
    //Mark:- SeeMore Feature
    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.AttendanceTableView.bounds.size.width, height: self.AttendanceTableView.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.AttendanceTableView.bounds.size.width, height: 150))
        noDataLabel.text = altSting
        noDataLabel.textColor = .black
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.AttendanceTableView.bounds.size.width - 108, y: noDataLabel.frame.height + 10, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        self.AttendanceTableView.backgroundView = noview
    }
    func restoreView(){
        self.AttendanceTableView.backgroundView = nil
        
    }
    
    @objc func seeMoreButtonTapped(sender : UIButton) {
        //Write button action here
        bIsSeeMore = true
        self.AttendanceTableView.reloadData()
        
        CallSeeMoreAttendanceDetailMessageApi()
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            DetailAttendanceArray = MainDetailTextArray
            self.AttendanceTableView.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "%K CONTAINS[c] %@","Day", searchText)
            let arrSearchResults = MainDetailTextArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            DetailAttendanceArray = NSMutableArray(array: arrSearchResults)
            if(DetailAttendanceArray.count > 0){
                self.AttendanceTableView.reloadData()
                print("DetailVoiceArray.count > 0")
            }else{
                print("noDataLabel.isHidden = false")
            }
            self.AttendanceTableView.reloadData()
        }
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBar.resignFirstResponder()")
        
        searchBar.resignFirstResponder()
        print("searchBar.resignFirstResponder()")
        
        SelectedSectionArray.removeAllObjects()
        DetailAttendanceArray = MainDetailTextArray
        self.AttendanceTableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_bar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        search_bar.resignFirstResponder()
    }
}
