//
//  AssignmentListVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 30/04/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper

class AssignmentListVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,Apidelegate,UISearchBarDelegate {
    
    var selectedDictionary = [String: Any]() as NSDictionary
    var SelectedTextDict = [String: Any]() as NSDictionary
    var SchoolDetailDict = [String: Any]() as NSDictionary
    var DetailTextArray = NSMutableArray()
    var strApiFrom = NSString()
    var SelectedStr = String()
    var ChildId = String()
    var SchoolId = String()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var assignmentDetailID = String()
    let todayDate = Calendar.current.startOfDay(for: Date())
    var fileType = String()
    var viewFrom = String()
    var strLanguage  = String()
    var altSting = String()
    
    var bIsSeeMore = Bool()
    var bIsArchive = Bool()
    
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    var getadID : Int!
    
    weak var timer: Timer?
    
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var AdView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var assignmentTableview: UITableView!
    @IBOutlet var PopupChooseImagePDFView: UIView!
    @IBOutlet weak var chooseLabel: UILabel!
    @IBOutlet weak var popupImageButton: UIButton!
    @IBOutlet weak var popupPdfButton: UIButton!
    
    @IBOutlet weak var search_bar: UISearchBar!
    var hud : MBProgressHUD = MBProgressHUD()
    var SelectedIndex = IndexPath()
    var popupChoosenBtn : KLCPopup  = KLCPopup()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var languageDictionary = NSDictionary()
    
    var menuId : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        bIsSeeMore = false
        print("Assignment456")
        
        
        
        
        search_bar.delegate = self
        if(appDelegate.isPasswordBind == "0"){
            bIsSeeMore = true
        }
        
        HiddenLabel.isHidden = true
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        assignmentTableview.reloadData()
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        if(Util .isNetworkConnected()){
            self.CallAssignmentMessageApi()
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    
    // MARK: - Button Action
    @IBAction func actionBack(_ sender: Any){
        print("back")
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func actionImageSelectionButton(_ sender: Any){
        fileType = "IMAGE"
        viewFrom = "Submission"
        popupChoosenBtn.dismiss(true)
        performSegue(withIdentifier: "ViewAsssignmentSegue", sender: self)
        
    }
    
    
    @IBAction func actionPDFButton(_ sender: Any){
        fileType = "PDF"
        viewFrom = "Submission"
        popupChoosenBtn.dismiss(true)
        performSegue(withIdentifier: "ViewAsssignmentSegue", sender: self)
    }
    
    @IBAction func actionClosePopUpButton(_ sender: Any) {
        popupChoosenBtn.dismiss(true)
    }
    
    // MARK: - TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
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
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return 400
            }else{
                return 340
            }
        }else{
            return 40
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row <= (DetailTextArray.count - 1)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentListTVCell", for: indexPath) as! AssignmentListTVCell
            cell.backgroundColor = UIColor.clear
            
            let dict:NSDictionary = DetailTextArray[indexPath.row] as! NSDictionary
            
            cell.dateLabel.text = dict["Date"] as? String
            cell.timeLabel.text =  dict["Time"] as? String
            cell.titleLabel.text = dict["Title"] as? String
            cell.typeLabel.text =  dict["Type"] as? String
            cell.sendByLabel.text = ": " +  String(describing: dict["SentBy"]!)
            cell.subjectLabel.text = ": " +  String(describing: dict["Subject"]!)
            cell.countLabel.text = ": " + String(describing: dict["SubmittedCount"]!)
            cell.categorylabel.text = ": " + String(describing: dict["category"]!)
            let dueDate = utilObj.convertStringIntoDate(strDate: String(describing: dict["EndDate"]!))
            cell.dueLabel.text = ": " + String(describing: dict["EndDate"]!)
            if( dueDate >= todayDate as Date ){
                cell.dueLabel.textColor = UIColor.black
            }else{
                cell.dueLabel.textColor = UIColor.red
            }
            if(String(describing: dict["SubmittedCount"]!) != "0"){
                
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    cell.submissionHeight.constant = 45
                }else{
                    cell.submissionHeight.constant = 35
                }
            }else{
                cell.submissionHeight.constant = 0
            }
            
