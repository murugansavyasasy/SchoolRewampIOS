//
//  ImageMessageVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 18/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ImagePicker
import MobileCoreServices
import PhotosUI

extension ImageMessageVC: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        urlPath = url
        self.setPDFFile()
    }
}

class ImageMessageVC: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ImagePickerDelegate, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var ClickHereButton: UIButton!
    @IBOutlet weak var MyImageView: UIImageView!
    @IBOutlet weak var SendImageLabel: UILabel!
    @IBOutlet weak var ClickImageCaptureButton: UIButton!
    @IBOutlet weak var ImageView: UIView!
    @IBOutlet var schoolsTableView: UITableView!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var img1Height: NSLayoutConstraint!
    @IBOutlet weak var img1Width: NSLayoutConstraint!
    @IBOutlet weak var imgCountLbl: UILabel!
    @IBOutlet weak var imgCountShowView: UIViewX!
    @IBOutlet weak var MyImageView2: UIImageView!
    @IBOutlet weak var MyImageView3: UIImageView!
    @IBOutlet weak var MyImageView4: UIImageView!
    @IBOutlet weak var MyPDFImage: UIImageView!
    @IBOutlet weak var MoreImagesButton: UIButton!
    var moreImagesArray = NSMutableArray()
    var imageLimit = 0
    var urlPath : URL!
    var strFrom = String()
    var pdfData : NSData? = nil
    var LanguageDict = NSDictionary()
    var imagePicker = UIImagePickerController()
    var strStaffID : String!
    var strSchoolID : String!
    let picker = UIImagePickerController()
    var selectedSchoolDictionary = NSMutableDictionary()
    var selectedSchoolID = NSString()
    var selectedStaffID = NSString()
    var imagesArray = NSMutableArray()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var getStaff : String!
    var getScl : String!
    var changeImgClick = 0
    var selectedImages: [UIImage] = []
    var imgArr : [Int] = []
    var cameraSelect : Int!
    override func viewDidLoad(){
        super.viewDidLoad()
        imagePicker.delegate = self
        
        
        imgCountLbl.isHidden = true
        imgCountShowView.isHidden = true
        let strImageLimit : NSString = UserDefaults.standard.object(forKey: IMAGE_COUNT) as! NSString
        imageLimit = strImageLimit.integerValue
        print("imageLimit",imageLimit)
        
        let defaults = UserDefaults.standard
        strStaffID = defaults.string(forKey: DefaultsKeys.StaffID)!
        strSchoolID = defaults.string(forKey: DefaultsKeys.SchoolD)!
        print("strSchoolID67",strSchoolID)
        self.initialSetup()
        
        
        
    }
    
    func initialSetup(){
        view.isOpaque = false
        ClickImageCaptureButton.isEnabled = false
        ClickImageCaptureButton.layer.cornerRadius = 5
        ClickImageCaptureButton.layer.masksToBounds = true
        picker.delegate = self
        self.MoreImagesButton.isHidden = true
        self.MyImageView.isHidden = false
        
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        self.callSelectedLanguage()
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionCaptureImageButton(_:)))
        if(UserDefaults.standard.object(forKey: IMAGE_COUNT) != nil){
            let strImageLimit : NSString = UserDefaults.standard.object(forKey: IMAGE_COUNT) as! NSString
            imageLimit = strImageLimit.integerValue
        }
        
        if(moreImagesArray.count > 0){
            ClickHereButton.isHidden = true
            ClickImageCaptureButton.isEnabled = true
            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
        }else{
            MoreImagesButton.isHidden = true
            ClickHereButton.isHidden = false
            ClickImageCaptureButton.isEnabled = false
            ClickImageCaptureButton.backgroundColor = UIColor.lightGray
        }
        
