
import UIKit
import ImagePicker
import MobileCoreServices

extension StudentSubmitAssignmentVC: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        urlPath = url
        self.setPDFFile()
    }
}

class StudentSubmitAssignmentVC: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ImagePickerDelegate,Apidelegate {
    
    @IBOutlet weak var ClickHereButton: UIButton!
    @IBOutlet weak var MyImageView: UIImageView!
    @IBOutlet weak var SendImageLabel: UILabel!
    @IBOutlet weak var ClickImageCaptureButton: UIButton!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var ImageView: UIView!
    @IBOutlet var descriptionTextField: UITextField!
    
    let picker = UIImagePickerController()
    var selectedDictionary = [String: Any]() as NSDictionary
    var selectedSchoolID = NSString()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var MyImageView2: UIImageView!
    @IBOutlet weak var MyImageView3: UIImageView!
    @IBOutlet weak var MyImageView4: UIImageView!
    @IBOutlet weak var MyPDFImage: UIImageView!
    @IBOutlet weak var MoreImagesButton: UIButton!
    
    var moreImagesArray = NSMutableArray()
    var convertedImagesUrlArray = NSMutableArray()
    var imageLimit = 2
    var urlPath : URL!
    var strFrom = String()
    var SchoolId = String()
    var ChildId = String()
    var strCountryCode = String()
    var strSomething = String()
    let todayDate = Calendar.current.startOfDay(for: Date())
    var pdfData : NSData? = nil
    var LanguageDict = NSDictionary()
    let utilObj = UtilClass()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var apicalled = "0"
    
    var currentImageCount = 0
    var totalImageCount = 0
    var imageUrlArray = NSMutableArray()
    var originalImagesArray = [UIImage]()
    var bIsArchive = Bool()
    
    var imagePicker = UIImagePickerController()
    var countryCoded : String!
    override func viewDidLoad(){
        super.viewDidLoad()
        
        countryCoded =  UserDefaults.standard.object(forKey: COUNTRY_ID) as! String

        imagePicker.delegate = self
        print("StudentAss")
        self.initialSetup()
    }
    
    func initialSetup(){
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        view.isOpaque = false
        ClickImageCaptureButton.isEnabled = false
        ClickImageCaptureButton.layer.cornerRadius = 5
        ClickImageCaptureButton.layer.masksToBounds = true
        
        SendButton.isEnabled = false
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        picker.delegate = self
        
        self.MoreImagesButton.isHidden = true
        self.MyImageView.isHidden = false
        
        self.MyPDFImage.isHidden = true
        bIsArchive = selectedDictionary["is_Archive"] as? Bool ?? false
        
        NotificationCenter.default.addObserver(self,selector: #selector(StudentSubmitAssignmentVC.receiveNotification(notification:)), name: NSNotification.Name(rawValue: "SendImagePDFAssignmentNotification"), object:nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        self.callSelectedLanguage()
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionCaptureImageButton(_:)))
        
        if(moreImagesArray.count > 0){
            ClickHereButton.isHidden = true
            ClickImageCaptureButton.isEnabled = true
            SendButton.isEnabled = true
            SendButton.backgroundColor = utilObj.GREEN_COLOR
            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
        }else{
            MoreImagesButton.isHidden = true
            ClickHereButton.isHidden = false
            ClickImageCaptureButton.isEnabled = false
            SendButton.isEnabled = false
            SendButton.backgroundColor = UIColor.lightGray
            ClickImageCaptureButton.backgroundColor = UIColor.lightGray
        }
        
        ImageView.addGestureRecognizer(tapped)
        
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
        
