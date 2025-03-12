//
//  HomeWorkVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 01/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper
import WebKit

class HomeWorkVC: UIViewController,Apidelegate ,UIPopoverPresentationControllerDelegate,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate{
    
    
    
    var SelectedTextDict = [String: Any]() as NSDictionary
    var SelectedVoiceDict = [String: Any]() as NSDictionary
    var DetailTextArray = NSMutableArray()
    
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    var strLanguage = String()
    var strText = String()
    var strVoice = String()
    var strCountryCode = String()
    var languageDictionary = NSDictionary()
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var MyTableView: UITableView!
    
    
    @IBOutlet weak var cv: UICollectionView!
    
    
    @IBOutlet weak var AdView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    @IBOutlet weak var search_bar: UISearchBar!
    var hud : MBProgressHUD = MBProgressHUD()
    var altSting = String()
    var bIsSeeMore = Bool()
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    var menuId : String!
    
    weak var timer: Timer?
    var getadID : Int!
    
    var dataListArr : [HWDataList] = []
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    var testHwcount : Int!
    var hwDataList : [HomeWorkArchiveDataList] = []
    var hw :  [HWDataList] = []
    var hwFilePath :  [HWFilePath] = []
    var cloneList :  [HomeWorkArchiveDataList] = []
    
    var rowIdentifier = "ParentHomeWorkCollectionViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        bIsSeeMore = false
        
        print("HOMEWORKVCC")
        
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        
        //
        
        
        
        
        cv.dataSource = self
        cv.delegate = self
        MyTableView.dataSource  = self
        MyTableView.delegate = self
        
        
        search_bar.delegate = self
        
