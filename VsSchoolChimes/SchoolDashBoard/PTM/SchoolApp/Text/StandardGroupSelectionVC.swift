//
//  StandardGroupSelectionVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MACLAP on 17/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import Alamofire

class StandardGroupSelectionVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,Apidelegate {
    
    
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var selectEntireSchoolButton: UIButton!
    @IBOutlet weak var SendButton: UIButton!
    //SendButton
    @IBOutlet weak var standardCollectionView: UICollectionView!
    @IBOutlet weak var StandardLabel: UILabel!
    @IBOutlet weak var GroupsLabel: UILabel!
    @IBOutlet weak var NoStandardLbl: UILabel!
    @IBOutlet weak var NoGroupLbl: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var vimeoVideoURL : URL!
    var groupHeadType :String!
    var SelectedGroups = NSMutableArray()
    var SelectedStandards = NSMutableArray()
    var enable = Bool()
    var disableView = UIView()
    var disableView1 = UIView()
    var fromViewController = NSString()
    var isEntireSchool = NSString()
    var apiCallFrom = NSString()
    var SchoolID = NSString()
    var staffId = NSString()
    var desc = NSString()
    var duration = NSString()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var groupsArray = NSArray()
    var standardsArray = NSArray()
    var standardCodeArray = NSMutableArray()
    var groupCodeArray = NSMutableArray()
    var  vimeoVideoDict = NSMutableDictionary()
    var selectedStandardCodeArray = NSMutableArray()
    var selectedGroupCodeArray = NSMutableArray()
    var selectedSchoolDictionary = NSMutableDictionary()
    var strCountryCode = String()
    var VoiceData : NSData? = nil
    var urlData: URL?
    var imageToSend = UIImage()
    var imageData : NSData? = nil
    var fromView = String()
    var VoiceHistoryArray = NSMutableArray()
    var imagesArray = NSMutableArray()
    var strFrom = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var apicalled = "0"
    var VideoData : NSData? = nil
    var pdfData : NSData? = nil
    var convertedImagesUrlArray = NSMutableArray()
    var currentImageCount = 0
    var totalImageCount = 0
    var imageUrlArray = NSMutableArray()
    var originalImagesArray = [UIImage]()
    var countryCoded : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        
        countryCoded =  UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        self.config()
        NoStandardLbl.isHidden = true
        NoGroupLbl.isHidden = true
        
