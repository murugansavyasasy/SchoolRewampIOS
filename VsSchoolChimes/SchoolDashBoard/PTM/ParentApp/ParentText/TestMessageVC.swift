//
//  TestMessageVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 01/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper



class TestMessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource,Apidelegate,UIPopoverPresentationControllerDelegate,UISearchBarDelegate,UIGestureRecognizerDelegate {
    var strApiFrom = NSString()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var DateWiseTextArray = NSMutableArray()
    var SelectedTextDict = NSDictionary()
    var languageDictionary = NSDictionary()
    var strLanguage = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var noDataLabel: UILabel!
    var SchoolId = String()
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var MyTableView: UITableView!
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    var gestureRecognizer = UITapGestureRecognizer()
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    
    var ArrayData = NSMutableArray()
    weak var timer: Timer?
    var noview : UIView!
    var menuId : String!
    
    
    var SchoolIDString = String()
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    var getadID : Int!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var AdView: UIView!
    
    @IBOutlet weak var imgView: UIImageView!
    var altSting = String()
    var bIsSeeMore = Bool()
    var ChildIDString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TestMessageVC")
        HiddenLabel.isHidden = true
        searchBar.delegate = self
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        
        print("ChildIDString",ChildIDString)
        print("SchoolId",SchoolIDString)
        print("AdConstant.getMenuId",AdConstant.getMenuId)
        
        
        //
        
        
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
            self.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
            
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
                