        descriptionTextField.resignFirstResponder()
        
        
        
        
        self.ClickHereButton.setTitleColor(UIColor.white, for: .normal)
        self.ClickHereButton.isUserInteractionEnabled = true
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction(title: "Pdf", style: .default, handler: { _ in
            self.FromPDF()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func alertClose(gesture: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: CHANGE BUTTON ACTION
    @IBAction func actionChangeImageButton(_ sender: UIButton) {
        print("Change Button")
        descriptionTextField.resignFirstResponder()
        
        
        self.ClickHereButton.setTitleColor(UIColor.white, for: .normal)
        self.ClickHereButton.isUserInteractionEnabled = true
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction(title: "Pdf", style: .default, handler: { _ in
            self.FromPDF()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    func openGallary()
    {
        strFrom = "Image"
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func CloseAlertView(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera",preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC,animated: true,completion: nil)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int){
        switch (buttonIndex){
        case 0:
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
                dismiss(animated: true, completion: nil)
            }
        case 1:
            shootFromLibrary(sender: integer_t(buttonIndex))
        case 2:
            shootFromPhoto(sender: integer_t(buttonIndex))
        case 3:
            self.FromPDF()
        default: break
        }
    }
    
    func FromLibrary(){
        strFrom = "IMAGE"
        self.ImagePickerGallery()
    }
    
    func FromPhoto(){
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
        }
        else {
            noCamera()
        }
    }
    func FromPDF(){
        strFrom = "PDF"
        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func shootFromLibrary(sender: integer_t){
        strFrom = "IMAGE"
        self.ImagePickerGallery()
    }
    
    func shootFromPhoto(sender: integer_t){
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
        }
        else {
            noCamera()
        }
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ClickImageCaptureButton.isEnabled = true
        ClickImageCaptureButton.isEnabled = true
        
        SendButton.isEnabled = true
        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        ClickImageCaptureButton.isEnabled = true
        SendButton.isEnabled = true
        MyImageView.contentMode = .scaleToFill
        MyImageView.image = chosenImage
        print("MyImageView.image", MyImageView.image)
        self.moreImagesArray.add(chosenImage)
        if(self.MyImageView.image != nil){
            dismiss(animated: true, completion: nil)
            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            SendButton.backgroundColor = utilObj.GREEN_COLOR
            
        }
    }
    
    //MARK: NEXT BUTTON ACTION
    @IBAction func actionNextButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SendImageMessageSegue", sender: self)
        }
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionMoreImages(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "moreImagesSegue", sender: self)
        }
    }
    
    
    
    func ImagePickerGallery() {
        var config = ImagePickerConfiguration()
        config.doneButtonTitle = "Finish"
        config.noImagesTitle = "Sorry! There are no images here!"
        config.recordLocation = false
        config.allowVideoSelection = false
        
        let imagePicker = ImagePickerController(configuration: config)
        imagePicker.delegate = self
        imagePicker.imageLimit = imageLimit
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func actionSendButton(_ sender: Any) {
        showSendAlert()
    }
    
    func showSendAlert(){
        var alertMessage = String()
        
        let policyEndDateStr = selectedDictionary["EndDate"] as? String ?? ""
        let policyDate = policyEndDateStr.toDate(withFormat: "dd-MM-yyyy") ?? Date()
        let noOfDays = Date().interval(ofComponent: .day, fromDate: policyDate)
        print("policyDate \(policyDate) TODAY \(Date())")
        
        print("DUE \(noOfDays)")
        if( noOfDays > 0){
            alertMessage = (LanguageDict["expires_submission_date"] as? String)!
        }else{
            alertMessage = (LanguageDict["submission_alert"] as? String)!
        }
        
        let alertController = UIAlertController(title: LanguageDict["alert"] as? String, message: alertMessage, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: LanguageDict["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.showLoading()
            
            self.currentImageCount = 0
            self.totalImageCount = 0
            self.imageUrlArray = NSMutableArray()
            self.originalImagesArray = [UIImage]()
            
            if(self.strFrom == "PDF"){
                self.uploadPDFFileToAWS(pdfData: self.pdfData!)
            }else{
                self.getImageURL(images:  self.moreImagesArray as! [UIImage])
            }
            
        }
        let cancelAction = UIAlertAction(title: LanguageDict["teacher_cancel"] as? String, style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - ImagePickerDelegate
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        for image in images{
            self.moreImagesArray.add(image)
        }
        if(moreImagesArray.count > 0){
            ClickHereButton.isHidden = true
            ClickImageCaptureButton.isEnabled = true
            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            SendButton.isEnabled = true
            SendButton.backgroundColor = utilObj.GREEN_COLOR
        }else{
            MoreImagesButton.isHidden = true
            ClickHereButton.isHidden = false
            ClickImageCaptureButton.isEnabled = false
            ClickImageCaptureButton.backgroundColor = UIColor.lightGray
            SendButton.isEnabled = false
            SendButton.backgroundColor = UIColor.lightGray
        }
        self.SetImagesFromPicker(imageCount: (images.count as NSNumber))
        self.SetImagesIntoPath(images: images)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func SetImagesIntoPath(images : [UIImage]){
        if(images.count == 1){
            self.MyImageView.image = images[0]
            pdfData = (self.MyImageView.image!.pngData() as NSData?)!
        }else if(images.count == 2){
            self.MyImageView.image = images[0]
            self.MyImageView2.image = images[1]
        }else if(images.count == 3){
            self.MyImageView.image = images[0]
            self.MyImageView2.image = images[1]
            self.MyImageView3.image = images[2]
        }else if(images.count >= 4){
            self.MyImageView.image = images[0]
            self.MyImageView2.image = images[1]
            self.MyImageView3.image = images[2]
            self.MyImageView4.image = images[3]
        }
    }
    
    func SetImagesFromPicker(imageCount : NSNumber){
        self.MyPDFImage.isHidden = true
        if(imageCount.intValue >= 4){
            self.MyImageView.isHidden = false
            self.MyImageView2.isHidden = false
            self.MyImageView3.isHidden = false
            self.MyImageView4.isHidden = false
            if(imageCount.intValue > 4){
                self.MoreImagesButton.isHidden = false
                let moreImagesCount = imageCount.intValue - 3
                self.MoreImagesButton.setTitle("+\(moreImagesCount)", for: .normal)
            }else{
                self.MoreImagesButton.isHidden = true
            }
        }else if(imageCount.intValue == 3){
            self.MyImageView.isHidden = false
            self.MyImageView2.isHidden = false
            self.MyImageView3.isHidden = false
            self.MyImageView4.isHidden = true
        }else if(imageCount.intValue == 2){
            self.MyImageView.isHidden = false
            self.MyImageView2.isHidden = false
            self.MyImageView3.isHidden = true
            self.MyImageView4.isHidden = true
        }else if(imageCount.intValue == 1){
            self.MyImageView.isHidden = false
            self.MyImageView2.isHidden = true
            self.MyImageView3.isHidden = true
            self.MyImageView4.isHidden = true
        }else{
            self.MyImageView.isHidden = true
            self.MyImageView2.isHidden = true
            self.MyImageView3.isHidden = true
            self.MyImageView4.isHidden = true
        }
    }
    
    func setPDFFile(){
        do {
            pdfData = try NSData(contentsOf: urlPath!, options: NSData.ReadingOptions())
        } catch {
            print("set PDF filer error : ", error)
        }
        
        if(pdfData != nil){
            self.MyPDFImage.image = UIImage(named: "pdfImage")
            self.MyPDFImage.isHidden = false
            self.MyImageView.isHidden = true
            
            
            ClickHereButton.isHidden = true
            ClickImageCaptureButton.isEnabled = true
            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            SendButton.isEnabled = true
            SendButton.backgroundColor = utilObj.GREEN_COLOR
            
        }else{
            
            ClickHereButton.isHidden = false
            ClickImageCaptureButton.isEnabled = false
            ClickImageCaptureButton.backgroundColor = UIColor.lightGray
            SendButton.isEnabled = false
            SendButton.backgroundColor = UIColor.lightGray
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
        LanguageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            descriptionTextField.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            descriptionTextField.textAlignment = .left
        }
        
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        SendButton.setTitle(LangDict["pop_response_btn_send"] as? String, for: .normal)
        
    }
    
    func submitImagePDFFile(){
        DispatchQueue.main.async {
            print(self.convertedImagesUrlArray)
            self.apicalled = "1"
            let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
            var requestStringer = baseUrlString! + POST_SUBMIT_STUDENT_ASSIGNMENT_NEW
            
            
            if(self.appDelegate.isPasswordBind == "1" && self.bIsArchive){
                requestStringer = baseUrlString! + POST_SUBMIT_STUDENT_ASSIGNMENT_NEW_SEEMORE
            }
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["SchoolID" : self.SchoolId,"AssignmentId" : String(describing: self.selectedDictionary["AssignmentId"]!),"ProcessBy" : self.ChildId,"description" : self.descriptionTextField.text!,"FileType" : self.strFrom.uppercased(), COUNTRY_CODE: self.strCountryCode,"FileNameArray" : self.convertedImagesUrlArray]
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: myDict)
            print("studentassMystring\(myString)")
            apiCall.nsurlConnectionFunction(requestString, myString, "SendImage")
            
        }
    }
    
    
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "csData", printingValue: csData!)
            
            if let CheckedArray = csData as? NSArray{
                var dicResponse : NSDictionary  = NSDictionary()
                
                for var i in 0..<CheckedArray.count
                {
                    dicResponse = CheckedArray[i] as! NSDictionary
                }
                
                let myalertstring = dicResponse["Message"] as! String
                if let mystatus = dicResponse["Status"] as? String {
                    if(mystatus == "1"){
                        Util.showAlert("", msg: myalertstring)
                        
                        let nc = NotificationCenter.default
                        nc.post(name: NSNotification.Name(rawValue: "NotificationFromSubmitAssigment"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                    else{
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                }
            }
            else{
                Util.showAlert("", msg: strSomething)
            }
            
        }
        else{
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
    
    //MARK: - Notification Receiver
    @objc func receiveNotification(notification:Notification) -> Void{
        if(notification.name.rawValue == "SendImagePDFAssignmentNotification"){
            self.convertedImagesUrlArray = notification.object as! NSMutableArray
            print("self.convertedImagesUrlArray : ", self.convertedImagesUrlArray)
            self.submitImagePDFFile()
        }
    }
    
    //MARK: AWS Upload
    func getImageURL(images : [UIImage]){
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
        
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".png")
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let  currentDate =   dateFormatter.string(from: Date())
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
        
       
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
//
        uploadRequest?.key = "communication" + "/" + currentDate +  "/" + ext
        uploadRequest?.bucket = bucketName
        uploadRequest?.contentType = "image/" + ext
        uploadRequest?.acl = .publicRead
   
        
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
            
            if let error = task.error {
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
                        self.submitImagePDFFile()
                    }
                }
            }
            else {
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    func uploadPDFFileToAWS(pdfData : NSData){
        var bucketName = ""
        if countryCoded == "1" {
                  
                   bucketName = DefaultsKeys.bucketNameIndia
               }else  {
                    bucketName = DefaultsKeys.bucketNameBangkok
               }
     
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
        uploadRequest?.bucket = bucketName
        
        uploadRequest?.contentType = "application/pdf"
        uploadRequest?.acl = .publicRead
        
        print("studNewTest")
        
        
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
            
            if let error = task.error {
                print("Upload failed : (\(error))")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                print("url",url)
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                print("publicURL",publicURL)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    let imageDict = NSMutableDictionary()
                    imageDict["FileName"] = absoluteString
                    self.imageUrlArray.add(imageDict)
                    self.convertedImagesUrlArray = self.imageUrlArray
                    self.submitImagePDFFile()
                }
            }
            else {
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    
}

// MARK: - Date Utility Methods
extension Date {
    
    func toString(withFormat format: String? = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezoneOffset = TimeZone.current.secondsFromGMT()
        let epochDate = self.timeIntervalSince1970
        let timezoneEpochOffset = (epochDate - Double(timezoneOffset))
        return Date(timeIntervalSince1970: timezoneEpochOffset)
    }
    
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        return end - start
    }
    
    //for B2B
    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }
    
    func isGraterThan(_ date: Date) -> Bool {
        return self > date
    }
    
    func serverTimestamp() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
    
}

extension String {
    
    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)?.toLocalTime()
        return date
    }
}
