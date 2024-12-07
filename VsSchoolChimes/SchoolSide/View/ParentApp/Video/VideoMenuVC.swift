//
//  VideoMenuVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 26/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import ObjectMapper

class VideoMenuVC: UITableViewController ,Apidelegate,UISearchBarDelegate {
    
    var typesArray: NSMutableArray = []
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    var strSelectedVideoUrl = String()
    var strSelectedVideoId = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var selectedDictionary = NSDictionary()
    var strSelectDate = NSString ()
    var SenderType = NSString ()
    var Screenheight = CFloat()
    @IBOutlet weak var TextDateLabel: UILabel!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var TextDetailstableview: UITableView!
    var ImageSelectedDict = [String: Any]() as NSDictionary
    var detailsDictionaryfull = NSDictionary()
    var languageDict = NSDictionary()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    let tableBg :UIColor = UIColor (red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.9)
    var hud : MBProgressHUD = MBProgressHUD()
    var altSting = String()
    
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    
    var ArrayData = NSMutableArray()
    var getVideoId : String!
    weak var timer: Timer?
    
    
    var AdView : UIView!
    var adViewHeight : NSLayoutConstraint!
    var imgView : UIImageView!
    var bIsSeeMore = Bool()
    var bIsArchive = Bool()
    
    var search_Bar : UISearchBar!
    var appBgImage : UIImageView!
    
    var getadID : Int!
    var menuId : String!
    var popupLoading : KLCPopup = KLCPopup()
    var getDownloadShowID : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Video3")
        