                self!.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
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
            vc.getMenuID = menuId
            vc.adIdget = getadID
            
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.callSelectedLanguage()
        
        
        searchBar.resignFirstResponder()
        searchBar.text = ""
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ConferenceCallVC.SearchTap(_:)))
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.isEnabled = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        bIsSeeMore = false
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(DateWiseTextArray.count == 0){
            if(appDelegate.isPasswordBind != "0"){
                emptyView()
            }
            return 0
        }else{
            self.MyTableView.backgroundView = nil
            return DateWiseTextArray.count
            
            
            
            if(!bIsSeeMore){
                return DateWiseTextArray.count + 1
                
            }else{
                print("DateWiseTextArray.count",DateWiseTextArray.count)
                return DateWiseTextArray.count
                
            }
            
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row < (DateWiseTextArray.count - 1)){
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return 94
            }else{
                return 80
            }
        }else{
            if(bIsSeeMore){
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return 94
                }else{
                    return 80
                }
            }else{
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return 94 + 40
                }else{
                    return 80 + 40
                }
            }
            
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateWiseVoiceTVCell", for: indexPath) as! DateWiseVoiceTVCell
        cell.backgroundColor = UIColor.clear
        let Dict = DateWiseTextArray[indexPath.row] as! NSDictionary
        cell.DateLbl.text = String(describing: Dict["Date"]!)
        cell.DayLbl.text = String(describing: Dict["Day"]!)
        cell.UnreadCountLbl.text = " " + String(describing: Dict["UnreadCount"]!) + "  "
        if(strLanguage == "ar"){
            cell.DateLbl.textAlignment = .right
            cell.DayLbl.textAlignment = .right
            cell.MainView.semanticContentAttribute = .forceRightToLeft
        }else{
            cell.DateLbl.textAlignment = .left
            cell.DayLbl.textAlignment = .left
            cell.MainView.semanticContentAttribute = .forceLeftToRight
        }
        if(bIsSeeMore)
        {
            cell.seemoreBtn.isHidden = true
        }else{
            cell.seemoreBtn.isHidden = false
        }
        
        cell.seemoreBtn.layer.cornerRadius = 5
        cell.seemoreBtn.layer.borderWidth = 2
        cell.seemoreBtn.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        cell.seemoreBtn.setTitle(SEE_MORE_TITLE, for: .normal)
        cell.seemoreBtn.backgroundColor = .white
        cell.seemoreBtn.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        cell.seemoreBtn.titleLabel?.font = .systemFont(ofSize: 12)
        
        cell.seemoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        
        SelectedTextDict = DateWiseTextArray[indexPath.row] as! NSDictionary
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "DateWiseTextSegue", sender: self)
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
        print("TestMSG")
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
    func CallDatawiseTextApi() {
        
        print("CallDatawiseTextApi")
        showLoading()
        strApiFrom = "DatawiseText"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + DATE_WISE_MESSAGE
        
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + DATE_WISE_MESSAGE
        }
        print("requestStringerUrls1",requestStringer)
        
        let childId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        let SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID" : childId,"SchoolID":SchoolId,"Type":"SMS", COUNTRY_CODE: strCountryCode]
        
        utilObj.printLogKey(printKey: "requestStringer", printingValue: requestStringer)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "DatawiseText")
    }
    func CallSeeMoreDatawiseTextApi() {
        
        print("CallSeeMoreDatawiseTextApi")
        showLoading()
        strApiFrom = "SeeMoreDatawiseText"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + DATE_WISE_MESSAGE_SEEMORE
        
        
        
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + DATE_WISE_MESSAGE_SEEMORE
        }
        print("requestStringerUrls",requestStringer)
        
        let childId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        let SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID" : childId,"SchoolID":SchoolId,"Type":"SMS", COUNTRY_CODE: strCountryCode]
        
        utilObj.printLogKey(printKey: "DatawiseText", printingValue: requestStringer)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "DatawiseText")
    }
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "csData", printingValue: csData)
            
            if(strApiFrom == "DatawiseText")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        
                        let Status = String(describing: dict["Status"]!)
                        let Message = String(describing: dict["Message"]!)
                        altSting = Message
                        
                        if(Status == "1")
                        {
                            ArrayData.add(dict)
                            DateWiseTextArray.add(dict)
                        }else{
                            if(appDelegate.isPasswordBind == "0"){
                                AlertMessage(strAlert: Message)
                            }
                        }
                    }
                    DateWiseTextArray = ArrayData
                    let childId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
                    Childrens.saveTextDateListDetail(DateWiseTextArray as! [Any], childId)
                    
                    utilObj.printLogKey(printKey: "DateWiseTextArray", printingValue: DateWiseTextArray)
                    MyTableView.reloadData()
                    
                }else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom == "SeeMoreDatawiseText")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        
                        let Status = String(describing: dict["Status"]!)
                        let Message = String(describing: dict["Message"]!)
                        
                        if(Status == "1")
                        {
                            DateWiseTextArray.add(dict)
                            
                        }else{
                            altSting = Message
                            AlertMessage(strAlert: Message)
                            
                        }
                    }
                    
                    let childId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
                    
                    Childrens.saveTextDateListDetail(DateWiseTextArray as! [Any], childId)
                    
                    utilObj.printLogKey(printKey: "DateWiseTextArray", printingValue: DateWiseTextArray)
                    MyTableView.reloadData()
                    
                }else{
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
        Util.showAlert("", msg: strSomething)
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        utilObj.printLogKey(printKey: "SelectedTextDict", printingValue: SelectedTextDict)
        
        if (segue.identifier == "DateWiseTextSegue")
        {
            let segueid = segue.destination as! TextVC
            segueid.selectedDictionary = SelectedTextDict
            
        }
    }
    @objc func catchNotification(notification:Notification) -> Void {
        
        bIsSeeMore = false
        if(appDelegate.isPasswordBind == "0"){
            bIsSeeMore = true
        }
        
        if(Util .isNetworkConnected())
        {
            DispatchQueue.main.async {
                self.CallDatawiseTextApi()
            }
        }
        else
        {
        }
    }
    func AlertMessage(strAlert : String)
    {
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: strAlert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
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
            self.MyTableView.semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            self.BottomView.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.MyTableView.semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            self.BottomView.semanticContentAttribute = .forceLeftToRight
        }
        
        HomeLabel.text = LangDict["home"] as? String
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
        self.loadViewData()
        
    }
    
    func loadViewData(){
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        
        self.title = languageDictionary["recent_messages"] as? String
        if(Util .isNetworkConnected()){
            DispatchQueue.main.async {
                self.CallDatawiseTextApi()
            }
        }else{
            let childId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
            DateWiseTextArray =   Childrens.getTextDateList(fromDB: childId) as! NSMutableArray
            if(DateWiseTextArray.count > 0){
                MyTableView.reloadData()
            }else{
                Util .showAlert("", msg: strNoInternet)
            }
        }
        MyTableView.reloadData()
    }
    
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void {
        self.callSelectedLanguage()
    }
    //Mark:- SeeMore Feature
    func emptyView(){
        noview  = UIView(frame: CGRect(x: 0, y: 0, width: self.MyTableView.bounds.size.width, height: self.MyTableView.bounds.size.height))
        
        noDataLabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.MyTableView.bounds.size.width, height: 60))
        noDataLabel.text = "No messages for the day. Click See More for previous messages."
        noDataLabel.textColor = .red
        noDataLabel.backgroundColor = UIColor(named: "NoDataColor")
        
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.MyTableView.bounds.size.width - 108, y: noDataLabel.frame.height + 30, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        self.MyTableView.backgroundView = noview
    }
    @objc func seeMoreButtonTapped(sender : UIButton) {
        //Write button action here
        bIsSeeMore = true
        self.MyTableView.reloadData()
        CallSeeMoreDatawiseTextApi()
    }
    
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            DateWiseTextArray  =  ArrayData
            self.MyTableView.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "Date CONTAINS [c] %@ OR Day CONTAINS [c] %@ ", searchText, searchText)
            let arrSearchResults = ArrayData.filter { resultPredicate.evaluate(with: $0) } as NSArray
            DateWiseTextArray = NSMutableArray(array: arrSearchResults)
            if(DateWiseTextArray.count > 0){
                
                self.MyTableView.reloadData()
                
                noview.isHidden = true
            }else{
                noview.isHidden = false
            }
            
            
            self.MyTableView.reloadData()
        }
        
        
        
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        SelectedSectionArray.removeAllObjects()
        DateWiseTextArray = MainDetailTextArray
        self.MyTableView.reloadData()
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBart: UISearchBar) {
        
        
        searchBar.resignFirstResponder()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}
