//
//  EmergencyVoiceVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 01/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper


class ParentEmergencyVoiceVC: UIViewController,UITableViewDelegate, UITableViewDataSource,Apidelegate,UISearchBarDelegate, UIPopoverPresentationControllerDelegate {
    var VoiceDict = NSDictionary()
    var SelectedVoiceDict = NSDictionary()
    var languageDictionary = NSDictionary()
    var DetailVoiceArray = NSMutableArray()
    var filtered_list = NSPredicate()
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId : String = ""
    var MessageId = String()
    var SenderType = String()
    var strLanguage = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var strCountryCode = String()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var Screenheight = CFloat()
    var urlData: URL?
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var TextDateLabel: UILabel!
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var EmergencyTableView: UITableView!
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var AdView: UIView!
    var altSting = String()
    var bIsSeeMore = Bool()
    
    var bIsArchive = Bool()
    var menuList : [MenuData] = []
    var imgListArray :NSMutableArray = []
    var imgArr :  [String] = []
    var AdNames :  [String] = []
    var redirectUrl :  [String] = []
    
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    
    var noDataLabel : UILabel!
    var noview : UIView!
    weak var timer: Timer?
    
    var menuId : String!
    
    var getadID : Int!
    var ArrayData = NSMutableArray()
    let indexPath = IndexPath(row: 0, section: 0)
    
    var getMsgFromMgnt : Int! = 2
    var isPasswordBindGet : String?
    var getArchive : String!
    override func viewDidLoad()  {
        super.viewDidLoad()
        
        
        print("ParentEmergencyVoiceVC")
        HiddenLabel.isHidden = true
        bIsSeeMore = false
        print("ParentEmergPASSWORDBIND",appDelegate.isPasswordBind)
        print("isPasswordBindGet",isPasswordBindGet)
        
        search_bar.showsCancelButton = true
        search_bar.delegate = self
        
        
        
        print("getMsgFromMgnt",getMsgFromMgnt)
        if getMsgFromMgnt == 1 {
            let defaults = UserDefaults.standard
            print("SchoolId",SchoolId)
            AdView.isHidden = true
            imageView.isHidden = true
            
//            SchoolId = defaults.string(forKey:DefaultsKeys.SchoolD)!
        }else {
            
            AdView.isHidden = false
            imageView.isHidden = false
            
            let defaults = UserDefaults.standard
            print("SchoolId",SchoolId)
            
            SchoolId = defaults.string(forKey:DefaultsKeys.SchoolD)!
            ChildId = defaults.string(forKey:DefaultsKeys.chilId)!
            AdConstant.getMenuId = "0"
            
            print("SchoolId",SchoolId)
            print("ChildId",ChildId)
            print("AdConstant.getMenuId",AdConstant.getMenuId)
            
            
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
            
            //
        }
    }
    
    
    @IBAction func startTimer() {
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
    
    
    
    @IBAction func stopTimer() {
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
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        Screenheight = CFloat(self.view.frame.size.height)
        callSelectedLanguage()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(DetailVoiceArray.count == 0){
            
            print("numberOfRowsInSection",DetailVoiceArray.count)
            if(appDelegate.isPasswordBind != "0"){
                emptyView()
            }
            return 0
        }else{
            restoreView()
            if(!bIsSeeMore){
                return DetailVoiceArray.count + 1
                
            }else{
                return DetailVoiceArray.count
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row <= (DetailVoiceArray.count - 1)){
            
            let dict = DetailVoiceArray[indexPath.row] as! NSDictionary
            
            var DescriptionText = String()
            var CheckNilText = String()
            if(SenderType == "FromStaff")
            {
                CheckNilText = ""
            }
            else
            {
                DescriptionText = Util .checkNil(String(describing: dict["Description"]! as Any))
                
                CheckNilText  = Util .checkNil(DescriptionText)
            }
            
            
            if(CheckNilText != "")        {
                let Stringlength : Int = CheckNilText.count
                
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    let MuValue : Int = Stringlength/61
                    return (267 + ( 22 * CGFloat(MuValue)))
                }else{
                    if(Screenheight > 580)
                    {
                        let MuValue : Int = Stringlength/50
                        return (198 + ( 18 * CGFloat(MuValue)))
                        
                    }else{
                        let MuValue : Int = Stringlength/44
                        return (198 + ( 18 * CGFloat(MuValue)))
                    }
                }
            }
            else{
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return 222
                }else{
                    return 168
                }
            }
        }else{
            return 40
            
        }
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(indexPath.row <= (DetailVoiceArray.count - 1)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "VocieMessageTVCell", for: indexPath) as! VocieMessageTVCell
            cell.backgroundColor = UIColor.clear
            let dict = DetailVoiceArray[indexPath.row] as! NSDictionary
            cell.TimeLbl.text = String(describing: dict["Time"]!)
            cell.DateLbl.text = String(describing: dict["Date"]!)
            cell.SubjectLbl.text = String(describing: dict["Subject"]!)
            cell.playAudioButton.setTitle(languageDictionary["teacher_btn_voice_play"] as? String, for: .normal)
            cell.VocieMessageLabel.text = languageDictionary["hint_play_voice"] as? String
            cell.DiscriptionTextLbl.isHidden = false
            if(SenderType == "FromStaff"){
                cell.playAudioButton.backgroundColor = UIColor (red:232.0/255.0, green:127.0/255.0, blue: 32.0/255.0, alpha: 1)
                cell.DiscriptionTextLbl.isHidden = false


                var desc  = String(describing: dict["Description"]!)

                       if desc != "" && desc != nil {

                           cell.DiscriptionTextLbl.text = desc

                           print("desc",desc)
                           cell.DiscriptionTextLbl.isHidden = false

                       }else{
                           cell.DiscriptionTextLbl.isHidden = true
                           print("desEmptyc",desc)
                         

                       }



            }else{
//                print("desEmptycElse")
                cell.playAudioButton.backgroundColor = UIColor (red:1.0/255.0, green:154.0/255.0, blue: 232.0/255.0, alpha: 1)
                cell.DiscriptionTextLbl.text = Util.checkNil(String(describing: dict["Description"]! as Any))
            }
            
            cell.playAudioButton.addTarget(self, action: #selector(actionplayAudioButton(sender:)), for: .touchUpInside)
            cell.playAudioButton.tag = indexPath.row
            let iReadVoice : Int? = Int((dict["AppReadStatus"] as? String)!)
            
            if(iReadVoice == 0){
                cell.NewLbl.isHidden = false
                
            }else{
                cell.NewLbl.isHidden = true
            }
            
            return cell
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
            
            
            if(SenderType == "FromStaff" || SenderType == "DateWiseVoice" )  {
                cell.SeeMoreBtn.isHidden = true
                
            }
            else{
                cell.SeeMoreBtn.isHidden = false
                
            }
            
            cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
            cell.backgroundColor = .clear
            return cell
            
        }
    }
    