        self.bIsSeeMore = false
        if(appDelegate.isPasswordBind == "0"){
            bIsSeeMore = true
        }
        self.TextDetailstableview.tableHeaderView = tableHeaderView
        self.TextDetailstableview.backgroundColor = tableBg
        self.view.backgroundColor = .white
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(VideoMenuVC.callNotification), name: NSNotification.Name(rawValue: "comeBackVimeoVideo"), object:nil)
        
    }
    
    @objc func callNotification(notification:Notification) -> Void {
        self.loadViewData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    @IBAction func actionBack(_ sender: UIButton){
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if(typesArray.count == 0){
            if(appDelegate.isPasswordBind != "0"){
                emptyView()
            }
            return 0
        }else{
            restoreView()
            if(!bIsSeeMore){
                return typesArray.count + 1
                
            }else{
                return typesArray.count
                
            }
        }
        
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if(indexPath.row <= (typesArray.count - 1)){
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "ImageFileTableViewCell", for: indexPath) as! ImageFileTableViewCell
            
            let detailsDictionary = typesArray.object(at: indexPath.row) as! NSDictionary
            cell1.DateLbl.text = String(describing: detailsDictionary["CreatedOn"]!)
            cell1.TimeLbl.text =  String(describing: detailsDictionary["CreatedBy"]!)
            cell1.TitleLbl.text = String(describing: detailsDictionary["Title"]!)
            cell1.SubjectLbl.text = String(describing: detailsDictionary["Description"]!)
            
            let iReadVoice : Int? = Int((detailsDictionary["IsAppViewed"] as? String)!)
            if(iReadVoice == 0){
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    cell1.NewLblWidth.constant = 45
                }else{
                    cell1.NewLblWidth.constant = 25
                }
                cell1.NewLbl.isHidden = false
            }
            else{
                cell1.NewLblWidth.constant = 0
                cell1.NewLbl.isHidden = true
            }
            cell1.MyImageView.image = UIImage(named: "VideoPlaceholder")
            
            return cell1
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
            cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
            cell.backgroundColor = .clear
            return cell
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // return UITableView.automaticDimension
        if(indexPath.row <= (typesArray.count - 1)){
            let dict = typesArray[indexPath.row] as! NSDictionary
            
            var DescriptionText = String()
            var CheckNilText = String()
            DescriptionText = String(describing: dict["Description"]!)
            CheckNilText  = Util .checkNil(DescriptionText)
            if(CheckNilText != "")        {
                
                let Stringlength : Int = CheckNilText.count
                
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    let MuValue : Int = Stringlength/61
                    return (395 + ( 22 * CGFloat(MuValue)))
                }else{
                    if(Screenheight > 580)
                    {
                        let MuValue : Int = Stringlength/50
                        return (265 + ( 18 * CGFloat(MuValue)))
                        
                    }else{
                        let MuValue : Int = Stringlength/44
                        return (265 + ( 18 * CGFloat(MuValue)))
                        
                    }
                }
                
            }
            else{
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return 373
                }else{
                    return 250
                }
                
            }
        }else{
            return 40
            
        }
        
        
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailsDictionary = typesArray.object(at: indexPath.row) as! NSDictionary
        
        
        bIsArchive = detailsDictionary["is_Archive"] as? Bool ?? false
        self.CallReadStatusUpdateApi(String(describing: detailsDictionary["DetailID"]!), "VIDEO")
     
        print("GETVIDEOID1\(detailsDictionary["VideoId"])")
      
        print("GEVimeoUrl1\(detailsDictionary["VimeoUrl"])")
        strSelectedVideoUrl = String(describing: detailsDictionary["VimeoUrl"]!)
        strSelectedVideoId = String(describing: detailsDictionary["VimeoId"]!)
        getDownloadShowID = Int(String(describing:detailsDictionary["isDownload"]!))
        
        if let questionMarkIndex = strSelectedVideoId.firstIndex(of: "?") {
            let result = String(strSelectedVideoId[..<questionMarkIndex]) // Extract substring before "?"
            print("Digits before '?': \(result)")
            getVideoId = String(result)
        } else {
            print("No '?' found in the string.")
        }
        
        
        DispatchQueue.main.async() {
            self.performSegue(withIdentifier: "VdieoDetailSegue", sender: self)
        }
        // self.playVimeoVideo()
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let newHeight = newWidth
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = newImage!.jpegData(compressionQuality: 0.5)! as Data
        UIGraphicsEndImageContext()
        
        return  UIImage(data:imageData)!;
    }
    
    func CallReadStatusUpdateApi(_ ID : String, _ type : String) {
        
        strApiFrom = "UpdateReadStatus"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        if(bIsArchive){
            // if(appDelegate.isPasswordBind == "1" && bIsArchive){
            requestStringer = baseUrlString! + READ_STATUS_UPDATE_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ID" : ID,"Type" : type, COUNTRY_CODE: strCountryCode]
        
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateReadStatus")
    }
    
    func CallVideoDetailApi() {
        showLoading()
        strApiFrom = "CallVideoDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_VIDEO_FILES
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_VIDEO_FILES
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["StudentId": ChildId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallVideoDetailApi")
    }
    func CallSeeMoreVideoDetailApi() {
        showLoading()
        strApiFrom = "CallSeeMoreVideoDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_VIDEO_FILES_SEEMORE
        
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_VIDEO_FILES_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["StudentId": ChildId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreVideoDetailApi")
    }
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        if(csData != nil){
            utilObj.printLogKey(printKey: "csData", printingValue: csData)
            if(strApiFrom == "StaffImageReadStatus"){
                if((csData?.count)! > 0){
                    TextDetailstableview.reloadData()
                }
            }else if(strApiFrom == "UpdateReadStatus"){
                
            }
            else if(strApiFrom == "CallVideoDetailApi")
            {
                //                typesArray.removeAllObjects()
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["result"]!)
                        let Message =  dict["Message"] as? String ?? ""
                        altSting = Message
                        if(Status == "1"){
                            typesArray.add(dict)
                            ArrayData.add(dict)
                        }else{
                            if(appDelegate.isPasswordBind == "0"){
                                //emptyView()
                                AlerMessage()
                                
                            }
                        }
                    }
                    typesArray = ArrayData
                    utilObj.printLogKey(printKey: "typesArray", printingValue: typesArray)
                    TextDetailstableview.reloadData()
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom == "CallSeeMoreVideoDetailApi")
            {
                // typesArray.removeAllObjects()
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["result"]!)
                        let Message = String(describing: dict["Message"]!)
                        if(Status == "1"){
                            typesArray.add(dict)
                        }else{
                            AlerMessage()
                        }
                    }
                    utilObj.printLogKey(printKey: "typesArray", printingValue: typesArray)
                    TextDetailstableview.reloadData()
                    
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
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        
        Util .showAlert("", msg: pagename.localizedDescription);
        
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "VdieoDetailSegue")
        {
            let segueid = segue.destination as! VimeoVideoDetailVC
            segueid.strVideoUrl = strSelectedVideoUrl
            segueid.videoId = strSelectedVideoId
            segueid.downloadVideoID = getVideoId
            segueid.getDownloadShowID = getDownloadShowID
           
        }
    }
    
    func showLoading() -> Void {
        //  self.view.window?.userInteractionEnabled = false
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        
        hud.hide(true)
    }
    func AlerMessage()
    {
        
        let alertController = UIAlertController(title: languageDict["alert"] as? String, message: strNoRecordAlert, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: languageDict["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            // print("Okaction")
            self.dismiss(animated: true, completion: nil)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
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
                }else{
                    self.loadViewData()
                }
            } catch {
                self.loadViewData()
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        loadViewData()
    }
    
    func loadViewData(){
        Screenheight = CFloat(self.view.frame.size.height)
        if(Util .isNetworkConnected()){
            ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
            SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
            self.CallVideoDetailApi()
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
    }
    
    
    //Mark:- SeeMore Feature
    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.TextDetailstableview.bounds.size.width, height: self.TextDetailstableview.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y:  190, width: self.TextDetailstableview.bounds.size.width, height: 60))
        noDataLabel.text = altSting
        noDataLabel.textColor = .red
        noDataLabel.backgroundColor = UIColor(named: "NoDataColor")
        
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        //
        
        let button = UIButton(frame: CGRect(x: self.TextDetailstableview.bounds.size.width - 108, y: noDataLabel.frame.height + 200, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        
        
        self.TextDetailstableview.backgroundView = noview
        
        
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
                    
                    
                    
                    //            var adDataList : [MenuData] = []
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
        
        
        self.TextDetailstableview.backgroundView = noview
        
        
        
        
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
    
    
    
    
    
    func restoreView(){
        self.TextDetailstableview.backgroundView = nil
    }
    
    @objc func seeMoreButtonTapped(sender : UIButton) {
        //Write button action here
        self.bIsSeeMore = true
        
        CallSeeMoreVideoDetailApi()
    }
    
    
   
    
    
    
}