            if(String(describing: dict["isAppRead"]!) == "1"){
                cell.newImageWidth.constant = 0
            }else{
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    cell.newImageWidth.constant = 45
                }else{
                    cell.newImageWidth.constant = 25
                }
            }
            
            cell.viewButton.addTarget(self, action: #selector(actionViewButton(sender:)), for: .touchUpInside)
            cell.viewButton.tag = indexPath.row
            
            cell.submitButton.addTarget(self, action: #selector(actionSubmitButton(sender:)), for: .touchUpInside)
            cell.submitButton.tag = indexPath.row
            
            cell.submissionButton.addTarget(self, action: #selector(actionSubmissionButton(sender:)), for: .touchUpInside)
            cell.submissionButton.tag = indexPath.row
            cell.layoutIfNeeded()
            if(strLanguage == "ar"){
                cell.mainView.semanticContentAttribute = .forceRightToLeft
                cell.subjectLabel.textAlignment = .right
                cell.dueLabel.textAlignment = .right
                cell.countLabel.textAlignment = .right
                cell.sendByLabel.textAlignment = .right
                
            }else{
                cell.subjectLabel.textAlignment = .left
                cell.dueLabel.textAlignment = .left
                cell.countLabel.textAlignment = .left
                cell.sendByLabel.textAlignment = .left
                
                
            }
            cell.subjectLabelLang.text = languageDictionary["teacher_atten_subject"] as? String
            cell.dueLabelLang.text = languageDictionary["subission_due"] as? String
            cell.countLabelLang.text = languageDictionary["subission_count"] as? String
            cell.sendByLabelLang.text = languageDictionary["send_by"] as? String
            cell.categoryLabelLang.text = languageDictionary["category"] as? String
            cell.viewButton.setTitle(languageDictionary["view"] as? String, for: .normal)
            cell.submitButton.setTitle(languageDictionary["btn_sign_submit"] as? String, for: .normal)
            cell.submissionButton.setTitle(languageDictionary["submissions"] as? String, for: .normal)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
            cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
            cell.backgroundColor = .clear
            return cell
            
        }
        
    }
    
    @objc func actionViewButton(sender: UIButton){
        selectedDictionary = DetailTextArray[sender.tag] as! NSDictionary
        bIsArchive = selectedDictionary["is_Archive"] as? Bool ?? false
        
        viewFrom = "View"
        fileType = String(describing: selectedDictionary["Type"]!)
        CallReadStatusUpdateApi()
    }
    
    @objc func actionSubmitButton(sender: UIButton){
        selectedDictionary = DetailTextArray[sender.tag] as! NSDictionary
        performSegue(withIdentifier: "SubmitAssignmentSegue", sender: self)
    }
    
    @objc func actionSubmissionButton(sender: UIButton){
        selectedDictionary = DetailTextArray[sender.tag] as! NSDictionary
        PopupChooseImagePDFView.frame.size.height = 250
        PopupChooseImagePDFView.frame.size.width = 400
        //                 
    }
    
    
    // MARK:- Api Calling
    func CallAssignmentMessageApi() {
        showLoading()
        strApiFrom = "CallAssignmentMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_STUDENT_ASSIGNMENT_LIST
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + POST_STUDENT_ASSIGNMENT_LIST
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ProcessBy": ChildId, COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber , SCHOOLIID : SchoolId]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        print("ASSSIGNMENT1111",requestString)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailAssignmentMessage")
    }
    func CallseeMoreAssignmentMessageApi() {
        showLoading()
        strApiFrom = "CallseeMoreAssignmentMessages"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_STUDENT_ASSIGNMENT_LIST_SEEMORE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + POST_STUDENT_ASSIGNMENT_LIST_SEEMORE
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ProcessBy": ChildId, COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber , SCHOOLIID : SchoolId]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        print("ASSSIGNMENT",requestString)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallseeMoreAssignmentMessages")
    }
    
    func CallReadStatusUpdateApi() {
        showLoading()
        strApiFrom = "UpdateReadStatus"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        
        if(bIsArchive){
            requestStringer = baseUrlString! + READ_STATUS_UPDATE_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["ID" : String(describing: selectedDictionary["DeTailId"]!),"Type" : "ASSIGNMENT"]
        
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateReadStatus")
    }
    
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom == "CallAssignmentMessage")
            {
                if let CheckedArray = csData as? NSArray{
                    print(CheckedArray)
                    if(CheckedArray.count > 0){
                        let Dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        let strmessage = Dict.object(forKey: "Message") as? String ?? ""
                        
                        if(Dict["AssignmentId"] != nil){
                            DetailTextArray = NSMutableArray(array: CheckedArray)
                            assignmentTableview.reloadData()
                            MainDetailTextArray = NSMutableArray(array: CheckedArray)
                        }else{
                            DetailTextArray = []
                            if(appDelegate.isPasswordBind == "0"){
                                AlertMessage(strAlert: NO_RECORD_MESSAGE)
                            }else{
                                altSting = strmessage
                            }
                        }
                        
                    }else{
                        DetailTextArray = []
                        if(appDelegate.isPasswordBind == "0"){
                            AlertMessage(strAlert: NO_RECORD_MESSAGE)
                        }
                    }
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    assignmentTableview.reloadData()
                    
                    
                }
                else{
                    AlertMessage(strAlert: strSomething)
                }
            }
            else if(strApiFrom == "CallseeMoreAssignmentMessages")
            {
                if let CheckedArray = csData{
                    
                    if(CheckedArray.count > 0){
                        let Dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        let strmessage = Dict.object(forKey: "Message") as? String ?? NO_RECORD_MESSAGE
                        
                        if(Dict["AssignmentId"] != nil){
                            DetailTextArray = NSMutableArray(array: CheckedArray)
                            MainDetailTextArray = NSMutableArray(array: CheckedArray)
                            assignmentTableview.reloadData()
                            
                        }else{
                            DetailTextArray = []
                            AlertMessage(strAlert: strmessage)
                        }
                        
                    }else{
                        DetailTextArray = []
                        AlertMessage(strAlert: NO_RECORD_MESSAGE)
                    }
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    assignmentTableview.reloadData()
                    
                    
                }
                else{
                    AlertMessage(strAlert: strSomething)
                }
            }
            else if(strApiFrom == "UpdateReadStatus")
            {
                if(String(describing: selectedDictionary["Type"]!) == "VOICE"){
                    performSegue(withIdentifier: "VedioAssignmentDetailSegue", sender: self)
                }else{
                    performSegue(withIdentifier: "ViewAsssignmentSegue", sender: self)
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
        if (segue.identifier == "ViewAsssignmentSegue"){
            let segueid = segue.destination as! ViewAssignmentVC
            segueid.selectedDictionary = selectedDictionary
            segueid.viewFrom = self.viewFrom
            segueid.fileType = self.fileType
            segueid.isStaff = "false"
        }
        if (segue.identifier == "VedioAssignmentDetailSegue"){
            let segueid = segue.destination as! AssignmentVideoDetailVC
            segueid.selectedDictionary = selectedDictionary
            segueid.isStaff = "false"
        }
        if (segue.identifier == "SubmitAssignmentSegue"){
            let segueid = segue.destination as! StudentSubmitAssignmentVC
            segueid.selectedDictionary = selectedDictionary
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
        strLanguage = Language
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        
        chooseLabel.text = LangDict["choose"] as? String ?? "Choose"
        popupPdfButton.setTitle(LangDict["choose_pdf"] as? String ?? "Choose Pdf", for: .normal)
        popupImageButton.setTitle(LangDict["choose_image"] as? String ?? "Choose Image", for: .normal)
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
    @objc func reloadApiData(notification:Notification) -> Void {
        self.CallAssignmentMessageApi()
    }
    
    //Mark:- SeeMore Feature
    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.assignmentTableview.bounds.size.width, height: self.assignmentTableview.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.assignmentTableview.bounds.size.width, height: 60))
        noDataLabel.text = "No messages for the day.Click \("See More") for previous messages."
        noDataLabel.textColor = .red
        noDataLabel.backgroundColor = UIColor(named: "NoDataColor")
        
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.assignmentTableview.bounds.size.width - 108, y: noDataLabel.frame.height + 30, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        self.assignmentTableview.backgroundView = noview
    }
    func restoreView(){
        self.assignmentTableview.backgroundView = nil
        
    }
    @objc func seeMoreButtonTapped(sender : UIButton) {
        bIsSeeMore = true
        self.assignmentTableview.reloadData()
        CallseeMoreAssignmentMessageApi()
    }
    
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            DetailTextArray = MainDetailTextArray
            self.assignmentTableview.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "Subject CONTAINS [c] %@ OR Title CONTAINS [c] %@ ", searchText, searchText)
            
            let arrSearchResults = MainDetailTextArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            DetailTextArray = NSMutableArray(array: arrSearchResults)
            if(DetailTextArray.count > 0){
                self.assignmentTableview.reloadData()
                print("DetailVoiceArray.count > 0")
            }else{
                print("noDataLabel.isHidden = false")
            }
            
            self.assignmentTableview.reloadData()
        }
        
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_bar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        search_bar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        DetailTextArray =  MainDetailTextArray
        self.assignmentTableview.reloadData()
    }
    
}
