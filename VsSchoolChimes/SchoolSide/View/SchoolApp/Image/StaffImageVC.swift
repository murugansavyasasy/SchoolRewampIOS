//
//  StaffImageVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 25/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ImagePicker
import MobileCoreServices
import PhotosUI

extension StaffImageVC: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        urlPath = url
        self.setPDFFile()
        self.enableButton()
    }
}

class StaffImageVC: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ImagePickerDelegate ,PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
     
        print("changeImgClick",changeImgClick)
        print("chanresultsk",results)
      
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [self] (object, error) in
                if let image = object as? UIImage {
                    self.selectedImages.append(image)
                    
//                       print("Selected images: \(selectedImages)")
                    print("IMGARRCOUNT",imgArr.count)
                    print("IMGAimagesArrayNT",imagesArray.count)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [self] in
            
            for item in selectedImages {
                if let image = item as? UIImage {
                    imagesArray.add(image)
                    print("Seles: \(image)")
                }
            }
            // Process the selected images
            print("pickerselectedIcount",selectedImages.count)
            self.SetImagesFromPicker(imageCount: (selectedImages.count as NSNumber))
                  self.SetImagesIntoPath(images: selectedImages)
//               imgArr.append(selectedImages.count)
            print("Selected images: \(selectedImages)")
//               print("IMGARRCOUNT",imgArr.count)
            
            if(selectedImages.count > 0){
                ClickHereButton.isHidden = true
                ClickImageCaptureButton.isEnabled = true
                ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
                
            }else{
//                MoreImagesButton.isHidden = true
                ClickHereButton.isHidden = false
                ClickImageCaptureButton.isEnabled = false
                ClickImageCaptureButton.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    @IBOutlet weak var img1Height: NSLayoutConstraint!
    @IBOutlet weak var img1Width: NSLayoutConstraint!
    
    @IBOutlet weak var ToStaffGroupsButton: UIButton!
    @IBOutlet weak var MyImageView: UIImageView!
    @IBOutlet weak var DescriptionTitle: UITextField!
    @IBOutlet weak var SendImageLabel: UILabel!
    @IBOutlet weak var ClickImageCaptureButton: UIButton!
    @IBOutlet weak var ImageView: UIView!
    @IBOutlet weak var StandardSectionButton: UIButton!
    @IBOutlet weak var StandardStudentButton: UIButton!
    @IBOutlet weak var ClickHereButton: UIButton!
    @IBOutlet weak var MyImageView2: UIImageView!
    @IBOutlet weak var MyImageView3: UIImageView!
    @IBOutlet weak var MyImageView4: UIImageView!
    @IBOutlet weak var MoreImagesButton: UIButton!
    @IBOutlet weak var MyPDFImage: UIImageView!
    var SchoolId = String()
    var StaffId = String()
    var pdfData : NSData? = nil
    var pdfType : String!
    var moreImagesArray = NSMutableArray()
    var urlPath : URL!
    var strFrom = String()
    var imageLimit = 0
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var uploadImageData : NSData? = nil
    let picker = UIImagePickerController()
    var LanguageDict = NSDictionary()
    var strCountryName = String()
    var imagePicker = UIImagePickerController()
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var LoginSchoolDetailArray = NSArray()
    var cameraSelect : Int!
    var imagesArray = NSMutableArray()
    
    var changeImgClick = 0
    var selectedImages: [UIImage] = []
    var imgArr : [Int] = []
    override func viewDidLoad(){
        super.viewDidLoad()
        self.initialSetup()
        imagePicker.delegate = self
        
        SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
        SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
        StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        
        strCountryName = UserDefaults.standard.object(forKey: COUNTRY_Name) as? String ?? ""
        print(strCountryName)
    }
    
    func initialSetup(){
        view.isOpaque = false
        
        StandardSectionButton.layer.cornerRadius = 5
        StandardSectionButton.layer.masksToBounds = true
        StandardStudentButton.layer.cornerRadius = 5
        StandardStudentButton.layer.masksToBounds = true
        
        ToStaffGroupsButton.layer.cornerRadius = 5
        ToStaffGroupsButton.layer.masksToBounds = true
        
        ClickImageCaptureButton.layer.cornerRadius = 5
        ClickImageCaptureButton.layer.masksToBounds = true
        ClickImageCaptureButton.isEnabled = false
        StandardSectionButton.isEnabled = false
        StandardStudentButton.isEnabled = false
        ToStaffGroupsButton.isEnabled = false
        let strImageLimit : NSString = UserDefaults.standard.object(forKey: IMAGE_COUNT) as! NSString
        imageLimit = strImageLimit.integerValue
        print("imageLimit",imageLimit)
        picker.delegate = self
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StaffImageVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
        
        self.MyImageView.isHidden = false
        //
    }
    
    override func viewWillAppear(_ animated: Bool){
        self.callSelectedLanguage()
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionCaptureImageButton(_:)))
//        ImageView.addGestureRecognizer(tapped)
        if(UserDefaults.standard.object(forKey: IMAGE_COUNT) != nil){
            let strImageLimit : NSString = UserDefaults.standard.object(forKey: IMAGE_COUNT) as! NSString
            imageLimit = strImageLimit.integerValue
        }
        if(moreImagesArray.count > 0){
            ClickHereButton.isHidden = true
            ClickImageCaptureButton.isEnabled = true
            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
        }else{
            ClickHereButton.isHidden = false
            ClickImageCaptureButton.isEnabled = false
            ClickImageCaptureButton.backgroundColor = UIColor.lightGray
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: TEXTFIELD DELEGATE
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
        DescriptionTitle.resignFirstResponder()
        
        
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.ImagePickerGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Pdf", style: .default, handler: { _ in
            self.FromPDF()
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
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
    
    
    @IBAction func openCamera() {
        // Check if the camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            strFrom = "Image"
            cameraSelect = 1
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true // Allows editing of the captured image
            present(imagePicker, animated: true, completion: nil)
        } else {
            // Camera is not available, show an alert
            let alert = UIAlertController(title: "Camera Not Available", message: "This device has no camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func alertClose(gesture: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: CHANGE BUTTON ACTION
    @IBAction func actionChangeImageButton(_ sender: UIButton) {
        DescriptionTitle.resignFirstResponder()
        
        
       
        
        self.ClickHereButton.setTitleColor(UIColor.white, for: .normal)
        self.ClickHereButton.isUserInteractionEnabled = false
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { [self] _ in
//            self.openGallary()
            
            changeImgClick  = 1
            self.ImagePickerGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Pdf", style: .default, handler: { _ in
            self.FromPDF()
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
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
    
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
//                               [UIImagePickerController.InfoKey : Any]) {
//        ClickImageCaptureButton.isEnabled = true
//        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//        MyImageView.contentMode = .scaleToFill
//        MyImageView.image = chosenImage
//        print("FilePAthImage",chosenImage)
//        self.moreImagesArray.add(chosenImage)
//        imagesArray.add(chosenImage)
//        if(self.MyImageView.image != nil){
//            enableButton()
//            dismiss(animated: true, completion: nil)
//            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
//            
//        }    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        
        
        
        if cameraSelect == 1 {
            ClickImageCaptureButton.isEnabled = true
                   let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                   MyImageView.contentMode = .scaleToFill
            selectedImages.removeAll()
            imagesArray.removeAllObjects()
            moreImagesArray.removeAllObjects()
                   MyImageView.image = chosenImage
            MyImageView.isHidden =  false
                   self.moreImagesArray.add(chosenImage)
            imagesArray.add(chosenImage)
            img1Width.constant = 353
            img1Height.constant = 160
           
            self.SetImagesFromPicker(imageCount: (moreImagesArray.count as NSNumber))
            self.SetImagesIntoPath(images: [chosenImage])
                   if(self.MyImageView.image != nil){
                       dismiss(animated: true, completion: nil)
                       ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
           
                   }
        }else{
            imagePicker.dismiss(animated: true, completion: nil)
            
            let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            //
            print("chosenImage12345",  chosenImage)
            //        imgShowView.isHidden = false
            //        imgShowTop.constant = 5
            //
            //        imgPdfAttachBtn.isHidden = false
            //        attachmentSelectType = "Image"
            //        HomeWorkType = "Image"
            //        textviewEnableorDisable()
            self.moreImagesArray.add(chosenImage)
            print("moreImagesArray",  moreImagesArray.count)
//            imgCountLbl.text = "+" + String(moreImagesArray.count)
//            imgCountLbl.isHidden = false
//            imgCountShowView.isHidden = false
            if moreImagesArray.count == 1 {
                img1Width.constant = 353
                img1Height.constant = 160
                MyImageView.image = moreImagesArray[0] as! UIImage
                //            MyImageView.isUserInteractionEnabled = true
                
                MyImageView2.isHidden = true
                
                //            let img1Ges = Img1Ges(target: self, action: #selector(imgPdfClick))
                //            img1Ges.url = moreImagesArray[0] as! UIImage
                //            ImageView.addGestureRecognizer(img1Ges)
                //            closeView1.isHidden = false
                //            closeView2.isHidden = true
                
            }else   if moreImagesArray.count == 2 {
                MyImageView2.isHidden = false
                img1Width.constant = 176
                img1Height.constant = 80
                MyImageView.image = moreImagesArray[0] as! UIImage
                MyImageView2.image = moreImagesArray[1] as! UIImage
                //            closeView1.isHidden = false
                //            closeView2.isHidden = false
                
                //            MyImageView.isUserInteractionEnabled = true
                //            MyImageView2.isUserInteractionEnabled = true
                
                //            let img1Ges = Img1Ges(target: self, action: #selector(imgPdfClick))
                //            img1Ges.url = moreImagesArray[0] as! UIImage
                //            MyImageView.addGestureRecognizer(img1Ges)
                //
                //
                //            let img2Ges = Img2Ges(target: self, action: #selector(imgPdfClick2))
                //            img2Ges.url = moreImagesArray[1] as! UIImage
                //            MyImageView2.addGestureRecognizer(img2Ges)
                //
            }else   if moreImagesArray.count == 3 {
                img1Width.constant = 176
                img1Height.constant = 80
                MyImageView.image = moreImagesArray[0] as! UIImage
                MyImageView2.image = moreImagesArray[1] as! UIImage
                MyImageView3.image = moreImagesArray[2] as! UIImage
                
                //            closeView1.isHidden = false
                //            closeView2.isHidden = false
                //
                
                MyImageView.isUserInteractionEnabled = true
                MyImageView2.isUserInteractionEnabled = true
                
                //            let img1Ges = Img1Ges(target: self, action: #selector(imgPdfClick))
                //            img1Ges.url = moreImagesArray[0] as! UIImage
                //            MyImageView.addGestureRecognizer(img1Ges)
                //
                //
                //            let img2Ges = Img2Ges(target: self, action: #selector(imgPdfClick2))
                //            img2Ges.url = moreImagesArray[1] as! UIImage
                //            MyImageView2.addGestureRecognizer(img2Ges)
                
                
                
            }else  {
                img1Width.constant = 176
                img1Height.constant = 80
                print("moreImagesArracount",moreImagesArray.count)
                MyImageView.image = moreImagesArray[0] as! UIImage
                MyImageView2.image = moreImagesArray[1] as! UIImage
                MyImageView3.image = moreImagesArray[2] as! UIImage
                MyImageView4.image = moreImagesArray[3] as! UIImage
                
                
                if moreImagesArray.count < 4 {
//                    imgCountShowView.isHidden = false
//                    imgCountLbl.isHidden = false
//                    imgCountLbl.text = String(moreImagesArray.count - 4)
                    
                }else{
                    print("moreImagesArr")
//                    imgCountShowView.isHidden = false
//                    imgCountLbl.isHidden = false
//                    imgCountLbl.text = String(moreImagesArray.count - 4)
                }
            }
            
        }
        
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
        let alertVC = UIAlertController(title: "No Camera",message: "Sorry, this device has no camera",preferredStyle: .alert)
        let okAction = UIAlertAction(title: LanguageDict["teacher_btn_ok"] as? String,style:.default,handler: nil)
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
            self.FromPDF()
        default: break
        }
    }
    
    func FromLibrary(){
        self.strFrom = "Image"
        
        self.ImagePickerGallery()
    }
    
    func FromPhoto(){
        self.strFrom = "Image"
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
        }else{
            noCamera()
        }
    }
    
    func FromPDF(){
        self.strFrom = "PDF"
        MyImageView.isHidden = true
        MyImageView2.isHidden = true
        MyImageView3.isHidden = true
        MyImageView4.isHidden = true
        
        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func shootFromLibrary(sender: integer_t){
        self.strFrom = "Image"
        
        self.ImagePickerGallery()
    }
    
    func shootFromPhoto(sender: integer_t){
        self.strFrom = "Image"
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
        }else{
            noCamera()
        }
    }
    
    func enableButton(){
        
        StandardSectionButton.isEnabled = true
        StandardSectionButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        StandardStudentButton.isEnabled = true
        StandardStudentButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        ToStaffGroupsButton.isEnabled = true
        ToStaffGroupsButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        ClickHereButton.isHidden = true
        ClickImageCaptureButton.isEnabled = true
        
    }
    
    
    
    
    //MARK: NEXT BUTTON ACTION
    
    
    
    
    
    @IBAction func actionStaffGroups(_ sender: UIButton) {
        
        
        
        
        let vc =  StaffGroupVoiceViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.selectType = "Image"
        vc.imgDesc = DescriptionTitle.text!
        vc.SchoolId = SchoolId
        vc.StaffId = StaffId
        vc.pdfData = self.pdfData
        vc.pdfDataType = pdfType
        
        print("SchoolId1",SchoolId)
        vc.imagesArrayGet = imagesArray
        present(vc, animated: true, completion: nil)
    }
    
    
    
    
    
    @IBAction func actionStandardOrSectionButton(_ sender: UIButton) {
        DescriptionTitle.resignFirstResponder()
        let StaffVC = self.storyboard?.instantiateViewController(withIdentifier: "StandardOrSectionVCStaff") as! StandardOrSectionVCStaff
        StaffVC.SendedScreenNameStr = "StaffMultipleImage"
        StaffVC.HomeTitleText = DescriptionTitle.text!
        StaffVC.uploadImageData = uploadImageData
        StaffVC.imagesArray = imagesArray
        StaffVC.strFrom = strFrom
        StaffVC.pdfData = self.pdfData
        self.present(StaffVC, animated: false, completion: nil)
    }
    
    @IBAction func actionStandardOrStudentButton(_ sender: UIButton) {
        DescriptionTitle.resignFirstResponder()
        DescriptionTitle.resignFirstResponder()
        let StaffStudent = self.storyboard?.instantiateViewController(withIdentifier: "StandardOrStudentsStaff") as! StandardOrStudentsStaff
        StaffStudent.SenderScreenName = "StaffMultipleImage"
        StaffStudent.HomeTitleText = DescriptionTitle.text!
        StaffStudent.uploadImageData = uploadImageData
        StaffStudent.imagesArray =  imagesArray
        StaffStudent.strFrom = strFrom
        StaffStudent.pdfData = self.pdfData
        self.present(StaffStudent, animated: false, completion: nil)
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        DescriptionTitle.resignFirstResponder()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionMoreImages(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "moreImagesSegue", sender: self)
        }
    }
    
    @objc func catchNotification(notification:Notification) -> Void{
        dismiss(animated: false, completion: nil)
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(ExamTestVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
    }
    
    func ImagePickerGallery() {
        
        if   changeImgClick == 1 {
            selectedImages.removeAll()
            imagesArray.removeAllObjects()
//            imgCountShowView.isHidden = true
//            imgCountLbl.isHidden = true
        }
        
        strFrom = "Image"
        pickImages()
        
//        let config = ImagePickerConfiguration()
//        config.doneButtonTitle = "Finish"
//        config.noImagesTitle = "Sorry! There are no images here!"
//        config.recordLocation = false
//        config.allowVideoSelection = false
//        
//        let imagePicker = ImagePickerController(configuration: config)
//        imagePicker.delegate = self
//        imagePicker.imageLimit = imageLimit
//        present(imagePicker, animated: true, completion: {
//            imagePicker.navigationController?.navigationBar.topItem?.title = ""
//            imagePicker.navigationController?.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
//        })
    }
    
    
    @IBAction func pickImages() {
       
           var config = PHPickerConfiguration()
        config.selectionLimit = imageLimit // Limit the selection to 4 images
           config.filter = .images  // Only allow image selection
           
        print("changeimageLimitk",imageLimit)
           let picker = PHPickerViewController(configuration: config)
           picker.delegate = self
           present(picker, animated: true, completion: nil)
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
            print("FilePAthImage",image)
        }
        
        if(moreImagesArray.count > 0){
            self.enableButton()
        }else{
            ClickHereButton.isHidden = false
            ClickImageCaptureButton.isEnabled = false
            ClickImageCaptureButton.backgroundColor = UIColor.lightGray
        }
        self.SetImagesFromPicker(imageCount: (images.count as NSNumber))
        self.SetImagesIntoPath(images: images)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func SetImagesIntoPath(images : [UIImage]){
//        let countGest = UITapGestureRecognizer(target: self, action: #selector(imgListNavigate))
//        imgCountShowView.addGestureRecognizer(countGest)
        print("SetImagesIntoPathCount",images.count)
        
        enableButton()
        if(images.count == 1){
            self.MyImageView.image = images[0]
            MyImageView.isHidden = false
           
//            imgCountShowView.isHidden = true
//            imgCountLbl.isHidden = true
            img1Width.constant = 353
            img1Height.constant = 160
        }else if(images.count == 2){
            self.MyImageView.image = images[0]
            self.MyImageView2.image = images[1]
            MyImageView.isHidden = false
            MyImageView2.isHidden = false
         
//            imgCountShowView.isHidden = true
            img1Width.constant = 176
            img1Height.constant = 80
//           
//            imgCountLbl.isHidden = true
        }else if(images.count == 3){
            self.MyImageView.image = images[0]
            self.MyImageView2.image = images[1]
            self.MyImageView3.image = images[2]
            img1Width.constant = 176
            img1Height.constant = 80
            MyImageView.isHidden = false
            MyImageView2.isHidden = false
            MyImageView3.isHidden = false
           
//            imgCountShowView.isHidden = true
//            imgCountLbl.isHidden = true
        }else if(images.count > 4) || images.count == 4{
            self.MyImageView.image = images[0]
            self.MyImageView2.image = images[1]
            self.MyImageView3.image = images[2]
            self.MyImageView4.image = images[3]
            img1Width.constant = 176
            img1Height.constant = 80
            MyImageView.isHidden = false
            MyImageView2.isHidden = false
            MyImageView3.isHidden = false
            MyImageView4.isHidden = false
           
            if images.count > 4 {
//                imgCountShowView.isHidden = false
//                imgCountLbl.isHidden = false
                var getCount =  images.count - 4
                if getCount != 0 {
//                    imgCountLbl.text = String(images.count - 4)
                }
                
            }
        }
        
        
    }
    
    func SetImagesFromPicker(imageCount : NSNumber){
        self.MyPDFImage.isHidden = true
        enableButton()
//        if(imageCount.intValue >= 4){
//            self.MyImageView.isHidden = false
//
//            if(imageCount.intValue > 4){
//                self.MoreImagesButton.isHidden = false
//                let moreImagesCount = imageCount.intValue - 3
//                self.MoreImagesButton.setTitle("+\(moreImagesCount)", for: .normal)
//            }else{
//                self.MoreImagesButton.isHidden = true
//            }
//        }else
        
        if(imageCount.intValue == 3){
            img1Width.constant = 176
            img1Height.constant = 80
//            imgCountShowView.isHidden = true
//            imgCountLbl.isHidden = true
            self.MyImageView.isHidden = false
            self.MyImageView2.isHidden = false
            self.MyImageView3.isHidden = false
            self.MyImageView4.isHidden = true
        }else if(imageCount.intValue == 2){
            img1Width.constant = 176
            img1Height.constant = 80
//            imgCountShowView.isHidden = true
//            imgCountLbl.isHidden = true
            self.MyImageView.isHidden = false
            self.MyImageView2.isHidden = false
            self.MyImageView3.isHidden = true
            self.MyImageView4.isHidden = true
        }else if(imageCount.intValue == 1){
            img1Width.constant = 353
            img1Height.constant = 160
//            imgCountShowView.isHidden = true
//            imgCountLbl.isHidden = true
            self.MyImageView.isHidden = false
            self.MyImageView2.isHidden = true
            self.MyImageView3.isHidden = true
            self.MyImageView4.isHidden = true
        }else if imageCount.intValue > 4 || imageCount.intValue == 4{
            img1Width.constant = 176
            img1Height.constant = 80
           
            self.MyImageView.isHidden = false
            self.MyImageView2.isHidden = false
            self.MyImageView3.isHidden = false
            self.MyImageView4.isHidden = false
            
            
            if imageCount.intValue > 4 {
//                imgCountShowView.isHidden = false
//                imgCountLbl.isHidden = false
                var getCount =  imageCount.intValue - 4
                if getCount != 0 {
//                    imgCountLbl.text = String(imageCount.intValue - 4)
                }
                
            }
        }
    }
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "moreImagesSegue"){
            let moreImagesVC = segue.destination as! MoreImagesVC
            moreImagesVC.moreImagesArray = moreImagesArray
        }
    }
    
    func setPDFFile(){
        do {
            pdfType = "1"
            pdfData = try NSData(contentsOf: urlPath!, options: NSData.ReadingOptions())
        } catch {
            print("set PDF filer error : ", error)
        }
        
        if(pdfData != nil){
            self.MyPDFImage.image = UIImage(named: "pdfImage")
            self.MyPDFImage.isHidden = false
            self.MyImageView.isHidden = true
            
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
            DescriptionTitle.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            DescriptionTitle.textAlignment = .left
        }
        SendImageLabel.text = LangDict["teacher_txt_composeImg"] as? String
        DescriptionTitle.placeholder = LangDict["teacher_image_hint_title"] as? String ?? "Type content here"
        
        if (strCountryName.uppercased() == SELECT_COUNTRY){
            StandardSectionButton.setTitle(LangDict["teacher_staff_to_sections_usa"] as? String, for: .normal)
            StandardStudentButton.setTitle(LangDict["teacher_staff_to_students"] as? String, for: .normal)
        }
        else{
            StandardSectionButton.setTitle(LangDict["teacher_staff_to_sections"] as? String, for: .normal)
            StandardStudentButton.setTitle(LangDict["teacher_staff_to_students"] as? String, for: .normal)
        }
        ClickHereButton.setTitle(LangDict["image_pdf_title_click"] as? String, for: .normal)
        ClickImageCaptureButton.setTitle(LangDict["teacher_txt_change_selection"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
}