//        ImageView.addGestureRecognizer(tapped)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            headerViewHeight.constant = 527
        }else{
            headerViewHeight.constant = 307
        }
        self.sizeHeaderToFit()
    }
    
    func sizeHeaderToFit() {
        headerView = schoolsTableView.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        schoolsTableView.tableHeaderView = headerView
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
//            self.changeImgClick  = 1
            self.ImagePickerGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Pdf", style: .default, handler: { _ in
            self.FromPDF()
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
    func alertClose(gesture: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    
//    func openCamera()
//    {
//        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
//        {
//            imagePicker.sourceType = UIImagePickerController.SourceType.camera
//            imagePicker.allowsEditing = true
//            self.present(imagePicker, animated: true, completion: nil)
//        }
//        else
//        {
//            
//            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
    
    func openGallary()
    {
        strFrom = "Image"
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    //MARK: CHANGE BUTTON ACTION
    @IBAction func actionChangeImageButton(_ sender: UIButton) {
        print("Change Button")
        print("opalImg")
        descriptionTextField.resignFirstResponder()
        
       
        
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
                picker.isNavigationBarHidden = false
                dismiss(animated: true, completion: nil)
            }
        case 1:
            ImagePickerGallery()
        case 2:
            self.openCamera()
        case 3:
            self.FromPDF()
        default: break
        }
    }
    
    func FromLibrary(){
        strFrom = "Image"
        
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
        strFrom = "Image"
        
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
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        ClickImageCaptureButton.isEnabled = true
//        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//        MyImageView.contentMode = .scaleToFill
//        MyImageView.image = chosenImage
//        self.moreImagesArray.add(chosenImage)
//        if(self.MyImageView.image != nil){
//            dismiss(animated: true, completion: nil)
//            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
//            
//        }
//    }
    
    
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
            imgCountLbl.text = "+" + String(moreImagesArray.count)
            imgCountLbl.isHidden = false
            imgCountShowView.isHidden = false
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
                    imgCountShowView.isHidden = false
                    imgCountLbl.isHidden = false
                    imgCountLbl.text = String(moreImagesArray.count - 4)
                    
                }else{
                    print("moreImagesArr")
                    imgCountShowView.isHidden = false
                    imgCountLbl.isHidden = false
                    imgCountLbl.text = String(moreImagesArray.count - 4)
                }
            }
            
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
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 65
        }else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.LoginSchoolDetailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageTVCell", for: indexPath) as! TextMessageTVCell
        let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.row) as? NSDictionary
        cell.SchoolNameLbl.text = schoolDict?["SchoolName"] as? String

        var schoolNameReg  =  schoolDict?["SchoolNameRegional"] as? String

                if schoolNameReg != "" && schoolNameReg != nil {

                    cell.SchoolNameRegionalLbl.text = schoolNameReg
                    cell.SchoolNameRegionalLbl.isHidden = false

//                        cell.locationTop.constant = 4
                }else{
                    cell.SchoolNameRegionalLbl.isHidden = true
        //            cell.SchoolNameRegional.backgroundColor = .red
                    cell.schoolNameTop.constant = 20

                }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didselectWork")
        let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.row) as? NSDictionary
        selectedSchoolID = schoolDict?["SchoolID"] as! NSString
        selectedSchoolDictionary["SchoolID"] = schoolDict?["SchoolID"] as! NSString
        selectedSchoolDictionary["StaffID"] = schoolDict?["StaffID"] as! NSString
        selectedSchoolDictionary["Description"] = descriptionTextField.text!
        
        print("selectedSchoolDictionary[SchoolID]",schoolDict?["SchoolID"])
        getScl = selectedSchoolDictionary["SchoolID"] as! String
        getStaff = selectedSchoolDictionary["StaffID"] as! String
        
        print("SchoolID124",getStaff)
        selectedSchoolDictionary["Description"] = descriptionTextField.text!
        if(self.strFrom == "PDF"){
            if(self.pdfData != nil){
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PrincipalImageVCToSelectionSegue", sender: self)
                }
            }else{
                Util.showAlert("", msg: LanguageDict["fill_all_alert"] as? String)
            }
        }else{
            if(MyImageView.image != nil){
                
                DispatchQueue.main.async {
                    print("MyImageViewDidSelect")
                    self.performSegue(withIdentifier: "PrincipalImageVCToSelectionSegue", sender: self)
                }
            }else{
                Util.showAlert("", msg:  LanguageDict["fill_all_alert"] as? String)
            }
        }
        
    }
    
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "ImageToPrincipalGroupSegue"){
            let segueid = segue.destination as! GroupStandardSelectionPrincipalVC
            segueid.fromViewController = "SendImage"
            segueid.SchoolID = strSchoolID as! NSString
            segueid.selectedSchoolDictionary = selectedSchoolDictionary
            segueid.imageToSend = MyImageView.image!
            
            print("strStaffGroupStandardSelectionPrincipalVC",strSchoolID)
            print("strSchoolIDGroupStandardSelectionPrincipalVC",strStaffID)
        }else if (segue.identifier == "moreImagesSegue"){
            let moreImagesVC = segue.destination as! MoreImagesVC
            moreImagesVC.moreImagesArray = moreImagesArray
        }else if (segue.identifier == "PrincipalImageVCToSelectionSegue"){
            let segueid = segue.destination as! PrincipalGroupSelectionVC
            segueid.fromViewController = "MultipleImage"
            segueid.SchoolID = getScl as! NSString
            segueid.StaffID = getStaff as! NSString
            segueid.selectedSchoolDictionary = selectedSchoolDictionary
           
            segueid.imagesArray = imagesArray
            segueid.strFrom = strFrom
            segueid.pdfData = self.pdfData
            
            print("strStaffID1234",getStaff)
            print("strSchoolID1234",getScl)
            print("strSimagesArray234",imagesArray.count)
            print("strSselectedImages4",imgArr.count)
        }
    }
    
    func ImagePickerGallery() {
        
        if   changeImgClick == 1 {
            selectedImages.removeAll()
            imagesArray.removeAllObjects()
            imgCountShowView.isHidden = true
            imgCountLbl.isHidden = true
        }
//        var config = ImagePickerConfiguration()
//        config.doneButtonTitle = "Finish"
//        config.noImagesTitle = "Sorry! There are no images here!"
//        config.recordLocation = false
//        config.allowVideoSelection = false
//        
//        let imagePicker = ImagePickerController(configuration: config)
//        imagePicker.delegate = self
//        imagePicker.imageLimit = imageLimit
//        present(imagePicker, animated: true, completion: nil)
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
//        imagePicker.imageLimit = 6
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
                   MoreImagesButton.isHidden = true
                   ClickHereButton.isHidden = false
                   ClickImageCaptureButton.isEnabled = false
                   ClickImageCaptureButton.backgroundColor = UIColor.lightGray
               }
           }
       }
    // MARK: - ImagePickerDelegate
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        selectedImages.removeAll()
        imagesArray.removeAllObjects()
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
            
        }else{
            MoreImagesButton.isHidden = true
            ClickHereButton.isHidden = false
            ClickImageCaptureButton.isEnabled = false
            ClickImageCaptureButton.backgroundColor = UIColor.lightGray
        }
