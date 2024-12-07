//
//  StandardOrSectionVCStaff.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 26/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import Alamofire

class StandardOrSectionVCStaff: UIViewController,Apidelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var PopupChoosePickerView: UIView!
    @IBOutlet weak var MyPickerView: UIPickerView!
    @IBOutlet weak var PickerTitleLabel: UILabel!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var pickerCancelButton: UIButton!
    @IBOutlet weak var pickerOkButton: UIButton!
    @IBOutlet var MyTableView: UITableView!
    var strApiFrom = NSString()
    var StaffId = String()
    var SchoolId = String()
    var TableString = String()
    var pickerStandardArray = [String]()
    var pickerSubjectArray = [String]()
    var pickerSectionArray = [String]()
    var selectedStandardRow = 0;
    var selectedSubjectRow = 0;
    var selectedSectionRow = 0;
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var StandarCodeArray:Array = [String]()
    var StandardNameArray:Array = [String]()
    var SubjectNameArray:Array = [String]()
    var DetailofSectionArray:Array = [Any]()
    var DetailofSubjectArray:Array = [Any]()
    var popupChooseStandard : KLCPopup  = KLCPopup()
    var SelectedStandardName = String()
    var DetailedSubjectArray:Array = [Any]()
    var SelectedSectionDetail:NSDictionary = [String:Any]() as NSDictionary
    var SelectedSubjectDetail:NSDictionary = [String:Any]() as NSDictionary
    var SectionTitleArray = NSMutableArray()
    
    var SelectedStandardString = String()
    var SelectedSubjectString = String()
    var SendedScreenNameStr = String()
    var HomeTitleText = String()
    var HomeTextViewText = String()
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    var StandardSectionSubjectArray = NSArray()
    var SectionCodeArray:Array = [String]()
    var SubjectCodeArray:Array = [String]()
    var SelectedSectionCodeArray = NSMutableArray()
    var ChoosenSectionIDArray : Array = [Any]()
    var durationString = String()
    var VoiceurlData: URL?
    var uploadImageData : NSData? = nil
    var VideoData : NSData? = nil
    var pdfData : NSData? = nil
    let UtilObj = UtilClass()
    var StandardSectionArray = NSArray()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedSchoolDictionary = NSMutableDictionary()
    var vimeoVideoDict = NSMutableDictionary()
    var fromView = String()
    var voiceHistoryArray = NSMutableArray()
    var imagesArray = NSMutableArray()
    var languageDictionary = NSDictionary()
    var strLanguage = String()
    var strFrom = String()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var apicalled = "0"
    var convertedImagesUrlArray = NSMutableArray()
    var currentImageCount = 0
    var totalImageCount = 0
    var imageUrlArray = NSMutableArray()
    var originalImagesArray = [UIImage]()
    
    var vimeoVideoURL : URL!
    var countryCoded : String!
    override func viewDidLoad()
    {
        
        
        super.viewDidLoad()
        view.isOpaque = false
        print("test11")
        
        print("GetvimeoVideoURL",vimeoVideoURL)
        countryCoded =  UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        
        PopupChoosePickerView.isHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        
        self.callSelectedLanguage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:PICKER VIEW
    public func numberOfComponents(in pickerView:  UIPickerView) -> Int
    {
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(TableString == "Standard")
        {
            return pickerStandardArray.count
            
        }
        
        else
        {
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
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(TableString == "Standard")
        {
            selectedStandardRow = row;
            
        }
        else if(TableString == "Section")
        {
            selectedSectionRow = row
        }
        else if(TableString == "Subject")
        {
            selectedSubjectRow = row
        }
        
    }
    //MARK: TABLEVIEW  DELEGATE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionTitleArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 1)
        {
            return pickerSectionArray.count
        }
        else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 55
        }else{
            return 40
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StaffAddNewClassTVCell", for: indexPath) as! StaffAddNewClassTVCell
        if(indexPath.section == 1)
        {
            cell.BorderImage.isHidden = true
            cell.SelectionImage.image = UIImage(named: "UnChechBoxImage")
            cell.SubjectView.layer.cornerRadius = 0
            cell.SubjectView.layer.masksToBounds = true
            cell.SubjectView.layer.shadowOpacity = 0.7
            cell.SubjectView.layer.shadowOffset = CGSize.zero
            cell.SubjectView.layer.shadowRadius = 4
            cell.SubjectView.layer.shadowColor = UIColor.black.cgColor
            cell.SchoolNameLbl.text = pickerSectionArray[indexPath.row]
            
        }else{
            
            
            cell.SchoolNameLbl.text = SelectedStandardString
            cell.BorderImage.isHidden = false
            cell.SubjectView.layer.cornerRadius = 3
            cell.SubjectView.layer.masksToBounds = true
            cell.SubjectView.layer.shadowOpacity = 0.7
            cell.SubjectView.layer.shadowOffset = CGSize.zero
            cell.SubjectView.layer.shadowRadius = 4
            cell.SubjectView.layer.shadowColor = UIColor.black.cgColor
            cell.SelectionImage.image = UIImage(named: "Downarrow")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        let headerLabel = UILabel()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            headerView.frame = CGRect(x: 0, y: 0, width:
                                        tableView.bounds.size.width, height: 30)
            headerLabel.frame = CGRect(x: 0, y: 10, width:
                                        tableView.bounds.size.width, height: 35)
            headerLabel.font = UIFont(name: "Verdana", size: 20)
        }
        else
        {
            
            headerView.frame = CGRect(x: 0, y: 0, width:
                                        tableView.bounds.size.width, height: 20)
            headerLabel.frame = CGRect(x: 0, y: 10, width:
                                        tableView.bounds.size.width, height: 25)
            headerLabel.font = UIFont(name: "Verdana", size: 15)
            
            
        }
        headerLabel.textColor = UIColor.white
        headerLabel.text = SectionTitleArray[section] as! String
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 40
        }else{
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        if(indexPath.section == 0)
        {
            MyPickerView.selectRow(selectedStandardRow, inComponent: 0, animated: true)
            self.actionSelectStandard()
            
        }else if(indexPath.section == 1){
            cell.SelectionImage.image = UIImage(named: "CheckBoximage")
            
            
            SelectedSectionCodeArray.add(SectionCodeArray[indexPath.row])
            
        }
        UtilObj.printLogKey(printKey: "SelectedSectionCodeArray", printingValue: SelectedSectionCodeArray)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        if(indexPath.section == 1)
        {
            cell.SelectionImage.image = UIImage(named: "UnChechBoxImage")
            let SectionCode = SectionCodeArray[indexPath.row]
            if(SelectedSectionCodeArray.contains(SectionCode))
            {
                SelectedSectionCodeArray.remove(SectionCode)
            }else{
                SelectedSectionCodeArray.add(SectionCode)
            }
            
        }
        UtilObj.printLogKey(printKey: "SelectedSectionCodeArray", printingValue: SelectedSectionCodeArray)
    }
    
    //MARK: BUTTON ACTION FUNCTIONS
    
    
    func actionSelectStandard()
    {
        TableString = "Standard"
        PickerTitleLabel.text = languageDictionary["select_standard"] as? String
        PopupChoosePickerView.isHidden = false
        self.MyPickerView.reloadAllComponents()
        
        if(pickerStandardArray.count > 0)
        {
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PopupChoosePickerView.frame.size.height = 300
                PopupChoosePickerView.frame.size.width = 350
            }
            
            PopupChoosePickerView.isHidden = false
            
            popupChooseStandard.show()
        }
        else
        {
            Util.showAlert(languageDictionary["alert"] as? String, msg: languageDictionary["no_students"] as? String)
        }
        
    }
    
    
    func UpdateStandardValue(StandardName : String)
    {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        cell.SchoolNameLbl.text = StandardName
        
        
    }
    
    
    //MARK: BUTTON ACTIONS
    @IBAction func actionSendButton(_ sender: UIButton)
    {
        if(SelectedSectionCodeArray.count > 0){
            for i in 0..<SelectedSectionCodeArray.count
            {
                let mystring = SelectedSectionCodeArray[i] as? String
                let StudentDic:NSDictionary = ["TargetCode" : mystring!]
                ChoosenSectionIDArray.append(StudentDic)
                print(ChoosenSectionIDArray)
                
            }
            if(UtilObj.IsNetworkConnected())
            {
                if(SendedScreenNameStr == "StaffTextMessage")
                {
                    self.SendStaffTextHomeWorkApi()
                }
                else if(SendedScreenNameStr == "StaffVoiceMessage")
                {
                    if( self.fromView == "Record"){
                        self.SendStaffVoiceMessageApi()
                    }else{
                        self.SendStaffHistoryVoiceMessageApi()
                    }
                    
                }else if(self.SendedScreenNameStr .isEqual("StaffMultipleImage"))
                {
                    if(self.strFrom == "Image"){
                        print("imagesArrayimagesArray",imagesArray)
                        print("igesArray",self.imagesArray as! [UIImage])
                        self.getImageURL(images: self.imagesArray as! [UIImage])
                    }else{
                        self.uploadPDFFileToAWS(pdfData: pdfData!)
                    }
                }else if(SendedScreenNameStr == "StaffImageMessage"){
                    self.SendImageAsStaff()
                }
                else if(SendedScreenNameStr == "VimeoVideoToParents"){
                    self.CallUploadVideoToVimeoServer()
                }
                else if(SendedScreenNameStr == "TextToParents")
                {
                    self.SendPrincipalTextApi()
                }else if(SendedScreenNameStr == "VoiceToParents")
                {
                    if(self.fromView == "Record"){
                        self.SendPrincipalVoiceMessageApi()
                    }else{
                        self.SendPrincipalVoiceHistoryMessageApi()
                    }
                }else if(self.SendedScreenNameStr .isEqual("MultipleImage"))
                {
                    print("strFromstrFrom2333",strFrom)
                    print("strFromsimagesArray",imagesArray as! [UIImage])
                    if(self.strFrom == "Image"){
                        self.getImageURL(images: self.imagesArray as! [UIImage])
                    }else{
                        self.uploadPDFFileToAWS(pdfData: pdfData!)
                    }
                }
            }
            else
            {
                Util.showAlert("", msg:strNoInternet )
            }
        }else{
            Util.showAlert("", msg: languageDictionary["alert_section"] as? String)
        }
        
    }
    
    @IBAction func actionOk(_ sender: UIButton) {
        PopupChoosePickerView.isHidden = true
        if(TableString == "Standard")
        {
            SectionCodeArray.removeAll()
            SelectedSectionCodeArray.removeAllObjects()
            SelectedStandardString = pickerStandardArray[selectedStandardRow]
            UpdateStandardValue(StandardName: SelectedStandardString)
            
            let sectionarray:Array = DetailofSectionArray[selectedStandardRow] as! [Any]
            
            UtilObj.printLogKey(printKey: "sectionarray", printingValue: sectionarray)
            
            var sectionNameArray :Array = [String]()
            if(sectionarray.count > 0)
            {
                for var i in 0..<sectionarray.count
                {
                    let dicResponse :NSDictionary = sectionarray[i] as! NSDictionary
                    sectionNameArray.append(dicResponse["SectionName"] as! String)
                    SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                }
                pickerSectionArray = sectionNameArray
                
            }else{
                pickerSectionArray = []
                
            }
            MyTableView.reloadData()
        }
        else if(TableString == "Section")
        {
            
        }
        popupChooseStandard.dismiss(true)
        
    }
    @IBAction func actionCancel(_ sender: UIButton) {
        PopupChoosePickerView.isHidden = true
        popupChooseStandard.dismiss(true)
    }
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: API CALLING
    
    func CallUploadVideoToVimeoServer() {
        print("CallUploadVideoToVimeoServer1")
        self.showLoading()
        strApiFrom = "VimeoVidoUpload"
        
        
        let vimeoAccessToken =  appDelegate.VimeoToken
        print("vimeoVideoURL111!11",vimeoVideoURL)
        print("vimeoAccessToken!11",vimeoAccessToken)
        
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
        // Output: true
        print("authToken",authToken)
        print("DefaultsVideoDownload",DefaultsKeys.allowVideoDownload)
        print("getDownload",getDownload)
        let parameters: [String: Any] = [
            "upload": [
                "approach": "tus",
                "size": "\(fileSize)"
            ],
            "privacy":[
                "view":"unlisted",
                "download": true
               
            ],
            
            "name": TitleGet,
            "description": TitleDescriotion
        ]
        
        print("zzzparameters",parameters)
        
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
                        self.SendVimeoVideoToSection()
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
            
            print("authToken1",authToken)
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
    
    
    func callStaffSendMultipleImage(){
        DispatchQueue.main.async {
            self.strApiFrom = "SendImageAsStaff"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_TO_SECTION_CLOUD//
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["SchoolID" : self.SchoolId,"StaffID" : self.StaffId,"Description" : self.HomeTitleText,"Seccode" : self.ChoosenSectionIDArray, COUNTRY_CODE: self.strCountryCode,"isMultiple":"1","FileType":"IMG","FileNameArray" : self.convertedImagesUrlArray]
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: myDict)
            self.UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendImageAsStaff")
        }
        
    }
    
    func callStaffSendPDF(){
        DispatchQueue.main.async {
            self.strApiFrom = "SendImageAsStaff"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_TO_SECTION_CLOUD //STAFF_SEND_IMAGE_MESSAGE
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["SchoolID" : self.SchoolId,"StaffID" : self.StaffId,"Description" : self.HomeTitleText,"Seccode" : self.ChoosenSectionIDArray, COUNTRY_CODE: self.strCountryCode,"isMultiple":"0","FileType":".pdf","FileNameArray" : self.convertedImagesUrlArray]
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: myDict)
            self.UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendImageAsStaff")
        }
    }
    
    
    func GetAllSectionCodeapi()
    {
        showLoading()
        strApiFrom = "GetSectionCodeAttendance"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_STANDARD_SECTION_SUBJECT
        if(SendedScreenNameStr == "TextToParents" || SendedScreenNameStr == "VoiceToParents"){
            requestStringer = baseUrlString! + GET_STANDARD_SECTION_SUBJECT
        }else{
            requestStringer = baseUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        }
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            if(SendedScreenNameStr == "TextToParents" || SendedScreenNameStr == "VoiceToParents"){
                requestStringer = baseReportUrlString! + GET_STANDARD_SECTION_SUBJECT
            }else{
                requestStringer = baseReportUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
            }
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolId" : SchoolId,"StaffID" : StaffId,"isAttendance" :"0", COUNTRY_CODE: strCountryCode]
        print("BAS: \(requestStringer) : \(SendedScreenNameStr)")
        let myString = Util.convertDictionary(toString: myDict)
        print("myString: \(myString)")
        
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSectionCodeAttendance")
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
        self.vimeoVideoDict["Seccode"] = ChoosenSectionIDArray
        self.vimeoVideoDict[COUNTRY_CODE] = strCountryCode
        
        let myString = Util.convertDictionary(toString: vimeoVideoDict)
        UtilObj.printLogKey(printKey: "myDict", printingValue: vimeoVideoDict)
        print("myString",myString)
        apiCall.nsurlConnectionFunction(requestString, myString, "sendVimeoVideo")
    }
    
    
    func SendStaffTextHomeWorkApi()
    {
        showLoading()
        strApiFrom = "SendStaffTextHomeWorkApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + STAFF_SEND_TEXT_MESSAGE
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description": HomeTitleText,"Message": HomeTextViewText,"Seccode" : ChoosenSectionIDArray, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendStaffTextHomeWorkApi")
    }
    
    func callSendMultipleImageToStandardSection()
    
    {
        DispatchQueue.main.async {
            self.strApiFrom = "StaffMultipleImage"
            self.apicalled = "1"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_TO_SECTION_CLOUD
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            self.selectedSchoolDictionary["isEntireSchool"] = "F"
            
            self.selectedSchoolDictionary["Seccode"] = self.ChoosenSectionIDArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = self.strCountryCode
            self.selectedSchoolDictionary["isMultiple"] = "1"
            self.selectedSchoolDictionary["FileType"] = "IMG"
            self.selectedSchoolDictionary["FileNameArray"] = self.convertedImagesUrlArray
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendImageAsPrincipalToSelectedClass")
        }
        
        
    }
    
    func callSendPDFToStandardSection(){
        DispatchQueue.main.async {
            self.strApiFrom = "StaffMultipleImage"
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + MULTIPLE_IMAGE_MESSAGE_TO_SECTION_CLOUD //STAFF_SEND_IMAGE_MESSAGE
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            self.selectedSchoolDictionary["isEntireSchool"] = "F"
            self.selectedSchoolDictionary["Seccode"] = self.ChoosenSectionIDArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = self.strCountryCode
            self.selectedSchoolDictionary["isMultiple"] = "0"
            self.selectedSchoolDictionary["FileType"] = ".pdf"
            self.selectedSchoolDictionary["FileNameArray"] = self.convertedImagesUrlArray
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendImageAsPrincipalToSelectedClass")
        }
    }
    
    func SendStaffVoiceMessageApi()
    {
        showLoading()
        strApiFrom = "SendStaffVoiceMessageApi"
        let VoiceData = NSData(contentsOf: self.VoiceurlData!)
        
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
            print("requestStringerOL56ty8765r",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText,"Duration": durationString ,"Seccode" : ChoosenSectionIDArray, COUNTRY_CODE: strCountryCode]
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.callPassVoiceParms(requestString, myString, "SendStaffVoiceMessageApi", VoiceData as Data?)
        }else{
            let requestStringer = baseUrlString! + SCHEDULE_STAFF_SEND_VOICE_MESSAGE
            print("requestStringerOL5wesdrfghb6ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText,"Duration": durationString ,"Seccode" : ChoosenSectionIDArray, COUNTRY_CODE: strCountryCode , "StartTime" : initialTime , "EndTime" : doNotDial , "Dates" : DefaultsKeys.dateArr  ]
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.callPassVoiceParms(requestString, myString, "SendStaffVoiceMessageApi", VoiceData as Data?)
        }
    }
    
    func SendStaffHistoryVoiceMessageApi()
    {
        let voiceDict = voiceHistoryArray[0] as! NSDictionary
        showLoading()
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
            print("requ543rtL56ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText,"Duration": durationString ,"filepath" : String(describing: voiceDict["FilePath"]!),"Seccode" : ChoosenSectionIDArray, COUNTRY_CODE: strCountryCode]
            
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendStaffVoiceMessageApi")
        }else{
            let requestStringer = baseUrlString! + SCHEDULE_STAFF_ENTIRE_SECTION_VOICE_HISTORY
            print("requestStringerbegyhOL56ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText,"Duration": durationString ,"filepath" : String(describing: voiceDict["FilePath"]!),"Seccode" : ChoosenSectionIDArray, COUNTRY_CODE: strCountryCode, "StartTime" : initialTime , "EndTime" : doNotDial , "Dates" : DefaultsKeys.dateArr ]
            
            UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendStaffVoiceMessageApi")
        }
    }
    
    func SendImageAsStaff()
    
    {
        showLoading()
        strApiFrom = "SendImageAsStaff"
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + STAFF_SEND_IMAGE_MESSAGE
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText,"Seccode" : ChoosenSectionIDArray, COUNTRY_CODE: strCountryCode]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.callPassImageParms(requestString, myString, "SendImageAsStaff", uploadImageData as Data?)
    }
    
    
    func SendPrincipalVoiceMessageApi()
    {
        showLoading()
        strApiFrom = "SendPrincipalVoiceMessageApi"
        let VoiceData = NSData(contentsOf: self.VoiceurlData!)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime =  DefaultsKeys.initialDisplayDate
        var doNotDial = DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        print("dateArr",DefaultsKeys.dateArr)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            let requestStringer = baseUrlString! + STAFF_SEND_VOICE_MESSAGE
            print("dghbdningerOL56ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            self.selectedSchoolDictionary["Seccode"] = ChoosenSectionIDArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            UtilObj.printLogKey(printKey: "myDict", printingValue: self.selectedSchoolDictionary)
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            print("VoiceurlData",VoiceurlData)
            print("myStringmyString",myString)
            apiCall.callPassVoiceParms(requestString, myString, "SendPrincipalVoiceMessageApi", VoiceData as Data?)
        }else{
            let requestStringer = baseUrlString! + SCHEDULE_STAFF_SEND_VOICE_MESSAGE
            print("dghbd36ty",requestStringer)
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            self.selectedSchoolDictionary["Seccode"] = ChoosenSectionIDArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            self.selectedSchoolDictionary["StartTime"] = initialTime
            self.selectedSchoolDictionary["EndTime"] = doNotDial
            self.selectedSchoolDictionary["Dates"] = DefaultsKeys.dateArr
            UtilObj.printLogKey(printKey: "myDict", printingValue: self.selectedSchoolDictionary)
            UtilObj.printLogKey(printKey: "myDict", printingValue: self.selectedSchoolDictionary)
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            print("VoiceurlData",VoiceurlData)
            print("myStringmyString",myString)
            apiCall.callPassVoiceParms(requestString, myString, "SendPrincipalVoiceMessageApi", VoiceData as Data?)
        }
        
        
    }
    func SendPrincipalVoiceHistoryMessageApi()
    {
        showLoading()
        strApiFrom = "SendPrincipalVoiceMessageApi"
        let VoiceDict = voiceHistoryArray[0] as! NSDictionary
        // let VoiceData = NSData(contentsOf: self.VoiceurlData!)
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
            print("dghbdningerOL56tyhist",requestStringer)
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            self.selectedSchoolDictionary["Seccode"] = ChoosenSectionIDArray
            self.selectedSchoolDictionary["filepath"] = String(describing: VoiceDict["FilePath"]!)
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            
            
            UtilObj.printLogKey(printKey: "myDict", printingValue: self.selectedSchoolDictionary)
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendPrincipalVoiceMessageApi")
        }else{
            let requestStringer = baseUrlString! + SCHEDULE_STAFF_ENTIRE_SECTION_VOICE_HISTORY
            print("dghbdningerOL56t33333y",requestStringer)
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            self.selectedSchoolDictionary["Seccode"] = ChoosenSectionIDArray
            self.selectedSchoolDictionary["filepath"] = String(describing: VoiceDict["FilePath"]!)
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            self.selectedSchoolDictionary["StartTime"] = initialTime
            self.selectedSchoolDictionary["EndTime"] = doNotDial
            self.selectedSchoolDictionary["Dates"] = DefaultsKeys.dateArr
            
            UtilObj.printLogKey(printKey: "myDict", printingValue: self.selectedSchoolDictionary)
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendPrincipalVoiceMessageApi")
        }
    }
    
    func SendPrincipalTextApi()
    {
        showLoading()
        strApiFrom = "SendPrincipalTextApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + STAFF_SEND_TEXT_MESSAGE
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        self.selectedSchoolDictionary["Seccode"] = ChoosenSectionIDArray
        self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
        
        let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
        UtilObj.printLogKey(printKey: "myDict", printingValue: self.selectedSchoolDictionary)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendPrincipalTextApi")
    }
    
    //MARK: API RESPONSE DELEGATE
    @objc func responestring(_ csData: NSMutableArray!, _ pagename: String!)
    {
        hideLoading()
        
        
        if(csData != nil)
        {UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            
            if(strApiFrom == "sendVimeoVideo"){
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
                                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
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
            else if(strApiFrom.isEqual(to:"GetSectionCodeAttendance"))
            {
                var dicResponse: NSDictionary = [:]
                var AlertString = String()
                if((csData?.count)! > 0)
                {
                    if let ResponseArray = csData as? NSArray
                    {
                        StandardSectionSubjectArray = ResponseArray
                        if(StandardSectionSubjectArray.count > 0)
                        {
                            for  i in 0..<StandardSectionSubjectArray.count
                            {
                                
                                dicResponse = StandardSectionSubjectArray[i] as! NSDictionary
                                let CheckstdName = String(describing: dicResponse["Standard"]!)
                                let stdName = Util.checkNil(CheckstdName)
                                let stdcode = String(describing: dicResponse["StandardId"]!)
                                StandarCodeArray.append(stdcode)
                                AlertString = stdcode
                                if(stdName != "" && stdName != "0")
                                {
                                    StandardNameArray.append(stdName!)
                                    DetailofSectionArray.append(dicResponse["Sections"] as! [Any])
                                    DetailedSubjectArray.append(dicResponse["Subjects"] as! [Any])
                                    
                                    pickerStandardArray = StandardNameArray
                                    
                                    if let sectionarray = DetailofSectionArray[0] as? NSArray
                                    {
                                        
                                        var sectionNameArray :Array = [String]()
                                        if(sectionarray.count > 0)
                                        {
                                            for  i in 0..<sectionarray.count
                                            {
                                                let dicResponse : NSDictionary = sectionarray[i] as! NSDictionary
                                                sectionNameArray.append(String(describing: dicResponse["SectionName"]!))
                                                
                                                SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                                            }
                                            pickerSectionArray = sectionNameArray
                                            MyTableView.reloadData()
                                        }
                                        
                                        
                                    }
                                    if let SubjectArray = DetailedSubjectArray[0] as? NSArray
                                    {
                                        
                                        var SubjectNameArray :Array = [String]()
                                        if(SubjectArray.count > 0)
                                        {
                                            for  i in 0..<SubjectArray.count
                                            {
                                                let dicResponse : NSDictionary = SubjectArray[i] as! NSDictionary
                                                SubjectNameArray.append(String(describing: dicResponse["SubjectName"]!))
                                                
                                                SubjectCodeArray.append(String(describing: dicResponse["SubjectId"]!))
                                            }
                                            pickerSubjectArray = SubjectNameArray
                                            let dicResponse :NSDictionary = SubjectArray[0] as! NSDictionary
                                            SelectedSubjectDetail = dicResponse
                                            let SubjectName = String (describing: dicResponse["SubjectName"]!)
                                            UpdateStandardValue(StandardName: String(pickerStandardArray[0]))
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                                
                                
                                else
                                {
                                    Util.showAlert("", msg: AlertString)
                                    dismiss(animated: false, completion: nil)
                                }
                            }
                        }
                        else
                        {
                            Util.showAlert("", msg: strNoRecordAlert)
                            dismiss(animated: false, completion: nil)
                        }
                    }
                    
                }
                else
                {   Util.showAlert("", msg: strNoRecordAlert)
                    dismiss(animated: false, completion: nil)
                    
                }
                
            }
            else if(strApiFrom.isEqual(to:"SendStaffTextHomeWorkApi"))
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
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        
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
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        
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
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        
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
                
                
            }else if(strApiFrom.isEqual(to:"StaffMultipleImage"))
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
                                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            }
                        }else{
                            Util.showAlert("", msg: myalertstring)
                            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
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
            //""
            else if(strApiFrom.isEqual(to:"SendPrincipalVoiceMessageApi"))
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
                        if(appDelegate.LoginSchoolDetailArray.count > 1){
                            self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }else{
                            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                        
                        
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
            else if(strApiFrom.isEqual(to:"SendPrincipalTextApi"))
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
                        
                        if(appDelegate.LoginSchoolDetailArray.count > 1){
                            self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }else{
                            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                        
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
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        // print("Error")
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
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            
        }
        self.SendButton.setTitle(LangDict["teacher_txt_send"] as? String, for: .normal)
        self.pickerOkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        self.pickerCancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        let strStandard : String = languageDictionary["teacher_atten_standard"] as? String ?? "Standard"
        let strSection : String = languageDictionary["teacher_atten_sections"] as? String ?? "Section(s)"
        SectionTitleArray = [strStandard, strSection]
        print("StandardOrSectionVCStaff SendedScreenNameStr\(SendedScreenNameStr)")
        
        if(SendedScreenNameStr == "TextToParents" || SendedScreenNameStr == "VoiceToParents"){
            print(SchoolId)
        }else{
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }
        if(StandardSectionSubjectArray.count == 0){
            if(UtilObj.IsNetworkConnected()){
                self.GetAllSectionCodeapi()
            }
            else
            {
                Util.showAlert("", msg:strNoInternet )
            }
            
        }
    }
    
    
    //MARK: AWS Upload
    
    func getImageURL(images : [UIImage]){
        showLoading()
        self.originalImagesArray = images
        self.totalImageCount = images.count
        print("imagesimages",images)
        print("imagcountes",images.count)
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
        //            let image = UIImage(named: "test")
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
                            print("getImageURL",self.getImageURL)
                        }
                    }else{
                        self.convertedImagesUrlArray = self.imageUrlArray
                        if(self.SendedScreenNameStr .isEqual("MultipleImage")){
                            self.callSendMultipleImageToStandardSection()
                        }else{
                            self.callStaffSendMultipleImage()
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
                    if(self.SendedScreenNameStr .isEqual("MultipleImage")){
                        self.callSendPDFToStandardSection()
                    }else{
                        self.callStaffSendPDF()
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
    
    
}



