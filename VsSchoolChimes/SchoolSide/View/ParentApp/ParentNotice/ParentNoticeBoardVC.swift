//
//  NoticeBoardVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 01/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper


class ParentNoticeBoardVC: UIViewController,UITableViewDataSource,UITableViewDelegate,Apidelegate,UISearchBarDelegate {
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    
    var selectedDictionary = [String: Any]() as NSDictionary
    var SelectedTextDict = [String: Any]() as NSDictionary
    var DetailTextArray = NSMutableArray()
    var strApiFrom = NSString()
    var SelectedStr = String()
    var ChildId = String()
    var SchoolId = String()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var altSting = String()
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    
    
    weak var timer: Timer?
    var menuId : String!
    
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    @IBOutlet weak var TextDateLabel: UILabel!
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var NoticeBoardTableview: UITableView!
    
    @IBOutlet weak var AdView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var search_bar: UISearchBar!
    var hud : MBProgressHUD = MBProgressHUD()
    var SelectedIndex = IndexPath()
    
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var languageDictionary = NSDictionary()
    
    var bIsSeeMore = Bool()
    var getadID : Int!
    
    var type1 : Int!
    var instituteId : Int!
    var staffId  : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ParentNoticeBoardVC")
        
        let userDefaults = UserDefaults.standard
        
        
        print("typesss",type1)
        if  type1  == 1{
            
            
        }else{
            
            
            instituteId = userDefaults.integer(forKey: DefaultsKeys.SchoolD)
            staffId = userDefaults.integer(forKey: DefaultsKeys.StaffID)        }
        
        
        
        bIsSeeMore = false
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        
        
        
        
        
        search_bar.delegate = self
        if(appDelegate.isPasswordBind == "0"){
            bIsSeeMore = true
        }
        HiddenLabel.isHidden = true
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        NoticeBoardTableview.reloadData()
        
        
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        if(Util .isNetworkConnected()){
            self.CallDetailNoticeMessageApi()
        }else{
            DetailTextArray =  Childrens.getSchoolNoticeBoard(fromDB: ChildId)
            
            if(DetailTextArray.count > 0)
            {
                NoticeBoardTableview.reloadData()
            }else{
                Util .showAlert("", msg: strNoInternet)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    // MARK: - Navigation
    
    // MARK:- Button Action
    @IBAction func actionBack(_ sender: Any)
    {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
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
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if(indexPath.row <= (DetailTextArray.count - 1)){
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "TextFileTableViewCell", for: indexPath) as! TextFileTableViewCell
            cell1.backgroundColor = UIColor.clear
            cell1.NewLbl.isHidden = true
            let dict = DetailTextArray[indexPath.row] as! NSDictionary
            cell1.TimeLbl.text = String(describing: dict["Day"]!)
            cell1.DateLbl.text = String(describing: dict["Date"]!)
            cell1.SubjectLbl.text = String(describing: dict["NoticeBoardTitle"]!)
            cell1.NoticeTextView.text = String(describing: dict["NoticeBoardContent"]!)
            let TextFieldChar : String = String(describing: dict["NoticeBoardContent"]!)
            
            cell1.NoticeTextView.tintColor = .systemGreen
            cell1.NoticeTextView.isEditable = false
            cell1.NoticeTextView.dataDetectorTypes = .all
            
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
            return cell1
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
            print("6")
            cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
            cell.backgroundColor = .clear
            return cell
            
        }
    }
    
    @objc func ExpandView(sender: UIButton){
        let SenderButton = sender
        SelectedIndex = IndexPath(row: sender.tag, section: 0)
        let cell = NoticeBoardTableview.cellForRow(at: SelectedIndex) as! TextFileTableViewCell
        if(SenderButton.isSelected){
            SelectedStr = "Selected"
            SenderButton.isSelected = false
            cell.ExtendArrow.image = UIImage(named: "GrayUpArrow")
        }else{
            SelectedStr = "NotSelected"
            SenderButton.isSelected = true
            
            cell.ExtendArrow.image = UIImage(named: "GrayDownArrow")
            
        }
        NoticeBoardTableview.reloadData()
        
    }
    
    // MARK: - Api Calling
    func CallDetailNoticeMessageApi() {
        showLoading()
        strApiFrom = "CallDetailNoticeMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + NOTICE_BOARD_MESSAGE
        
        
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + NOTICE_BOARD_MESSAGE
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        print("requestStringer1",requestStringer)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailNoticeMessage")
    }
    func CallSeeMoreDetailNoticeMessageApi() {
        showLoading()
        strApiFrom = "CallSeeMoreDetailNoticeMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + NOTICE_BOARD_MESSAGE_SEEMORE
        
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + NOTICE_BOARD_MESSAGE_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        print("requestStringer2",requestStringer)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreDetailNoticeMessage")
    }
    
    func CallReadStatusUpdateApi() {
        
        strApiFrom = "UpdateReadStatus"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        print("requestStringer3",requestStringer)
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ID" : "","Type" : "SMS"]
        
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateReadStatus")
    }
    
    // MARK: - Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom == "CallDetailNoticeMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["Status"]!)
                        let Message = dict["Message"] as? String ?? ""
                        altSting = Message
                        if(Status == "1")
                        {
                            let dict = arrayData[i] as! NSDictionary
                            var MutalDict : NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
                            
                            MutalDict["ID"] = String(describing: i)
                            DetailTextArray.add(MutalDict)
                            MainDetailTextArray.add(MutalDict)
                        }else{
                            
                            if(appDelegate.isPasswordBind == "0"){
                                AlertMessage(strAlert: Message)
                            }
                            
                            
                        }
                    }
                    