//        self.SetImagesFromPicker(imageCount: (images.count as NSNumber))
//        self.SetImagesIntoPath(images: images)
        imagePicker.dismiss(animated: true, completion: nil)
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
    
    
    func SetImagesIntoPath(images : [UIImage]){
        let countGest = UITapGestureRecognizer(target: self, action: #selector(imgListNavigate))
        imgCountShowView.addGestureRecognizer(countGest)
        print("SetImagesIntoPathCount",images.count)
       
        if(images.count == 1){
            self.MyImageView.image = images[0]
            MyImageView.isHidden = false
           
            imgCountShowView.isHidden = true
            imgCountLbl.isHidden = true
            img1Width.constant = 353
            img1Height.constant = 160
            self.ClickHereButton.isUserInteractionEnabled = false
        }else if(images.count == 2){
            self.MyImageView.image = images[0]
            self.MyImageView2.image = images[1]
            MyImageView.isHidden = false
            MyImageView2.isHidden = false
         
            imgCountShowView.isHidden = true
            img1Width.constant = 176
            img1Height.constant = 80
            self.ClickHereButton.isUserInteractionEnabled = false
            imgCountLbl.isHidden = true
        }else if(images.count == 3){
            self.MyImageView.image = images[0]
            self.MyImageView2.image = images[1]
            self.MyImageView3.image = images[2]
            img1Width.constant = 176
            img1Height.constant = 80
            MyImageView.isHidden = false
            MyImageView2.isHidden = false
            MyImageView3.isHidden = false
            self.ClickHereButton.isUserInteractionEnabled = false
            imgCountShowView.isHidden = true
            imgCountLbl.isHidden = true
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
            self.ClickHereButton.isUserInteractionEnabled = false
            if images.count > 4 {
                imgCountShowView.isHidden = false
                imgCountLbl.isHidden = false
                var getCount =  images.count - 4
                if getCount != 0 {
                    imgCountLbl.text = String(images.count - 4)
                }
                
            }
        }
    }
    
    
    
    @IBAction func imgListNavigate() {
        let vc = SenderSideImageShowViewController(nibName: nil, bundle: nil)
        vc.selectedImages = selectedImages
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    func SetImagesFromPicker(imageCount : NSNumber){
        self.MyPDFImage.isHidden = true
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
            imgCountShowView.isHidden = true
            imgCountLbl.isHidden = true
            self.MyImageView.isHidden = false
            self.MyImageView2.isHidden = false
            self.MyImageView3.isHidden = false
            self.MyImageView4.isHidden = true
        }else if(imageCount.intValue == 2){
            img1Width.constant = 176
            img1Height.constant = 80
            imgCountShowView.isHidden = true
            imgCountLbl.isHidden = true
            self.MyImageView.isHidden = false
            self.MyImageView2.isHidden = false
            self.MyImageView3.isHidden = true
            self.MyImageView4.isHidden = true
        }else if(imageCount.intValue == 1){
            img1Width.constant = 353
            img1Height.constant = 160
            imgCountShowView.isHidden = true
            imgCountLbl.isHidden = true
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
                imgCountShowView.isHidden = false
                imgCountLbl.isHidden = false
                var getCount =  imageCount.intValue - 4
                if getCount != 0 {
                    imgCountLbl.text = String(imageCount.intValue - 4)
                }
                
            }
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
            //            
            ClickHereButton.isHidden = true
            ClickImageCaptureButton.isEnabled = true
            ClickImageCaptureButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
        }else{
            
            ClickHereButton.isHidden = false
            ClickImageCaptureButton.isEnabled = false
            ClickImageCaptureButton.backgroundColor = UIColor.lightGray
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
        SendImageLabel.text = LangDict["teacher_txt_composeImg"] as? String
        descriptionTextField.placeholder = LangDict["teacher_image_hint_title"] as? String
        ClickHereButton.setTitle(LangDict["image_pdf_title_click"] as? String, for: .normal)
        ClickImageCaptureButton.setTitle(LangDict["teacher_txt_change_selection"] as? String, for: .normal)
        
    }
    
}

