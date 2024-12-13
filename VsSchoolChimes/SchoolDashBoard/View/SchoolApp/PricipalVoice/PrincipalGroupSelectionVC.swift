//
//  PrincipalGroupSelectionVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 04/07/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import Alamofire

class PrincipalGroupSelectionVC: UIViewController,Apidelegate {
    
    
    @IBOutlet weak var SendEntireSchoolButton: UIButton!
    @IBOutlet weak var SendStandardGroupButton: UIButton!
    @IBOutlet weak var SendStandardSectionButton: UIButton!
    var SchoolID = NSString()
    var StaffID = NSString()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var fromViewController = NSString()
    
    var VoiceData : NSData? = nil
    var VideoData : NSData? = nil
    var urlData: URL?
    var imageToSend = UIImage()
    var imageData : NSData? = nil
    var apiCallFrom = NSString()
    var selectedSchoolDictionary = NSMutableDictionary()
    var VoiceHistoryArray =  NSMutableArray()
    var imagesArray = NSMutableArray()
    var vimeoVideoDict = NSMutableDictionary()
    var fromView = String()
    var  strFrom = String() //"Image"
    var strOk = String()
    var strCancel = String()
    var strAlertMsg = String()
    var strAlertTitle = String()
    var pdfData : NSData? = nil
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var videoURL: URL?
    var apicalled = "0"
    var selType : String!
    
    var convertedImagesUrlArray = NSMutableArray()
    var currentImageCount = 0
    var totalImageCount = 0
    var imageUrlArray = NSMutableArray()
    var originalImagesArray = [UIImage]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var vimeoVideoURL : URL!
    var countryCoded : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test1")
        
        
        print("PrincipalGroupSelectionVC")
        
        
        print("StaffID",StaffID)
        print("SchoolID",SchoolID)
        print("fromView",fromView)
        print("strFrom",strFrom)
        
        countryCoded =  UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        SendEntireSchoolButton.layer.cornerRadius = 5
        SendEntireSchoolButton.layer.masksToBounds = true
        
        SendStandardGroupButton.layer.cornerRadius = 5
        SendStandardGroupButton.layer.masksToBounds = true
        
