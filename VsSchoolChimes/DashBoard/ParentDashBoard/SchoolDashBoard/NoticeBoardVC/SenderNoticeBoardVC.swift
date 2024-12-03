//
//  SenderNoticeBoardVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 18/11/24.
//

import UIKit
import AWSCore
import AWSS3

@available(iOS 14.0, *)
class SenderNoticeBoardVC: UIViewController, UITextViewDelegate, UITextFieldDelegate,UIDocumentPickerDelegate {
    
    @IBOutlet weak var HeadingLabel: UILabel!
    
    @IBOutlet weak var FromLabel: UILabel!
    
    @IBOutlet weak var UploadAttachLbl: UILabel!
    @IBOutlet weak var ToLabel: UILabel!
    @IBOutlet weak var attachmentView: RectangularDashedView!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var UploadView: RectangularDashedView!
    
    @IBOutlet weak var FromDatePicker: UIDatePicker!
    @IBOutlet weak var ToDatePicker: UIDatePicker!
    
    @IBOutlet weak var SubmitBtn: UIButton!
    @IBOutlet weak var textview: UITextView!
    
    let photoPickManager = PhotoPickerManager.shared
    var selectedImages: [UIImage] = []
    var convertedImagesUrlArray = NSMutableArray()
    
    var imageUrlArray = NSMutableArray()
    var pdfData : Data? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FromDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        FromDatePicker.datePickerMode = .date
        FromDatePicker.minimumDate = Date()
        
        ToDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        ToDatePicker.datePickerMode = .date
        ToDatePicker.minimumDate = Date()
        
        textview.delegate = self
        textfield.delegate = self
        
        let collection = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        collectionView.register(collection, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        collectionHeight.constant = 0
        
        photoPickManager.onImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            
            selectedImages.append(contentsOf: images)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.reloadData()
            
            for image in images {
                print("Selected image: \(image)")
               // photoPickManager.uploadAWS(image: image)
            }
        }
        
        let attachmentGesture = UITapGestureRecognizer(target: self, action: #selector(presentSelectionAlert))
        
        attachmentView.addGestureRecognizer(attachmentGesture)
        
        StyleAndTranslater()
        
    }
    

    func StyleAndTranslater(){
        //MARK: Translate
        HeadingLabel.text =  "Compose NoticeBoard".translated()
        
        //MARK: UI Design
        SubmitBtn.layer.cornerRadius = Colornames.CORadius10
        textview.text = "Type content here"
        textview.textColor = .lightGray
        textview.layer.cornerRadius = Colornames.CORadius10
        textview.layer.borderWidth = 0.8
        textview.layer.borderColor = UIColor.black.cgColor
        textfield.layer.cornerRadius = Colornames.CORadius10
        textfield.layer.borderWidth = 0.8
        textfield.layer.borderColor = UIColor.black.cgColor
        
        //MARK: Label Font
        HeadingLabel.setFont(style: .header, size: FontSize.HeaderSize)
        FromLabel.setFont(style: .title, size: FontSize.TitleSize)
        UploadAttachLbl.setFont(style: .body, size: FontSize.BodySize)
        ToLabel.setFont(style: .title, size: FontSize.TitleSize)

        //MARK: Label Font
        SubmitBtn.setTitleFont(style: .body, size: FontSize.BodySize)

    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        if sender == FromDatePicker{
            ToDatePicker.minimumDate = FromDatePicker.date
        }
        self.dismiss(animated: true, completion: nil)
        let selectedDate = sender.date
        print("Selected Date: \(selectedDate)")
      
        }
     
    @IBAction func SubmitAction(_ sender: Any) {
        
        let vc = SelectRecipientVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
       
//        let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
//        //
//        // Camera option
//      
//        
////             PDF option
//        let pdfAction = UIAlertAction(title: "submit".translated(), style: .default) { [self] _ in
//            
//            let vc = NoticeBoardVc(nibName: nil, bundle: nil)
//            vc.images = selectedImages
//            
//            
//          
//            
//            dismiss(animated: true)
//          
//        }
//        alertController.addAction(pdfAction)
//        
//        // Cancel action
//        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
//        alertController.addAction(cancelAction)
//        
//        // Present the alert
//        self.present(alertController, animated: true, completion: nil)
    }

    
    @IBAction func BackClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // Dismiss the keyboard
            return true
        }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // When text changes, we update the button state
//        updateSubmitButtonState()
//        return true
//    }
//    
//    func updateSubmitButtonState() {
//        if textfield.text?.isEmpty == false && textview.text.isEmpty == false {
//            SubmitBtn.backgroundColor = .button
//        }
//        else{
//            SubmitBtn.backgroundColor = .systemGray4
//        }
//    }


   
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textfield.text?.isEmpty == false && textview.text.isEmpty == false {
            SubmitBtn.backgroundColor = .button
        }
        else{
            SubmitBtn.backgroundColor = .systemGray4
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textfield.text?.isEmpty == false && textview.text.isEmpty == false{
            SubmitBtn.backgroundColor = .button
            textview.textColor = .black
        }
        else{
            SubmitBtn.backgroundColor = .systemGray4
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textview.text == "Type content here"{
            textView.text = nil
        }
        
        if textfield.text?.isEmpty == false && textview.text.isEmpty == false{
            SubmitBtn.backgroundColor = .button
        }
        else{
            SubmitBtn.backgroundColor = .systemGray4
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textview.text.isEmpty == true{
            textview.text = "Type content here"
            textview.textColor = .lightGray
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
           if text == "\n" { // Check if the return key is pressed
               textView.resignFirstResponder() // Dismiss the keyboard
               return false // Prevent the newline character from being added
           }
           return true
       }
    
    // MARK: File Attachments Actions
    
    
    @IBAction func presentSelectionAlert() {
            let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
            //
            // Camera option
            let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
    //
//                openCamera()
            }
            alertController.addAction(cameraAction)
            
            // Gallery option
            let galleryAction = UIAlertAction(title: "Gallery".translated(), style: .default) { [self] _ in
    //
                selectImages()
    //
                       }
            alertController.addAction(galleryAction)
            
//             PDF option
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
    
    func selectImages() {
        
            photoPickManager.presentPhotoPicker(from: self, selectionLimit: 5)


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


}

@available(iOS 14.0, *)
extension SenderNoticeBoardVC : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if selectedImages.count != 0 && selectedImages.count <= 3{
            
            collectionHeight.constant = 120
        }
        
        if selectedImages.count > 3{
            collectionHeight.constant = 240
        }
        if selectedImages.count == 0{
            collectionHeight.constant = 0
        }

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

    extension SenderNoticeBoardVC: UICollectionViewDelegateFlowLayout {

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want

            return CGSize(width: width, height: width)

        }

        

        

        

        

    
    

    
    
}

