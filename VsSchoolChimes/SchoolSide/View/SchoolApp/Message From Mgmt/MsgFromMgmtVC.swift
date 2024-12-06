//
//  MsgFromMgmtVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 12/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class MsgFromMgmtVC: UIViewController, UITableViewDelegate, UITableViewDataSource,Apidelegate{
    @IBOutlet weak var MgmtTableView: UITableView!
    
    var strApiFrom = String()
    var strStaffID = String()
    var strSchoolID = String()
    var arrMgmtData: NSMutableArray = []
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var SelectedDict = [String: Any]() as NSDictionary
    var languageDictionary = NSDictionary()
    var SchoolDetailDict = NSDictionary()
    var strLanguage = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var strCountryCode = String()
    
    var passDate : String!
    
    var altSting = String()
    var bIsSeeMore = Bool()
    let utilObj = UtilClass()
    
    var loginAsName = String()
    var checkSchoolId : String!
    //    var  dict = NSDictionary()
    var isArchieveGet = "0"
    
//    var unReardVideoCount : Int
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(MsgFromMgmtVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackStaff"), object:nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("MGMTviewWillAppear")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        

        bIsSeeMore = false
        if(appDelegate.isPasswordBind == "0"){
            bIsSeeMore = true
        }
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        
        
        
        print("loginAsName",loginAsName)
        print("loginAsName",loginAsName)
        if(loginAsName == "Principal")
        {
            
            print("checkSchoolId11",checkSchoolId)
            if checkSchoolId == "1" {
                
                strSchoolID = String(describing: SchoolDetailDict["SchoolID"]!)
                strStaffID = String(describing: SchoolDetailDict["StaffID"]!)

                print("strSchoolID",strSchoolID)
                print("strStaffID",strStaffID)
            }else{
                let userDefaults = UserDefaults.standard
                strStaffID = userDefaults.string(forKey: DefaultsKeys.StaffID)!
                strSchoolID = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
                
            }
        }
        
        
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        if(Util .isNetworkConnected())
        {
            print("TTTTTT",appDelegate.LoginSchoolDetailArray.count)
            if(appDelegate.LoginSchoolDetailArray.count > 1)
            {
                
                
                strSchoolID = String(describing: SchoolDetailDict["SchoolID"]!)
                strStaffID = String(describing: SchoolDetailDict["StaffID"]!)
                print("strSchoolID",strSchoolID)
                print("strStaffID",strStaffID)
                print("TTTTTT111")
            }else{
                let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
                strStaffID = String(describing: dict["StaffID"]!)
                strSchoolID = String(describing: dict["SchoolID"]!)
                
                
                
                print("TTTTT222T")
            }
            
            print("WillAppear")
            GetMgmtDetailApiCalling()
            
            
        }
        else
        {
            Util .showAlert("", msg: strNoInternet)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        GetMgmtDetailApiCalling()
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
        GetMgmtDetailApiCalling()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var iCount : Int? = 0
        iCount = arrMgmtData.count
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if(indexPath.row <= (arrMgmtData.count - 1)){
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return 215
            }else{
                return 170
            }
        }else{
            return 40
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        hideLoading()
        if(indexPath.row <= (arrMgmtData.count - 1)){
            let cell = tableView.dequeueReusableCell(withIdentifier: "MsgFromMgmtTVCell", for: indexPath) as! MsgFromMgmtTVCell
            cell.backgroundColor = UIColor.clear
            let dict : NSDictionary = arrMgmtData[indexPath.row] as! NSDictionary
            cell.DateLbl.text = String(describing: dict["Date"]!)
            cell.DayLbl.text = String(describing: dict["Day"]!)
            
          
            let TextCount : String = String(describing: dict["TotalSMS"]!)
            let VoiceCount : String = String(describing: dict["TotalVOICE"]!)
            let PdfCount : String = String(describing: dict["TotalPDF"]!)
            let ImageCount : String = String(describing: dict["TotalIMG"]!)
            let VideoCount : String = String(describing: dict["TotalVIDEO"]!)
            
            let UnreadTextCount : String = String(describing: dict["UnreadSMS"]!)
            let UnreadVoiceCount : String = String(describing: dict["UnreadVOICE"]!)
            let UnreadPdfCount : String = String(describing: dict["UnreadPDF"]!)
            let UnreadImageCount : String = String(describing: dict["UnreadIMG"]!)
            let UnreadVideoCount : String = String(describing: dict["UnreadVIDEO"]!)
            if(UnreadTextCount != "0")
            {
                cell.UnreadTextCountLabel.isHidden = false
                cell.UnreadTextCountLabel.text = UnreadTextCount
            }else{
                cell.UnreadTextCountLabel.isHidden = true
                
            }
            if(UnreadVoiceCount != "0"){
                cell.UnreadVoiceCountLabel.isHidden = false
                cell.UnreadVoiceCountLabel.text = UnreadVoiceCount
            }else{
                cell.UnreadVoiceCountLabel.isHidden = true
            }
            if(UnreadPdfCount != "0"){
                cell.UnreadPdfCountLabel.isHidden = false
                cell.UnreadPdfCountLabel.text = UnreadPdfCount
            }else{
                cell.UnreadPdfCountLabel.isHidden = true
            }
            if(UnreadImageCount != "0"){
                cell.UnreadImageCountLabel.isHidden = false
                cell.UnreadImageCountLabel.text = UnreadImageCount
            }else{
                cell.UnreadImageCountLabel.isHidden = true
            }
            if(UnreadVideoCount != "0"){
                cell.UnreadVideoCountLabel.isHidden = false
                cell.UnreadVideoCountLabel.text = UnreadVideoCount
            }else{
                cell.UnreadVideoCountLabel.isHidden = true
            }
            let strVoice = languageDictionary ["teacher_txt_voice"] as? String ?? "Voice"
            let strText = languageDictionary ["teacher_txt_text"] as? String ?? "Text"
            let strImage = languageDictionary ["teacher_txt_Image"] as? String ?? "Image"
            let strpdf = languageDictionary ["pdf_1"] as? String ?? "PDF"
            let strvideo = languageDictionary ["videoName"] as? String ?? "PDF"
            
            cell.VoiceCountLbl.text =  strVoice + "(" + VoiceCount + ")"
            cell.ImageCountLbl.text = strImage + "(" + ImageCount  + ")"
            cell.PdfCountLbl.text = strpdf + "(" + PdfCount + ")"
            cell.TextCountLbl.text = strText + "(" + TextCount + ")"
            cell.VideoCountLbl.text = strvideo + "(" + VideoCount + ")"
            
            
            
            
            print("PdfCount",PdfCount)
            if(VoiceCount != "0"){
                var is_Archive : String = String(describing: dict["is_Archive"]!)
                if is_Archive  == "1" {
                    self.isArchieveGet = "1"
                    print("isArchieveGet",self.isArchieveGet)
                }else{
                    self.isArchieveGet = "0"
                }
                cell.VoiceButton.addTarget(self, action: #selector(actionVoiceButton(sender:)), for: .touchUpInside)
            }
            cell.VoiceButton.tag = indexPath.row
            
            if(TextCount != "0"){
                var is_Archive : String = String(describing: dict["is_Archive"]!)
                if is_Archive  == "1" {
                    self.isArchieveGet = "1"
                    print("isArchieveGet",self.isArchieveGet)
                }else{
                    self.isArchieveGet = "0"
                }
                cell.TextButton.addTarget(self, action: #selector(actionTextButton(sender:)), for: .touchUpInside)
            }
            cell.TextButton.tag = indexPath.row
            
            if(PdfCount != "0"){
                var is_Archive : String = String(describing: dict["is_Archive"]!)
                if is_Archive  == "1" {
                    self.isArchieveGet = "1"
                    print("isArchieveGet",self.isArchieveGet)
                }else{
                    self.isArchieveGet = "0"
                }
                cell.PdfButton.addTarget(self, action: #selector(actionPdfButton(sender:)), for: .touchUpInside)
            }
            cell.PdfButton.tag = indexPath.row
            
            if(ImageCount != "0"){
                var is_Archive : String = String(describing: dict["is_Archive"]!)
                if is_Archive  == "1" {
                    self.isArchieveGet = "1"
                    print("isArchieveGet",self.isArchieveGet)
                }else{
                    self.isArchieveGet = "0"
                }
                cell.ImageButton.addTarget(self, action: #selector(actionImageButton(sender:)), for: .touchUpInside)
            }
            cell.ImageButton.tag = indexPath.row
            
            
            if(VideoCount != "0"){
                
                
                
                let defaults = UserDefaults.standard
                defaults.set(dict["Date"], forKey: DefaultsKeys.selectDate)
                var is_Archive : String = String(describing: dict["is_Archive"]!)
                if is_Archive  == "1" {
                    self.isArchieveGet = "1"
                    print("isArchieveGet",self.isArchieveGet)
                }else{
                    self.isArchieveGet = "0"
                }
                
                cell.VideoButton.addTarget(self, action: #selector(actionVideoButton(sender:)), for: .touchUpInside)
            }
            cell.VideoButton.tag = indexPath.row
            return cell
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
            cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
            cell.backgroundColor = .clear
            return cell
            
        }
        
        
    }
    
    @objc func actionVoiceButton(sender: UIButton){
        print("SelectedDict111",SelectedDict)
        print("arrMgmtData",arrMgmtData)
        SelectedDict = arrMgmtData[sender.tag] as! NSDictionary
        print("SelectedDict11111",SelectedDict)
        performSegue(withIdentifier: "StaffMgmtVoiceSegue", sender: self)
    }
    @objc func actionTextButton(sender: UIButton)
    {
        SelectedDict = arrMgmtData[sender.tag] as! NSDictionary
        performSegue(withIdentifier: "StaffMgmtTextSegue", sender: self)
    }
    @objc func actionPdfButton(sender: UIButton)
    {
        SelectedDict = arrMgmtData[sender.tag] as! NSDictionary
        performSegue(withIdentifier: "StaffMgmtPdfSegue", sender: self)
    }
    @objc func actionImageButton(sender: UIButton)
    {
        SelectedDict = arrMgmtData[sender.tag] as! NSDictionary
        performSegue(withIdentifier: "StaffMgmtImageSegue", sender: self)
    }
    
    @objc func actionVideoButton(sender: UIButton)
    {
        SelectedDict = arrMgmtData[sender.tag] as! NSDictionary
//        performSegue(withIdentifier: "StaffMgmtVideoSegue", sender: self)
        
        
        let vc = ManagementVideoViewController(nibName: nil, bundle: nil)
        vc.videoSelectedDict = SelectedDict
        vc.modalPresentationStyle = .fullScreen
        vc.SchoolID = strSchoolID
        let dict : NSDictionary = arrMgmtData[sender.tag] as! NSDictionary
        vc.getDate = dict["Date"] as! String
        print("passpas1sDate",passDate)
     
        vc.chilId = strStaffID
        vc.getTag = sender.tag
        vc.getMsgFromMgnt = 1
        vc.getArchive = isArchieveGet
        vc.countryCode = strCountryCode
        print("strStaffID",strStaffID)
        present(vc, animated: true, completion: nil)
        
    }
    
    //MARK: API CALLING
    func GetMgmtDetailApiCalling()
    {
        showLoading()
        strApiFrom = "GetMgmtDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_MESSAGE_COUNT
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_MESSAGE_COUNT
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["MemberId" : strStaffID,"SchoolId" : strSchoolID, COUNTRY_CODE: strCountryCode]
        
        print("mgmt",requestString)
        print("myDict11",myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetMgmtDetailApi")
    }
    func GetSeeMoreMgmtDetailApiCalling()
    {
        showLoading()
        strApiFrom = "GetSeeMoreMgmtDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_MESSAGE_COUNT_SEEMORE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_MESSAGE_COUNT_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["MemberId" : strStaffID,"SchoolId" : strSchoolID]
        print("mgmtsee",requestString)
        print("myDictsee",myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSeeMoreMgmtDetailApi")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual("GetMgmtDetailApi"))
                
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                if let CheckedArray = csData as? NSArray
                {
                    if(CheckedArray.count > 0)
                    {
                        let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        if let val =  dict["Date"] {
                            let strVal:String = String(describing: val)
                            strNoRecordAlert = dict["Day"] as? String ?? strNoRecordAlert
                            
                            print(strNoRecordAlert)
                            if(strVal == "0")
                            {
                                altSting = strNoRecordAlert
                                if(appDelegate.isPasswordBind == "0"){
                                    self.AlerMessage()
                                }
                            }else
                            {
                                arrMgmtData = NSMutableArray(array: CheckedArray)
                                
                            }
                            MgmtTableView.reloadData()
                            
                            
                        }else
                        {
                            self.AlerMessage()
                            
                        }
                    }else
                    {
                        self.AlerMessage()
                    }
                    
                }else
                {
                    self.AlerMessage()
                }
                
            }
            else if(strApiFrom.isEqual("GetSeeMoreMgmtDetailApi"))
                    
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                if let CheckedArray = csData as? NSArray
                {
                    if(CheckedArray.count > 0)
                    {
                        let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        if let val =  dict["Date"] {
                            let strVal:String = String(describing: val)
                            print(strVal)
                            strNoRecordAlert = dict["Day"] as? String ?? strNoRecordAlert
                            
                            if(strVal == "0")
                            {
                                altSting = strNoRecordAlert
                                
                                self.AlerMessage()
                            }else
                            {
                                for i in 0..<CheckedArray.count
                                {
                                    let dict = CheckedArray[i] as! NSDictionary
                                    arrMgmtData.add(dict)
                                    
                                    
                                }
                                
                                MgmtTableView.reloadData()
                            }
                            
                        }else
                        {
                            self.AlerMessage()
                            
                        }
                    }else
                    {
                        self.AlerMessage()
                    }
                    
                }else
                {
                    self.AlerMessage()
                }
                
            }
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        
    }
    
    func AlerMessage()
    {
        
        let alertController = UIAlertController(title: languageDictionary["Ǎlert"] as? String, message: altSting, preferredStyle: .alert)
        
        
        
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        UtilObj.printLogKey(printKey: "SelectedDict", printingValue: SelectedDict)
        
        if (segue.identifier == "StaffMgmtVoiceSegue")
        {
            let segueid = segue.destination as! ParentEmergencyVoiceVC
            segueid.SenderType = "FromStaff"
            segueid.getArchive = isArchieveGet
            segueid.getMsgFromMgnt = 1
            AdConstant.mgmtVoiceType = "1"
            segueid.VoiceDict = SelectedDict
            segueid.SchoolId = strSchoolID
            segueid.ChildId = strStaffID

print("SelectedDict34",SelectedDict)

        }
        else if (segue.identifier == "StaffMgmtTextSegue")
        {
            let segueid = segue.destination as! TextVC
            segueid.selectedDictionary = SelectedDict
            print("isArchieveGet",isArchieveGet)
            segueid.getArchive = isArchieveGet
            segueid.getMsgFromMgnt = 1
            segueid.SchoolId = strSchoolID
            segueid.ChildId = strStaffID

            segueid.strScreenFrom = "FromStaff"
            
            
        }
        else if (segue.identifier == "StaffMgmtImageSegue")
        {
            let segueid = segue.destination as! ParentImageVc
            segueid.ImageSelectedDict = SelectedDict
            segueid.getArchive = isArchieveGet
            segueid.getMsgFromMgnt = 1
            segueid.SchoolId = strSchoolID
            segueid.ChildId = strStaffID

            segueid.SenderType = "FromStaff"
            
            
        }
        else if (segue.identifier == "StaffMgmtPdfSegue")
        {
            let segueid = segue.destination as! PdfVC
            segueid.PDFSelectedDict = SelectedDict
            
            segueid.getArchive = isArchieveGet
            segueid.getMsgFromMgnt = 1
            segueid.SchoolId = strSchoolID
            segueid.ChildId = strStaffID
//            segueid.bIsArchive = true
            segueid.strSenderType = "FromStaff"
            
            
        }
        
        else if (segue.identifier == "StaffMgmtVideoSegue")
        {
            
            
            
//            let segueid = segue.destination as! ParentVideoVc
////            segueid.PDFSelectedDict = SelectedDict
//            
////            segueid.getArchive = isArchieveGet
//            segueid.getMsgFromMgnt = 1
//            segueid.SchoolId = strSchoolID
//            segueid.ChildId = strStaffID
////            segueid.bIsArchive = true
////            segueid.strSenderType = "FromStaff"
            
            
            
            
            
            let vc = ManagementVideoViewController(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            vc.videoSelectedDict = SelectedDict

            vc.strSenderType = "FromStaff"
            vc.getArchive = isArchieveGet
            print("pass",passDate)
            vc.SchoolID = strSchoolID
            vc.chilId = strStaffID
            vc.getDate = passDate
            vc.getMsgFromMgnt = 1
            vc.countryCode = strCountryCode
            present(vc, animated: true, completion: nil)
            
            
            
        }
    }
    
    
    @objc func catchNotification(notification:Notification) -> Void {
        print("Notification Comeback")
        GetMgmtDetailApiCalling()
        
        hideLoading()
        if(Util .isNetworkConnected())
        {
            bIsSeeMore = false
            if(appDelegate.isPasswordBind == "0"){
                bIsSeeMore = true
            }
            
            
            
        }
        else
        {
            Util .showAlert("", msg: strNoInternet)
        }
    }
    
    func navTitle()
    {
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        titleLabel.textColor = UIColor (red:166.0/255.0, green: 114.0/255.0, blue: 155.0/255.0, alpha: 1)
        let secondWord : String  = languageDictionary["messages"] as? String ?? "Messages"
        let thirdWord   : String  = languageDictionary["from_management"] as? String ?? "from Management"
        let comboWord = secondWord + " " + thirdWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.white]
            let range = NSString(string: comboWord).range(of: secondWord)
            attributedText.addAttributes(attrs, range: range)
        }else{
            let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]
            let range = NSString(string: comboWord).range(of: secondWord)
            attributedText.addAttributes(attrs, range: range)
        }
        
        
        titleLabel.attributedText = attributedText
        if(strLanguage == "ar"){
            titleLabel.textAlignment = .right
        }else{
            titleLabel.textAlignment = .left
        }
        self.self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.titleView = titleLabel
        
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        self.navigationController?.navigationBar.barTintColor = UtilObj.SCHOOL_NAV_BAR_COLOR
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }else{
                    
                }
            } catch {
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
        navTitle()
    }
    
    
    //Mark:- SeeMore Feature
    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.MgmtTableView.bounds.size.width, height: self.MgmtTableView.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.MgmtTableView.bounds.size.width, height: 150))
        noDataLabel.text = altSting
        noDataLabel.textColor = .lightGray
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.MgmtTableView.bounds.size.width - 108, y: noDataLabel.frame.height + 10, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        self.MgmtTableView.backgroundView = noview
    }
    func restoreView(){
        self.MgmtTableView.backgroundView = nil
    }
    
    @objc func seeMoreButtonTapped(sender : UIButton) {
        
        self.bIsSeeMore = true
        self.MgmtTableView.reloadData()
        GetSeeMoreMgmtDetailApiCalling()
    }
    
}
