//
//  PdfVC.swift
//  VoicesnapParentApp
//
//  Created by PREMKUMAR on 16/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper
import WebKit
import KRProgressHUD

class PdfVC: UIViewController,UITableViewDataSource,UITableViewDelegate,Apidelegate,UIGestureRecognizerDelegate ,URLSessionDownloadDelegate,UISearchBarDelegate, WKNavigationDelegate{
    
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var TextDateLabel: UILabel!
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var TextDetailstableview: UITableView!
    
    @IBOutlet weak var AdView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var webView: WKWebView!
    var ChildId = String()
    var getadID : Int!
    var SchoolId = String()
    var strLanguage = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var typesArray: NSMutableArray = []
    var selectedDictionary = NSDictionary()
    
    var selectedDetailDictionary = NSDictionary()
    var languageDictionary = NSDictionary()
    var strApiFrom = NSString()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var strSelectDate = NSString ()
    var popupDetailView : KLCPopup  = KLCPopup()
    var popupSignatureView : KLCPopup  = KLCPopup()
    var PDFSelectedDict = [String: Any]() as NSDictionary
    var strAgreeText : NSString = ""
    var strUploadID : NSString = ""
    var strDraw : NSString = ""
    var strSignQuestion : NSString = ""
    var strSignView : NSString = ""
    var strSenderType : NSString = ""
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    let singcolorText :UIColor = UIColor (red:222.0/255.0, green: 106.0/255.0, blue: 3.0/255.0, alpha: 1)
    var altSting = String()
    var bIsSeeMore = Bool()
    var bIsArchive = Bool()
    
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    
    var menuId : String!
    weak var timer: Timer?
    
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    
    var getArchive : String!
    var getMsgFromMgnt : Int! = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HiddenLabel.isHidden = true
        bIsSeeMore = false
        
        print("Circular123")
        