        if(appDelegate.isPasswordBind == "0"){
            bIsSeeMore = true
        }
        HiddenLabel.isHidden = true
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        cv.reloadData()
        search_bar.delegate = self
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            
            
            
            homeWorkRes()
            
        }
        
        
        
        
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
        
        //
        cv.register(UINib(nibName: rowIdentifier, bundle: nil), forCellWithReuseIdentifier: rowIdentifier)
        
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
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(HomeWorkVC.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        nc.addObserver(self,selector: #selector(HomeWorkVC.UpdateLogoutSelection), name: NSNotification.Name(rawValue: "SettingNotification"), object:nil)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    
    @objc func actionVoiceButton(sender: UIButton)
    {
        SelectedVoiceDict = DetailTextArray[sender.tag] as! NSDictionary
        let VoiceCount = String(describing: SelectedVoiceDict["VoiceCount"]!)
        if(VoiceCount != "0")
        {
            performSegue(withIdentifier: "HomeWorkToVoiceSegue", sender: self)
        }
    }
    
    @objc func TextButton(sender: UIButton)
    {
        SelectedTextDict = DetailTextArray[sender.tag] as! NSDictionary
        let TextCount = String(describing: SelectedTextDict["TextCount"]!)
        if(TextCount != "0")
        {
            performSegue(withIdentifier: "HomeWorkToTextSegue", sender: self)
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
        print("HMVC")
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
    
    // MARK:- Api Calling
    func CallHomeWorkMessageApi() {
        showLoading()
        strApiFrom = "CallHomeWorkMessageApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + HOMEWORK_MESSAGE_COUNT
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + HOMEWORK_MESSAGE_COUNT
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallHomeWorkMessageApi")
    }
    
    func CallSeeMoreHomeWorkMessageApi() {
        showLoading()
        
        let modal = ParentHomeWorkArchiveModal()
        modal.ChildID = ChildId
        

        let modal_str = modal.toJSONString()
        print("homeWorkResChildId",modal_str)

        ParentHomeWorkArchiveRequest.call_request(param: modal_str!) {
            [self]
            (res) in
            
            let modal_response : [ParentHomeWorkArchiveResponse] = Mapper<ParentHomeWorkArchiveResponse>().mapArray(JSONString: res)!
            
            
            
            
            
            
            if modal_response[0].Status.elementsEqual("1") {
                
                
                self.hwDataList =  hwDataList + modal_response[0].homeWorkArchiveData
                cloneList = modal_response[0].homeWorkArchiveData
                
                hideLoading()
                for i in hwDataList {
                    hw = i.hwData
                    
                }
                
                for i in hw {
                    hwFilePath = i.filepath
                }
                
                cv.dataSource = self
                cv.delegate = self
                cv.reloadData()
                
                HiddenLabel.isHidden = true
            }else{
                hideLoading()
                HiddenLabel.isHidden = false
                HiddenLabel.text  = modal_response[0].Message
                
            }
            
            
            
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "csData", printingValue: csData)
            if(strApiFrom == "CallHomeWorkMessageApi")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    DetailTextArray.removeAllObjects()
                    MainDetailTextArray.removeAllObjects()
                    if (arrayData.count > 0)
                    {
                        for i in 0..<arrayData.count
                        {
                            let dict = CheckedArray[i] as! NSDictionary
                            let strhone = dict["HomeworkDay"] as? String ?? ""
                            if(dict["HomeworkDay"] != nil && strhone != ""){
                                DetailTextArray.add(dict)
                                MainDetailTextArray.add(dict)
                            }else{
                                // AlertMessage()
                                let strhone = dict["TextCount"] as? String ?? "No record found"
                                
                                altSting = strhone
                                
                                if(appDelegate.isPasswordBind == "0"){
                                    AlertMessage()
                                }
                            }
                            
                            
                        }
                    }else{
                        // AlertMessage()
                        altSting = "No record found"
                        
                    }
                    DetailTextArray =  MainDetailTextArray
                    Childrens.saveHomeWorkDetail(DetailTextArray as! [Any], ChildId)
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    cv.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            //
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
        utilObj.printLogKey(printKey: "SelectedVoiceDict", printingValue: SelectedVoiceDict)
        utilObj.printLogKey(printKey: "SelectedTextDict", printingValue: SelectedTextDict)
        
        if (segue.identifier == "HomeWorkToVoiceSegue")
        {
            let segueid = segue.destination as! HomeWorkVoiceVC
            
            segueid.VoiceDict = SelectedVoiceDict
            
            
        }
        else if (segue.identifier == "HomeWorkToTextSegue")
        {
            let segueid = segue.destination as! HomeWorkTextVC
            
            segueid.selectedDictionary = SelectedTextDict
            
            
        }
    }
    func AlertMessage()
    {
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: strNoRecordAlert, preferredStyle: .alert)
        
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
            self.cv.semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            self.BottomView.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.cv.semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            self.BottomView.semanticContentAttribute = .forceLeftToRight
        }
        HomeLabel.text = LangDict["home"] as? String
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        strText = LangDict["teacher_txt_text"] as? String ?? "Text"
        strVoice = LangDict["teacher_txt_voice"] as? String ?? "Voice"
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        self.title = languageDictionary["title_homework"] as? String
        if(Util .isNetworkConnected()){
            self.CallHomeWorkMessageApi()
        }
        else
        {
            DetailTextArray = Childrens.getHomeWorkDetail(fromDB: ChildId)
            if(DetailTextArray.count > 0)
            {
                cv.reloadData()
            }else{
                Util .showAlert("", msg: strNoInternet)
            }
        }
        cv.reloadData()
    }
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void {
        self.callSelectedLanguage()
    }
    //Mark:- SeeMore Feature
    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.cv.bounds.size.width, height: self.cv.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.cv.bounds.size.width, height: 60))
        noDataLabel.text = altSting
        noDataLabel.textColor = .red
        noDataLabel.backgroundColor = UIColor(named: "NoDataColor")
        
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.cv.bounds.size.width - 108, y: noDataLabel.frame.height + 30, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        self.cv.backgroundView = noview
    }
    func restoreView(){
        self.cv.backgroundView = nil
    }
    @objc func seeMoreButtonTapped(sender : UIButton) {
        //Write button action here
        bIsSeeMore = true
        
        self.cv.reloadData()
        CallSeeMoreHomeWorkMessageApi()
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        
        let filtered_list : [HomeWorkArchiveDataList] = Mapper<HomeWorkArchiveDataList>().mapArray(JSONString: cloneList.toJSONString()!)!
        
        
        if !searchText.isEmpty{
            
            
            
            hwDataList = filtered_list.filter {
                $0.date.lowercased().contains(searchText.lowercased())
            }
            
            
            
        }else{
            
            
            
            hwDataList = filtered_list
            
            HiddenLabel.isHidden = true
            
            
            print("pendingList")
            
            
            
        }
        
        
        if hwDataList.count > 0{
            HiddenLabel.isHidden = true
            
            print ("searchListPendigCount",hwDataList.count)
        }else{
            
            HiddenLabel.isHidden = false
            HiddenLabel.text = "No Records Found"
            
        }
        
        
        
        
        
        
        
        cv.reloadData()
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        DetailTextArray = MainDetailTextArray
        self.cv.reloadData()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_bar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.MyTableView.reloadData()
        
        search_bar.resignFirstResponder()
    }
    
    
    
    
    
    func homeWorkRes() {
        let modal = ParentHomeWorkArchiveModal()
        modal.ChildID = ChildId
        print("homeWorkResChildId",ChildId)
        let modal_str = modal.toJSONString()
        
        
        print("homeworkRequest",modal_str)
        ParentGetHomeWorkRequest.call_request(param: modal_str!) {
            [self]
            (res) in
            print("HomeWorkresponce",res)
            let modal_response : [ParentHomeWorkArchiveResponse] = Mapper<ParentHomeWorkArchiveResponse>().mapArray(JSONString: res)!
            
            if modal_response[0].Status.elementsEqual("1") {
                self.hwDataList = modal_response[0].homeWorkArchiveData
                cloneList = modal_response[0].homeWorkArchiveData
                for i in hwDataList {
                    hw = i.hwData
                    
                }
                
                for i in hw {
                    hwFilePath = i.filepath
                }
                
                cv.dataSource = self
                cv.delegate = self
                cv.reloadData()
                HiddenLabel.isHidden = true
            }else{
                hideLoading()
                HiddenLabel.isHidden = false
                HiddenLabel.text  = modal_response[0].Message
                
            }
            
            
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return   hwDataList.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rowIdentifier, for: indexPath) as! ParentHomeWorkCollectionViewCell
        
        let hwList : HomeWorkArchiveDataList = hwDataList[indexPath.item]
        print("hwDataList.count",hwList.hwData.count)
        cell.dateLbl.text = hwList.date
        cell.hwCountLbl.text =  String(hwList.hwData.count)
        //
        
        if(bIsSeeMore)
        {
            MyTableView.isHidden = true
        }else{
            MyTableView.isHidden = false
        }
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = (view.frame.width-25)/3
        return CGSize(width: width, height: 120)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let hwList : HomeWorkArchiveDataList = hwDataList[indexPath.item]
        
        let vc = ParentHWImagePdfVoiceViewController(nibName: nil, bundle: nil)
        vc.filePathListArr = hwList.hwData
        
        vc.filepath = hwFilePath
        vc.dateText = hwList.date
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
        print("5")
        cell.selectionStyle = .none
        cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        cell.backgroundColor = .clear
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 40
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if(!bIsSeeMore){
            return DetailTextArray.count + 1
            
        }else{
            return DetailTextArray.count
            
        }
    }
}
