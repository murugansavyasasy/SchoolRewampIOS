//
//  UploadViemoVideoVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 26/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ImagePicker
import MobileCoreServices
import AVFoundation

import Alamofire



extension UIImagePickerController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.black
        self.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
    }
}
extension AVURLAsset {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)
        
        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}

extension UIViewController {
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    func createThumbnailImage(videopath: URL) -> UIImage? {
        let asset = AVURLAsset(url: videopath)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timestamp = CMTime(seconds: 0.0, preferredTimescale: 60)
        if let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) {
            print("imageRef",imageRef)
            return UIImage(cgImage: imageRef)
            
        } else {
            return nil
        }
    }
}

class UploadViemoVideoVC: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate,Apidelegate{
    
    @IBOutlet weak var ClickHereButton: UIButton!
    @IBOutlet weak var MyImageView: UIImageView!
    
    @IBOutlet weak var SendImageLabel: UILabel!
    @IBOutlet weak var ClickImageCaptureButton: UIButton!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var ImageView: UIView!
    @IBOutlet weak var StandardSectionButton: UIButton!
    @IBOutlet weak var StandardStudentButton: UIButton!
    @IBOutlet weak var staffView: UIView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var aboutTextField: UITextField!
    
    @IBOutlet weak var StaffGroupButton: UIButton!
    let videoLibraryPicker = UIImagePickerController()
    
