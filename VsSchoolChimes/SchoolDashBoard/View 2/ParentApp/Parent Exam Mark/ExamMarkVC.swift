//
//  ExamMarkVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 15/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper


class ExamMarkVC: UIViewController , UITableViewDelegate, UITableViewDataSource,Apidelegate ,UIPopoverPresentationControllerDelegate,UISearchBarDelegate{
    @IBOutlet weak var ExamMarkTableView: UITableView!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var search_bar: UISearchBar!
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    @IBOutlet weak var AdView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var strApiFrom = String()
    var AlertString = String()
    var ChildIDString = String()
    var SchoolIDString = String()
    var arrExamMark : NSArray = []
    var selectedExamDictionary = NSDictionary()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var strLanguage = String()
    var languageDictionary = NSDictionary()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var arrExamDetail : NSMutableArray = []
    
    var MainDetailTextArray:  NSArray = []
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    
    var firstImage : Int  = 0
    
    var getadID : Int!
    
    weak var timer: Timer?
    var menuId : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        search_bar.delegate = self
        
        
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        
        
        let seconds = 1.0
        
        
        
        async {
            do {
                //
                menuId = AdConstant.getMenuId as String
                print("menu_id:\(AdConstant.getMenuId)")
                
                
                
                let AdModal = AdvertismentModal()
                AdModal.MemberId = ChildIDString
                AdModal.MemberType = "student"
                if AdConstant.mgmtVoiceType == "1" {
                    AdModal.MenuId = "0"
                }
                AdModal.MenuId = menuId
                AdModal.SchoolId = SchoolIDString
                
                
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
                    
                    
                    
                    //
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
    }
    override func viewWillAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(ExamMarkVC.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        nc.addObserver(self,selector: #selector(ExamMarkVC.UpdateLogoutSelection), name: NSNotification.Name(rawValue: "SettingNotification"), object:nil)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrExamMark.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        var height : CGFloat = 0
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            height =  100
            
        }else{
            height =  84
            
        }
        return height
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExamMarkTVCell", for: indexPath) as! ExamMarkTVCell
        cell.backgroundColor = UIColor.clear
        let Dict : NSDictionary = arrExamMark[indexPath.row] as! NSDictionary
        cell.ExamNameLbl.text = String(describing: Dict["name"]!)
        if(strLanguage == "ar"){
            cell.ExamView.semanticContentAttribute = .forceRightToLeft
        }else{
            cell.ExamView.semanticContentAttribute = .forceLeftToRight
        }
        cell.ViewExamBtn.tag = indexPath.row
        cell.ViewExamBtn.addTarget(self, action: #selector(examClicked), for: .touchUpInside)
        
        cell.ViewProgressBtn.tag = indexPath.row
        
        cell.ViewProgressBtn.addTarget(self, action: #selector(progressClicked), for: .touchUpInside)
        
        
        
        return cell
        
    }
   
    
    @objc func examClicked(sender:UIButton) {
        
        let buttonRow = sender.tag
        selectedExamDictionary = arrExamMark[buttonRow] as! NSDictionary
        let exID = "\(selectedExamDictionary.object(forKey: "value") as? NSNumber ?? 0)"
        
        GetViewExamApiCalling(exID: exID)
    }
    @objc func progressClicked(sender:UIButton) {
        
        let buttonRow = sender.tag
        selectedExamDictionary = arrExamMark[buttonRow] as! NSDictionary
        let exID = "\(selectedExamDictionary.object(forKey: "value") as? NSNumber ?? 0)"
        GetViewProgressApiCalling(exID: exID)
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
        UserDefaults.standard.removeObject(forKey: DefaultsKeys.getgroupHeadRole)
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
        print("EXMark")
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
    
    
    
    
    //MARK: API CALLING
    
    func GetExamListApiCalling()
    {
        
        showLoading()
        strApiFrom = "GetExamListApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_EXAM_LIST_METHOD
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_EXAM_LIST_METHOD
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID" : ChildIDString,"SchoolID" : SchoolIDString, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        print("EXAMMARK",requestString)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetExamListApi")
    }
    
    func GetViewExamApiCalling(exID : String)
    {
        
        showLoading()
        strApiFrom = "viewexam"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_VIEW_EXAMS
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_VIEW_EXAMS
        }
        UtilObj.printLogKey(printKey: "requestStringer", printingValue: requestStringer)
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID" : ChildIDString,"SchoolID" : SchoolIDString, "ExamID": exID]
        let myString = Util.convertDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "myString", printingValue: myString)
        print("EXAMMARKS",requestString)
        apiCall.nsurlConnectionFunction(requestString, myString, "viewexam")
    }
    func GetViewProgressApiCalling(exID : String)
    {
        
        showLoading()
        strApiFrom = "progresscard"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_PROGRESS_CARD
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        UtilObj.printLogKey(printKey: "requestStringer", printingValue: requestStringer)
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID" : ChildIDString,"SchoolID" : SchoolIDString, "ExamID": exID]
        let myString = Util.convertDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "progresscard")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual("GetExamListApi"))
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                if let CheckedArray = csData as? NSArray
                {
                    if(CheckedArray.count > 0)
                    {
                        let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        if let val =  dict["value"] {
                            let strVal:String = String(describing: val)
                            
                            
                            AlertString  = String(describing: dict["name"]!)
                            print(strVal)
                            if(strVal == "-2")
                            {
                                self.AlerMessage(alrtStr: AlertString)
                            }
                            
                            else
                            {
                                arrExamMark = CheckedArray
                                //                                arrExamMark = MainDetailTextArray
                                MainDetailTextArray = CheckedArray
                                
                                Childrens.saveExamMarkListDetail(arrExamMark as! [Any], ChildIDString)
                                
                                ExamMarkTableView.reloadData()
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
            else  if(strApiFrom.isEqual("viewexam"))
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                let emptyDict : NSDictionary = NSDictionary()
                let Dict : NSDictionary = csData?.mutableCopy() as? NSDictionary ?? emptyDict
                
                UtilObj.printLogKey(printKey: "Dict", printingValue: Dict)
                if(Dict.count > 0){
                    
                    let Status = Dict["Status"] as? String ?? "0"
                    let Message = Dict["Message"] as? String
                    let strAlertString = Message as? String ?? ""
                    if(Status == "1"){
                        
                        let arrDat = Dict["Data"] as? NSArray ?? []
                        arrExamDetail = NSMutableArray(array: arrDat)
                        self.performSegue(withIdentifier: "ExamMarkDetailSegue", sender: self)
                        
                    }else{
                        Util.showAlert("", msg: Message)
                        
                    }
                    
                    
                }else
                {
                    Util.showAlert("", msg: NO_DATA_FOUND)
                }
                
            }else  if(strApiFrom.isEqual("progresscard"))
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                //
                let emptyDict : NSDictionary = NSDictionary()
                let Dict : NSDictionary = csData?.mutableCopy() as? NSDictionary ?? emptyDict
                if(Dict.count > 0){
                    
                    let Status = Dict["Status"] as? String ?? "0"
                    let Message = Dict["Message"] as? String
                    if(Status == "1"){
                        let openUrls = Dict["Data"] as? String ?? "0"
                        
                        self.openURL(urlSting: openUrls)
                        
                    }else{
                        Util.showAlert("", msg: Message)
                        
                    }
                    
                }else{
                    self.AlerMessage(alrtStr: NO_DATA_FOUND)
                    
                }
                
                
                
            }
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        hideLoading()
        
    }
    
    func openURL(urlSting : String){
        //
        
        let strUrl = urlSting.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: strUrl!) else { return }
        UIApplication.shared.openURL(url)
    }
    func AlerMessage(alrtStr : String)
    {
        
        let alertController = UIAlertController(title: "Alert", message: alrtStr, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "ExamMarkDetailSegue")
        {
            let segueid = segue.destination as! StudentMarkVC
            segueid.ExamDictionary = selectedExamDictionary
            segueid.arrExamDetail =  arrExamDetail
        }
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
            self.view.semanticContentAttribute = .forceRightToLeft
            self.ExamMarkTableView.semanticContentAttribute = .forceRightToLeft
            BottomView.semanticContentAttribute = .forceRightToLeft
            TitleLabel.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.ExamMarkTableView.semanticContentAttribute = .forceLeftToRight
            BottomView.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            TitleLabel.textAlignment = .left
            
        }
        HomeLabel.text = LangDict["home"] as? String
        TitleLabel.text = LangDict["list_of_exams"] as? String
        //        LanguageLabel.text = LangDict["txt_language"] as? String
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        strNoRecordAlert = LangDict["no_exams"] as? String ?? "No Exams Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
        self.loadViewData()
        
    }
    
    func loadViewData(){
        self.title = languageDictionary["exams"] as? String
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        if(Util .isNetworkConnected()){
            self.GetExamListApiCalling()
        }
        else{
            arrExamMark =  Childrens.getExamMarkList(fromDB: ChildIDString)
            if(arrExamMark.count > 0){
                ExamMarkTableView.reloadData()
            }else{
                Util .showAlert("", msg: strNoInternet)
                
            }
        }
    }
    
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void {
        self.callSelectedLanguage()
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            arrExamMark = MainDetailTextArray
            self.ExamMarkTableView.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "%K CONTAINS[c] %@","name", searchText)
            let arrSearchResults = MainDetailTextArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            arrExamMark = NSMutableArray(array: arrSearchResults)
            if(arrExamMark.count > 0){
                self.ExamMarkTableView.reloadData()
                print("DetailVoiceArray.count > 0")
            }else{
                print("noDataLabel.isHidden = false")
            }
            self.ExamMarkTableView.reloadData()
        }
        
        
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        arrExamMark = MainDetailTextArray
        self.ExamMarkTableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_bar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        search_bar.resignFirstResponder()
    }
}