                    DetailTextArray =  MainDetailTextArray
                    
                    Childrens.saveSchoolNoticeBoardDetail(DetailTextArray as! [Any] , ChildId)
                    
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    NoticeBoardTableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            if(strApiFrom == "CallSeeMoreDetailNoticeMessage")
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
                            let dict = arrayData[i] as! NSDictionary
                            var MutalDict : NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
                            
                            MutalDict["ID"] = String(describing: i)
                            DetailTextArray.add(MutalDict)
                        }else{
                            AlertMessage(strAlert: Message)
                            
                            
                            
                            
                        }
                    }
                    
                    
                    Childrens.saveSchoolNoticeBoardDetail(DetailTextArray as! [Any] , ChildId)
                    
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    NoticeBoardTableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom == "UpdateReadStatus")
            {
                if((csData?.count)! > 0){
                    
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
        // popupLoading.dismiss(true)
    }
    func AlertMessage(strAlert : String)
    {
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: strAlert, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(SelectedTextDict)
        
        if (segue.identifier == "DetailNoticeBoardSegue")
        {
            let segueid = segue.destination as! TextDetailVC
            
            segueid.selectedDictionary = SelectedTextDict
            segueid.SenderType = "NoticeBoard"
            
        }
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
                }
            } catch {
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
        TextDateLabel.text = LangDict["home_notice_board"] as? String
    }
    //Mark:- SeeMore Feature
    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.NoticeBoardTableview.bounds.size.width, height: self.NoticeBoardTableview.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.NoticeBoardTableview.bounds.size.width, height: 60))
        noDataLabel.text = altSting
        noDataLabel.textColor = .red
        noDataLabel.backgroundColor = UIColor(named: "NoDataColor")
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.NoticeBoardTableview.bounds.size.width - 108, y: noDataLabel.frame.height + 30, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        self.NoticeBoardTableview.backgroundView = noview
    }
    func restoreView(){
        self.NoticeBoardTableview.backgroundView = nil
    }
    @objc func seeMoreButtonTapped(sender : UIButton) {
        //Write button action here
        bIsSeeMore = true
        self.NoticeBoardTableview.reloadData()
        CallSeeMoreDetailNoticeMessageApi()
        
    }
    
    
    
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            DetailTextArray =  MainDetailTextArray
            self.NoticeBoardTableview.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "NoticeBoardContent CONTAINS [c] %@ OR NoticeBoardTitle CONTAINS [c] %@ ", searchText, searchText)
            let arrSearchResults = MainDetailTextArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            DetailTextArray = NSMutableArray(array: arrSearchResults)
            if(DetailTextArray.count > 0){
                self.NoticeBoardTableview.reloadData()
                print("DetailVoiceArray.count > 0")
            }else{
                print("noDataLabel.isHidden = false")
            }
            //            CallDetailSeeMoreEmergencyVocieApi()
            self.NoticeBoardTableview.reloadData()
        }
        
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_bar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //        self.NoticeBoardTableview.reloadData()
        //        CallSeeMoreDetailNoticeMessageApi()
        
        search_bar.resignFirstResponder()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBar.resignFirstResponder()")
        
        searchBar.resignFirstResponder()
        print("searchBar.resignFirstResponder()")
        print(DetailTextArray.count)
        
        SelectedSectionArray.removeAllObjects()
        DetailTextArray = MainDetailTextArray
        self.NoticeBoardTableview.reloadData()
    }
}
