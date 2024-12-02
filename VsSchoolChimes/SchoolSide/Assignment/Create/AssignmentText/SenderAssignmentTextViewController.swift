//
//  SenderAssignmentTextViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/19/24.
//

import UIKit
import DropDown
import AWSCore
import AWSS3

@available(iOS 14.0, *)
class SenderAssignmentTextViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate,UIDocumentPickerDelegate {

    
   
    @IBOutlet weak var fullTextView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var chooseImgBtn: UIButton!
    @IBOutlet weak var imageSelectView: RectangularDashedView!
    @IBOutlet weak var categoryDropDownLbl: UILabel!
    @IBOutlet weak var assignTitleTxtFld: UITextField!
    @IBOutlet weak var chooseRecipientsBtn: UIButton!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var categoryDropDownView: UIView!
    @IBOutlet weak var subDateLbl: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
   
    var selectedShow = ""
    var selectedImages: [UIImage] = []
    var getType = "Principal"
    var imageStr : [String] = []
    var currentImageCount = 0
    var schoolListArr = ["Sales","Vss","SSS","SSS2020"]
    var totalImageCount = 0
    var originalImagesArray = [UIImage]()
    var imageUrlArray = NSMutableArray()
    var  getImagePdfType : String!
    var convertedImagesUrlArray = NSMutableArray()
    var pdfData : Data? = nil
//    let imagePickerHelper = CameraUtility()
    let photoPickManager = PhotoPickerManager.shared
    let dropDown = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if selectedShow == "Text" {
            imageSelectView.isHidden = true
            fullTextView.isHidden = false
            collectionView.isHidden = true
        }else if selectedShow == "Image" {
            imageSelectView.isHidden = false
            fullTextView.isHidden = true
            collectionView.isHidden = true
        }else if selectedShow == "Pdf" {
            imageSelectView.isHidden = true
            fullTextView.isHidden = true
            collectionView.isHidden = true
        }
        
        collectionView.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
 
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVc))
        backView.addGestureRecognizer(backGesture)
        
        let categoryGesture = UITapGestureRecognizer(target: self, action: #selector(categoryDropdown))
        categoryDropDownView.addGestureRecognizer(categoryGesture)
        
        
        photoPickManager.onImagePicked = { [weak self] images in
                   guard let self = self else { return }
                   // Handle selected images here
            
            selectedImages.append(contentsOf: images)

                   for image in images {
                       print("Selected image: \(image)")

                       collectionView.isHidden = false
                       collectionView.delegate = self
                       collectionView.dataSource = self
                       photoPickManager.uploadAWS(image: image)
                   }
               }
        
        
        
        
        // Do any additional setup after loading the view.
    }

    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
       
        self.dismiss(animated: true, completion: nil)
        let selectedDate = sender.date
        print("Selected Date: \(selectedDate)")
      
        }
    @IBAction func backVc() {
        dismiss(animated: true)
    }

    @IBAction func chooseRecipientsAction(_ sender: UIButton) {
    }
    
    @IBAction  func categoryDropdown (){
        
       
        dropDown.dataSource = ["GENERAL", "CLASS WORK", "PROJECT", "RESEARCH PAPER"]
        dropDown.bottomOffset = CGPoint(x: 0, y:(categoryDropDownView.bounds.height))
        
        dropDown.direction = .bottom
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
               print("Selected item: \(item) at index: \(index)")
               
               // Update the label inside the UIView
            if let label = self?.categoryDropDownView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self!.categoryDropDownLbl.text = item
               }
               
           
            
           }
      
    }
    
    @IBAction func chooseImgBtnAction(_ sender: UIButton) {
        presentSelectionAlert()
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
        
      
       
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
   
    func selectImages() {
        photoPickManager.presentPhotoPicker(from: self, selectionLimit: 3)


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
    
    
    
    
      
    

}


@available(iOS 14.0, *)
extension SenderAssignmentTextViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    
    

       
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
extension SenderAssignmentTextViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
        return CGSize(width: width, height: width)
    }
    
    
    
    
}
    
    
//@available(iOS 14.0, *)

// MARK: School List Tv Cell
//extension SenderSideImagePdfViewController: UITableViewDelegate,UITableViewDataSource {
//
//        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            schoolListArr.count
//        }
//
//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
//            return cell
//        }
//
//}