        print("getMsgFromMgnt",getMsgFromMgnt)
        
        
        print("getMsgFromMgnt",getMsgFromMgnt)
        if getMsgFromMgnt == 1 {
            let defaults = UserDefaults.standard
            print("SchoolId",SchoolId)
            
//
        }else{
            async {
                // 1
                let defaults = UserDefaults.standard
                print("SchoolId",SchoolId)
                
                SchoolId = defaults.string(forKey:DefaultsKeys.SchoolD)!
                ChildId = defaults.string(forKey:DefaultsKeys.chilId)!
                
                //
            }
            
            
            
            
            
            
            search_bar.delegate = self
            if(appDelegate.isPasswordBind == "0"){
                bIsSeeMore = true
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
        }
        
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    @IBAction func actionBack(_ sender: UIButton){
        if(strSenderType == "FromStaff")
        {
            
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: "comeBackStaff"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }else
        {
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        
    }
    
    // MARK: - TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var iCount : Int? = 0
        iCount = typesArray.count
        if(iCount == 0){
            if(appDelegate.isPasswordBind != "0"){
                emptyView()
            }
            iCount = 0
        }else{
            restoreView()
            if(!bIsSeeMore){
                iCount = iCount! + 1
                
            }
        }
        return iCount!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(indexPath.row <= (typesArray.count - 1)){
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "PdfFileTableViewCell", for: indexPath) as! PdfFileTableViewCell
            cell1.backgroundColor = UIColor.clear
            let detailsDictionary = typesArray.object(at: indexPath.row) as! NSDictionary
            cell1.TimeLbl.text = String(describing: detailsDictionary["Time"]!)
            cell1.SubjectLbl.text = String(describing: detailsDictionary["Subject"]!)
            cell1.DateLbl.text = String(describing: detailsDictionary["Date"]!)
            cell1.ViewFileButton.addTarget(self, action: #selector(viewPdfFile(sender:)), for: .touchUpInside)
            cell1.ViewFileButton.tag = indexPath.row
            cell1.DownloadButton.addTarget(self, action: #selector(PdfVC.SavePdfFileButton(sender:)), for: .touchUpInside)
            cell1.DownloadButton.tag = indexPath.row
            cell1.ViewFileButton.setTitle(languageDictionary["btn_pdf_view"] as? String, for: .normal)
            cell1.DownloadButton.setTitle(languageDictionary["btn_pdf_save"] as? String, for: .normal)
            cell1.DiscriptionLabel.text = languageDictionary["hint_view_pdf"] as? String
            cell1.descLbl.isHidden = true
            let iReadVoice : Int? = Int((detailsDictionary["AppReadStatus"] as? String)!)

           if(strSenderType == "FromStaff") {


            var desc  = String(describing: detailsDictionary["Description"]!)

            if desc != "" && desc != nil {

                cell1.descLbl.text = desc

                print("desc",desc)
                cell1.descLbl.isHidden = false

            }else{
                cell1.descLbl.isHidden = true
                print("desEmptyc",desc)


            }
//
            }
            if(iReadVoice == 0){
                cell1.NewLbl.isHidden = false
            }else{
                cell1.NewLbl.isHidden = true
            }
            
            
            return cell1
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
            print("cell.SeeMoreBtn10")
            cell.SeeMoreBtn.isHidden = false
            cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
            cell.backgroundColor = .clear
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.row <= (typesArray.count - 1)){
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return 170
            }else{
                return 120
            }
        }else{
            return 40
            
        }
    }
    
    @objc func viewPdfFile(sender : UIButton)
    {
        print("clickViewFile")
        let buttonTag = sender.tag
        let dicSelect : NSDictionary = typesArray.object(at: buttonTag) as! NSDictionary
        
        selectedDetailDictionary = dicSelect
        
        let dict = NSMutableDictionary(dictionary: dicSelect)
        
        let iReadVoice : Int? = Int((dicSelect["AppReadStatus"] as? String)!)
        
        print("iReadVoice",iReadVoice)
        if(iReadVoice == 0){
            
            dict["AppReadStatus"] = "1"
            
            typesArray[buttonTag] = dict
            
            if(Util .isNetworkConnected())
            {
                if(strSenderType == "FromStaff")
                {
                    bIsArchive = dict["is_Archive"] as? Bool ?? false
                    CallStaffReadStatusUpdateApi(String(describing: dicSelect["ID"]!) , "PDF")
                }else{
                    bIsArchive = dict["is_Archive"] as? Bool ?? false
                    CallReadStatusUpdateApi(String(describing: dicSelect["MessageID"]!) , "PDF")
                }
                
            }
            else
            {
                Util .showAlert("", msg: strNoInternet)
            }
        }
        TextDetailstableview.reloadData()
        
        
        
//        DispatchQueue.main.async { [self] in
            let myurlstring = String(describing: dicSelect["URL"]!)
                   let strUrl = myurlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                   
            
            
                  
            let vc = PdfViewVc(nibName: nil, bundle: nil)
            vc.myurlstring  = strUrl!
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
//              
//                }
            
           
        
        
    }

@objc func closeButtonTapped() {
       // Dismiss the view controller
       dismiss(animated: true, completion: nil)
   }
    
    
    @objc func SavePdfFileButton (sender : UIButton){
        // self.showLoading()
        let buttonTag = sender.tag
        let dicSelect : NSDictionary = typesArray.object(at: buttonTag) as! NSDictionary
        guard let url = URL(string:String(describing: dicSelect["URL"]!)) else { return }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
        
    }
    
    
    // MARK: - Api Calling
    
    func CallStaffPDFMessageApi() {
        showLoading()
        strApiFrom = "CallStaffPDFMessageApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_FILES_STAFF
        
        print("requestStringerCircular1",requestStringer)
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FILES_STAFF
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolId": SchoolId,"MemberId" : ChildId,"CircularDate" : TextDateLabel.text!,"Type" : "PDF", COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallStaffPDFMessageApi")
    }
    func CallSeeMoreStaffPDFMessageApi() {
        showLoading()
        strApiFrom = "CallSeeMoreStaffPDFMessageApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_FILES_STAFF_ARCHIVE
        print("requestStringerCircular2",requestStringer)
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FILES_STAFF_ARCHIVE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"SchoolId":"1235","MemberId":"112712","CircularDate":"20-05-2018","Type":"VOICE"}
        let myDict:NSMutableDictionary = ["SchoolId": SchoolId,"MemberId" : ChildId,"CircularDate" : TextDateLabel.text!,"Type" : "PDF", COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreStaffPDFMessageApi")
    }
    
