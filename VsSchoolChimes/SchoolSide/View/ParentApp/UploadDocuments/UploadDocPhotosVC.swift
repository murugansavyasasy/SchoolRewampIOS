//
//  HomeViewController.swift
//
//

import Foundation
import UIKit
import ImagePicker
import MobileCoreServices
extension UploadDocPhotosVC: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        urlPath = url
        self.setPDFFile()
    }
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        urlPath = url
        self.setPDFFile()
        
    }
    
}
class UploadDocPhotosVC: UIViewController, UIActionSheetDelegate,
                         UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                         UITextFieldDelegate, ImagePickerDelegate,Apidelegate,UITableViewDataSource,UITableViewDelegate {
    
    var imageLimit = 1
    var urlPath : URL!
    var pdfData : NSData? = nil
    var strApiFrom = NSString()
    var hud : MBProgressHUD = MBProgressHUD()
    let utilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strSomething = String()
    @IBOutlet weak var browseView: UIView!
    @IBOutlet weak var browseLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var filenameTF: UITextField!
    
    @IBOutlet weak var uploadTableView: UITableView!
    
    
    var profileImgeUrl = String()
    
    var LanguageDict = NSDictionary()
    let picker = UIImagePickerController()
    
    var arrBrowseFile = NSMutableArray()
    
    var arrAWSBrowseFile = NSMutableArray()
    
    var arrSectionBrowseFile = NSMutableArray()
    
    
    var selectDict = NSMutableDictionary()
    var selectIndex = Int()
    
    var bIsTitle = Bool()
    var bIsuploadTitle = Bool()
    
    var browseFileType = 0
    var instuteId : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let strProfile = "\(appDelegate.strUploadPhotoTitle)"
        
        self.title = strProfile
        
        filenameTF.delegate = self
        
        bIsTitle = false
        bIsuploadTitle = false
        
        browseView.layer.cornerRadius = 8
        picker.delegate = self
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
        //        submitButton.backgroundColor = .clear
        //        submitButton.layer.cornerRadius = 5
        //        submitButton.layer.borderWidth = 1
        //        submitButton.layer.borderColor = UIColor.lightGray.cgColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(callUploadView))
        browseView.isUserInteractionEnabled = true
        browseView.addGestureRecognizer(tap)
        
        callSelectedLanguage()
        strSomething = LanguageDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
    }
    
    @objc func callUploadView(){
        let alert = UIAlertController(title: "Upload your profile here", message: "", preferredStyle: .actionSheet)


      
            for i in ["Gallery","Files"] {

                alert.addAction(UIAlertAction(title: i, style: .default, handler: choose_image_handler))

            }






        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)


    }
    func choose_image_handler(action: UIAlertAction){


        let alert = UIAlertController(title: "Select Attachment", message: "", preferredStyle: .actionSheet)

        print(action.title!)

        if ((action.title!.elementsEqual("Gallery"))){

            print("camera")


            browseFileType = 1


            print("gallery")
//
            FromLibrary()


        }else if ((action.title!.elementsEqual("Files"))){



            FromPDF()

        }




    }

    func fileSelection(){
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            let alertController = UIAlertController(title: LanguageDict["upload_image"] as? String, message: LanguageDict["choose_option"] as? String, preferredStyle: .alert)
            // Initialize Actions
            let yesAction = UIAlertAction(title: LanguageDict["choose_from_gallery"] as? String, style: .default) { (action) -> Void in
                self.FromLibrary()
            }
            
            let cameraAction = UIAlertAction(title:  LanguageDict["compose_camera"] as? String, style: .default) {
                (action) -> Void in
                self.FromLibrary()
                
            }
            let CancelAction = UIAlertAction(title: LanguageDict["teacher_cancel"] as? String, style: .default) { (action) -> Void in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            // Add Actions
            alertController.addAction(yesAction)
            alertController.addAction(cameraAction)
            alertController.addAction(CancelAction)
            
            // Present Alert Controller
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            
            let alert = UIAlertController(title:  LanguageDict["upload_image"] as? String, message: LanguageDict["choose_option"] as? String, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: LanguageDict["choose_from_gallery"] as? String, style: .default , handler:{ (UIAlertAction)in
                self.FromLibrary()
            }))
            
            alert.addAction(UIAlertAction(title:  LanguageDict["compose_camera"] as? String, style: .default , handler:{ (UIAlertAction)in
                self.FromPhoto()
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
    
    @IBAction func actionSubmitButton(_ sender: UIButton) {
        
        callAPIsubmitFiles()
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
            //  shootFromPhoto(sender: integer_t(buttonIndex))
        default: break
        }
    }
    
    func FromLibrary(){
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
        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func shootFromLibrary(sender: integer_t){
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
        let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        
        if browseFileType == 1 {

//                urlPath = chosenImage
//                self.setPDFFile()

        }else{
            profileImageView.image = chosenImage
            profileImageView.layer.borderWidth = 1
            profileImageView.layer.masksToBounds = false
            profileImageView.layer.borderColor = UIColor.black.cgColor
            profileImageView.layer.cornerRadius = profileImageView.frame.height/2
            profileImageView.clipsToBounds = true
        }

        self.uploadAWS(image: chosenImage)
        
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func openGallery(sender: AnyObject) {
        
        selectImage()
    }
    
    func selectImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    func selectCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    
    
    
    
    func ImagePickerGallery() {
        var config = ImagePickerConfiguration()
        config.doneButtonTitle = "Finish"
        config.noImagesTitle = "Sorry! There are no images here!"
        config.recordLocation = false
        config.allowVideoSelection = false
        
        let imagePicker = ImagePickerController(configuration: config)
        imagePicker.delegate = self
        imagePicker.imageLimit = 1
        present(imagePicker, animated: true, completion: nil)
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
    }
    // MARK: - ImagePickerDelegate
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        let img = images[0] as? UIImage
        if browseFileType == 1 {



        }else{
            profileImageView.image = img
            profileImageView.layer.borderWidth = 1
            profileImageView.layer.masksToBounds = false
            profileImageView.layer.borderColor = UIColor.black.cgColor
            profileImageView.layer.cornerRadius = profileImageView.frame.height/2
            profileImageView.clipsToBounds = true
        }

        self.uploadAWS(image: img!)
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func setPDFFile(){
        do {
            
            let urlString: String = urlPath.absoluteString
            self.addBrowseFile(strPath: urlString)
            print("urlStringurlString",urlString)
            print("addBrowseFile11",addBrowseFile)
            self.uploadTableView.reloadData()

        } catch {
            print("set PDF filer error : ", error)
        }
        
        
    }
    func uploadAWS(image : UIImage){
        showLoading()
//        let S3BucketName = "school-master-documents"
        
        
        var  bucket = ""
        if browseFileType == 1 {
            
            bucket = DefaultsKeys.uploadprofileBrowes
            
        }else{
            
            bucket = DefaultsKeys.UploadProfileBucket
        }
        
        let S3BucketName = bucket
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // url for image in the bundle
        
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".png")
        
        // signatureImageName = imageName as String
        
        let ext = imageName as String
        //  let imageURL = Bundle.main.url(forResource: "lock_icon", withExtension: ext)!
        
        let fileName = imageNameWithoutExtension
        let fileType = ".png"
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        //            let image = UIImage(named: "test")
        let data = image.jpegData(compressionQuality: 0.9)
        do {
            try data?.write(to: imageURL)
        }
        catch {}
        
        print("IMG",imageURL)

        if browseFileType == 1 {

            urlPath = imageURL
            self.setPDFFile()
            DispatchQueue.main.async {
                self.hideLoading()
            }
        }else{



            
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.body = imageURL
            
            if  browseFileType == 1{
              
                uploadRequest?.key = "student-documents" + "/" + instuteId + "/" + ext
            }else{
                uploadRequest?.key = "student_photos" + "/" + instuteId + "/" + ext
            }
//            uploadRequest?.key =  ext
            uploadRequest?.bucket = S3BucketName
            uploadRequest?.contentType = ".jpg"
            uploadRequest?.acl = .publicRead

            // upload

            let transferManager = AWSS3TransferManager.default()
            transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in

                if let error = task.error {
                    print("Upload failed : (\(error))")
                }

                if task.result != nil {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                    if let absoluteString = publicURL?.absoluteString {
                        print("Uploaded to:\(absoluteString)")



                        self.profileImgeUrl = absoluteString



                    }
                    DispatchQueue.main.async {
                        self.hideLoading()
                    }
                }
                else {
                    print("Unexpected empty result.")
                }
                return nil
            }
        }
    }
    
    func addBrowseFile(strPath : String){
        
        bIsTitle = false
        bIsuploadTitle = false
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "School_Upload_Doc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".pdf")
        
        let myDict:NSMutableDictionary = [
            "documentPath" :strPath,
            "documentName" : imageName,
            "documentDisplayName" : self.filenameTF.text ?? "",
        ]
        self.arrBrowseFile.add(myDict)
        self.uploadTableView.reloadData()
        //  callSplitSections()
    }
    
    
  
    
    func uploadPDFFileToAWS(pdfData : NSData){
        showLoading()
        var  bucket = ""
        if browseFileType == 1 {
            
            bucket = DefaultsKeys.uploadprofileBrowes
            
        }else{
            
            bucket = DefaultsKeys.UploadProfileBucket
        }
        let S3BucketName = bucket
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // url for image in the bundle
        
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "School_Upload_Doc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".pdf")
        
        // signatureImageName = imageName as String
        
        let ext = imageName as String
        //  let imageURL = Bundle.main.url(forResource: "lock_icon", withExtension: ext)!
        
        let fileName = imageNameWithoutExtension
        let fileType = ".pdf"
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        
        do {
            try pdfData.write(to: imageURL)
        }
        catch {}
        
        print(imageURL)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key = "student-documents" + "/" + instuteId + "/" + ext
//        uploadRequest?.key =  ext
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.contentType =  ext
        uploadRequest?.acl = .publicRead
        
        // upload
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in
            
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
                    

                        self.selectDict["documentPath"] = absoluteString
                        self.selectDict["documentName"] = fileName



                        arrBrowseFile.removeObject(at: selectIndex)
                        self.arrSectionBrowseFile.add(selectDict)

                    // self.arrBrowseFile[selectIndex] = selectDict
                    DispatchQueue.main.async {
                        //  self.callSplitSections()
                        self.hideLoading()
                        self.uploadTableView.reloadData()
                    }
                }
            }
            else {
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    func callAPIsubmitFiles(){
        showLoading()
        DispatchQueue.main.async {
            
            let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
            var requestStringer = baseUrlString! + POST_UPLOAD_DOC_PHOTO
            
            let childId = String(describing: self.appDelegate.SchoolDetailDictionary["ChildID"]!)
            let SchoolId = String(describing: self.appDelegate.SchoolDetailDictionary["SchoolID"]!)
            
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = [
                "schoolId" : SchoolId,
                "studentid" : childId,
                "StudentImage" : self.profileImgeUrl,
                "StudentDocumentUpload" : self.arrSectionBrowseFile
            ]
            
            let apiCall = API_call.init()
            apiCall.delegate = self
            let myString = Util.convertDictionary(toString: myDict)
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
                        
                        self.filenameTF.text = ""
                        self.arrBrowseFile = []
                        self.arrAWSBrowseFile = []
                        self.arrSectionBrowseFile = []
                        self.uploadTableView.reloadData()
                        //
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
        // popupLoading.dismiss(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0){
            return self.arrBrowseFile.count
        }else if(section == 1){
            return arrSectionBrowseFile.count
        }else{
            return  1
        }
        //return arrSectionBrowseFile.count  + self.arrAWSBrowseFile.count + 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0 // you can have your own choice, of course
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        print("arrBrowseFile",arrBrowseFile)
        print("arrSectionBrowseFile",arrSectionBrowseFile)
        if(indexPath.section == 0){
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UploadTVCell", for: indexPath) as? UploadTVCell
            {
                let iIndex = indexPath.row
                if let dicStores = arrBrowseFile.object(at: iIndex) as? NSDictionary {
                    
                    // cell.titleLbl.text = dicStores.object(forKey: "name") as? String
                    let strP = dicStores.object(forKey: "documentPath") as? String ?? ""
                    cell.pathLbl.text = strP
                    if(strP.contains("amazonaws.com")){
                        cell.uploadBtn.setTitle("Delete", for: .normal)
                        
                        if(!bIsuploadTitle){
                            bIsuploadTitle = true
                            cell.titleLbl.text = "Uploaded Documents : (Only these documents will be sent for approval )"
                        }else{
                            cell.titleLbl.text = ""
                        }
                        
                    }else{
                        cell.uploadBtn.setTitle("Upload", for: .normal)
                        
                        if(!bIsTitle){
                            bIsTitle = true
                            cell.titleLbl.text = "( Click upload for each document to upload )"
                            
                        }else{
                            cell.titleLbl.text = ""
                        }
                        
                        
                    }
                    
                    
                    cell.contentView.backgroundColor = .clear
                    cell.selectionStyle = .none
                    
                    cell.uploadBtn.tag = indexPath.row
                    cell.uploadBtn.addTarget(self, action: #selector(callUploadAction), for: .touchUpInside)
                }
                
                
                return cell
            }
        }else if(indexPath.section == 1){
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteTVCell", for: indexPath) as? DeleteTVCell
            {
                let iIndex = indexPath.row
                if let dicStores = arrSectionBrowseFile.object(at: iIndex) as? NSDictionary {
                    
                    // cell.titleLbl.text = dicStores.object(forKey: "name") as? String
                    let strP = dicStores.object(forKey: "documentPath") as? String ?? ""
                    cell.pathLbl.text = strP
                    if(strP.contains("amazonaws.com")){
                        cell.uploadBtn.setTitle("Delete", for: .normal)
                        
                        if(!bIsuploadTitle){
                            bIsuploadTitle = true
                            cell.titleLbl.text = "Uploaded Documents : (Only these documents will be sent for approval )"
                        }else{
                            cell.titleLbl.text = ""
                        }
                        
                    }else{
                        cell.uploadBtn.setTitle("Upload", for: .normal)
                        
                        if(!bIsTitle){
                            bIsTitle = true
                            cell.titleLbl.text = "( Click upload for each document to upload )"
                            
                        }else{
                            cell.titleLbl.text = ""
                        }
                        
                        
                    }
                    
                    
                    cell.contentView.backgroundColor = .clear
                    cell.selectionStyle = .none
                    
                    cell.uploadBtn.tag = indexPath.row
                    cell.uploadBtn.addTarget(self, action: #selector(callDeleteAction), for: .touchUpInside)
                }
                
                
                return cell
            }
        }
        
        else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UploadSubmitTVCell", for: indexPath) as? UploadSubmitTVCell
            {
                
                cell.submitBtn.tag = indexPath.row
                cell.submitBtn.addTarget(self, action: #selector(callSubmitAction), for: .touchUpInside)
                
                return cell
            }
            
        }
        
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0){
            return 80
        }else if(indexPath.section == 1){
            return 80
        }else{
            return  40
        }
        
    }
    
    @objc func callUploadAction(sender: UIButton){
        let iIndex = sender.tag
        if let dicStores = arrBrowseFile.object(at: iIndex) as? NSDictionary {
            selectIndex = iIndex
            selectDict = NSMutableDictionary(dictionary: dicStores) as! NSMutableDictionary
            let strPa = dicStores.object(forKey: "documentPath") as? String ?? ""
            let strPay = dicStores.object(forKey: "documentDisplayName") as? String ?? ""
            
            bIsTitle = false
            bIsuploadTitle = false
            
            let strP = dicStores.object(forKey: "documentPath") as? String ?? ""
            print("SelPath: \(strP)")
            if(strP.contains("amazonaws.com")){
                
                if(iIndex <= arrBrowseFile.count){
                    bIsTitle = false
                    arrBrowseFile.remove(selectDict)
                    arrSectionBrowseFile.removeObject(at: iIndex)
                    //  callSplitSections()
                    self.uploadTableView.reloadData()
                }
                
            }else{
                if(filenameTF.text!.count > 0){
                    selectDict["documentDisplayName"] = self.filenameTF.text
                    
                    callUploadPDFFile(urlPa: strPa)
                    self.filenameTF.text = ""
                }else{
                    if(strPay.count == 0){
                        Util.showAlert("", msg: "Please enter file name")
                    }else{
                        callUploadPDFFile(urlPa: strPa)
                    }
                }
                
            }
            
            
            
        }
    }
    
    @objc func callDeleteAction(sender: UIButton){
        print("delete")
        let iIndex = sender.tag
        
        if let dicStores = arrSectionBrowseFile.object(at: iIndex) as? NSDictionary {
            selectIndex = iIndex
            selectDict = NSMutableDictionary(dictionary: dicStores) as! NSMutableDictionary
            let strPa = dicStores.object(forKey: "documentPath") as? String ?? ""
            let strPay = dicStores.object(forKey: "documentDisplayName") as? String ?? ""
            
            bIsTitle = false
            bIsuploadTitle = false
            
            let strP = dicStores.object(forKey: "documentPath") as? String ?? ""
            print("SelPath: \(strP)")
            if(strP.contains("amazonaws.com")){
                
                if(iIndex <= arrBrowseFile.count){
                    bIsTitle = false
                    arrBrowseFile.remove(selectDict)
                    arrSectionBrowseFile.removeObject(at: iIndex)
                    //  callSplitSections()
                    self.uploadTableView.reloadData()
                }
                
            }else{
                if(filenameTF.text!.count > 0){
                    selectDict["documentDisplayName"] = self.filenameTF.text
                    
                    callUploadPDFFile(urlPa: strPa)
                    self.filenameTF.text = ""
                }else{
                    if(strPay.count == 0){
                        Util.showAlert("", msg: "Please enter file name")
                    }else{
                        callUploadPDFFile(urlPa: strPa)
                    }
                }
                
            }
            
            
            
        }
    }
    
    @objc func callSubmitAction(sender: UIButton){
        print(arrBrowseFile)
        
        let resultPredicate = NSPredicate(format: "SELF.documentPath contains[c] %@", "amazonaws.com")
        
        if let sortedDta = arrBrowseFile.filtered(using: resultPredicate) as? NSArray {
            
            arrAWSBrowseFile = NSMutableArray(array: sortedDta)
            
            print(sortedDta)
        }
        
        callAPIsubmitFiles()
        
    }
    
    func callSplitSections(){
        arrSectionBrowseFile = []
        print("Spilit")
        let resultPredicate1 = NSPredicate(format: "SELF.documentPath contains[c] %@", "file://")
        
        if let sortedDta = arrBrowseFile.filtered(using: resultPredicate1) as? NSArray {
            
            let arrM : NSMutableArray = NSMutableArray(array: sortedDta)
            
            arrSectionBrowseFile.addObjects(from: arrM as! [Any])
            print("file")
            
        }
        let resultPredicate = NSPredicate(format: "SELF.documentPath contains[c] %@", "amazonaws.com")
        
        if let sortedDta = arrBrowseFile.filtered(using: resultPredicate) as? NSArray {
            
            print("aws")
            
            let arrM : NSMutableArray = NSMutableArray(array: sortedDta)
            
            arrSectionBrowseFile.addObjects(from: arrM as! [Any])
            
        }
        
        print(arrSectionBrowseFile)
        
        
    }
    
    func callUploadPDFFile(urlPa : String){
        do {
            bIsuploadTitle = false
            
            let fileUrl = URL(string: urlPa)
            print("set PDF fileUrl: ", fileUrl)
            
            pdfData = try NSData(contentsOf: fileUrl!, options: NSData.ReadingOptions())
            self.uploadPDFFileToAWS(pdfData: pdfData!)
            
            
        } catch {
            print("set PDF filer error : ", error)
        }
        
        
    }
}