    var selectedDictionary = [String: Any]() as NSDictionary
    var SchoolDetailDict = NSDictionary()
    var selectedSchoolID = NSString()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var imageLimit = 1
    var urlPath : URL!
    var strFrom = String()
    var agreeVideoAlertMessge = String()
    var SchoolId = String()
    var StaffId = String()
    var assignmentType = String()
    var strCountryCode = String()
    var strCountryName = String()
    var strSomething = String()
    var vimeoVideoURl = "https://vimeo.com/422366859/5189c75e6c"
    var vimeoVideoSize = ""
    var strSubmissionDate = String()
    var loginAsName = String()
    let todayDate = Calendar.current.startOfDay(for: Date())
    var pdfData : NSData? = nil
    var LanguageDict = NSDictionary()
    var vimeoVideoDict  = NSMutableDictionary()
    var moreImagesArray = NSMutableArray()
    let utilObj = UtilClass()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let dateView = UIView()
    var vimeoUrl : NSURL?
    var getVimeoVideoURL : URL!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.initialSetup()
        print("Video2")
        strCountryName = UserDefaults.standard.object(forKey: COUNTRY_Name) as? String ?? ""
        print(strCountryName)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
    }
    
    func initialSetup(){
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        view.isOpaque = false
        ClickImageCaptureButton.isEnabled = false
        ClickImageCaptureButton.layer.cornerRadius = 5
        ClickImageCaptureButton.layer.masksToBounds = true
        
        SendButton.isEnabled = false
        SendButton.layer.cornerRadius = 5
        SendButton.isEnabled = false
        StandardSectionButton.layer.cornerRadius = 5
        StandardSectionButton.isEnabled = false
        StaffGroupButton.layer.cornerRadius = 5
        StaffGroupButton.isEnabled = false
        StandardStudentButton.layer.cornerRadius = 5
        StandardStudentButton.layer.masksToBounds = true
        videoLibraryPicker.delegate = self
        
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        
        if(loginAsName == "Principal")
        {
            self.staffView.isHidden  = true
            
        }else{
            self.staffView.isHidden  = false
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionCaptureImageButton(_:)))
        if(moreImagesArray.count > 0){
            ClickHereButton.isHidden = true
            ClickImageCaptureButton.isEnabled = true
            SendButton.isEnabled = true
            SendButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
            StandardSectionButton.isEnabled = true
            StandardSectionButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
            StaffGroupButton.isEnabled = true
            StaffGroupButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
            StandardStudentButton.isEnabled = true
            StandardStudentButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
        }else{
            ClickHereButton.isHidden = false
            ClickImageCaptureButton.isEnabled = false
            SendButton.isEnabled = false
            SendButton.backgroundColor = UIColor.lightGray
            
            StandardSectionButton.backgroundColor = UIColor.lightGray
            StandardSectionButton.isEnabled = false
            StaffGroupButton.backgroundColor = UIColor.lightGray
            StaffGroupButton.isEnabled = false
            
            StandardStudentButton.isEnabled = false
            StandardStudentButton.backgroundColor = UIColor.lightGray
            ClickImageCaptureButton.backgroundColor = UIColor.lightGray
        }
        
        ImageView.addGestureRecognizer(tapped)
        self.MyImageView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool){
        self.callSelectedLanguage()
        self.CallVideoAgreementApi()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " " {
            return false
        }
        return true
    }
    
    //MARK: CAPTURE BUTTON ACTION
    @IBAction func actionCaptureImageButton(_ sender: UIButton){
        self.AlerMessage(alrtMessage: agreeVideoAlertMessge)
        
    }
    
    @IBAction func actionCloseView(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func fileSelection(){
        titleTextField.resignFirstResponder()
        aboutTextField.resignFirstResponder()
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            let alertController = UIAlertController(title: LanguageDict["upload_image"] as? String, message: LanguageDict["choose_option"] as? String, preferredStyle: .alert)
            // Initialize Actions
            let yesAction = UIAlertAction(title: LanguageDict["choose_from_gallery"] as? String, style: .default) { (action) -> Void in
                self.FromGallery()
            }
            
            
            let CancelAction = UIAlertAction(title: LanguageDict["teacher_cancel"] as? String, style: .default) { (action) -> Void in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            // Add Actions
            alertController.addAction(yesAction)
            alertController.addAction(CancelAction)
            
            // Present Alert Controller
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title:  LanguageDict["upload_image"] as? String, message: LanguageDict["choose_option"] as? String, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: LanguageDict["choose_from_gallery"] as? String, style: .default , handler:{ (UIAlertAction)in
                self.FromGallery()
            }))
            
            alert.addAction(UIAlertAction(title: LanguageDict["teacher_cancel"] as? String, style: .cancel, handler:{ (UIAlertAction)in
                print("User click Dismiss button")
            }))
            
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
        }
        
    }
    
    func alertClose(gesture: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: CHANGE BUTTON ACTION
    @IBAction func actionChangeImageButton(_ sender: UIButton) {
        fileSelection()
    }
    
    func CloseAlertView(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func actionSendButton(_ sender: Any) {
        aboutTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        vimeoVideoDict = [
            "Title": self.titleTextField.text! ,
            "Description": self.aboutTextField.text!,
        ]
        if(loginAsName == "Principal"){
            
            
            if(appDelegate.LoginSchoolDetailArray.count == 1){
                goToSingleSchool()
                print("1111222232")
            }else{
                goToPrincipalSelection()
                print("1111222234")
            }
        }else{
            vimeoVideoDict["SchoolId"] = SchoolId
            vimeoVideoDict["ProcessBy"] = StaffId
        }
    }
    @IBAction func actionStandardSendButton(_ sender: Any) {
        print("111122223")
        aboutTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        vimeoVideoDict = [
            "Title": self.titleTextField.text! ,
            "Description": self.aboutTextField.text!,
            "SchoolId": SchoolId,
            "ProcessBy": StaffId,
        ]
        
        let StaffVC = self.storyboard?.instantiateViewController(withIdentifier: "StandardOrSectionVCStaff") as! StandardOrSectionVCStaff
        
        StaffVC.SendedScreenNameStr = "VimeoVideoToParents"
        StaffVC.StaffId = StaffId
        StaffVC.SchoolId = SchoolId
        StaffVC.vimeoVideoDict = self.vimeoVideoDict
        StaffVC.VideoData = NSData(contentsOf: vimeoUrl as! URL)
        StaffVC.vimeoVideoURL =  vimeoUrl as! URL 
        print("vimeoUrlvimeoUrl111",StaffVC.vimeoVideoURL)
        print(" StaffVC.VidvimeoUrleoData", vimeoUrl)
        self.present(StaffVC, animated: false, completion: nil)
    }
    
    
    @IBAction func ActionStaffGroup(_ sender: UIButton) {
        
        let vc =  StaffGroupVoiceViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.StaffId = StaffId
        vc.videoDesc = aboutTextField.text!
        vc.SchoolId = SchoolId
        vc.videoTitle = titleTextField.text!
        vc.pdfDataType = "Video"
        vimeoVideoDict = [
            "Title": self.titleTextField.text! ,
            "Description": self.aboutTextField.text!,
            "SchoolId": SchoolId,
            "ProcessBy": StaffId,
        ]
        vc.vimeoVideoURL = vimeoUrl as! URL
        
        vc.vimeoVideoDict = self.vimeoVideoDict
        vc.VideoData = NSData(contentsOf: vimeoUrl as! URL)
        vc.videoProcessBy = StaffId
        vc.SendedScreenNameStr = "VimeoVideoToParents"
        vc.vimeoVideoURL = vimeoUrl as! URL
        vc.selectType = "Video"
        
        
        present(vc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func actionStudentSendButton(_ sender: Any) {
        aboutTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        vimeoVideoDict = [
            "Title": self.titleTextField.text! ,
            "Description": self.aboutTextField.text!,
            "SchoolId": SchoolId,
            "ProcessBy": StaffId,
        ]
        
        let StudentVC = self.storyboard?.instantiateViewController(withIdentifier: "StandardOrStudentsStaff") as! StandardOrStudentsStaff
        StudentVC.vimeoVideoDict = self.vimeoVideoDict
        StudentVC.SenderScreenName = "VimeoVideoToParents"
        StudentVC.VideoData = NSData(contentsOf: vimeoUrl as! URL)
        StudentVC.SchoolId = SchoolId
        print("vimeoUrlvimeoUr1",vimeoUrl)
        StudentVC.vimeoVideoURL =  vimeoUrl as! URL
        print("StudentVC.vimeoVideoURL",StudentVC.vimeoVideoURL)
        print("vimeoUrlvimeoUr111")
        StudentVC.StaffId = StaffId
        self.present(StudentVC, animated: false, completion: nil)
    }
    func goToPrincipalSelection(){
        print(SchoolDetailDict)
        let schoolVC  = self.storyboard?.instantiateViewController(withIdentifier: "AssignmentSchoolSelectionVC") as! AssignmentSchoolSelectionVC
        schoolVC.ViewFrom = "VimeoVideo"
        schoolVC.VoiceData = NSData(contentsOf: vimeoUrl as! URL)
        schoolVC.vimeoVideoDict =  self.vimeoVideoDict
        schoolVC.vimeoURL =  vimeoUrl as! URL
        
        schoolVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(schoolVC, animated: true, completion: nil)
    }
    func goToSingleSchool(){
        
        SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
        
        vimeoVideoDict["SchoolId"] =  String(describing: SchoolDetailDict["SchoolID"]!) as NSString
        vimeoVideoDict["ProcessBy"] = String(describing: SchoolDetailDict["StaffID"]!) as NSString
        print(SchoolDetailDict)
        let schoolVC  = self.storyboard?.instantiateViewController(withIdentifier: "PrincipalGroupSelectionVC") as! PrincipalGroupSelectionVC
        schoolVC.fromViewController = "VimeoVideoToParents"
        schoolVC.fromView = "VimeoVideoToParents"
        schoolVC.vimeoVideoDict = self.vimeoVideoDict
        schoolVC.VideoData = NSData(contentsOf: vimeoUrl as! URL)
        schoolVC.vimeoVideoURL =  vimeoUrl as! URL
        print("vimeoUrlvimeoUr1",vimeoUrl)
        
        print("StudentVC.vimeoVideoURL",schoolVC.vimeoVideoURL)
        print("vimeoUrlvimeoUr222")
        schoolVC.SchoolID = String(describing: SchoolDetailDict["SchoolID"]!) as NSString
        schoolVC.StaffID = String(describing: SchoolDetailDict["StaffID"]!) as NSString
        schoolVC.selectedSchoolDictionary = NSMutableDictionary(dictionary: SchoolDetailDict)
        schoolVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(schoolVC, animated: true, completion: nil)
        
        
        
    }
    
    func goToSectionSelection(){
        print(SchoolDetailDict)
        let schoolVC  = self.storyboard?.instantiateViewController(withIdentifier: "PrincipalGroupSelectionVC") as! PrincipalGroupSelectionVC
        schoolVC.fromViewController = "VimeoVideoToParents"
        schoolVC.fromView = "VimeoVideoToParents"
        schoolVC.SchoolID = SchoolId as NSString
        schoolVC.StaffID = StaffId as NSString
        schoolVC.VideoData = NSData(contentsOf: vimeoUrl as! URL)
        schoolVC.vimeoVideoDict =  self.vimeoVideoDict
        schoolVC.vimeoVideoURL =  vimeoUrl as! URL
        print("StudentVC.vimeoVideoURL",schoolVC.vimeoVideoURL)
        print("vimeoUrlvimeoUr1",vimeoUrl)
        print("vimeoUrlvimeoUr333")
        schoolVC.selectedSchoolDictionary = NSMutableDictionary(dictionary: SchoolDetailDict)
        schoolVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(schoolVC, animated: true, completion: nil)
    }
    
    
    
    // MARK: - ImagePickerDelegate
    
    func FromGallery(){
        
        self.videoLibraryPicker.allowsEditing = false
        self.videoLibraryPicker.delegate = self
        self.videoLibraryPicker.sourceType = .photoLibrary
        self.videoLibraryPicker.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
        self.videoLibraryPicker.modalPresentationStyle = .fullScreen
        
        present(self.videoLibraryPicker, animated: true, completion: nil)
        
        self.videoLibraryPicker.popoverPresentationController?.sourceView = self.view
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let userDefault = UserDefaults.standard
        // To handle video
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL{
            
            let data = try! Data.init(contentsOf: videoUrl as URL)
            let vimeoVideoSize = Float(Double(data.count)/1024/1024)
            print("appDelegatevideoSize",appDelegate.videoSize)
            if(vimeoVideoSize < (appDelegate.videoSize as NSString).floatValue){
                vimeoUrl = videoUrl
                
                self.MyImageView.image = self.createThumbnailImage(videopath: videoUrl as URL)
                print("videoUrl11",videoUrl)
                
                
                if let videoURL = URL(string: videoUrl.absoluteString!) {
                    if let fileSizeString = getVideoFileSizeInMB(url: videoURL) {
                        print("File size: \(fileSizeString)")
                        
                        DefaultsKeys.videoFilesize = fileSizeString
                    }
                }
            }else{
                
                self.videoLibraryPicker.dismiss(animated: true, completion: nil)
                
                let strAlrtTitle = "Video Size " + String(describing: vimeoVideoSize) + " MB"
                Util .showAlert(strAlrtTitle, msg: appDelegate.videoSizeAlert)
                //alert
            }
            if(self.MyImageView.image != nil){
                self.videoLibraryPicker.dismiss(animated: true, completion: nil)
                ClickHereButton.isHidden = true
                ClickImageCaptureButton.isEnabled = true
                ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
                SendButton.isEnabled = true
                SendButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
                StandardStudentButton.isEnabled = true
                StandardStudentButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
                StandardSectionButton.isEnabled = true
                StandardSectionButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
                StaffGroupButton.isEnabled = true
                StaffGroupButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
                
            }else{
                print("Something went wrong in video")
            }
            
            
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
                    print("parsedData",parsedData)
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }
            } catch {
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        LanguageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            titleTextField.textAlignment = .right
            aboutTextField.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            titleTextField.textAlignment = .left
            aboutTextField.textAlignment = .left
        }
        if (strCountryName.uppercased() == SELECT_COUNTRY){
            StandardSectionButton.setTitle(LangDict["teacher_staff_to_sections_usa"] as? String, for: .normal)
            StandardStudentButton.setTitle(LangDict["teacher_staff_to_students"] as? String, for: .normal)
        }
        else{
            StandardSectionButton.setTitle(LangDict["teacher_staff_to_sections"] as? String, for: .normal)
            StandardStudentButton.setTitle(LangDict["teacher_staff_to_students"] as? String, for: .normal)
        }
        ClickHereButton.setTitle(LangDict["choose_gallery_video"] as? String, for: .normal)
        ClickImageCaptureButton.setTitle(LangDict["change_video"] as? String, for: .normal)
        SendImageLabel.text = LangDict["compose_video"] as? String
        titleTextField.placeholder = LangDict["title"] as? String
        aboutTextField.placeholder = LangDict["about_video"] as? String
        
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        SendButton.setTitle(LangDict["teacher_choose_recipient"] as? String, for: .normal)
        
    }
    
    func CallVideoAgreementApi() {
        showLoading()
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + VIDEO_AGREEMENT_POST
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + VIDEO_AGREEMENT_POST
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = [:]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        print("REPORTTT",requestString)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailAssignmentMessage")
    }
    
    func CallVideoDetailApi1() {
        showLoading()
        
        //
        let vimeoAccessToken = appDelegate.VimeoToken
        
        createVimeoUploadURL(authToken: vimeoAccessToken, videoFilePath: getVimeoVideoURL) { [self] result in
            switch result {
            case .success(let uploadLink):
                uploadVideoToVimeo(uploadLink: uploadLink, videoFilePath: getVimeoVideoURL, authToken: vimeoAccessToken) { [self] result in
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
                "size": "\(fileSize)" // Use the actual video file size
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
            "name": TitleGet, // Replace with actual video name
            "description": TitleDescriotion // Replace with actual video description
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
                        let embed = json["embed"]! as AnyObject
                        IFrameLink = embed["html"]! as! String
                        
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
    
    
    
    
    
    //NSURLVimeoFunction
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        if(csData != nil){
            if(csData!.count > 0){
                for i in 0..<csData!.count{
                    let dict : NSDictionary = csData?[i] as! NSDictionary
                    if(String(describing: dict["result"]!) == "1"){
                        
                        let agreeVideoAlertMessge1 = "\(i+1).\(String(describing: dict["Content"]!)) \n"
                        agreeVideoAlertMessge = agreeVideoAlertMessge + agreeVideoAlertMessge1
                    }
                    
                }
            }
            
        }
    }
    
    
    
    @objc func failedresponse(_ pagename: Error!) {
        print(pagename.localizedDescription)
        hideLoading()
        
        Util .showAlert("", msg: pagename.localizedDescription);
        
    }
    
    
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        
        hud.hide(true)
    }
    
    func AlerMessage(alrtMessage : String)
    {
        
        let alertController = UIAlertController(title: "", message: alrtMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Agree", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.fileSelection()
            
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getVideoFileSizeInMB(url: URL) -> String? {
        do {
            // Get file attributes
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            
            // Get the file size in bytes
            if let fileSize = attributes[.size] as? Int64 {
                // Convert bytes to MB
                let fileSizeInMB = Double(fileSize) / 1_048_576
                // Convert the file size to a string with two decimal places
                let fileSizeString = String(format: "%.2f MB", fileSizeInMB)
                return fileSizeString
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        
        return nil
    }
}