    func CallPdfMessageApi() {
        showLoading()
        strApiFrom = "CallPdfMessageApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_EMERGENCY_FILES
        
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_EMERGENCY_FILES
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, "Type" : "PDF", COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        print("requestStringerCircular3",requestStringer)
        apiCall.nsurlConnectionFunction(requestString, myString, "CallPdfMessageApi")
    }
    func CallSeeMorePdfMessageApi() {
        showLoading()
        strApiFrom = "CallSeeMorePdfMessageApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_EMERGENCY_FILES_SEEMORE
        print("requestStringerCircularseemore1",requestStringer)
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_EMERGENCY_FILES_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, "Type" : "PDF", COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMorePdfMessageApi")
    }
    func CallReadStatusUpdateApi(_ ID : String, _ type : String) {
        showLoading()
        strApiFrom = "UpdateReadStatusApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        print("Circular1CallUpdateApi",requestStringer)
        if(bIsArchive){
            requestStringer = baseUrlString! + READ_STATUS_UPDATE_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["ID" : ID,"Type" : type, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertNSDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateReadStatusApi")
    }
    
    func CallStaffReadStatusUpdateApi(_ ID : String, _ type : String) {
        showLoading()
        strApiFrom = "UpdateReadStatusApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + READ_STATUS_UPDATE
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["ID" : ID,"Type" : type, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertNSDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateReadStatusApi")
    }
    // MARK: - Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        
        if(csData != nil)
        {
            if(strApiFrom == "CallPdfMessageApi")
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
                            typesArray.add(dict)
                            MainDetailTextArray.add(dict)
                            
                        }else{
                            if(appDelegate.isPasswordBind == "0"){
                                AlertMessage(strAlert: Message)
                            }
                            
                            
                            
                        }
                    }
                    utilObj.printLogKey(printKey: "typesArray", printingValue: typesArray)
                    TextDetailstableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            if(strApiFrom == "CallSeeMorePdfMessageApi")
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
                            typesArray.add(dict)
                            MainDetailTextArray.add(dict)
                        }else{
                            AlertMessage(strAlert: Message)
                            //
                            
                        }
                    }
                    utilObj.printLogKey(printKey: "typesArray", printingValue: typesArray)
                    TextDetailstableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            if(strApiFrom == "CallStaffPDFMessageApi")
            {
                
                print("arraarrayData",csData?.count)

                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    
                    print("arrayDataarrayData",arrayData.count)
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["ID"]!)
                        