    @objc func actionplayAudioButton(sender: UIButton){
        SelectedVoiceDict = DetailVoiceArray[sender.tag] as! NSDictionary
        let dict = NSMutableDictionary(dictionary: SelectedVoiceDict)
        let iReadVoice : Int? = Int((SelectedVoiceDict["AppReadStatus"] as? String)!)
        
        bIsArchive = SelectedVoiceDict["is_Archive"] as? Bool ?? false
        
        if(iReadVoice == 0){
            // cell1.NewOrOldLabel.isHidden = false
            
            dict["AppReadStatus"] = "1"
            
            DetailVoiceArray[sender.tag] = dict
            
            
            if(Util .isNetworkConnected()){
                
                CallReadStatusUpdateApi(String(describing: SelectedVoiceDict[MessageId]!) , "VOICE")
            }else{
            }
            
        }
        EmergencyTableView.reloadData()
        if(SenderType == "FromStaff"){
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "VoiceDetailSeg", sender: self)
            }
        }else{
            downlaodvoice()
        }
    }
    
    func downlaodvoice(){
        let strFilePath : String =  String(describing: SelectedVoiceDict["URL"]!)
        
        let audioUrl = URL(string: strFilePath)
        
        if let audioUrl = URL(string: strFilePath) {
            
            
            let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
            
            let strpath = String(describing: SelectedVoiceDict[MessageId]!) + ".MP3"
            let destinationUrl = documentsUrl.appendingPathComponent(strpath)
            
            
            urlData = destinationUrl
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "VoiceDetailSeg", sender: self)
                }
                
            } else {
                
                if(Util .isNetworkConnected())
                {
                    let sessionConfig = URLSessionConfiguration.default
                    let session = URLSession(configuration: sessionConfig)
                    
                    let request = URLRequest(url:audioUrl)
                    
                    let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                        if let tempLocalUrl = tempLocalUrl, error == nil {
                            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                print("Successfully downloaded. Status code: \(statusCode)")
                                
                                
                            }
                            
                            do {
                                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationUrl)
                                print("Success")
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "VoiceDetailSeg", sender: self)
                                }
                                
                            } catch (let writeError) {
                                print("Error creating a file \(destinationUrl) : \(writeError)")
                            }
                            
                        } else {
                            print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
                        }
                    }
                    task.resume()
                    
                    
                }else
                {
                    Util .showAlert("", msg: strNoInternet)
                }
            }
        }
    }
    
    
    @IBAction func actionBack(_ sender: UIButton)
    {
        if(SenderType == "DateWiseVoice")
        {
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: "VoicecomeBack"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
        else if(SenderType == "FromStaff")
        {
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: "comeBackStaff"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    // MARK:- Api Calling
    
    
    
    func CallStaffEmergencyVocieApi() {
        print("CallStaffEmergencyVocieFirst")
        showLoading()
        strApiFrom = "CallStaffEmergencyVocie"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_FILES_STAFF
        
        print("requestStringerEmergency1",requestStringer)
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FILES_STAFF
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolId": SchoolId,"MemberId" : ChildId,"CircularDate" : TextDateLabel.text!,"Type" : "VOICE", COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallStaffEmergencyVocie")
    }
    func CallSeeMoreStaffEmergencyVocieApi() {
        print("CallStaffEmergencyVocieTwo")
        showLoading()
        strApiFrom = "CallSeeMoreStaffEmergencyVocie"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_FILES_STAFF_ARCHIVE
        print("requestStringerEmergency2",requestStringer)
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FILES_STAFF_ARCHIVE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolId": SchoolId,"MemberId" : ChildId,"CircularDate" : TextDateLabel.text!,"Type" : "VOICE", COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreStaffEmergencyVocie")
    }
    func CallDetailVocieMessageApi() {
        print("CallStaffEmergencyVocieThree")
        showLoading()
        strApiFrom = "CallDetailVoiceMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        var requestStringer = baseUrlString! + GET_FILES
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FILES
            
            print("requestStringer",requestStringer)
        }
        if(bIsArchive){
            requestStringer = baseReportUrlString! + GET_FILES_SEEMORE
        }
        
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId,"CircularDate" : TextDateLabel.text!,"Type" : "VOICE", COUNTRY_CODE: strCountryCode]
        
        print("myDictmyDictmyDictmyDict",myDict)
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailVoiceMessage")
    }
    func CallDetailEmergencyVocieApi() {
        print("CallStaffEmergencyVocieFour")
        showLoading()
        strApiFrom = "CallDetailEmergencyVocie"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_EMERGENCY_FILES
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        print("PASSWORDBIND",appDelegate.isPasswordBind)
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_EMERGENCY_FILES
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, "Type" : "VOICE", COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        
        print("IMAGE",requestString)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        print("PARENTEMERGENCYVOICE",requestString)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailEmergencyVocie")
    }
    func CallDetailSeeMoreEmergencyVocieApi() {
        print("CallStaffEmergencyVocieFive")
        showLoading()
        strApiFrom = "CallDetailSeeMoreEmergencyVocie"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_EMERGENCY_FILES_SEEMORE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        print("PASSWORDBIND",appDelegate.isPasswordBind)
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_EMERGENCY_FILES_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"ChildID":"7466","SchoolID":"1806","Type":"VOICE"}
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, "Type" : "VOICE", COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        print("SEEMOREEMERGENCY",requestString)
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailSeeMoreEmergencyVocie")
    }
    func CallReadStatusUpdateApi(_ ID : String, _ type : String) {
        showLoading()
        
        strApiFrom = "UpdateReadStatus"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        print("bIsArchivebIsArchive",bIsArchive)
        if(bIsArchive){
            
            print("AfterIFFFFF",bIsArchive)
            requestStringer = baseUrlString! + READ_STATUS_UPDATE_SEEMORE
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ID" : ID,"Type" : type, COUNTRY_CODE: strCountryCode]
        
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateReadStatus")
    }
    
    
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom == "CallDetailVoiceMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    //
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["Status"]!)
                        let Message = String(describing: dict["Message"]!)
                        if(Status == "1")
                        {
                            DetailVoiceArray.add(dict)
                            ArrayData.add(dict)
                        }else{
                            AlertMessage(alrString: Message)
                            
                            //
                            
                        }
                    }
                    DetailVoiceArray =  ArrayData
                    
                    Childrens.saveNormalVoiceDateWiseDetail(DetailVoiceArray as! [Any], ChildId)
                    
                    utilObj.printLogKey(printKey: "DetailVoiceArray", printingValue: DetailVoiceArray)
                    EmergencyTableView.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom == "CallDetailEmergencyVocie")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["Status"]!)
                        let Message = dict["Message"] as? String ?? ""
                        
                        if(Status == "1")
                        {
                            DetailVoiceArray.add(dict)
                            ArrayData.add(dict)
                        }else{
                            
                            altSting = Message
                            if(appDelegate.isPasswordBind == "0"){
                                AlertMessage(alrString: Message)
                            }
                            
                            
                        }
                    }
                    //                    DetailVoiceArray =  MainDetailTextArray
                    Childrens.saveVoiceDetail(DetailVoiceArray as! [Any] , ChildId)
                    
                    
                    utilObj.printLogKey(printKey: "DetailVoiceArray", printingValue: DetailVoiceArray)
                    EmergencyTableView.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom == "CallDetailSeeMoreEmergencyVocie")
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
                            DetailVoiceArray.add(dict)
                            ArrayData.add(dict)
                        }else{
                            AlertMessage(alrString: Message)
                            
                            
                        }
                    }
                    
                    Childrens.saveVoiceDetail(DetailVoiceArray as! [Any] , ChildId)
                    
                    DetailVoiceArray = ArrayData
                    utilObj.printLogKey(printKey: "DetailVoiceArray", printingValue: DetailVoiceArray)
                    EmergencyTableView.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom == "CallStaffEmergencyVocie")
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
                            DetailVoiceArray.add(dict)
                        }else{
                            AlertMessage(alrString: Message)
                            
                        }
                        
                        
                    }
                    utilObj.printLogKey(printKey: "DetailVoiceArray", printingValue: DetailVoiceArray)
                    EmergencyTableView.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom == "CallSeeMoreStaffEmergencyVocie")
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
                            DetailVoiceArray.add(dict)
                        }else{
                            AlertMessage(alrString: Message)
                            
                            
                        }
                        
                        
                    }
                    utilObj.printLogKey(printKey: "DetailVoiceArray", printingValue: DetailVoiceArray)
                    EmergencyTableView.reloadData()
                    
                    
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
        // popupLoading.dismiss(true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //  print(detailsDict)
        
        if (segue.identifier == "VoiceDetailSeg")
        {
            let segueid = segue.destination as! VoiceDetailVC
            segueid.SenderName = SenderType
            segueid.urlData = urlData
            
            segueid.selectedDictionary = SelectedVoiceDict
            
        }
    }
    func AlertMessage(alrString:String)
    {
        
        let alertController = UIAlertController(title: "Alert", message: alrString, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.dismiss(animated: true, completion: nil)
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
            if(SenderType == "DateWiseVoice")
            {
                ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
                SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
                
                TextDateLabel.text = String(describing: VoiceDict["Date"]!)
                bIsArchive = VoiceDict["is_Archive"] as? Bool ?? false
                
                MessageId = "ID"
                EmergencyTableView.reloadData()
                
                self.CallDetailVocieMessageApi()
                
                
            }
            else if(SenderType == "FromStaff")
            {
                if(appDelegate.LoginSchoolDetailArray.count > 0)
                {
                    let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary

                    if getMsgFromMgnt == 1 {
                                let defaults = UserDefaults.standard
                                print("SchoolId",SchoolId)



                    }else{
                        ChildId = String(describing: dict["StaffID"]!)
                        SchoolId = String(describing: dict["SchoolID"]!)
                    }
                    bIsArchive = VoiceDict["is_Archive"] as? Bool ?? false
                    
                    TextDateLabel.text = String(describing: VoiceDict["Date"]!)
                    MessageId = "ID"
                    
                    if(bIsArchive){
                        CallSeeMoreStaffEmergencyVocieApi()
                        
                    }else{
                        CallStaffEmergencyVocieApi()
                        
                    }
                    
                    
                }else
                {
                    Util.showAlert("", msg: strNoRecordAlert)
                }
            }
            
            
            else{
                if getMsgFromMgnt == 1 {
                            let defaults = UserDefaults.standard
                            print("SchoolId",SchoolId)



                }else{
                    ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
                    SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
                }
                EmergencyTableView.reloadData()
                
                TextDateLabel.text = languageDictionary["emergency"] as? String ?? "Emergency"
                MessageId = "MessageID"
                
                self.CallDetailEmergencyVocieApi()
            }
            
        }
        else
        {
            if(SenderType == "DateWiseVoice")
            {
                MessageId = "ID"
                
                ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
                TextDateLabel.text = String(describing: VoiceDict["Date"]!)
                
                DetailVoiceArray = Childrens.getNormalVoiceDateWise(fromDB: ChildId, getDateId: TextDateLabel.text!)
                if(DetailVoiceArray.count > 0)
                {
                    EmergencyTableView.reloadData()
                }else{
                    Util .showAlert("", msg: strNoInternet)
                }
                
                
            }else if(SenderType == "FromStaff")
            {
                MessageId = "ID"
                Util .showAlert("", msg: strNoInternet)
            }
            else{
                
                MessageId = "MessageID"
                ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
                DetailVoiceArray = Childrens.getVoiceFromDB(ChildId)
                if(DetailVoiceArray.count > 0)
                {
                    EmergencyTableView.reloadData()
                }else{
                    Util .showAlert("", msg: strNoInternet)
                }
                
            }
            
        }
        EmergencyTableView.reloadData()
    }
    
    //Mark:- SeeMore Feature
    func emptyView(){
        noview = UIView(frame: CGRect(x: 0, y: 0, width: self.EmergencyTableView.bounds.size.width, height: self.EmergencyTableView.bounds.size.height))
        
        noDataLabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.EmergencyTableView.bounds.size.width, height: 60))
        noDataLabel.text = altSting
        noDataLabel.textColor = .red
        noDataLabel.backgroundColor = UIColor(named: "NoDataColor")
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.EmergencyTableView.bounds.size.width - 108, y: noDataLabel.frame.height + 30, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        self.EmergencyTableView.backgroundView = noview
    }
    func restoreView(){
        self.EmergencyTableView.backgroundView = nil
        
    }
    @objc func seeMoreButtonTapped(sender : UIButton) {
        //Write button action here
        bIsSeeMore = true
        self.EmergencyTableView.reloadData()
        CallDetailSeeMoreEmergencyVocieApi()
    }
    
    
    //Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            DetailVoiceArray =  ArrayData
            self.EmergencyTableView.reloadData()
        }else{
            
            
            let resultPredicate = NSPredicate(format: "Date CONTAINS [c] %@ OR Description CONTAINS [c] %@ ", searchText, searchText)
            
            
            let arrSearchResults = ArrayData.filter { resultPredicate.evaluate(with: $0)} as NSArray
            DetailVoiceArray = NSMutableArray(array: arrSearchResults)
            if(DetailVoiceArray.count > 0){
                self.EmergencyTableView.reloadData()
                print("DetailVoiceArray.count > 0")
            }else{
                print("noDataLabel.isHidden = false")
                
            }
            self.EmergencyTableView.reloadData()
        }
        
        
        
        
        
        
        
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        DetailVoiceArray =  MainDetailTextArray
        
        self.EmergencyTableView.reloadData()
    }
    
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_bar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        search_bar.resignFirstResponder()
    }
    
    
    
    @IBAction func homeBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func passwordBtnAction(_ sender: UIButton) {
        self.showPopover(sender, Titletext: "")
    }
    
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
    
    
    @IBAction func faqBtnAction(_ sender: UIButton) {
        let faqVC  = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
        faqVC.fromVC = "Parent"
        self.navigationController?.pushViewController(faqVC, animated: true)
    }
    
    
    @IBAction func actionlogout(_ sender: Any) {
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFrom = "Logout"
        changePasswordVC.strFromStaff = "Child"
        changePasswordVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(changePasswordVC, animated: true, completion: nil)
    }
    
    func callLogoutAction(){
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFrom = "ChangePassword"
        changePasswordVC.strFromStaff = "Child"
        self.navigationController?.pushViewController(changePasswordVC, animated: true)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func UpdateLogoutSelection(notification:Notification) -> Void
    {
        print("PVoice")
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
}



class AdGesture : UITapGestureRecognizer {
    var ad_name : String!
    var redirect_url : String!
    var ad_index : IndexPath!
}
