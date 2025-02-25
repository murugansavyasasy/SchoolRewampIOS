//
//  SendImagePDFAssignmentVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 07/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ImagePicker
import MobileCoreServices

extension SendImagePDFAssignmentVC: UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        urlPath = url
        self.setPDFFile()
    }
}

class SendImagePDFAssignmentVC: UIViewController , UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ImagePickerDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var ClickHereButton: UIButton!
    @IBOutlet weak var MyImageView: UIImageView!
    @IBOutlet weak var titleImageIcon: UIImageView!
    @IBOutlet weak var SendImageLabel: UILabel!
    @IBOutlet weak var ClickImageCaptureButton: UIButton!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var ImageView: UIView!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet weak var SubmissionDateLabel: UILabel!
    
    @IBOutlet weak var catSelView: UIView!
    @IBOutlet weak var submissionDateButton: UIButton!
    
    let picker = UIImagePickerController()
    var selectedDictionary = [String: Any]() as NSDictionary
    var SchoolDetailDict = NSDictionary()
    var selectedSchoolID = NSString()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var MyImageView2: UIImageView!
    @IBOutlet weak var MyImageView3: UIImageView!
    @IBOutlet weak var MyImageView4: UIImageView!
    @IBOutlet weak var MyPDFImage: UIImageView!
    @IBOutlet weak var MoreImagesButton: UIButton!
    
    
    @IBOutlet weak var pickerOkButton: UIButton!
    @IBOutlet weak var pickerCancelButton: UIButton!
    @IBOutlet weak var PopupChooseStandardPickerView: UIView!
    
    @IBOutlet weak var CategorypickerView: UIPickerView!
    @IBOutlet weak var selectCategorylbl: UILabel!
    
    @IBOutlet weak var updateCategorylbl: UILabel!
    
    var moreImagesArray = NSMutableArray()
    var imageLimit = 1
    var urlPath : URL!
    var strFrom = String()
    var SchoolId = String()
    var StaffId = String()
    var assignmentType = String()
    var strCountryCode = String()
    var strSomething = String()
    var strSubmissionDate = String()
    let todayDate = Calendar.current.startOfDay(for: Date())
    var pdfData : NSData? = nil
    var LanguageDict = NSDictionary()
    var assignmentDict  = NSMutableDictionary()
    let utilObj = UtilClass()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let dateView = UIView()
    var pickerCategoryArray = [String]()
    var selectedCategoryRow = 0;
    var TableString = String()
    var SelectedCategoryString = String()
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.initialSetup()
        
        imagePicker.delegate = self
        //        pickerCategoryArray = ["GENERAL","CLASS WORK","PROJECT","RESEARCH PAPER"]
        pickerCategoryArray = ["GENERAL","CLASS WORK","PROJECT","RESEARCH PAPER"]
        SelectedCategoryString = pickerCategoryArray[selectedCategoryRow]
        updateCategorylbl.text = SelectedCategoryString
        
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (TableString == "category"){
            return pickerCategoryArray.count
        }
        else{
            return pickerCategoryArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (TableString == "category"){
            return pickerCategoryArray[row]
        }
        else{
            return pickerCategoryArray[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (TableString == "category"){
            selectedCategoryRow = row
        }
        
    }
    func actionSelectCategory(){
        TableString = "category"
        selectCategorylbl.text = LanguageDict["select_category"] as? String
        self.CategorypickerView.reloadAllComponents()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChooseStandardPickerView.frame.size.height = 300
            PopupChooseStandardPickerView.frame.size.width = 350
            
        }
        //
        
        //        G3
        
        PopupChooseStandardPickerView.center = view.center
        PopupChooseStandardPickerView.alpha = 1
        PopupChooseStandardPickerView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(PopupChooseStandardPickerView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            //use if you want to darken the background
            //self.viewDim.alpha = 0.8
            //go back to original form
            self.PopupChooseStandardPickerView.transform = .identity
        })
        
        
        
        
        print("SENDIMAGEPDFIMASSIGNMENT")
        
        
        
    }
    
    func initialSetup(){
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        view.isOpaque = false
        ClickImageCaptureButton.isEnabled = false
        ClickImageCaptureButton.layer.cornerRadius = 5
        ClickImageCaptureButton.layer.masksToBounds = true
        
        SendButton.isEnabled = false
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        picker.delegate = self
        
        let loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        if(loginAsName == "Principal")
        {
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }else{
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }
        
        let currentDate: NSDate = NSDate()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strSubmissionDate = dateFormatter.string(from: currentDate as Date)
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        submissionDateButton.setTitle("   " + dateFormatter.string(from: currentDate as Date), for: .normal)
        
        self.MoreImagesButton.isHidden = true
        self.MyImageView.isHidden = false
        //        self.MyImageView2.isHidden = true
        //        self.MyImageView3.isHidden = true
        //        self.MyImageView4.isHidden = true
        self.MyPDFImage.isHidden = true
        
        
    }
    
    
    @IBAction func actionOk(_ sender: Any) {
        SelectedCategoryString = pickerCategoryArray[selectedCategoryRow]
        updateCategorylbl.text = SelectedCategoryString
        PopupChooseStandardPickerView.alpha = 0
        //        popupLoading.dismiss(true)
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        PopupChooseStandardPickerView.alpha = 0
        //        popupLoading.dismiss(true)
    }
    
    
    
    @IBAction func actionCategorypopUp(_ sender: Any) {
        self.actionSelectCategory()
    }
    
    override func viewWillAppear(_ animated: Bool){
        self.callSelectedLanguage()
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionCaptureImageButton(_:)))
        
        if(moreImagesArray.count > 0){
            ClickHereButton.isHidden = true
            ClickImageCaptureButton.isEnabled = true
            SendButton.isEnabled = true
            SendButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
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
        // Dispose of any resources that can be recreated.
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
        
        fileSelection()
    }
    
    @IBAction func actionCloseView(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func fileSelection(){
        descriptionTextField.resignFirstResponder()
        if(assignmentType == "pdf"){
            self.FromPDF()
        }else{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                let alertController = UIAlertController(title: LanguageDict["upload_image"] as? String, message: LanguageDict["choose_option"] as? String, preferredStyle: .alert)
                // Initialize Actions
                let yesAction = UIAlertAction(title: LanguageDict["choose_from_gallery"] as? String, style: .default) { (action) -> Void in
                    self.openGallery()
                }
                
                let cameraAction = UIAlertAction(title:  LanguageDict["compose_camera"] as? String, style: .default) {
                    (action) -> Void in
                    self.FromPhoto()
                    
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
                    self.openGallery()
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
        strFrom = "IMAGE"
        self.ImagePickerGallery()
    }
    
    func FromPhoto(){
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            strFrom = "Image"
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
    
    func openGallery()
    {
        strFrom = "Image"
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    //
    
    
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
            
            
            SendButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
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
        descriptionTextField.resignFirstResponder()
        
        assignmentDict = [
            "AssignmentId" : "0",
            "SchoolID" : SchoolId,
            "AssignmentType": strFrom,
            "Title": self.descriptionTextField.text! ,
            "content": "",
            "Duration":"0" ,
            "category" : selectedCategoryRow + 1,
            "ProcessBy":StaffId,
            "isMultiple": moreImagesArray.count > 0 ? "1" : "0",
            "processType":"add",
            "EndDate":strSubmissionDate,
            
        ]
        utilObj.printLogKey(printKey: "assignmentDict", printingValue: assignmentDict)
        let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
        AddCV.SchoolDetailDict = SchoolDetailDict
        AddCV.sendAssignmentDict = self.assignmentDict
        AddCV.assignmentType = "StaffAssignment"
        AddCV.pdfData = self.pdfData
        AddCV.imagesArray = moreImagesArray
        self.present(AddCV, animated: false, completion: nil)
        
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
            SendButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
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
            //            self.MyImageView2.isHidden = true
            //            self.MyImageView3.isHidden = true
            //            self.MyImageView4.isHidden = true
            
            ClickHereButton.isHidden = true
            ClickImageCaptureButton.isEnabled = true
            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            SendButton.isEnabled = true
            SendButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
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
        
        
        if(assignmentType == "pdf"){
            titleImageIcon.image = UIImage(named: "pdfImage")
            ClickHereButton.setTitle(LangDict["click_here_pdf"] as? String, for: .normal)
            ClickImageCaptureButton.setTitle(LangDict["change_pdf"] as? String, for: .normal)
            SendImageLabel.text = LangDict["compose_pdf"] as? String
            descriptionTextField.placeholder = LangDict["assignment_title"] as? String
        }else{
            titleImageIcon.image = UIImage(named: "ImageIcon")
            ClickHereButton.setTitle(LangDict["click_here_image"] as? String, for: .normal)
            ClickImageCaptureButton.setTitle(LangDict["change_image"] as? String, for: .normal)
            SendImageLabel.text = LangDict["teacher_txt_compose_Img"] as? String
            descriptionTextField.placeholder = LangDict["assignment_title"] as? String
        }
        SubmissionDateLabel.text = LangDict["subission_date"] as? String
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        SendButton.setTitle(LangDict["teacher_choose_recipient"] as? String, for: .normal)
        
    }
    
    //MARK: DatePicker
    
    @IBAction func actionDateButton(_ sender: UIButton) {
        descriptionTextField.resignFirstResponder()
        self.congifureDatePicker()
    }
    
    func congifureDatePicker()
    {
        dateView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.actionClosePopup(_:)))
        dateView.addGestureRecognizer(tap)
        
        let doneButton = UIButton()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            doneButton.frame = CGRect(x: 0, y: self.view.frame.height - 250, width: self.dateView.frame.width, height: 50)
        }else
        {
            doneButton.frame = CGRect(x: 0, y: self.view.frame.height - 235, width: self.dateView.frame.width, height: 35)
        }
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        doneButton.addTarget(self, action: #selector(self.actionDoneButton(_:)), for: .touchUpInside)
        // Posiiton date picket within a view
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        let timeViews = UIView()
        timeViews.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        timeViews.backgroundColor = UIColor.white
        let currentDate: NSDate = NSDate()
        // Set some of UIDatePicker properties
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.minimumDate = currentDate as Date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        // Add an event to call onDidChangeDate function when value is changed.
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        
        // Add DataPicker to the view
        dateView.addSubview(timeViews)
        dateView.addSubview(doneButton)
        dateView.addSubview(datePicker)
        
        //
        
        
        //        G3
        
        dateView.center = view.center
        dateView.alpha = 1
        dateView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(dateView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.dateView.transform = .identity
        })
        
        
        
        
        print("SENDIMAGEPDFIMASSIGNMENTDAa")
        popupLoading.dimmedMaskAlpha =  0
        
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strSubmissionDate = dateFormatter.string(from: sender.date) as String
        submissionDateButton.setTitle("   " + selectedDate + "   ", for: .normal)
        
    }
    
    @objc func actionDoneButton(_ sender: UIButton)
    {
        dateView.alpha = 0
        //        popupLoading.dismiss(true)
    }
    @objc func actionClosePopup(_ sender: UIButton)
    {
        popupLoading.dismiss(true)
    }
    
}
