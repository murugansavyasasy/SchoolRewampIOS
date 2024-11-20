//
//  SenderSideImagePdfViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/13/24.
//

import UIKit
import PhotosUI

import AWSS3
@available(iOS 14.0, *)
class SenderSideImagePdfViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate {
//, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var stdSecBtn: UIButton!
    
    @IBOutlet weak var groupBtn: UIButton!
    
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var uploadAttacLbl: UILabel!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var staffSideOverAllView: UIView!
    @IBOutlet weak var staffSideView: UIView!
    
    @IBOutlet weak var schoolListTv: UITableView!
    
    @IBOutlet weak var sendingView: UIView!
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imgPdCollectionView: UICollectionView!
    
    @IBOutlet weak var secStudBtn: UIButton!
    
    @IBOutlet weak var imgPdfSelectView: RectangularDashedView!
    
    var selectedImages: [UIImage] = []
    var getType = "Principal"
    var imageStr : [String] = []
  
    var schoolListArr = ["Sales","Vss","SSS","SSS2020"]
    var totalImageCount = 0
    var currentImageCount = 0
    var originalImagesArray = [UIImage]()
    var imageUrlArray = NSMutableArray()
    var  getImagePdfType : String!
    var convertedImagesUrlArray = NSMutableArray()
    var pdfData : Data? = nil
//    let imagePickerHelper = CameraUtility()
    let photoPickManager = PhotoPickerManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        
//        "Standard or section" = "தரம் அல்லது பிரிவு";
//        "Section or student" = "பிரிவு அல்லது மாணவர்";
//        
        
        stdSecBtn.setTitle("Standard or section".translated(), for: .normal)
        secStudBtn.setTitle("Section or student".translated(), for: .normal)
        groupBtn.setTitle("Groups".translated(), for: .normal)
        
        
        uploadAttacLbl.text = "Upload Attachment".translated()
        titleLbl.text = "Upload Image/Pdf".translated()
        descTextField.placeholder = "Description".translated()
      
        
//        schoolListTv.dataSource = self
//        schoolListTv.delegate = self
        
        imgPdCollectionView.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        
        