        SendStandardSectionButton.layer.cornerRadius = 5
        SendStandardSectionButton.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    @IBAction func actionStandardGroupButton(_ sender: UIButton)
    {
        print("THISselectedSchoolDictionary")
        print("selectedSchoolDictionary \(selectedSchoolDictionary)")
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "StandardGroupSelectionSegue", sender: self)
        }
    }
    @IBAction func actionStandardSectionButton(_ sender: UIButton)
    {
        let StaffVC = self.storyboard?.instantiateViewController(withIdentifier: "StandardOrSectionVCStaff") as! StandardOrSectionVCStaff
        StaffVC.SendedScreenNameStr = fromViewController as String
        StaffVC.selectedSchoolDictionary = selectedSchoolDictionary
        StaffVC.SchoolId = SchoolID as String
        StaffVC.StaffId = StaffID as String
        StaffVC.VoiceurlData = urlData
        StaffVC.fromView = self.fromView
        StaffVC.voiceHistoryArray = VoiceHistoryArray
        StaffVC.vimeoVideoDict = self.vimeoVideoDict
        print("self.vimeoVideoDictww",self.vimeoVideoDict)
        StaffVC.imagesArray = imagesArray
        StaffVC.strFrom = strFrom
        StaffVC.VideoData = self.VideoData
        print("vistrFroml222",strFrom)
        print("vimeoUrlvimeoUrl222",vimeoVideoURL)
        print("vimeoUPrincipal",imagesArray)
        StaffVC.vimeoVideoURL = vimeoVideoURL
        print("vimeoUrlvimeoUrl222u",StaffVC.vimeoVideoURL)
        StaffVC.pdfData = self.pdfData
        
        self.present(StaffVC, animated: false, completion: nil)
    }
    
    
    @IBAction func actionSendEntireSchoolButton(_ sender: UIButton){
        self.AlerMessagefuntion()
        
    }
    //MARK: Api Calling
    
    func CallUploadVideoToVimeoServer() {
        self.showLoading()
        apiCallFrom = "VimeoVidoUpload"
        let vimeoAccessToken = appDelegate.VimeoToken
        
        
        print("PrincipalGroupSelectionVC!",vimeoVideoURL)
        
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
        
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authToken)",
            "Content-Type": "application/json",
            "Accept": "application/vnd.vimeo.*+json;version=3.4"
        ]
        
        
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
                    print("Vimeo API Response: \(value)")
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
                        hideLoading()
                        self.callSendVimeVideoAllSchools()
                        
                        
                        
                        
                        
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
    
    func callSendVoiceToGroupsAndStandards()
    {
        apiCallFrom = "SendVoiceToGroupsAndStandards"
        self.showLoading()
        VoiceData = NSData(contentsOf: self.urlData!)
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime = DefaultsKeys.initialDisplayDate
        var doNotDial =  DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        print("doNotDialDateArr",DefaultsKeys.dateArr)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            let requestStringer = baseUrlString! + SendVoiceToGroupsAndStandards
            print("requestStringerOL111156ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            self.selectedSchoolDictionary["isEntireSchool"] = "T"
            self.selectedSchoolDictionary["StdCode"] = []
            self.selectedSchoolDictionary["GrpCode"] = []
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
        }else{
            let requestStringer = baseUrlString! + ScheduleSendVoiceToGroupsAndStandards
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            print("requestStringe2222rOL56ty",requestStringer)
            
            self.selectedSchoolDictionary["isEntireSchool"] = "T"
            self.selectedSchoolDictionary["StdCode"] = []
            self.selectedSchoolDictionary["GrpCode"] = []
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            
            
            self.selectedSchoolDictionary["StartTime"] = initialTime
            self.selectedSchoolDictionary["EndTime"] = doNotDial
            self.selectedSchoolDictionary["Dates"] = DefaultsKeys.dateArr
            
            
            
            
            
            
            
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
        }
    }
    
    func callVoiceHistoryToGroupsAndStandards()
    {
        apiCallFrom = "SendVoiceToGroupsAndStandards"
        let VoiceDict = VoiceHistoryArray[0] as! NSDictionary
        self.showLoading()
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime = DefaultsKeys.initialDisplayDate
        var doNotDial =  DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            
            let requestStringer = baseUrlString! + VOICE_HISTORY_GROUP_STANDARD
            print("requestStri223233ngerOL56ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            self.selectedSchoolDictionary["isEntireSchool"] = "T"
            self.selectedSchoolDictionary["StdCode"] = []
            self.selectedSchoolDictionary["GrpCode"] = []
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            self.selectedSchoolDictionary["filepath"] = String(describing: VoiceDict["FilePath"]!)
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }else {
            
            
            let requestStringer = baseUrlString! + SCHEDULE_VOICE_HISTORY_GROUP_STANDARD
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            print("requestStre3r2rr2ringerOL56ty",requestStringer)
            
            self.selectedSchoolDictionary["isEntireSchool"] = "T"
            self.selectedSchoolDictionary["StdCode"] = []
            self.selectedSchoolDictionary["GrpCode"] = []
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            self.selectedSchoolDictionary["filepath"] = String(describing: VoiceDict["FilePath"]!)
            self.selectedSchoolDictionary["StartTime"] = initialTime
            self.selectedSchoolDictionary["EndTime"] = doNotDial
            self.selectedSchoolDictionary["Dates"] = DefaultsKeys.dateArr

            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            print("DefaultsKeys.dateArr",DefaultsKeys.dateArr)
            print("SendVoicemyString",myString)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }
    }
    
    func callSendImageToGroupsAndStandards()
    
    {
        apiCallFrom = "SendImageToGroupsAndStandards"
        imageData = (imageToSend.pngData() as NSData?)!
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + STAFF_SEND_IMAGE_MESSAGE
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        self.selectedSchoolDictionary["isEntireSchool"] = "T"
        self.selectedSchoolDictionary["StdCode"] = []
        self.selectedSchoolDictionary["GrpCode"] = []
        self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
        apiCall.callPassImageParms(requestString, myString, "SendImageAsPrincipalToSelectedClass", imageData as? Data)
        
    }
    
    func callSendMultipleImageToAllSchools()
    
    {
        DispatchQueue.main.async {
            self.apicalled = "1"
            var ApiDict = NSMutableDictionary()
            self.apiCallFrom = "SendImageToGroupsAndStandards"
            
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_TO_SCHOOL_CLOUD //MULTIPLE_IMAGE_MESSAGE_GROUP_STANDARD
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            var schoolArray = NSMutableArray()
            let SchoolDict = ["SchoolId" : self.selectedSchoolDictionary["SchoolID"],"StaffID":self.selectedSchoolDictionary["StaffID"]]
            schoolArray.add(SchoolDict)
            
            ApiDict["School"] = schoolArray
            ApiDict["CallerType"] = self.selectedSchoolDictionary["StaffID"]
            ApiDict["Description"] = self.selectedSchoolDictionary["Description"]
            
            ApiDict[COUNTRY_CODE] = self.strCountryCode
            ApiDict["isMultiple"] = "1"
            ApiDict["FileType"] = "IMG"
            ApiDict["FileNameArray"] = self.convertedImagesUrlArray
            
            print(ApiDict)
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: ApiDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendImageAsPrincipalToSelectedClass")
        }
        
    }
    
    func callSendPDFToAllSchools(){
        DispatchQueue.main.async {
            self.apiCallFrom = "SendImageToGroupsAndStandards"
            var ApiDict = NSMutableDictionary()
            
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_TO_SCHOOL_CLOUD//SendImageToGroupsAndStandards
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            var schoolArray = NSMutableArray()
            let SchoolDict = ["SchoolId" : self.selectedSchoolDictionary["SchoolID"],"StaffID":self.selectedSchoolDictionary["StaffID"]]
            schoolArray.add(SchoolDict)
            
            ApiDict["School"] = schoolArray
            ApiDict["CallerType"] = self.selectedSchoolDictionary["StaffID"]
            
            ApiDict["Description"] = self.selectedSchoolDictionary["Description"]
            
            ApiDict[COUNTRY_CODE] = self.strCountryCode
            ApiDict["isMultiple"] = "0"
            ApiDict["FileType"] = ".pdf"
            ApiDict["FileNameArray"] = self.convertedImagesUrlArray
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: ApiDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }
    }
    
    func callSendVideoToAllSchools(){
        apiCallFrom = "SendImageToGroupsAndStandards"
        var videoData : NSData? = nil
        do {
            videoData = try NSData(contentsOf: videoURL!, options: NSData.ReadingOptions())
        } catch {
            print("set PDF filer error : ", error)
        }
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + UPLOAD_YOUTUBE_VIDEO
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        self.selectedSchoolDictionary["isEntireSchool"] = "T"
        self.selectedSchoolDictionary["StdCode"] = []
        self.selectedSchoolDictionary["GrpCode"] = []
        self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
        apiCall.callPassVideoParms(requestString, myString, "SendVideoAsPrincipalToSelectedClass", videoData as Data?)
    }
    
    func callSendSMSToGroupsAndStandards()
    {
        apiCallFrom = "SendSMSToGroupsAndStandards"
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SendSMSToGroupsAndStandards
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        self.selectedSchoolDictionary["isEntireSchool"] = "T"
        self.selectedSchoolDictionary["StdCode"] = []
        self.selectedSchoolDictionary["GrpCode"] = []
        self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
        apiCall.nsurlConnectionFunction(requestString, myString, "TextToParents")
    }
    
    func callSendVimeVideoAllSchools()
    {
        apiCallFrom = "sendVimeoVideo"
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_VIMEO_VIDEO_ENTIRE_SCHOOL
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.vimeoVideoDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "TextToParents")
    }
    
    
    func callSchoolEvents()
    {
        apiCallFrom = "SchoolEvents"
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + ManageSchoolEvents
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        self.selectedSchoolDictionary["isEntireSchool"] = "T"
        self.selectedSchoolDictionary["StdCode"] = []
        self.selectedSchoolDictionary["GrpCode"] = []
        self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
        apiCall.nsurlConnectionFunction(requestString, myString, "SchoolEvents")
    }
    
    //MARK: Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        print(csData)
        hideLoading()
        if(csData != nil)
        {
            if((csData?.count)! > 0){
                let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                
                if(apiCallFrom == "sendVimeoVideo"){
                    
                    let Status = String(describing: dicUser["result"]!)
                    let Message = String(describing: dicUser["Message"]!)
                    if(Status == "1")
                    {
                        Util.showAlert("", msg: Message)
                        let loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
                        if(loginAsName == "Principal")
                        {
                            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }else{
                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                        
                        
                    }else{
                        Util.showAlert("", msg: Message)
                    }
                    
                }
                
                else if let status = dicUser["Status"] as? NSString
                {
                    let Status = status
                    let Message = dicUser["Message"] as! NSString
                    
                    if(Status .isEqual(to: "1")){
                        
                        if(apiCallFrom == "SendImageToGroupsAndStandards"){
                            if(self.strFrom == "Image"){
                                if(apicalled == "1"){
                                    apicalled = "0"
                                    Util.showAlert("", msg: Message as String?)
                                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                }
                            }else{
                                Util.showAlert("", msg: Message as String?)
                                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            }
                            
                        }else{
                            Util.showAlert("", msg: Message as String?)
                            
                            if(appDelegate.LoginSchoolDetailArray.count > 1){
                                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            }else{
                                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            }
                            
                        }
                        
                    }else{
                        Util.showAlert("", msg: Message as String?)
                    }
                }
                
            }
        }else{
            Util.showAlert("", msg: strSomething)
        }
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: strSomething);
    }
    
    //MARK: Loading Indicator
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
    }
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "StandardGroupSelectionSegue")
        {
            let segueid = segue.destination as! StandardGroupSelectionVC
            segueid.fromViewController = fromViewController
            segueid.SchoolID = SchoolID
            segueid.urlData = urlData
            segueid.selectedSchoolDictionary = selectedSchoolDictionary
            segueid.fromView = self.fromView
            segueid.VoiceHistoryArray = VoiceHistoryArray
            segueid.imagesArray = imagesArray
            segueid.pdfData = pdfData
            segueid.strFrom = strFrom
            segueid.VideoData = self.VideoData
            segueid.vimeoVideoURL = vimeoVideoURL
            print("StdGrpselfVideovimeoVideoURL",vimeoVideoURL)
            
            segueid.vimeoVideoDict = self.vimeoVideoDict
            print("StdGrpself.vimeoVideoDict",self.vimeoVideoDict)
            segueid.fromViewController = fromViewController
            
        }
    }
    
    func AlerMessagefuntion()
    {
        print(self.fromViewController)
        let alertController = UIAlertController(title: strAlertTitle, message: strAlertMsg, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: strOk, style: UIAlertAction.Style.default) {
            UIAlertAction in
            if(self.fromViewController .isEqual(to: "VoiceToParents"))
            {
                if(self.fromView == "Record"){
                    self.callSendVoiceToGroupsAndStandards()
                }else{
                    self.callVoiceHistoryToGroupsAndStandards()
                }
                
            }
            else if(self.fromViewController .isEqual(to: "TextToParents"))
            {
                self.callSendSMSToGroupsAndStandards()
            }
            else if(self.fromViewController .isEqual(to: "SchoolEvents"))
            {
                self.callSchoolEvents()
            }
            else if(self.fromViewController .isEqual(to: "SendImage"))
            {
                self.callSendImageToGroupsAndStandards()
            }else if(self.fromViewController .isEqual(to: "SendVideo"))
            {
                self.callSendVideoToAllSchools()
            }
            
            else if(self.fromViewController .isEqual(to: "MultipleImage"))
            {
                if(self.strFrom == "Image"){
                    self.getImageURL(images: self.imagesArray as! [UIImage])
                    // self.callSendMultipleImageToAllSchools()
                }else{
                    self.uploadPDFFileToAWS(pdfData: self.pdfData!)
                    //self.callSendPDFToAllSchools()
                }
            }
            
            else if(self.fromViewController .isEqual(to: "VimeoVideoToParents"))
            {
                self.CallUploadVideoToVimeoServer()
                //self.callSendVimeVideoAllSchools()
            }
        }
        let cancelAction = UIAlertAction(title: strCancel, style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.dismiss(animated: false, completion: nil)
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
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
                }
            } catch {
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        
        strAlertMsg = LangDict["confirm_to_send"] as? String ?? "Are you confirm to send"
        strAlertTitle = LangDict["alert"] as? String ?? "Alert"
        strOk = LangDict["teacher_pop_remove_btn_yes"] as? String ?? "Ok"
        strCancel = LangDict["teacher_pop_remove_btn_no"] as? String ?? "Cancel"
        SendEntireSchoolButton.setTitle(LangDict["send_to_entire_school"] as? String, for: .normal)
        SendStandardGroupButton.setTitle(LangDict["send_to_standard_groups"] as? String, for: .normal)
        SendStandardSectionButton.setTitle(LangDict["send_to_standard_section"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
    //MARK: AWS Upload
    
    func getImageURL(images : [UIImage]){
        showLoading()
        self.originalImagesArray = images
        self.totalImageCount = images.count
        self.uploadAWS(image: images[currentImageCount])
    }
    
    func uploadAWS(image : UIImage){
        var bucketName = ""
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
                        self.callSendMultipleImageToAllSchools()
                        
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
                    self.callSendPDFToAllSchools()
                    
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


