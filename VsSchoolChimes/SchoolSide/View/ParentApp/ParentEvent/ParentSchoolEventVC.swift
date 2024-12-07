//
//  SchoolEventVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 01/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper

class ParentSchoolEventVC: UIViewController,UITableViewDataSource,UITableViewDelegate,Apidelegate,UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var EventTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var AdView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    var selectedDictionary = [String: Any]() as NSDictionary
    var SelectedTextDict = [String: Any]() as NSDictionary
    var DetailTextArray = NSMutableArray()
    var HolidayDataArray = NSMutableArray()
    var languageDictionary = NSDictionary()
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    var strLanguage = String()
    var SelectedIndex = IndexPath()
    var SelectedStr = String()
    var strTabFrom = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var altSting = String()
    var bIsSeeMore = Bool()
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    var getadID : Int!
    
    weak var timer: Timer?
    var holidayData : [HolidayDataRes] = []
    
    var menuId : String!
    var identifers = "holidayCelsTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("eventTc")
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        
        
        EventTableView.register(UINib(nibName: identifers , bundle: nil), forCellReuseIdentifier: identifers)
        
        
        
        HiddenLabel.isHidden = true
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        EventTableView.reloadData()
        
        
        
        
        
        async {
            do {
                
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
            self.getadID = AdConstant.adDataList[0].id!
            self.AdName = AdConstant.adDataList[0].advertisementName!
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
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(ParentSchoolEventVC.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        nc.addObserver(self,selector: #selector(ParentSchoolEventVC.UpdateLogoutSelection), name: NSNotification.Name(rawValue: "SettingNotification"), object:nil)
        self.callSelectedLanguage()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    // MARK:- Button Action
    @IBAction func actionBack(_ sender: UIButton)
    {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK:- TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(strTabFrom == "Events")
        {
            if(DetailTextArray.count == 0){
                if(appDelegate.isPasswordBind != "0"){
                    emptyView()
                }
                return 0
            }else{
                restoreView()
                if(!bIsSeeMore){
                    return DetailTextArray.count + 1
                    
                }else{
                    return DetailTextArray.count
                    
                }
            }
        }else{
            if(holidayData.count == 0){
                if(appDelegate.isPasswordBind != "0"){
                    emptyView()
                }
                return 0
            }else{
                restoreView()
                
                print("holidayDatacount12345",holidayData.count)
                return holidayData.count
                
                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(strTabFrom == "Events")
        {
            if(indexPath.row <= (DetailTextArray.count - 1)){
                
                if(SelectedIndex == indexPath)
                {
                    if(SelectedStr == "Selected")
                    {
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            return 388
                        }else{
                            return 345
                        }
                    }else{
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            return 299
                        }else{
                            return 199
                        }
                    }
                }else
                {
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        return 299
                    }else{
                        return 199
                    }
                }
            }else{
                return 40
            }
        }else{
            
            
            print("automaticDimensionautomaticDimension")
            
            return 100
            
            //            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(strTabFrom == "Events")
        {
            
            
            
            if(indexPath.row <= (DetailTextArray.count - 1)){
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "TextFileTableViewCell", for: indexPath) as! TextFileTableViewCell
                cell1.backgroundColor = UIColor.clear
                cell1.selectionStyle = .none
                
                cell1.NewLbl.isHidden = true
                let dict = DetailTextArray[indexPath.row] as! NSDictionary
                cell1.TimeLbl.text = String(describing: dict["EventTime"]!)
                cell1.DateLbl.text = String(describing: dict["EventDate"]!)
                cell1.SubjectLbl.text = String(describing: dict["EventTitle"]!)
                cell1.NoticeTextView.text = String(describing: dict["EventContent"]!)
                let TextFieldChar : String = String(describing: dict["EventContent"]!)
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    if(TextFieldChar.count > 200)
                    {
                        cell1.ExtendArrow.isHidden = false
                        cell1.NoticeButton.tag = indexPath.row
                        
                        cell1.NoticeButton.addTarget(self, action: #selector(ExpandView(sender:)), for: .touchUpInside)
                        
                    }else{
                        cell1.ExtendArrow.isHidden = true
                        cell1.ExtendArrow.image = UIImage(named: "GrayDownArrow")
                        cell1.NoticeButton.isUserInteractionEnabled = false
                    }
                    
                }else
                {
                    if(TextFieldChar.count > 110)
                    {
                        cell1.ExtendArrow.isHidden = false
                        cell1.NoticeButton.tag = indexPath.row
                        
                        cell1.NoticeButton.addTarget(self, action: #selector(ExpandView(sender:)), for: .touchUpInside)
                        
                    }else{
                        cell1.ExtendArrow.isHidden = true
                        cell1.ExtendArrow.image = UIImage(named: "GrayDownArrow")
                        cell1.NoticeButton.isUserInteractionEnabled = false
                    }
                    
                }
                if(strLanguage == "ar"){
                    cell1.NoticeTextView.textAlignment = .right
                }else{
                    cell1.NoticeTextView.textAlignment = .left
                }
                return cell1
            }
            
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
                print("7")
                cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
                cell.backgroundColor = .clear
                return cell
                
            }
        }else{
            
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "holidayCelsTableViewCell", for: indexPath) as! holidayCelsTableViewCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            
            let dict: HolidayDataRes = holidayData[indexPath.row]
            if(strLanguage == "ar"){
                cell.HolidayDateLabel.textAlignment = .right
                //
                cell.FloatHolidayDateLabel.textAlignment = .right
                cell.HolidayDateLabel.text = dict.holiday_date
                cell.FloatHolidayDateLabel.text = dict.holiday_name
                cell.FloatHolidayDateLabel.textColor = .black
                //
                cell.HolidayDateLabel.numberOfLines = 0
                cell.FloatHolidayDateLabel.numberOfLines = 0
                cell.FloatHolidayDateLabel.textColor = .black
                if holidayData.count % 2 == 0{
                    
                    cell.subViews.backgroundColor = UIColor(named: "ColorDaily1")
                }
                
                
                else{
                    
                    cell.subViews.backgroundColor = UIColor(named: "ColorDaily2")
                    
                }
                
                
                
            }else{
                
                
                
                //
                cell.HolidayDateLabel.text = dict.holiday_date
                
                
                cell.FloatHolidayDateLabel.text = dict.holiday_name
                
                //
                cell.FloatHolidayDateLabel.textColor = .black
                
                //
                print("holidayData11.count",holidayData.count)
                
                if indexPath.row % 2 == 0{
                    
                    cell.subViews.backgroundColor = UIColor(named: "ColorDaily1")
                }
                
                
                else{
                    
                    cell.subViews.backgroundColor = UIColor(named: "ColorDaily2")
                    
                }
                
                
                
                
            }
            
            
            return cell
            
            
        }
        
    }
    
    @objc  func ExpandView(sender: UIButton)
    {
        let SenderButton = sender
        
        SelectedIndex = IndexPath(row: sender.tag, section: 0)
        let cell = EventTableView.cellForRow(at: SelectedIndex) as! TextFileTableViewCell
        if(SenderButton.isSelected)
        {
            SelectedStr = "Selected"
            SenderButton.isSelected = false
            cell.ExtendArrow.image = UIImage(named: "GrayUpArrow")
            
            
        }else{
            SelectedStr = "NotSelected"
            SenderButton.isSelected = true
            
            cell.ExtendArrow.image = UIImage(named: "GrayDownArrow")
            
        }
        EventTableView.reloadData()
        
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
        print("PSch")
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
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            strTabFrom = "Events"
            
            if(Util .isNetworkConnected())
            {
                self.CallDetailEventMessageApi()
            }
            else
            {
                DetailTextArray =  Childrens.getSchoolEvent(fromDB: ChildId) as! NSMutableArray
                if(DetailTextArray.count > 0)
                {
                    EventTableView.reloadData()
                }else{
                    Util .showAlert("", msg: strNoInternet)
                }
            }
        case 1:
            strTabFrom = "Holiday"
            
            if(Util .isNetworkConnected())
            {
                self.CallHolidayMessageApi()
            }
            else
            {
                Util .showAlert("", msg: strNoInternet)
            }
            
        default:
            break;
        }
    }
    
    
    // }
    // MARK:- Api Calling
    func CallHolidayMessageApi() {
        
        
        let pending = HolidaysModal()
        pending.memberid = ChildId
        pending.schoolid = SchoolId
        
        
        let pendingStr = pending.toJSONString()
        
        print("dashBoarddashBoard",pending.toJSON())
        
        HolidayRequest.call_request(param: pendingStr!) {
            [self]
            (res) in
            
            
            print("PendingReqsts",PendingReqsts.self)
            
            
            let pendingResponse : HolidaysRes = Mapper<HolidaysRes>().map(JSONString: res)!
            
            
            
            if pendingResponse.status == 1 {
                
                holidayData = pendingResponse.holidayData
                EventTableView.isHidden = false
                EventTableView.dataSource = self
                EventTableView.delegate = self
                EventTableView.reloadData()
            }else{
                EventTableView.isHidden = true
                
                
            }
            
            
            
            
        }
        
        
        
    }
    func CallSeeMoreHolidayMessageApi() {
        showLoading()
        strApiFrom = "CallSeeMoreHolidayMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + VIEW_HOLIDAYS_METHOD_SEEMORE
        
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + VIEW_HOLIDAYS_METHOD_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        print("requestStringer1",requestStringer)
        let myDict:NSMutableDictionary = ["memberid": ChildId,"schoolid" : SchoolId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        print(myDict)
        print(requestStringer)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreHolidayMessage")
    }
    
    func CallDetailEventMessageApi() {
        showLoading()
        strApiFrom = "CallDetailEventMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + SCHOOL_EVENT_MESSAGE
        print("requestStringer2",requestStringer)
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + SCHOOL_EVENT_MESSAGE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailEventMessage")
    }
    func CallSeeMoreDetailEventMessageApi() {
        showLoading()
        strApiFrom = "CallSeeMoreDetailEventMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + SCHOOL_EVENT_MESSAGE_SEEMORE
        print("requestStringer3",requestStringer)
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + SCHOOL_EVENT_MESSAGE_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreDetailEventMessage")
    }
    func CallReadStatusUpdateApi(_ circularDate : String,_ ID : String, _ type : String) {
        showLoading()
        strApiFrom = "detailssss"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        
        print("requestStringer4",requestStringer)
        
        
        let arrUserData : NSMutableArray = []
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["fn" : "ReadStatusUpdate","ChildID": selectedDictionary.object(forKey: "ChildID") as Any,"SchoolID" : selectedDictionary.object(forKey: "SchoolID") as Any,"Date" : circularDate,"Type" : type,"ID" : ID, COUNTRY_CODE: strCountryCode]
        
        arrUserData.add(myDict)
        
        let myString = Util.convertNSMutableArray(toString: arrUserData)
        
        
        apiCall.nsurlConnectionFunction(requestString, myString, type)
    }
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        
        if(csData != nil)
        {
            if(strApiFrom == "CallDetailEventMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    DetailTextArray.removeAllObjects()
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["Status"]!)
                        let Message = dict["Message"] as? String ?? ""
                        altSting = Message
                        if(Status == "1")
                        {
                            HiddenLabel.isHidden = true
                            DetailTextArray.add(dict)
                        }else{
                            //AlertMessage(strAlert: Message)
                            HiddenLabel.isHidden = true
                            HiddenLabel.text = Message
                            altSting = Message
                            if(appDelegate.isPasswordBind == "0"){
                                HiddenLabel.isHidden = false
                                
                            }
                            
                            
                            
                        }
                    }
                    
                    Childrens.saveSchoolEventDetail(DetailTextArray as! [Any] , ChildId)
                    
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    EventTableView.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
                }
            }
            else if(strApiFrom == "CallSeeMoreDetailEventMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    //DetailTextArray.removeAllObjects()
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["Status"]!)
                        let Message = String(describing: dict["Message"]!)
                        if(Status == "1")
                        {
                            HiddenLabel.isHidden = true
                            DetailTextArray.add(dict)
                        }else{
                            AlertMessage(strAlert: Message)
                            
                        }
                    }
                    
                    Childrens.saveSchoolEventDetail(DetailTextArray as! [Any] , ChildId)
                    
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    EventTableView.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
                }
            }
            else if(strApiFrom == "CallHolidayMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    HolidayDataArray.removeAllObjects()
                    
                    
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["status"]!)
                        let Message = String(describing: dict["message"]!)
                        if(Status == "0"){
                            //AlertMessage(strAlert: Message)
                            HiddenLabel.isHidden = true
                            HiddenLabel.text = Message
                            altSting = Message
                            if(appDelegate.isPasswordBind == "0"){
                                HiddenLabel.isHidden = false
                                
                            }
                            
                            
                        }else{
                            HiddenLabel.isHidden = true
                            HolidayDataArray.add(dict)
                        }
                        
                        
                    }
                    
                    utilObj.printLogKey(printKey: "HolidayDataArray", printingValue: HolidayDataArray)
                    EventTableView.reloadData()
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom == "CallSeeMoreHolidayMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    
                    
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["HolidayDate"]!)
                        let Message = String(describing: dict["Reason"]!)
                        if(Status == "0"){
                            AlertMessage(strAlert: Message)
                            
                        }else{
                            HiddenLabel.isHidden = true
                            HolidayDataArray.add(dict)
                        }
                    }
                    
                    utilObj.printLogKey(printKey: "HolidayDataArray", printingValue: HolidayDataArray)
                    EventTableView.reloadData()
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
        }else{
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
        
        if (segue.identifier == "DetailEventBoardSegue"){
            let segueid = segue.destination as! TextDetailVC
            
            segueid.selectedDictionary = SelectedTextDict
            segueid.SenderType = "SchoolEvent"
            
        }
    }
    
    func AlertMessage(strAlert : String){
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: strAlert, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            //self.dismiss(animated: true, completion: nil)
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
            self.EventTableView.semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            self.BottomView.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.EventTableView.semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            self.BottomView.semanticContentAttribute = .forceLeftToRight
        }
        HomeLabel.text = LangDict["home"] as? String
        //        LanguageLabel.text = LangDict["txt_language"] as? String
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        
        segmentedControl.setTitle(LangDict["events"] as? String, forSegmentAt: 0)
        segmentedControl.setTitle(LangDict["holidays"] as? String, forSegmentAt: 1)
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
        self.loadViewData()
        
    }
    
    func loadViewData(){
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.title = languageDictionary["events"] as? String
        strTabFrom = "Events"
        if(Util .isNetworkConnected())
        {
            self.CallDetailEventMessageApi()
        }
        else
        {
            DetailTextArray =  Childrens.getSchoolEvent(fromDB: ChildId) as! NSMutableArray
            if(DetailTextArray.count > 0)
            {
                EventTableView.reloadData()
            }else{
                Util .showAlert("", msg: strNoInternet)
            }
        }
        EventTableView.reloadData()
    }
    
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void {
        self.callSelectedLanguage()
    }
    //Mark:- SeeMore Feature
    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.EventTableView.bounds.size.width, height: self.EventTableView.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.EventTableView.bounds.size.width, height: 60))
        noDataLabel.text = altSting
        noDataLabel.textColor = .red
        noDataLabel.backgroundColor = UIColor(named: "NoDataColor")
        
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.EventTableView.bounds.size.width - 108, y: noDataLabel.frame.height + 30, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        self.EventTableView.backgroundView = noview
    }
    func restoreView(){
        self.EventTableView.backgroundView = nil
    }
    @objc func seeMoreButtonTapped(sender : UIButton) {
        //Write button action here
        bIsSeeMore = true
        self.EventTableView.reloadData()
        
        if(strTabFrom == "Events"){
            CallSeeMoreDetailEventMessageApi()
            
        }else{
            CallSeeMoreHolidayMessageApi()
        }
        
    }
    
    
}
