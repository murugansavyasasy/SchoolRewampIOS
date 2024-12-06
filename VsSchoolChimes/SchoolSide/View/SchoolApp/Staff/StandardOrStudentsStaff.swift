//
//  StandardOrStudentsStaff.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 26/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import Alamofire

class StandardOrStudentsStaff : UIViewController,Apidelegate,UIPickerViewDelegate ,UIPickerViewDataSource{
    
    @IBOutlet weak var PickerTitleLabel: UILabel!
    @IBOutlet weak var SectionView: UIView!
    @IBOutlet weak var StandardView: UIView!
    @IBOutlet weak var MyPickerView: UIPickerView!
    @IBOutlet weak var PopupChooseStandardPickerView: UIView!
    @IBOutlet weak var SectionNameLbl: UILabel!
    @IBOutlet weak var StandardNameLbl: UILabel!
    @IBOutlet weak var SelectStudentButton: UIButton!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var pickerCancelButton: UIButton!
    @IBOutlet weak var pickerOkButton: UIButton!
    @IBOutlet weak var FloatSectionLabel: UILabel!
    @IBOutlet weak var FloatStandardNameLabel: UILabel!
    var strApiFrom = NSString()
    var StaffId = String()
    var SchoolId = String()
    var loginAsName = String()
    var TableString = String()
    var pickerStandardArray = [String]()
    var pickerSectionArray = [String]()
    var selectedStandardRow = 0;
    var selectedSectionRow = 0;
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var StandarCodeArray:Array = [String]()
    var SectionCodeArray:Array = [String]()
    var StandardNameArray:Array = [String]()
    var DetailofSectionArray:Array = [Any]()
    var popupChooseStandard : KLCPopup  = KLCPopup()
    var popupAttendance : KLCPopup  = KLCPopup()
    var SelectedStandardName = String()
    var SelectedSectionDeatil:NSDictionary = [String:Any]() as NSDictionary
    var SchoolDeatilDict:NSDictionary = [String:Any]() as NSDictionary
    let UtilObj = UtilClass()
    var StandardSectionArray = NSArray()
    var SelectedClassIDString = String()
    var SelectedSectionIDString = String()
    var HomeTitleText = String()
    var HomeTextViewText = String()
    var SenderScreenName = String()
    var SelectedDictforApi = [String:Any]() as NSDictionary
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var durationString = String()
    var urlData: URL?
    var uploadImageData : NSData? = nil
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var fromView = String()
    var voiceHistoryArray = NSMutableArray()
    var imagesArray = NSMutableArray()
    var pdfData : NSData? = nil
    var strFrom = String()
    var strCountryCode = String()
    var languageDict = NSDictionary()
    var apicalled = "0"
    var convertedImagesUrlArray = NSMutableArray()
    var currentImageCount = 0
    var totalImageCount = 0
    var imageUrlArray = NSMutableArray()
    var originalImagesArray = [UIImage]()
    var vimeoVideoDict = NSMutableDictionary()
    var VideoData : NSData? = nil
    var vimeoVideoURL : URL!
    var countryCoded : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        print("test2")
        