        if(self.fromViewController .isEqual(to: "VoiceToParents"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
            
        }
        else if(self.fromViewController .isEqual(to: "TextToParents"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
        }
        else if(self.fromViewController .isEqual(to: "SchoolEvents"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
        }
        else if(self.fromViewController .isEqual(to: "SendImage"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
        }
        else if(self.fromViewController .isEqual(to: "MultipleImage"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
        }
        else if(self.fromViewController .isEqual(to: "VimeoVideoToParents"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
        } else if(self.fromViewController .isEqual(to: "OnlineMeetingVC"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
        }
    }
    
    @IBAction func actionBackButton (_ sender:UIButton){
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionSendButton(_ sender: UIButton)
    {
        
        print("actionSendButton")
        
        
        
        
        
        print("fromView",fromView)
        print("groupHeadType",groupHeadType)
        
        
        if groupHeadType == "1"{
            
            
            print("11234567")
            if(self.fromView == "Record"){
                
                self.callSendVoiceToGroupsAndStandards()
            }else{
                self.callSendVoiceHistoryToGroupsAndStandards()
                
                
            }
            
            
        }
        
        
        
        if(self.fromViewController .isEqual(to: "VoiceToParents"))
        {
            print("11234567")
            if(self.fromView == "Record"){
                
                self.callSendVoiceToGroupsAndStandards()
            }else{
                self.callSendVoiceHistoryToGroupsAndStandards()
            }
            
            
            
            
        }
        else if(self.fromViewController .isEqual(to: "TextToParents"))
        {
            print("7890")
            self.callSendSMSToGroupsAndStandards()
        }
        else if(self.fromViewController .isEqual(to: "SchoolEvents"))
        {
            print("098765")
            self.callSchoolEvents()
        }
        else if(self.fromViewController .isEqual(to: "SendImage"))
        {
            print("55676709")
            var imageArray = NSMutableArray()
            imagesArray.add(self.imageToSend)
            self.getImageURL(images: imagesArray as! [UIImage])
        }
        else if(self.fromViewController .isEqual(to: "MultipleImage"))
        {
            print("erdtfyg")
            if(self.strFrom == "Image"){
                self.getImageURL(images: self.imagesArray as! [UIImage])
            }else{
                self.uploadPDFFileToAWS(pdfData: pdfData!)
            }
        }
        else if(self.fromViewController .isEqual(to: "VimeoVideoToParents"))
        {
            print("rejhd74e367e738e7")
            self.CallUploadVideoToVimeoServer()
        }
    }
    
    func config()
    {
        
        
        groupCollectionView.delegate = self;
        groupCollectionView.dataSource = self;
        standardCollectionView.delegate = self;
        standardCollectionView.dataSource = self;
        isEntireSchool = "F"
        
        standardCollectionView.reloadData()
        groupCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        
        if(collectionView == standardCollectionView)
        {
            return 1
        }
        else
        {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == standardCollectionView)
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return CGSize(width: (standardCollectionView.frame.size.width)-20, height: 50)
            }else{
                return CGSize(width: (standardCollectionView.frame.size.width)-20, height: 30)
            }
        }
        else
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return CGSize(width: (groupCollectionView.frame.size.width)-20, height: 50)
            }else{
                
                return CGSize(width: (groupCollectionView.frame.size.width)-20, height: 30)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == standardCollectionView)
        {
            
            
            
            return standardsArray.count
        }else{
            
            
            return groupsArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == standardCollectionView)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellStandards", for: indexPath) as! StandardGroupCVCell
            var i = Int()
            let standardDict = standardsArray.object(at: indexPath.row) as? NSDictionary
            
            i = indexPath.row+1
            cell.Checkbox.tag = (i)*(-1)
            cell.NumberLabel.text = standardDict?.object(forKey: "StandardName") as? String
            cell.Checkbox.addTarget(self, action: #selector(actionCheckBoxButton(sender:)), for: .touchUpInside)
            
            let targetDictionary = NSMutableDictionary()
            targetDictionary["TargetCode"] = standardDict?.object(forKey: "StandardID")
            if(selectedStandardCodeArray .contains(targetDictionary))
            {
                cell.Checkbox.isSelected = true
            }
            else{
                cell.Checkbox.isSelected = false
            }
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellGroups", for: indexPath) as! StandardGroupCVCell
            let groupDict = groupsArray.object(at: indexPath.row) as? NSDictionary
            cell.Checkbox1.tag = (indexPath.row+1)*(1)
            cell.Checkbox1.addTarget(self, action: #selector(actionCheckBoxButton(sender:)), for: .touchUpInside)
            cell.NumberLabel.text = groupDict?.object(forKey: "GroupName") as? String
            let targetDictionary = NSMutableDictionary()
            targetDictionary["TargetCode"] = groupDict?.object(forKey: "GroupID")
            if(selectedGroupCodeArray .contains(targetDictionary))
            {
                cell.Checkbox1.isSelected = true
            }
            else{
                cell.Checkbox1.isSelected = false
            }
            
            return cell
        }
    }
    
    @IBAction func actionSelectEntireSchoolButton(sender: UIButton) {
        if(enable == true)
        {
            enable = false
            selectEntireSchoolButton.isSelected = false
            isEntireSchool = "F"
            standardCollectionView.reloadData()
            groupCollectionView.reloadData()
        }
        else{
            enable = true
            selectEntireSchoolButton.isSelected = true
            isEntireSchool = "T"
            standardCollectionView.reloadData()
            groupCollectionView.reloadData()
        }
    }
    
    @IBAction func actionCheckBoxButton (sender: UIButton)
    {
        if(sender.tag > 0)
        {
            var i = Int()
            i =  (sender.tag) * (1)
            i = i - 1
            
            let groupDict = groupsArray.object(at: i) as? NSDictionary
            
            let targetDictionary = NSMutableDictionary()
            targetDictionary["TargetCode"] = groupDict?.object(forKey: "GroupID")
            
            if(sender .isSelected == false)
            {
                selectedGroupCodeArray.add(targetDictionary)
            }else{
                selectedGroupCodeArray.remove(targetDictionary)
            }
            groupCollectionView.reloadData()
            
        }else{
            var i = Int()
            i =  (sender.tag) * (-1)
            i = i - 1
            
            let standardDict = standardsArray.object(at: i) as? NSDictionary
            
            let targetDictionary = NSMutableDictionary()
            targetDictionary["TargetCode"] = standardDict?.object(forKey: "StandardID")
            
            if(sender .isSelected == false)
            {
                selectedStandardCodeArray.add(targetDictionary)
            }else{
                selectedStandardCodeArray.remove(targetDictionary)
            }
            standardCollectionView.reloadData()
        }
    }
    
    //MARK: Api Calling
    
    func CallUploadVideoToVimeoServer() {
        self.showLoading()
        apiCallFrom = "VimeoVidoUpload"
        
        //
        let vimeoAccessToken =  appDelegate.VimeoToken
        print("vimeoVideoURL!",vimeoVideoURL)
        print("vimeoAccessToken!",vimeoAccessToken)
        
        createVimeoUploadURL(authToken: vimeoAccessToken, videoFilePath: vimeoVideoURL) { [self] result in
            switch result {
            case .success(let uploadLink):
                uploadVideoToVimeo(uploadLink: uploadLink, videoFilePath: vimeoVideoURL, authToken: vimeoAccessToken) { [self] result in
                    switch result {
                    case .success:
                        print("")
                        
                        
                        
                    case .failure(let error):
                        print("Failed to upload video: \(error)")
                        hideLoading()
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
        
        
        
        guard let fileSize = getFileSize(at: videoFilePath) else {
            completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get file size"])))
            return
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
                    print("Vimeo API Response: \(value)")
                    if let json = value as? [String: Any],
                       let upload = json["upload"] as? [String: Any],
                       let uploadLink = upload["upload_link"] as? String {
                        
                        let embedUrl = json["player_embed_url"] as! String
                        let IFrameLink : String!
                        let embed = json["embed"]! as AnyObject
                        IFrameLink = embed["html"]! as! String
                        
                        let LinkGet  = json["link"] as! String
                        vimeoVideoDict["URL"] = LinkGet
                        vimeoVideoDict["Iframe"] = embed["html"]!
                        vimeoVideoDict["videoFileSize"] = DefaultsKeys.videoFilesize
                        
                        print(vimeoVideoDict)
                        
                        self.callSendViemoVideoToGroupsAndStandards()
                        print("videe=embedUrl",IFrameLink)
                        //                        print("IFrameLink",IFrameLink)
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
    
    func GetSchoolStrengthBySchoolID(schoolID : NSString)
    {
        apiCallFrom = "GetSchoolStrengthBySchoolID"
        self.showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        var requestStringer = baseUrlString! + NEW_STANDARD_GROUP
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + NEW_STANDARD_GROUP
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolId" : schoolID, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        print("Params : \(myString)")
        print("requestString : \(myDict)")
        print("requestString : \(requestString)")
        
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSchoolStreng")
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
            print("requestStringerVOICE_HISTORY_ENTIRE_SCHOOL11",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            print("requestString",requestString)
            print("VoiceData",VoiceData)
            print("groupHeadTypegroupHeadTypeSend",groupHeadType)
            if groupHeadType == "1"{
                self.selectedSchoolDictionary["SchoolID"]  = SchoolID
                self.selectedSchoolDictionary["StaffID"]  = staffId
                self.selectedSchoolDictionary["Description"]   = desc
                self.selectedSchoolDictionary["Duration"] = duration
            }
            
            
            self.selectedSchoolDictionary["isEntireSchool"] = "F"
            self.selectedSchoolDictionary["StandardID"] = selectedStandardCodeArray
            self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            ScheduleSendVoiceToGroupsAndStandards
            print("selectedSchoolDictionaryselectedSchoolDictionary",selectedSchoolDictionary)
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
        }else {
            
            let requestStringer = baseUrlString! + ScheduleSendVoiceToGroupsAndStandards
            print("requestStringerVOICE_HISTORY_tyENTIRE_SCHOOL",requestStringer)
            
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            print("requestString",requestString)
            print("VoiceData",VoiceData)
            print("groupHeadTypegroupHeadTypeSend",groupHeadType)
            if groupHeadType == "1"{
                self.selectedSchoolDictionary["SchoolID"]  = SchoolID
                self.selectedSchoolDictionary["StaffID"]  = staffId
                self.selectedSchoolDictionary["Description"]   = desc
                self.selectedSchoolDictionary["Duration"] = duration
            }
            
            self.selectedSchoolDictionary["StartTime"] = initialTime
            self.selectedSchoolDictionary["EndTime"] = doNotDial
            self.selectedSchoolDictionary["Dates"] = DefaultsKeys.dateArr
            
            
            
            self.selectedSchoolDictionary["isEntireSchool"] = "F"
            self.selectedSchoolDictionary["StandardID"] = selectedStandardCodeArray
            self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            ScheduleSendVoiceToGroupsAndStandards
            print("selectedSchoolDictionaryselectedSchoolDictionary",selectedSchoolDictionary)
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
            
        }
    }
    
    func callSendMultipleImageToStandardSection()
    
    {
        DispatchQueue.main.async {
            self.apiCallFrom = "StaffMultipleImage"
            self.apicalled = "1"
            
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_GROUP_STANDARD_CLOUD
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            self.selectedSchoolDictionary["isEntireSchool"] = "F"
            self.selectedSchoolDictionary["Stdcode"] = self.selectedStandardCodeArray
            self.selectedSchoolDictionary["GrpCode"] = self.selectedGroupCodeArray
            self.selectedSchoolDictionary["FileNameArray"] = self.convertedImagesUrlArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = self.strCountryCode
            self.selectedSchoolDictionary["isMultiple"] = "1"
            self.selectedSchoolDictionary["FileType"] = "IMG"
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendImageAsPrincipalToSelectedClass")
        }
        
    }
    
    func callSendPDFToStandardSection(){
        DispatchQueue.main.async {
            self.apiCallFrom = "StaffMultipleImage"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_GROUP_STANDARD_CLOUD
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            self.selectedSchoolDictionary["isEntireSchool"] = "F"
            self.selectedSchoolDictionary["Stdcode"] = self.selectedStandardCodeArray
            self.selectedSchoolDictionary["GrpCode"] = self.selectedGroupCodeArray
            self.selectedSchoolDictionary["FileNameArray"] = self.convertedImagesUrlArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = self.strCountryCode
            self.selectedSchoolDictionary["isMultiple"] = "0"
            self.selectedSchoolDictionary["FileType"] = ".pdf"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendImageAsPrincipalToSelectedClass")
        }
    }
    
    func callSendVoiceHistoryToGroupsAndStandards(){
        print("callSendVoiceHistoryToGroupsAndStandards",VoiceHistoryArray[0])
        
        apiCallFrom = "SendVoiceToGroupsAndStandards"
        let VoiceDict = VoiceHistoryArray[0] as! NSDictionary
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime = DefaultsKeys.initialDisplayDate
        var doNotDial =  DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            
            let requestStringer = baseUrlString! + VOICE_HISTORY_GROUP_STANDARD
            print("requestStringerVO333L",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            if groupHeadType == "1"{
                self.selectedSchoolDictionary["SchoolID"]  = SchoolID
                self.selectedSchoolDictionary["StaffID"]  = staffId
                self.selectedSchoolDictionary["Description"]   = desc
                self.selectedSchoolDictionary["Duration"] = duration
            }
            
            self.selectedSchoolDictionary["isEntireSchool"] = "F"
            self.selectedSchoolDictionary["StandardID"] = selectedStandardCodeArray
            self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
            self.selectedSchoolDictionary["filepath"] = String(describing: VoiceDict["FilePath"]!)
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            print("selectedSchoolDictionary",selectedSchoolDictionary)
            
            print("selectedStandardCodeArray",selectedStandardCodeArray)
            print("selectedGroupCodeArray",selectedGroupCodeArray)
            print("strCountryCode",strCountryCode)
            print("SendVoicemyString",myString)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }else {
            let requestStringer = baseUrlString! + SCHEDULE_VOICE_HISTORY_GROUP_STANDARD
            print("requestStringerOL56ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            if groupHeadType == "1"{
                self.selectedSchoolDictionary["SchoolID"]  = SchoolID
                self.selectedSchoolDictionary["StaffID"]  = staffId
                self.selectedSchoolDictionary["Description"]   = desc
                self.selectedSchoolDictionary["Duration"] = duration
            }
            
            self.selectedSchoolDictionary["isEntireSchool"] = "F"
            self.selectedSchoolDictionary["StandardID"] = selectedStandardCodeArray
            self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
            self.selectedSchoolDictionary["filepath"] = String(describing: VoiceDict["FilePath"]!)
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            self.selectedSchoolDictionary["StartTime"] = initialTime
            self.selectedSchoolDictionary["EndTime"] = doNotDial
            self.selectedSchoolDictionary["Dates"] = DefaultsKeys.dateArr
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            print("selectedSchoolDictionary",selectedSchoolDictionary)
            
            print("selectedStandardCodeArray",selectedStandardCodeArray)
            print("selectedGroupCodeArray",selectedGroupCodeArray)
            print("strCountryCode",strCountryCode)
            print("DefaultsKeys.dateArr",DefaultsKeys.dateArr)
            print("SendVoicemyString",myString)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }
    }
    
    func callSendImageToGroupsAndStandards(){
        DispatchQueue.main.async {
            self.apiCallFrom = "SendImageToGroupsAndStandards"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_GROUP_STANDARD_CLOUD
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            self.selectedSchoolDictionary["isEntireSchool"] = "F"
            self.selectedSchoolDictionary["Stdcode"] = self.selectedStandardCodeArray
            self.selectedSchoolDictionary["GrpCode"] = self.selectedGroupCodeArray
            self.selectedSchoolDictionary["FileNameArray"] = self.convertedImagesUrlArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = self.strCountryCode
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendImageAsPrincipalToSelectedClass")
        }
    }
    
    func callSendViemoVideoToGroupsAndStandards(){
        apiCallFrom = "sendVimeoVideo"
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_VIMEO_VIDEO_GROUP_STANDARD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        self.vimeoVideoDict["StdCode"] = selectedStandardCodeArray
        self.vimeoVideoDict["GrpCode"] = selectedGroupCodeArray
        self.vimeoVideoDict[COUNTRY_CODE] = strCountryCode
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.vimeoVideoDict)
        print(myString)
        apiCall.nsurlConnectionFunction(requestString, myString, "TextToParents")
    }
    
    func callSendSMSToGroupsAndStandards(){
        apiCallFrom = "SendSMSToGroupsAndStandards"
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SendSMSToGroupsAndStandards
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        print(isEntireSchool)
        print(selectedStandardCodeArray)
        print(selectedGroupCodeArray)
        self.selectedSchoolDictionary["isEntireSchool"] = "F"
        self.selectedSchoolDictionary["StandardID"] = selectedStandardCodeArray
        self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
        self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
        print(myString)
        apiCall.nsurlConnectionFunction(requestString, myString, "TextToParents")
    }
    
    func callSchoolEvents(){
        apiCallFrom = "SchoolEvents"
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + ManageSchoolEvents
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        self.selectedSchoolDictionary["isEntireSchool"] = "F"
        self.selectedSchoolDictionary["StandardID"] = selectedStandardCodeArray
        self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
        self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
        apiCall.nsurlConnectionFunction(requestString, myString, "SchoolEvents")
    }
    
    //MARK: Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        hideLoading()
        if(csData != nil){
            print("RES : \(csData) \(pagename)")
            if((csData?.count)! > 0){
                let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                
                if(apiCallFrom == "sendVimeoVideo"){
                    if let CheckedArray = csData as? NSArray
                    {
                        
                        for i in 0..<CheckedArray.count
                        {
                            let dict = CheckedArray[i] as! NSDictionary
                            let Status = String(describing: dict["result"]!)
                            let Message = String(describing: dict["Message"]!)
                            if(Status == "1")
                            {
                                Util.showAlert("", msg: Message)
                                let loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
                                if(loginAsName == "Principal")
                                {
                                    
                                    if(appDelegate.LoginSchoolDetailArray.count > 1){
                                        self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                    }else{
                                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                    }
                                }else{
                                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                }
                                
                                
                            }else{
                                
                                Util.showAlert("", msg: Message)
                                
                            }
                        }
                        
                    }
                    else{
                        Util.showAlert("", msg: strSomething)
                    }
                    
                }
                
                else if(apiCallFrom .isEqual(to: "GetSchoolStrengthBySchoolID")){
                    if let CheckStandardArray = dicUser.object(forKey: "Standards") as? NSArray{
                        
                        if(CheckStandardArray.count > 0){
                            let Dict : NSDictionary = CheckStandardArray[0] as! NSDictionary
                            let strStdID : String = String(describing: Dict["StandardID"]!)
                            let checkStr =  Util.checkNil(strStdID)
                            if(checkStr == "" || checkStr == "0"){
                                NoStandardLbl.isHidden = false
                                NoStandardLbl.text = String(describing: Dict["StandardName"]!)
                                standardCollectionView.isHidden = true
                                standardCollectionView.reloadData()
                            }else{
                                standardsArray = CheckStandardArray
                                NoStandardLbl.isHidden = true
                                standardCollectionView.isHidden = false
                                standardCollectionView.reloadData()
                            }
                        }else{
                            NoStandardLbl.isHidden = false
                            NoStandardLbl.text = "Classes not Found"
                            standardCollectionView.isHidden = true
                            standardCollectionView.reloadData()
                        }
                    }
                    if let CheckGroupArray = dicUser.object(forKey: "Groups") as? NSArray{
                        
                        if(CheckGroupArray.count > 0){
                            let Dict : NSDictionary = CheckGroupArray[0] as! NSDictionary
                            let strStdID : String = String(describing: Dict["GroupID"]!)
                            let checkStr =  Util.checkNil(strStdID)
                            if(checkStr == "" || checkStr == "0"){
                                NoGroupLbl.isHidden = false
                                NoGroupLbl.text = String(describing: Dict["GroupName"]!)
                                groupCollectionView.isHidden = true
                                groupCollectionView.reloadData()
                            }else{
                                groupsArray = CheckGroupArray
                                NoGroupLbl.isHidden = true
                                groupCollectionView.isHidden = false
                                groupCollectionView.reloadData()
                            }
                        }else{
                            NoGroupLbl.isHidden = false
                            NoGroupLbl.text = "Groups not Found"
                            groupCollectionView.isHidden = true
                            groupCollectionView.reloadData()
                        }
                    }
                }else if(apiCallFrom .isEqual(to: "StaffMultipleImage")){
                    if let status = dicUser["Status"] as? NSString
                    {
                        let Status = status
                        let Message = dicUser["Message"] as! NSString
                        
                        if(Status .isEqual(to: "1")){
                            if(self.strFrom == "Image"){
                                if(apicalled == "1"){
                                    apicalled = "0"
                                    Util.showAlert("", msg: Message as String?)
                                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                }
                            }else{
                                Util.showAlert("", msg: Message as String?)
                                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            }
                        }else{
                            Util.showAlert("", msg: Message as String?)
                        }
                    }
                }else{
                    if let status = dicUser["Status"] as? NSString
                    {
                        let Status = status
                        let Message = dicUser["Message"] as! NSString
                        
                        if(Status .isEqual(to: "1")){
                            Util.showAlert("", msg: Message as String?)
                            
                            if(appDelegate.LoginSchoolDetailArray.count > 1){
                                self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            }else{
                                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            }
                        }else{
                            Util.showAlert("", msg: Message as String?)
                        }
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
        SendButton.setTitle(LangDict["teacher_txt_send"] as? String, for: .normal)
        StandardLabel.text = LangDict["standards_teacher"] as? String
        GroupsLabel.text = LangDict["groups_teacher"] as? String
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
                        if(self.fromViewController .isEqual(to: "MultipleImage")){
                            self.callSendMultipleImageToStandardSection()
                        }else{
                            self.callSendImageToGroupsAndStandards()
                        }
                        
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
        let CognitoPoolID =  DefaultsKeys.CognitoPoolID
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
        // upload
        
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
                    self.callSendPDFToStandardSection()
                    
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