        let selectedAlertGesture = UITapGestureRecognizer(target: self, action: #selector(presentSelectionAlert))
        imgPdfSelectView.addGestureRecognizer(selectedAlertGesture)
        
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backAction))
        backView.addGestureRecognizer(backGesture)
        
        staffSideView.isHidden = true
        schoolListTv.isHidden = true
        staffSideOverAllView.isHidden = true
        sendingView.isHidden = true
        
        if getType == "Principal" || getType == "Group" {
            schoolListTv.isHidden = false
            sendingView.isHidden = false
            staffSideView.isHidden = true
            staffSideOverAllView.isHidden = true
        }else {
            schoolListTv.isHidden = true
            sendingView.isHidden = false
            staffSideOverAllView.isHidden = false
            staffSideView.isHidden = false
            
        }
        
        photoPickManager.onImagePicked = { [weak self] images in
                   guard let self = self else { return }
                   // Handle selected images here
            
            selectedImages.append(contentsOf: images)
            imgPdCollectionView.delegate = self
            imgPdCollectionView.dataSource = self
           
                   for image in images {
                       print("Selected image: \(image)")
                       photoPickManager.uploadAWS(image: image)
                   }
               }
        
        
       
        
        
        
        
        
        
    }
    
    @IBAction func backAction() {
        dismiss(animated: true)
    }
    
    
    @IBAction func presentSelectionAlert() {
        let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
       
        // Camera option
        let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in

            openCamera()
        }
        alertController.addAction(cameraAction)
        
        // Gallery option
        let galleryAction = UIAlertAction(title: "Gallery".translated(), style: .default) { [self] _ in

            selectImages()

                   }
        alertController.addAction(galleryAction)
        
        // PDF option
        let pdfAction = UIAlertAction(title: "PDF".translated(), style: .default) { [self] _ in
           
            selectPDF()
        }
        alertController.addAction(pdfAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
   


      
    
    
    //    MARK: Handle Select Camera,Pdf,Image
    @IBAction func openCamera() {
        // Check if the camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true // Allows editing of the captured image
            present(imagePicker, animated: true, completion: nil)
        } else {
            // Camera is not available, show an alert
            let alert = UIAlertController(title: "Camera Not Available".translated(), message: "This device has no camera.".translated(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".translated(), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
   
    // Handle the image once it has been captured
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            // Use the captured image
            // For example, display it in an image view or save it
            print("Captured Image: \(image)")
            self.selectedImages.append(image)
        } else if let image = info[.originalImage] as? UIImage {
            print("Captured Image: \(image)")
            self.selectedImages.append(image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Handle cancellation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func selectPDF() {

        print("SELECT PDF")
        

        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: URL) {

        
        
        
        let fileurl: URL = urls as URL
        let filename = urls.lastPathComponent
        let fileextension = urls.pathExtension
        print("URL: \(fileurl)", "NAME: \(filename)", "EXTENSION: \(fileextension)")
        
 
        let imageData = NSData(contentsOf: urls)
        
        
        
        
        do {
            pdfData = try Data(contentsOf: urls, options: NSData.ReadingOptions())
            uploadPDFFileToAWS(pdfData: pdfData!)
            
        } catch {
            print("set PDF filer error : ", error)
            
        }
           
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
 
    
    
    func uploadPDFFileToAWS(pdfData : Data){
        let S3BucketName = AwsCredentials.bucketNameIndia
        let CognitoPoolID = AwsCredentials.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".pdf")
        
        let ext = imageName as String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let  currentDate =   dateFormatter.string(from: Date())
        
        
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
        uploadRequest?.key =  currentDate +  "/" + "File_" + ext
        uploadRequest?.bucket = S3BucketName
        
        uploadRequest?.contentType = "application/pdf"
        
        
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
                    self.imageUrlArray.add(imageDict)
                    self.convertedImagesUrlArray = self.imageUrlArray
                    
                    
                    
                    
                 
                }
            }
            else {
                
              
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    
    
    
  
         
           
    
            
            
    
    
//    MARK: Button Action
    
    
    @IBAction func toStaffBtnAction(_ sender: UIButton) {
        
    }
    
    @IBAction func toStdSecBtnAction(_ sender: UIButton) {
    }
    
    
    @IBAction func toSecStudBtnAction(_ sender: UIButton) {
    }
    
}

@available(iOS 14.0, *)
extension SenderSideImagePdfViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    
    
    
    func selectImages() {
        photoPickManager.presentPhotoPicker(from: self, selectionLimit: 3)


       }
       
     
 
    
    
    
       
       // MARK: - UICollectionView DataSource
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           print("selectedImagescount",selectedImages.count)
           return selectedImages.count
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
           cell.imageViews.image = selectedImages[indexPath.item]
           return cell
       }
       
       // MARK: - UICollectionView Delegate
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           // Delete the selected image
           selectedImages.remove(at: indexPath.item)
           collectionView.deleteItems(at: [indexPath])
       }
       
       
    
}

@available(iOS 14.0, *)
extension SenderSideImagePdfViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
        return CGSize(width: width, height: width)
    }
    
    
    
    
}
    
    
//@available(iOS 14.0, *)
//class SenderSideImagePdfViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate {
////, UITableViewDataSource, UITableViewDelegate  {
//    
//    @IBOutlet weak var stdSecBtn: UIButton!
//    
//    @IBOutlet weak var groupBtn: UIButton!
//    
//    @IBOutlet weak var descTextField: UITextField!
//    @IBOutlet weak var uploadAttacLbl: UILabel!
//    
//    @IBOutlet weak var titleLbl: UILabel!
//    
//    @IBOutlet weak var staffSideOverAllView: UIView!
//    @IBOutlet weak var staffSideView: UIView!
//    
//    @IBOutlet weak var schoolListTv: UITableView!
//    
//    @IBOutlet weak var sendingView: UIView!
//    
//    
//    @IBOutlet weak var backView: UIView!
//    @IBOutlet weak var imgPdCollectionView: UICollectionView!
//    
//    @IBOutlet weak var secStudBtn: UIButton!
//    
//    @IBOutlet weak var imgPdfSelectView: RectangularDashedView!
//    
//    var selectedImages: [UIImage] = []
//    var getType = "Principal"
//    var imageStr : [String] = []
//    var currentImageCount = 0
//    var schoolListArr = ["Sales","Vss","SSS","SSS2020"]
//    var totalImageCount = 0
//    var originalImagesArray = [UIImage]()
//    var imageUrlArray = NSMutableArray()
//    var  getImagePdfType : String!
//    var convertedImagesUrlArray = NSMutableArray()
//    var pdfData : Data? = nil
//    let imagePickerHelper = CameraUtility()
//    let photoPickerManager = PhotoPickerManager()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
////        
////        "Standard or section" = "தரம் அல்லது பிரிவு";
////        "Section or student" = "பிரிவு அல்லது மாணவர்";
////        
//        
//        stdSecBtn.setTitle("Standard or section".translated(), for: .normal)
//        secStudBtn.setTitle("Section or student".translated(), for: .normal)
//        groupBtn.setTitle("Groups".translated(), for: .normal)
//        
//        
//        uploadAttacLbl.text = "Upload Attachment".translated()
//        titleLbl.text = "Upload Image/Pdf".translated()
//        descTextField.placeholder = "Description".translated()
//        imgPdCollectionView.delegate = self
//        imgPdCollectionView.dataSource = self
//        
////        schoolListTv.dataSource = self
////        schoolListTv.delegate = self
//        
//        imgPdCollectionView.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
//        
//        
//        
//        let selectedAlertGesture = UITapGestureRecognizer(target: self, action: #selector(presentSelectionAlert))
//        imgPdfSelectView.addGestureRecognizer(selectedAlertGesture)
//        
//        
//        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backAction))
//        backView.addGestureRecognizer(backGesture)
//        
//        staffSideView.isHidden = true
//        schoolListTv.isHidden = true
//        staffSideOverAllView.isHidden = true
//        sendingView.isHidden = true
//        
//        if getType == "Principal" || getType == "Group" {
//            schoolListTv.isHidden = false
//            sendingView.isHidden = false
//            staffSideView.isHidden = true
//            staffSideOverAllView.isHidden = true
//        }else {
//            schoolListTv.isHidden = true
//            sendingView.isHidden = false
//            staffSideOverAllView.isHidden = false
//            staffSideView.isHidden = false
//            
//        }
//        
//        photoPickerManager.onImagePicked = { [weak self] images in
//                   guard let self = self else { return }
//                   // Handle selected images here
//            
//           
//                   for image in images {
//                       print("Selected image: \(image)")
//                       photoPickerManager.uploadAWS(image: image)
//                   }
//               }
//        
//        
//        
//      
//        imagePickerHelper.onImagesPicked = { images in
//            // Handle the selected images here
//            print("Selected images: \(images)")
//        }
//        
//        
//        
//        
//        
//        
//        
//        
//    }
//    
//    @IBAction func backAction() {
//        dismiss(animated: true)
//    }
//    
//    
//    @IBAction func presentSelectionAlert() {
//        let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
//        //
//        // Camera option
//        let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
////            CameraUtility.openCamera(from: self)
//            openCamera()
//        }
//        alertController.addAction(cameraAction)
//        
//        // Gallery option
//        let galleryAction = UIAlertAction(title: "Gallery".translated(), style: .default) { [self] _ in
////            let cameraUtility = CameraUtility()
//            selectImages()
////            cameraUtility.selectImages(from: self)
//                   }
//        alertController.addAction(galleryAction)
//        
//        // PDF option
//        let pdfAction = UIAlertAction(title: "PDF".translated(), style: .default) { [self] _ in
////            CameraUtility.selectPDF(from: self)
//            selectPDF()
//        }
//        alertController.addAction(pdfAction)
//        
//        // Cancel action
//        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
//        alertController.addAction(cancelAction)
//        
//        // Present the alert
//        self.present(alertController, animated: true, completion: nil)
//    }
//    
//   
//
//
//      
//    
//    
//    //    MARK: Handle Select Camera,Pdf,Image
//    @IBAction func openCamera() {
//        // Check if the camera is available
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = .camera
//            imagePicker.allowsEditing = true // Allows editing of the captured image
//            present(imagePicker, animated: true, completion: nil)
//        } else {
//            // Camera is not available, show an alert
//            let alert = UIAlertController(title: "Camera Not Available".translated(), message: "This device has no camera.".translated(), preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK".translated(), style: .default, handler: nil))
//            present(alert, animated: true, completion: nil)
//        }
//    }
//    
//    func selectPDF() {
//        photoPickerManager.shared.documentPicker(controller, didPickDocumentAt: selectedURL) { (pdfData, filename, fileExtension) in
//            if let data = pdfData {
//                print("PDF Data: \(data)")
//                let pdfData = Data() // Your PDF Data here
//                photoPickerManager.shared.uploadPDFFileToAWS(pdfData: pdfData) { (url) in
//                    if let uploadedURL = url {
//                        print("File uploaded to: \(uploadedURL)")
//                    }
//                }
//                print("Filename: \(filename ?? "Unknown")")
//            }
//        }
//    }
//    // Handle the image once it has been captured
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[.editedImage] as? UIImage {
//            // Use the captured image
//            // For example, display it in an image view or save it
//            print("Captured Image: \(image)")
//            self.selectedImages.append(image)
//        } else if let image = info[.originalImage] as? UIImage {
//            print("Captured Image: \(image)")
//            self.selectedImages.append(image)
//        }
//        dismiss(animated: true, completion: nil)
//    }
//    
//    // Handle cancellation
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    
//    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: URL) {
//
//        
//        
//        
//        let fileurl: URL = urls as URL
//        let filename = urls.lastPathComponent
//        let fileextension = urls.pathExtension
//        print("URL: \(fileurl)", "NAME: \(filename)", "EXTENSION: \(fileextension)")
//        
// 
//        let imageData = NSData(contentsOf: urls)
//        
//        
//        
//        
//        do {
//            pdfData = try Data(contentsOf: urls, options: NSData.ReadingOptions())
//            uploadPDFFileToAWS(pdfData: pdfData!)
//            
//        } catch {
//            print("set PDF filer error : ", error)
//            
//        }
//           
//        
//    }
//    
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//    
//    
//    
//    
//    
//    
////    MARK: Aws Upload
//    func uploadAWS(image : UIImage){
//    
//        let S3BucketName = AwsCredentials.bucketNameIndia
//        let CognitoPoolID = AwsCredentials.CognitoPoolID
//        let Region = AWSRegionType.APSouth1
//        
//        
//      
//        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
//        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
//        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".png")
//        
//        
//        
//        let dateFormatter = DateFormatter()
//        
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        
//        let  currentDate =   dateFormatter.string(from: Date())
//        
//        let ext = imageName as String
//        
//        let fileName = imageNameWithoutExtension
//        let fileType = ".jpg"
//        
//        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
//        let data = image.jpegData(compressionQuality: 0.9)
//        do {
//            try data?.write(to: imageURL)
//        }
//        catch {}
//        
//        print(imageURL)
//        
//        let uploadRequest = AWSS3TransferManagerUploadRequest()
//        uploadRequest?.body = imageURL
//        uploadRequest?.key =   currentDate +  "/" + "File_" + ext
//        uploadRequest?.bucket = S3BucketName
//        
//        if getImagePdfType == "Image" {
//            uploadRequest?.contentType = "image/png"
//        } else{
//            uploadRequest?.contentType = "image/png"
//        }
//      
//        
//        let transferManager = AWSS3TransferManager.default()
//        transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in
//            
//            if let error = task.error {
//                print("Upload failed : (\(error))")
//            }
//            var imageFilePath = NSMutableArray()
//            if task.result != nil {
//                let url = AWSS3.default().configuration.endpoint.url
//                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
//                if let absoluteString = publicURL?.absoluteString {
//                    print("Uploaded to:\(absoluteString)")
//                    
//                  
//                    
//                    
//                    imageStr.append(absoluteString)
//                  
//                    
//                    let imageDicthome = NSMutableDictionary()
//                    imageDicthome["path"] = absoluteString
//                    imageDicthome["type"] = "IMAGE"
//                    let imageDict = NSMutableDictionary()
//                    var emptyDictionary = [String: String]()
//                    
//                    imageFilePath.add(imageDicthome)
//                    
//                    
//                    
//                
//                    
//                    self.currentImageCount = self.currentImageCount + 1
//                    if self.currentImageCount < self.totalImageCount{
//                        DispatchQueue.main.async {
//                            self.getImageURL(images: self.originalImagesArray)
//                        }
//                    }else{
//                        self.convertedImagesUrlArray = self.imageUrlArray
//                        
//                        
//                    }
//                }
//            }
//            
//            return nil
//        }
//       
//    }
//    
//    
//    func uploadPDFFileToAWS(pdfData : Data){
//        let S3BucketName = AwsCredentials.bucketNameIndia
//        let CognitoPoolID = AwsCredentials.CognitoPoolID
//        let Region = AWSRegionType.APSouth1
//        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
//        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
//        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".pdf")
//        
//        let ext = imageName as String
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        
//        let  currentDate =   dateFormatter.string(from: Date())
//        
//        
//        let fileName = imageNameWithoutExtension
//        let fileType = ".pdf"
//        
//        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
//        
//        do {
//            try pdfData.write(to: imageURL)
//        }
//        catch {}
//        
//        print(imageURL)
//        
//        let uploadRequest = AWSS3TransferManagerUploadRequest()
//        uploadRequest?.body = imageURL
//        uploadRequest?.key =  currentDate +  "/" + "File_" + ext
//        uploadRequest?.bucket = S3BucketName
//        
//        uploadRequest?.contentType = "application/pdf"
//        
//        
//        let transferManager = AWSS3TransferManager.default()
//        transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in
//            
//            if let error = task.error {
//                print("Upload failed : (\(error))")
//                
//              
//            }
//            
//            if task.result != nil {
//                let url = AWSS3.default().configuration.endpoint.url
//                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
//                if let absoluteString = publicURL?.absoluteString {
//                    print("Uploaded to:\(absoluteString)")
//                  
//                    let imageDict = NSMutableDictionary()
//                    imageDict["FileName"] = absoluteString
//                    self.imageUrlArray.add(imageDict)
//                    self.convertedImagesUrlArray = self.imageUrlArray
//                    
//                    
//                    
//                    
//                 
//                }
//            }
//            else {
//                
//              
//                print("Unexpected empty result.")
//            }
//            return nil
//        }
//    }
//    
//    
//    
//    
//  
//        
//    
//    func getImageURL(images : [UIImage]){
//        
//       
//       
//        self.originalImagesArray = images
//        self.totalImageCount = images.count
//        if currentImageCount < images.count{
//            self.uploadAWS(image: images[currentImageCount])
//        }
//    }
//    
//    
//    
//         
//           
//    
//            
//            
//    
//    
////    MARK: Button Action
//    
//    
//    @IBAction func toStaffBtnAction(_ sender: UIButton) {
//        
//    }
//    
//    @IBAction func toStdSecBtnAction(_ sender: UIButton) {
//    }
//    
//    
//    @IBAction func toSecStudBtnAction(_ sender: UIButton) {
//    }
//    
//}
//
//@available(iOS 14.0, *)
//extension SenderSideImagePdfViewController : UICollectionViewDelegate,UICollectionViewDataSource,PHPickerViewControllerDelegate{
//    
//    
//    
//    func selectImages() {
//        photoPickerManager.presentPhotoPicker(from: self, selectionLimit: 3)
//
////           var config = PHPickerConfiguration()
////           config.selectionLimit = 5  // Limit selection to 5 images
////           config.filter = .images    // Only allow images
////           
////           let picker = PHPickerViewController(configuration: config)
////           picker.delegate = self
////           present(picker, animated: true, completion: nil)
//       }
//       
//       // MARK: - PHPickerViewControllerDelegate
//       func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//           picker.dismiss(animated: true, completion: nil)
//           
//           for result in results {
//               if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
//                   result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
//                       guard let self = self, let image = image as? UIImage, error == nil else { return }
//                       DispatchQueue.main.async { [self] in
//                           self.selectedImages.append(image)
//                           self.getImagePdfType = "Image"
//                           self.uploadAWS(image: image)
////                           self.convertAssetToImages()
//                           self.imgPdCollectionView.reloadData()
//                       }
//                   }
//               }
//           }
//       }
//    
//    
// 
//    
//    
//    
//       
//       // MARK: - UICollectionView DataSource
//       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//           return selectedImages.count
//       }
//       
//       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
//           cell.imageViews.image = selectedImages[indexPath.item]
//           return cell
//       }
//       
//       // MARK: - UICollectionView Delegate
//       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//           // Delete the selected image
//           selectedImages.remove(at: indexPath.item)
//           collectionView.deleteItems(at: [indexPath])
//       }
//       
//       
//    
//}
//
//@available(iOS 14.0, *)
//extension SenderSideImagePdfViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
//        return CGSize(width: width, height: width)
//    }
//    
//    
//    
//    
//}
//    
//    
////@available(iOS 14.0, *)
//
//// MARK: School List Tv Cell
////extension SenderSideImagePdfViewController: UITableViewDelegate,UITableViewDataSource {
////        
////        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////            schoolListArr.count
////        }
////        
////        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////            let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
////            return cell
////        }
////  
////}
//
//
//