        countryCoded =  UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StandardOrStudentsStaff.catchNotification), name: NSNotification.Name(rawValue: "comeBack1"), object:nil)
        let Dict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
        SchoolId = String(describing: Dict["SchoolID"]!)
        StaffId = String(describing: Dict["StaffID"]!)
        callSelectedLanguage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.ButtonCornerDesign()
        if(StandardSectionArray.count == 0){
            if(UtilObj.IsNetworkConnected()){
                self.GetAllSectionCodeapi()
            }else{
                Util.showAlert("", msg:strNoInternet )
            }
        }
    }
    
    func ButtonCornerDesign(){
        PopupChooseStandardPickerView.layer.cornerRadius = 8
        PopupChooseStandardPickerView.layer.masksToBounds = true
        StandardView.layer.cornerRadius = 5
        StandardView.layer.masksToBounds = true
        SectionView.layer.cornerRadius = 5
        SectionView.layer.masksToBounds = true
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        SelectStudentButton.layer.cornerRadius = 5
        SelectStudentButton.layer.masksToBounds = true
        
    }
    
    @objc func catchNotification(notification:Notification) -> Void {
        //print("catch notification in text message")
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBackMenu"), object: nil)
        
    }
    
    //MARK: PickerView
    
    public func numberOfComponents(in pickerView:  UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(TableString == "Standard"){
            return pickerStandardArray.count
        }else{
            return pickerSectionArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(TableString == "Standard")
        {
            return pickerStandardArray[row]
            
        }
        else
        {
            
            return pickerSectionArray[row]
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(TableString == "Standard")
        {
            selectedStandardRow = row;
            
            
        }
        else
        {
            selectedSectionRow = row
        }
        
    }
    
    
    
    // MARK: DONE PICKER ACTION
    @IBAction func actionDonePickerView(_ sender: UIButton)
    {
        PopupChooseStandardPickerView.alpha = 0
        if(TableString == "Standard")
        {
            StandardNameLbl.text = pickerStandardArray[selectedStandardRow]
            SelectedStandardName = pickerStandardArray[selectedStandardRow]
            UtilObj.printLogKey(printKey: "SelectedStandardName", printingValue: SelectedStandardName)
            let sectionarray:Array = DetailofSectionArray[selectedStandardRow] as! [Any]
            var sectionNameArray :Array = [String]()
            if(sectionarray.count > 0)
            {
                for i in 0..<sectionarray.count
                {
                    let dicResponse :NSDictionary = sectionarray[i] as! NSDictionary
                    sectionNameArray.append(String(describing: dicResponse["SectionName"]!))
                    SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                }
                SectionNameLbl.text = String(sectionNameArray[0])
                
                pickerSectionArray = sectionNameArray
                SelectedSectionDeatil = sectionarray[0] as! NSDictionary
                SelectedSectionIDString = String(describing: SelectedSectionDeatil["SectionId"]!)
            }
            else{
                Util.showAlert("", msg: languageDict["no_section"] as? String)
                SectionNameLbl.text = ""
                pickerSectionArray = []
                SelectedSectionIDString = ""
            }
            
            SelectedClassIDString = String(StandarCodeArray[selectedStandardRow])
            
            UtilObj.printLogKey(printKey: "SelectedSectionDeatil", printingValue: SelectedSectionDeatil)
            
        }
        else
        {
            
            let sectionarray:Array = DetailofSectionArray[selectedStandardRow] as! [Any]
            SelectedSectionDeatil = sectionarray[selectedSectionRow] as! NSDictionary
            UtilObj.printLogKey(printKey: "SelectedSectionDeatil", printingValue: SelectedSectionDeatil)
            SelectedSectionIDString = String(describing: SelectedSectionDeatil["SectionId"]!)
            UtilObj.printLogKey(printKey: "SelectedSectionDeatil", printingValue: SelectedSectionDeatil)
            SectionNameLbl.text = pickerSectionArray[selectedSectionRow]
            
            
        }
        
        popupChooseStandard.dismiss(true)
        
        
    }
    
    @IBAction func actionCancelPickerView(_ sender: UIButton) {
        PopupChooseStandardPickerView.alpha = 0
        popupChooseStandard.dismiss(true)
    }
    
    
    
    
    // MARK: CHOOSE STANDARD BUTTON ACTION
    
    @IBAction func actionChooseStandardButton(_ sender: UIButton) {
        TableString = "Standard"
        PickerTitleLabel.text = languageDict["select_standard"] as? String//"Select Standard"
        self.MyPickerView.reloadAllComponents()
        if(pickerStandardArray.count > 0)
        {
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PopupChooseStandardPickerView.frame.size.height = 300
                
                PopupChooseStandardPickerView.frame.size.width = 350
                
                
            }
            
            
            
            //            G3
            
            
            PopupChooseStandardPickerView.center = view.center
            PopupChooseStandardPickerView.alpha = 1
            PopupChooseStandardPickerView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
            
            self.view.addSubview(PopupChooseStandardPickerView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
                
                self.PopupChooseStandardPickerView.transform = .identity
            })
            
            
            print("StandardOrStudentStaff1")
            
        }
        else
        {
            Util.showAlert("", msg: languageDict["no_students"] as? String)
            
        }
        
    }
    
    // MARK: CHOOSE SECTION BUTTON ACTION
    @IBAction func actionChooseSectionButton(_ sender: UIButton) {
        TableString = "Section"
        PickerTitleLabel.text = languageDict["select_section"] as? String //"Select Section"
        self.MyPickerView.reloadAllComponents()
        if((StandardNameLbl.text?.count)! > 0){
            if(UIDevice.current.userInterfaceIdiom == .pad){
                PopupChooseStandardPickerView.frame.size.height = 300
                PopupChooseStandardPickerView.frame.size.width = 350
            }
            
            //            G3
            
            PopupChooseStandardPickerView.center = view.center
            PopupChooseStandardPickerView.alpha = 1
            PopupChooseStandardPickerView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
            
            self.view.addSubview(PopupChooseStandardPickerView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
                
                self.PopupChooseStandardPickerView.transform = .identity
            })
            
            
            print("StandardOrStudentStaff1222")
        }else{
            Util.showAlert("", msg: languageDict["standard_first"] as? String)
        }
        
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionCancelAttendanceView(_ sender: UIButton) {
        popupAttendance.dismiss(true)
        
    }
    
    // MARK: SELECT STUDENT BUTTON ACTION
    @IBAction func actionSelectStudentButton(_ sender: UIButton) {
        if((StandardNameLbl.text?.count)! > 0 && (SectionNameLbl.text?.count)! > 0){
            SelectedDictforApi = ["SchoolID":SchoolId,"StaffID": StaffId,"ClassID": SelectedClassIDString,"SectionID":SelectedSectionIDString]
            let studentVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectstudentVC") as! SelectstudentVC
            
            studentVC.SectionStandardName = StandardNameLbl.text! + " - " + SectionNameLbl.text!
            studentVC.SectionDetailDictionary = SelectedSectionDeatil
            studentVC.SchoolId = SchoolId
            studentVC.SelectedDictforApi = SelectedDictforApi
            studentVC.SenderNameString = "StaffStudentSelection"
            studentVC.HomeTextViewText = HomeTextViewText
            studentVC.HomeTitleText = HomeTitleText
            studentVC.urlData = urlData
            studentVC.durationString = durationString
            studentVC.SenderNameString = SenderScreenName
            studentVC.uploadImageData = uploadImageData
            studentVC.fromView = self.fromView
            studentVC.voiceHistoryArray = self.voiceHistoryArray
            
            studentVC.vimeoVideoDict = self.vimeoVideoDict
            studentVC.VideoData = self.VideoData
            studentVC.vimeoVideoURL = vimeoVideoURL
            
            print("self.vimeoVideoDictself.vimeoVideoDict",self.vimeoVideoDict)
            studentVC.imagesArray = self.imagesArray
            studentVC.strFrom = strFrom
            studentVC.pdfData = self.pdfData
            
            self.present(studentVC, animated: false, completion: nil)
            
            
        }else{
            Util.showAlert("", msg: languageDict["select_standard_section_alert"] as? String)
        }
    }
    
    @IBAction func actionSendButton(_ sender: UIButton) {
        if((StandardNameLbl.text?.count)! > 0 && (SectionNameLbl.text?.count)! > 0){
            if(UtilObj.IsNetworkConnected()){
                if(SenderScreenName == "StaffTextMessage"){
                    self.SendTextMessageToStudentAsStaff()
                }
                else if(SenderScreenName == "StaffVoiceMessage"){
                    if( self.fromView == "Record"){
                        self.SendStaffVoiceMessageApi()
                    }else{
                        self.SendStaffHistoryVoiceMessageApi()
                    }
                }else if(SenderScreenName == "StaffImageMessage"){
                    self.SendImageAsStaff()
                }else if(SenderScreenName == "StaffMultipleImage"){
                    if(self.strFrom == "Image"){
                        self.getImageURL(images: self.imagesArray as! [UIImage])
                    }else{
                        self.uploadPDFFileToAWS(pdfData: pdfData!)
                    }
                }else if(SenderScreenName == "VimeoVideoToParents"){
                    self.CallUploadVideoToVimeoServer()
                }
            }else{
                Util.showAlert("", msg:strNoInternet )
            }
        }else{
            Util.showAlert("", msg: languageDict["select_standard_section_alert"] as? String)
            
        }
    }
    
    
    //MARK:API CALLING
    
    func CallUploadVideoToVimeoServer() {
        self.showLoading()
        strApiFrom = "VimeoVidoUpload"
        
        
        let vimeoAccessToken = appDelegate.VimeoToken
        
        createVimeoUploadURL(authToken: vimeoAccessToken, videoFilePath: vimeoVideoURL) { [self] result in
            switch result {
            case .success(let uploadLink):
                uploadVideoToVimeo(uploadLink: uploadLink, videoFilePath: vimeoVideoURL, authToken: vimeoAccessToken) { [self] result in
                    switch result {
                    case .success:
                        print("Video uploaded successfully!")
                        
                        
                    case .failure(let error):
                        print("Failed to upload video: \(error)")
                        
                        let refreshAlert = UIAlertController(title: "", message: "Failed to upload video", preferredStyle: UIAlertController.Style.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                            
                            
                        }))
                        
                        
                        present(refreshAlert, animated: true, completion: nil)
                        
                        
                    }
                }
            case .failure(let error):
                print("Failed to create upload URL: \(error)")
                
                let refreshAlert = UIAlertController(title: "", message: "Failed to upload video", preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                }))
                
                
                present(refreshAlert, animated: true, completion: nil)
                
                
            }
        }
        
        
    }
    
    
    
    enum UploadResult {
        case success(String)
        case failure(Error)
    }
    
    func getFileSize(at url: URL) -> UInt64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                return fileSize
            }
        } catch {
            print("Error: \(error)")
        }
        return nil
    }
    
    func createVimeoUploadURL(authToken: String, videoFilePath: URL, completion: @escaping (UploadResult) -> Void) {
        
        
        guard let fileSize = getFileSize(at: videoFilePath) else {
            completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get file size"])))
            return
        }
        
        var TitleGet =  vimeoVideoDict["Title"] as! String
        var TitleDescriotion = vimeoVideoDict["Description"] as! String
        if TitleGet != "" && TitleGet != nil {
            TitleGet =  vimeoVideoDict["Title"] as! String
        }else{
            TitleGet =  "Test Name"
        }
        if TitleDescriotion != "" &&  TitleDescriotion != nil {
            TitleDescriotion = vimeoVideoDict["Description"] as! String
            
        }else{
            TitleDescriotion =  "Test Description"
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authToken)",
            "Content-Type": "application/json",
            "Accept": "application/vnd.vimeo.*+json;version=3.4"
        ]
        let userDefaults = UserDefaults.standard
        let getDownload = UserDefaults.standard.value(forKey: DefaultsKeys.allowVideoDownload) as? Bool ?? false
        let parameters: [String: Any] = [
            "upload": [
                "approach": "tus",
                "size": "\(fileSize)"
            ],
            "privacy":[
                "view":"unlisted",
                "download": true
            ],
            "embed":[
                "buttons":[
                    "share":"false"
                ]
            ],
            "name": TitleGet,
            "description": TitleDescriotion
        ]
        
        AF.request("https://api.vimeo.com/me/videos", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success(let value):
                    print("Vimeo API Response: \(value)") // Print the full JSON
                    if let json = value as? [String: Any],
                       let upload = json["upload"] as? [String: Any],
                       let uploadLink = upload["upload_link"] as? String {
                        
                        let embedUrl = json["player_embed_url"] as! String
                        let IFrameLink : String!
                        let LinkGet  = json["link"] as! String
                        let embed = json["embed"]! as AnyObject
                        IFrameLink = embed["html"]! as! String
                        
                        
                        
                        vimeoVideoDict["URL"] = LinkGet
                        vimeoVideoDict["Iframe"] = embed["html"]!
                        vimeoVideoDict["videoFileSize"] = DefaultsKeys.videoFilesize
                        print(vimeoVideoDict)
                        print("vimeoVideoDictURL", vimeoVideoDict["URL"])
                        print("vimeoVideoDictIframe", vimeoVideoDict["Iframe"])
                        
                        self.SendVimeoVideoToSection()
                        
                        print("videe=embedUrl",IFrameLink)
                        completion(.success(uploadLink))
                    } else {
                        completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload link not found"])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func uploadVideoToVimeo(uploadLink: String, videoFilePath: URL, authToken: String, chunkSize: Int = 5 * 1024 * 1024, completion: @escaping (UploadResult) -> Void) {
        guard let fileHandle = try? FileHandle(forReadingFrom: videoFilePath) else {
            completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to read video file"])))
            return
        }
        print("fileHandleBefore",fileHandle)
        var offset: Int = 0
        let fileSize = fileHandle.seekToEndOfFile()
        fileHandle.seek(toFileOffset: 0)
        
        print("fileHandleBefore",fileHandle)
        func uploadNextChunk() {
            let chunkData = fileHandle.readData(ofLength: chunkSize)
            
            if chunkData.isEmpty {
                fileHandle.closeFile()
                completion(.success(("")))
                return
            }
            
            var request = URLRequest(url: URL(string: uploadLink)!)
            request.httpMethod = "PATCH"
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/offset+octet-stream", forHTTPHeaderField: "Content-Type")
            request.setValue("\(offset)", forHTTPHeaderField: "Upload-Offset")
            request.setValue("1.0.0", forHTTPHeaderField: "Tus-Resumable")
            request.httpBody = chunkData
            
            let uploadTask = URLSession.shared.uploadTask(with: request, from: chunkData) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 204 {
                        offset += chunkSize
                        uploadNextChunk()
                    } else if httpResponse.statusCode == 412 {
                        // Handle 412 error (precondition failed), retry or get correct offset from server
                        if let rangeHeader = httpResponse.value(forHTTPHeaderField: "Upload-Offset"), let serverOffset = Int(rangeHeader) {
                            offset = serverOffset
                            uploadNextChunk()
                        } else {
                            let error = NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload chunk: Precondition Failed"])
                            completion(.failure(error))
                        }
                    } else {
                        let error = NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload chunk, status code: \(httpResponse.statusCode)"])
                        completion(.failure(error))
                    }
                }
            }
            
            uploadTask.resume()
        }
        
        uploadNextChunk()
    }
    
    func SendVimeoVideoToSection()
    {
        showLoading()
        strApiFrom = "sendVimeoVideo"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_VIMEO_VIDEO_ENTIRE_SECTION
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let SectionID = String(describing: SelectedSectionDeatil["SectionId"]!)
        self.vimeoVideoDict["Seccode"] = SectionID
        self.vimeoVideoDict[COUNTRY_CODE] = strCountryCode
        
        let myString = Util.convertDictionary(toString: vimeoVideoDict)
        UtilObj.printLogKey(printKey: "myDict", printingValue: vimeoVideoDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "sendVimeoVideo")
    }
    
    
    func GetAllSectionCodeapi(){
        showLoading()
        strApiFrom = "GetSectionCodeAttendance"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        // let requestStringer = baseUrlString! + GETSTANDARD_SECTION
        var requestStringer = baseUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"SchoolId":"1302","StaffID":"7643","isAttendance":"1"}
        let myDict:NSMutableDictionary = ["SchoolId" : SchoolId,"StaffID" : StaffId,"isAttendance" : "0", COUNTRY_CODE: strCountryCode]
        
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSectionCodeAttendance")
    }
    
    
    
    func SendTextMessageToStudentAsStaff(){
        showLoading()
        strApiFrom = "SendTextMessageToStudentAsStaff"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + STAFF_SEND_TEXT_MESSAGE
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let SectionID = String(describing: SelectedSectionDeatil["SectionId"]!)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId ,"Description":HomeTitleText ,"Message" : HomeTextViewText, COUNTRY_CODE: strCountryCode,"Seccode": [["TargetCode":SectionID]]]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendTextMessageToStudentAsStaff")
    }
    
    func SendStaffVoiceMessageApi(){
        showLoading()
        strApiFrom = "SendStaffVoiceMessageApi"
        let VoiceData = NSData(contentsOf: self.urlData!)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime = DefaultsKeys.initialDisplayDate
        var doNotDial =  DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            let requestStringer = baseUrlString! + STAFF_SEND_VOICE_MESSAGE
            print("dghbdning3d3f6ty",requestStringer)
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let SectionID = String(describing: SelectedSectionDeatil["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText,"Duration": durationString, COUNTRY_CODE: strCountryCode ,"Seccode" : [["TargetCode":SectionID]]]
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
        }else{
            let requestStringer = baseUrlString! + SCHEDULE_STAFF_SEND_VOICE_MESSAGE
            print("dghbdningerOL5cefcghbejnc6ty",requestStringer)
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let SectionID = String(describing: SelectedSectionDeatil["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText,"Duration": durationString, COUNTRY_CODE: strCountryCode ,"Seccode" : [["TargetCode":SectionID]], "StartTime" : initialTime , "EndTime" : doNotDial , "Dates" : DefaultsKeys.dateArr ]
            
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
        }
    }
    
    func SendStaffHistoryVoiceMessageApi(){
        showLoading()
        let voiceDict = voiceHistoryArray[0] as! NSDictionary
        strApiFrom = "SendStaffVoiceMessageApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime = DefaultsKeys.initialDisplayDate
        var doNotDial =  DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            let requestStringer = baseUrlString! + STAFF_ENTIRE_SECTION_VOICE_HISTORY
            print("dghbdningececrerOL56ty",requestStringer)
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let SectionID = String(describing: SelectedSectionDeatil["SectionId"]!)
            
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText,"Duration": durationString ,"filepath" : String(describing: voiceDict["FilePath"]!), COUNTRY_CODE: strCountryCode,"Seccode" : [["TargetCode":SectionID]]]
            
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "StaffVoiceHistory")
        }else{
            let requestStringer = baseUrlString! + SCHEDULE_STAFF_ENTIRE_SECTION_VOICE_HISTORY
            print("dghbdningerOcfenbcvhfvnvL56ty",requestStringer)
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let SectionID = String(describing: SelectedSectionDeatil["SectionId"]!)
            
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText,"Duration": durationString ,"filepath" : String(describing: voiceDict["FilePath"]!), COUNTRY_CODE: strCountryCode,"Seccode" : [["TargetCode":SectionID]], "StartTime" : initialTime , "EndTime" : doNotDial , "Dates" : DefaultsKeys.dateArr ]
            
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "StaffVoiceHistory")
        }
    }
    
    func SendImageAsStaff(){
        showLoading()
        strApiFrom = "SendImageAsStaff"
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + STAFF_SEND_IMAGE_MESSAGE
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let SectionID = String(describing: SelectedSectionDeatil["SectionId"]!)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText, COUNTRY_CODE: strCountryCode,"Seccode" : [["TargetCode":SectionID]]]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.callPassImageParms(requestString, myString, "SendImageAsStaff", uploadImageData as Data?)
    }
    
    func StaffMultipleImage(){
        DispatchQueue.main.async {
            self.apicalled = "1"
            self.strApiFrom = "SendImageAsStaff"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_TO_SECTION_CLOUD
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let SectionID = String(describing: self.SelectedSectionDeatil["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : self.SchoolId,"StaffID" : self.StaffId,"Description" : self.HomeTitleText, COUNTRY_CODE: self.strCountryCode,"Seccode" : [["TargetCode":SectionID]],"isMultiple":"1","FileType":"IMG","FileNameArray" : self.convertedImagesUrlArray]
            self.UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }
        
    }
    func StaffPdfImageSend(){
        DispatchQueue.main.async {
            self.strApiFrom = "SendImageAsStaff"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_TO_SECTION_CLOUD
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let SectionID = String(describing: self.SelectedSectionDeatil["SectionId"]!)
            let myDict:NSMutableDictionary = ["SchoolID" : self.SchoolId,"StaffID" : self.StaffId,"Description" : self.HomeTitleText, COUNTRY_CODE: self.strCountryCode,"Seccode" : [["TargetCode":SectionID]],"isMultiple":"0","FileType":".pdf","FileNameArray" : self.convertedImagesUrlArray]
            self.UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }
        //apiCall.callPassPDFParms(requestString, myString, "SendImageAsStaff", pdfData as Data?)
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        
        hideLoading()
        if(csData != nil)        {
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            
            if(strApiFrom.isEqual(to:"sendVimeoVideo"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["result"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
                
                
            }
            else if(strApiFrom.isEqual(to:"GetSectionCodeAttendance"))
            {
                
                var dicResponse: NSDictionary = [:]
                var AlertString = String()
                if((csData?.count)! > 0)
                {
                    let ResponseArray = NSArray(array: csData!)
                    let Dict = ResponseArray[0] as! NSDictionary
                    if(Dict != nil)
                    {
                        if let CheckedArray = ResponseArray as? NSArray
                        {
                            StandardSectionArray = CheckedArray
                            if(StandardSectionArray.count > 0)
                            {
                                for  i in 0..<StandardSectionArray.count
                                {
                                    dicResponse = StandardSectionArray[i] as! NSDictionary
                                    
                                    let stdcode = String(describing: dicResponse["StandardId"]!)
                                    StandarCodeArray.append(stdcode)
                                    
                                    let CheckstdName = String(describing: dicResponse["Standard"]!)
                                    let stdName = Util.checkNil(CheckstdName)
                                    
                                    AlertString = stdcode
                                    if(stdName != "" && stdName != "0")
                                    {
                                        StandardNameArray.append(stdName!)
                                        DetailofSectionArray.append(dicResponse["Sections"] as! [Any])
                                        pickerStandardArray = StandardNameArray
                                        StandardNameLbl.text = pickerStandardArray[0]
                                        SelectedClassIDString = String(StandarCodeArray[0])
                                        let sectionarray:Array = DetailofSectionArray[0] as! [Any]
                                        var sectionNameArray :Array = [String]()
                                        for  i in 0..<sectionarray.count
                                        {
                                            let dicResponse : NSDictionary = sectionarray[i] as! NSDictionary
                                            sectionNameArray.append(String(describing: dicResponse["SectionName"]!))
                                            SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                                        }
                                        print(SectionCodeArray)
                                        if(SectionCodeArray.count > 0){
                                            SelectedSectionIDString = String(SectionCodeArray[0])
                                        }
                                        
                                        pickerSectionArray = sectionNameArray
                                        if(sectionarray.count > 0){
                                            let dicResponse :NSDictionary = sectionarray[0] as! NSDictionary
                                            SelectedSectionDeatil = dicResponse
                                            let SectionString = dicResponse["SectionName"] as! String
                                            SectionNameLbl.text = SectionString
                                        }
                                        
                                    }
                                    else
                                    {
                                        Util.showAlert("", msg: AlertString)
                                        dismiss(animated: false, completion: nil)
                                    }
                                }
                            }
                        }
                        else{
                            Util.showAlert("", msg: strNoRecordAlert)
                        }                    }
                    
                }
                
                else
                {   Util.showAlert("", msg: strNoRecordAlert)
                    dismiss(animated: false, completion: nil)
                    
                }
            }
            else if(strApiFrom.isEqual(to:"SendTextMessageToStudentAsStaff"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
                
                
            }
            else if(strApiFrom.isEqual(to:"SendStaffVoiceMessageApi"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
                
                
            }
            else if(strApiFrom.isEqual(to:"SendImageAsStaff"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1"){
                        if(self.strFrom == "Image"){
                            if(apicalled == "1"){
                                apicalled = "0"
                                Util.showAlert("", msg: myalertstring)
                                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                            }
                        }else{
                            Util.showAlert("", msg: myalertstring)
                            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        }
                    }else{
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                }else{
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
        languageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            SectionNameLbl.textAlignment = .right
            StandardNameLbl.textAlignment = .right
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            SectionNameLbl.textAlignment = .left
            StandardNameLbl.textAlignment = .left
        }
        self.SendButton.setTitle(LangDict["teacher_pop_response_btn_send"] as? String, for: .normal)
        self.SelectStudentButton.setTitle(LangDict["select_student_attedance"] as? String, for: .normal)
        self.pickerOkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        self.pickerCancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        FloatStandardNameLabel.text = LangDict["teacher_atten_standard"] as? String
        FloatSectionLabel.text = LangDict["teacher_atten_sections"] as? String
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
    //MARK: AWS Upload
    
    func getImageURL(images : [UIImage]){
        showLoading()
        self.originalImagesArray = images
        self.totalImageCount = images.count
        if currentImageCount < images.count{
            self.uploadAWS(image: images[currentImageCount])
        }
    }
    
    func uploadAWS(image : UIImage){
      
        var bucketName = ""
                print("countryCoded",countryCoded)
                if countryCoded == "1" {
                   
                    bucketName = DefaultsKeys.bucketNameIndia
                }else  {
                     bucketName = DefaultsKeys.bucketNameBangkok
                }
                
        
        let S3BucketName = bucketName
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".png")
        
        
        let ext = imageName as String
        
        let fileName = imageNameWithoutExtension
        let fileType = ".png"
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        let data = image.jpegData(compressionQuality: 0.9)
        do {
            try data?.write(to: imageURL)
        }
        catch {}
        
        print(imageURL)
        let dateFormatter = DateFormatter()
              
              dateFormatter.dateFormat = "yyyy-MM-dd"
              
              let  currentDate =   dateFormatter.string(from: Date())
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key = "communication" + "/" + currentDate +  "/" + ext
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.contentType = "image/" + ext
        uploadRequest?.acl = .publicRead
        print("ext",ext)
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
            
            if let error = task.error {
                self.hideLoading()
                print("Upload failed : (\(error))")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    let imageDict = NSMutableDictionary()
                    imageDict["FileName"] = absoluteString
                    self.imageUrlArray.add(imageDict)
                    self.currentImageCount = self.currentImageCount + 1
                    if self.currentImageCount < self.totalImageCount{
                        DispatchQueue.main.async {
                            self.getImageURL(images: self.originalImagesArray)
                        }
                        
                    }else{
                        self.convertedImagesUrlArray = self.imageUrlArray
                        
                        self.StaffMultipleImage()
                        
                    }
                }
            }
            else {
                self.hideLoading()
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    
    func uploadPDFFileToAWS(pdfData : NSData){
        self.showLoading()
        
        var bucketName = ""
                print("countryCoded",countryCoded)
                if countryCoded == "1" {
                   
                    bucketName = DefaultsKeys.bucketNameIndia
                }else  {
                     bucketName = DefaultsKeys.bucketNameBangkok
                }
        let S3BucketName = bucketName
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".pdf")
        
        
        let ext = imageName as String
        
        let fileName = imageNameWithoutExtension
        let fileType = ".pdf"
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        
        do {
            try pdfData.write(to: imageURL)
        }
        catch {}
        
        print(imageURL)
        
        let dateFormatter = DateFormatter()
              
              dateFormatter.dateFormat = "yyyy-MM-dd"
              
              let  currentDate =   dateFormatter.string(from: Date())
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key = "communication" + "/" + currentDate +  "/" + ext
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.contentType = "application/pdf"
        uploadRequest?.acl = .publicRead
        
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
            
            if let error = task.error {
                print("Upload failed : (\(error))")
                self.hideLoading()
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    let imageDict = NSMutableDictionary()
                    imageDict["FileName"] = absoluteString
                    self.imageUrlArray.add(imageDict)
                    self.convertedImagesUrlArray = self.imageUrlArray
                    self.StaffPdfImageSend()
                    
                }
            }
            else {
                self.hideLoading()
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    
}