                        let Message = String(describing: dict["URL"]!)
                        let CheckNilText : String = Util .checkNil(Status)
                        if(CheckNilText != "")
                        {
                            typesArray.add(dict)
                        }else{
                            AlertMessage(strAlert: Message)
                            
                            
                        }
                    }
                    
                    TextDetailstableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else             if(strApiFrom == "CallSeeMoreStaffPDFMessageApi")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["ID"]!)
                        
                        let Message = String(describing: dict["URL"]!)
                        let CheckNilText : String = Util .checkNil(Status)
                        if(CheckNilText != "")
                        {
                            typesArray.add(dict)
                        }else{
                            AlertMessage(strAlert: Message)
                            
                            
                        }
                    }
                    
                    TextDetailstableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else  if(strApiFrom == "UpdateReadStatusApi")
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
                            
                        }else{
                            
                        }
                    }
                    
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
        Util.showAlert("", msg: strSomething)
        
    }
    
    // MARK: - Loading
    func showLoading() -> Void {
        //  self.view.window?.userInteractionEnabled = false
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
            self.dismiss(animated: true, completion: nil)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "PdfDetailSeg"){
            let segueid = segue.destination as! PdfDetailVC
            segueid.selectedPDFDictionary = selectedDetailDictionary
            segueid.selectedDictionary = selectedDictionary
        }
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        if typesArray != nil{
            typesArray.removeAllObjects()
        }
        
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
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        
        if(Util .isNetworkConnected())
        {
            if(strSenderType == "FromStaff")
            {
                
                if(appDelegate.LoginSchoolDetailArray.count > 0)
                {
                    let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary

                    print("dictdictdict",dict)
                    if getMsgFromMgnt == 1 {
                        print("SCHOOLID",SchoolId)
                    }else{
                        ChildId = String(describing: dict["StaffID"]!)
                        SchoolId = String(describing: dict["SchoolID"]!)
                    }
                    TextDateLabel.text = String(describing: PDFSelectedDict["Date"]!)
                    
                    print("bIsArchivebIsArchive2222",dict["is_Archive"])
                    bIsArchive = PDFSelectedDict["is_Archive"] as? Bool ?? false
                   
                    print("bIsArchive1",bIsArchive)
                    print("getArchivegetArchive",getArchive)
                    
                    if(bIsArchive){
                        print("bIsArchivebIsArchiveifif",bIsArchive)
                        CallSeeMoreStaffPDFMessageApi()
                    }
                    
                    else{
                        
                        CallStaffPDFMessageApi()

               
                        
                    }
                }else{
                    Util.showAlert("", msg: strNoRecordAlert)
                }
            }else{
                if getMsgFromMgnt == 1 {
                    print("SCHOOLID",SchoolId)
                }else{
                    ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
                    SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
                }
                TextDateLabel.text =  languageDictionary["recent_files"] as? String
                self.CallPdfMessageApi()
            }
            
        }
        else
        {
            Util .showAlert("", msg: strNoInternet)
        }
        TextDetailstableview.reloadData()
    }
    //MARK : Download file
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents"){
                
                if(!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)){
                    try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                }
            }
            
            let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(url.lastPathComponent)
            
            if let iCloudDocumentsURL = iCloudDocumentsURL {
                var isDir:ObjCBool = false
                if(FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir)) {
                    try FileManager.default.removeItem(at: iCloudDocumentsURL)
                    try FileManager.default.copyItem(at: destinationURL, to: iCloudDocumentsURL)
                }else{
                    try FileManager.default.copyItem(at: destinationURL, to: iCloudDocumentsURL)
                }
            }
            self.showAlert(message: self.languageDictionary["pdf_saved"] as? String ?? "PDF file saved successfully!")
            
        } catch let error {
            
            print("Copy Error: \(error.localizedDescription)")
            self.showAlert(message: self.languageDictionary["pdf_alreadysaved"] as? String ?? "PDF file already saved!")
            
        }
    }
    
    func showAlert(message : String){
        let alert = UIAlertController(title: languageDictionary["alert"] as? String, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Mark:- SeeMore Feature
    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.TextDetailstableview.bounds.size.width, height: self.TextDetailstableview.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.TextDetailstableview.bounds.size.width, height: 60))
        noDataLabel.text = "No messages for the day. Click See More for previous messages."
        noDataLabel.textColor = .red
        noDataLabel.backgroundColor = UIColor(named: "NoDataColor")
        
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.TextDetailstableview.bounds.size.width - 108, y: noDataLabel.frame.height + 40, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        self.TextDetailstableview.backgroundView = noview
    }
    func restoreView(){
        self.TextDetailstableview.backgroundView = nil
        
    }
    
    @objc func seeMoreButtonTapped(sender : UIButton) {
        //Write button action here
        bIsSeeMore = true
        self.TextDetailstableview.reloadData()
        
        print("strSenderType",strSenderType)
        if(strSenderType == "FromStaff") {
            CallSeeMoreStaffPDFMessageApi()
    }else{
        CallSeeMorePdfMessageApi()
    }
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            typesArray = MainDetailTextArray
            
            self.TextDetailstableview.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "Subject CONTAINS [c] %@ OR Date CONTAINS [c] %@ ", searchText, searchText)
            let arrSearchResults = MainDetailTextArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            typesArray = NSMutableArray(array: arrSearchResults)
            if(typesArray.count > 0){
                self.TextDetailstableview.reloadData()
                print("DetailVoiceArray.count > 0")
            }else{
                print("noDataLabel.isHidden = false")
            }
            self.TextDetailstableview.reloadData()
        }
        
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_bar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //
        
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBar.resignFirstResponder()")
        
        searchBar.resignFirstResponder()
        print("searchBar.resignFirstResponder()")
        
        SelectedSectionArray.removeAllObjects()
        typesArray = MainDetailTextArray
        self.TextDetailstableview.reloadData()
    }
}

