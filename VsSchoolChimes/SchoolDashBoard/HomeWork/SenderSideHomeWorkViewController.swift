//
//  SenderSideHomeWorkViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/15/24.
//

import UIKit
import PhotosUI
import AWSS3
import FSCalendar

@available(iOS 14.0, *)
class SenderSideHomeWorkViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate, FSCalendarDelegate, FSCalendarDataSource {
    
    
    @IBOutlet weak var homeWorkCollectionView: UICollectionView!
    @IBOutlet weak var dateSelectView: FSCalendar!
    @IBOutlet weak var secLbl: UILabel!
    @IBOutlet weak var secView: UIView!
    @IBOutlet weak var stdLbl: UILabel!
    @IBOutlet weak var stdView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var overAllHomeWorkReportListView: UIView!
    @IBOutlet weak var overAllHomeWorkListView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var homeWorkReportsLbl: UILabel!
    @IBOutlet weak var homeworkLbl: UILabel!
    @IBOutlet weak var composeHwMsgLbl: UILabel!
    @IBOutlet weak var ContentTxtView: UITextView!
    @IBOutlet weak var hwTopicTxtFld: UITextField!
    @IBOutlet weak var homeWorkReportsSegView: UIView!
    @IBOutlet weak var homeWorkSegView: UIView!
    @IBOutlet weak var addAttachBtn: UIButton!
    
    var imageStr : [String] = []
    var currentImageCount = 0
    var selectedImages: [UIImage] = []
    var totalImageCount = 0
    var originalImagesArray = [UIImage]()
    var imageUrlArray = NSMutableArray()
    var  getImagePdfType : String!
    var convertedImagesUrlArray = NSMutableArray()
    var pdfData : Data? = nil
    let photoPickManager = PhotoPickerManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overAllHomeWorkReportListView.isHidden = true
        
        composeHwMsgLbl.text = "Upload Attachment".translated()
        
        
        homeWorkCollectionView.delegate = self
        homeWorkCollectionView.dataSource = self
        
        homeWorkCollectionView.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
      
        
        dateSelectView.isHidden = false
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backAction))
        backView.addGestureRecognizer(backGesture)
        
        let homeWorkGesture = UITapGestureRecognizer(target: self, action: #selector(selectHomeWork))
        homeWorkSegView.addGestureRecognizer(homeWorkGesture)
        
        
        let homeworkReportGesture = UITapGestureRecognizer(target: self, action: #selector(selectHomeWorkReports))
        homeWorkReportsSegView.addGestureRecognizer(homeworkReportGesture)
        
        //        let dateClick = UITapGestureRecognizer(target: self, action: #selector(calanderClikcVC))
        //        calanderView.addGestureRecognizer(dateClick)
        
        
        photoPickManager.onImagePicked = { [weak self] images in
                   guard let self = self else { return }
                   // Handle selected images here
            
           
                   for image in images {
                       print("Selected image: \(image)")
                       photoPickManager.uploadAWS(image: image)
                   }
               }
        
        
    
    }
    
    
    @IBAction func backAction() {
        dismiss(animated: true)
    }
    
    
   
    @IBAction func addAttachBtnAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
        //
        // Camera option
        let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { _ in
            self.openCamera()
        }
        alertController.addAction(cameraAction)
        
        // Gallery option
        let galleryAction = UIAlertAction(title: "Gallery".translated(), style: .default) { [self] _ in
            selectImages()
        }
        alertController.addAction(galleryAction)
        
        // PDF option
        let pdfAction = UIAlertAction(title: "PDF".translated(), style: .default) { _ in
            self.selectPDF()
        }
        alertController.addAction(pdfAction)
        
        // Voice option
        let voiceAction = UIAlertAction(title: "Voice".translated(), style: .default) { _ in
            //            self.selectPDF()
        }
        alertController.addAction(voiceAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func selectHomeWork() {
        homeWorkSegView.backgroundColor = Colornames.gradient3
        homeWorkReportsSegView.backgroundColor = .white
        homeWorkReportsLbl.textColor = .black
        homeworkLbl.textColor = .white
        overAllHomeWorkListView.isHidden = false
        overAllHomeWorkReportListView.isHidden = true
        //        homeWorkSegView.isHidden = false
        //        homeWorkReportsSegView.isHidden = true
        
    }
    
    
    
    @IBAction func selectHomeWorkReports() {
        overAllHomeWorkListView.isHidden = true
        overAllHomeWorkReportListView.isHidden = false
        homeWorkReportsSegView.backgroundColor = Colornames.gradient3
        homeWorkSegView.backgroundColor = .white
        //        homeWorkReportsSegView.isHidden = false
        //        homeWorkSegView.isHidden = true
        homeWorkReportsLbl.textColor = .white
        homeworkLbl.textColor = .black
        
    }
    
    
    
    
    
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        // Handle the selected date
        print("Selected date: \(selectedDate)")
        
        
    }
    @objc func datePicked(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        //           print("Selected Date: \(selectedDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Set the desired date format
        
        // Format the selected date
        let formattedDate = dateFormatter.string(from: selectedDate)
        
        // Print or use the formatted date
        print("Selected Date: \(formattedDate)")
        
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        // Set minimum date to 30 days ago
        let currentDate = Date()
        return Calendar.current.date(byAdding: .day, value: -30, to: currentDate) ?? currentDate
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        // Set maximum date to today
        return Date()
    }
    
    // MARK: - FSCalendarDelegate
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        // Allow selection only if the date is within the last 30 days
        let currentDate = Date()
        let minDate = Calendar.current.date(byAdding: .day, value: -30, to: currentDate)!
        return date >= minDate && date <= currentDate
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
        
        
        
        
        
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
    
    func selectPDF() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
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
    
    
    
    
    
    
    //    MARK: Aws Upload
   
    
    
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
    
    
    
    
    
    
    
   
}
    
    
         
@available(iOS 14.0, *)
extension SenderSideHomeWorkViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    
    
    
    func selectImages() {
        photoPickManager.presentPhotoPicker(from: self, selectionLimit: 3)
    }
       
       
    
       
       // MARK: - UICollectionView DataSource
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
extension SenderSideHomeWorkViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
        return CGSize(width: width, height: width)
    }
    
    
    
    
}
    
 
