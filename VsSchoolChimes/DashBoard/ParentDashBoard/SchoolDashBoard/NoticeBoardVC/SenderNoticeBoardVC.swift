//
//  SenderNoticeBoardVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 18/11/24.
//

import UIKit
import AWSCore
import AWSS3
import SDWebImage
import SwiftUI

@available(iOS 14.0, *)
class SenderNoticeBoardVC: UIViewController, UITextViewDelegate, UITextFieldDelegate,UIDocumentPickerDelegate, DeleteImge {
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        costomView.imageCollectionview.reloadData()
    }
    
    
    @IBOutlet weak var HeadingLabel: UILabel!
    @IBOutlet weak var textview: UITextView!
    
    let photoPickManager = PhotoPickerManager.shared
    var selectedImages: [UIImage] = []
    var convertedImagesUrlArray = NSMutableArray()
    var dateSelection = false
    var imageUrlArray = NSMutableArray()
    var pdfData : Data? = nil
    var placeholderLabel: UILabel!
    var doneButton: UIButton!
    var datePicker: UIDatePicker!
    var activeButton: UIButton?
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var setTitle: UILabel!
    @IBOutlet weak var enterDetails: UILabel!
    @IBOutlet weak var outerTxt: UIView!
    @IBOutlet weak var contentCount: UILabel!
    @IBOutlet weak var calanderBtn: HalfColorButton!
    @IBOutlet weak var calanderBtn2: HalfColorButton!
    @IBOutlet weak var fromdateBtn: UIButton!
    @IBOutlet weak var todateBtn: UIButton!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var costomView: ImageSelection!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var addPhotoLbl: UILabel!
    @IBOutlet weak var createDateLbl: UILabel!
    
    @IBOutlet weak var toDate: UILabel!
    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var eventTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupdatePicker()
        setInitialButtonTitles()
        setupPlaceholder()
        keyboardDionebtn()
        
        
        costomView.imageCollectionview.delegate = self
        costomView.imageCollectionview.dataSource = self
        outerTxt.layer.cornerRadius = 10
        outerTxt.layer.borderWidth = 0.5
        outerTxt.layer.borderColor = UIColor.black.cgColor
        
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        
        calanderBtn.layer.borderWidth = 1 // Border width
        calanderBtn.layer.borderColor = UIColor.gray.cgColor // Border color
        calanderBtn2.layer.borderWidth = 1 // Border width
        calanderBtn2.layer.borderColor = UIColor.gray.cgColor // Border color
        
        textview.delegate = self
        
        let collection = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        costomView.imageCollectionview.register(collection, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        photoPickManager.onImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            
            selectedImages.append(contentsOf: images)
            costomView.imageCollectionview.reloadData()
            //            for image in images {
            //                print("Selected image: \(image)")
            //                photoPickManager.uploadAWS(image: image)
            //            }
        }
        
        
       
        
    }
    //MARK: BUTTON TITLE CURRANT TIME
    func setInitialButtonTitles() {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        let dateOnlyFormatter = DateFormatter()
        
        // Set the date format (e.g., "Tue 3 Dec 2024")
        dateFormatter.dateFormat = "EEE d MMM yyyy"
        dateOnlyFormatter.dateFormat = "EEE d"
        
        // Set the time format (e.g., "4:30 PM")
        timeFormatter.timeStyle = .short
        
        // Get the current date and time
        let currentDate = Date() // Current date and time
        let nextHourTime = Calendar.current.date(byAdding: .hour, value: 0, to: currentDate) ?? currentDate
        
        // Format the date and time
        let formattedDate = dateFormatter.string(from: currentDate)   // "Tue 3 Dec 2024"
        let formattedTime = timeFormatter.string(from: nextHourTime)  // "4:30 PM"
        let dateOnly = dateOnlyFormatter.string(from: nextHourTime)   // "Tue 3"
        
        // Set the formatted time to the time button
        fromdateBtn.setTitle(formattedDate, for: .normal)
        todateBtn.setTitle(formattedDate, for: .normal)
        // Set the date and time to the date button
        dateSet(formattedDate, dateOnly,dateOnly)
    }
    
    func dateSet(_ date: String, _ splitDate: String,_ currectndate:String) {
        
        
        // Fonts for different parts
        let weekdayFont = UIFont.systemFont(ofSize: 12) // Smaller font for weekday
        let dayFont = UIFont.boldSystemFont(ofSize: 22)    // Larger font for day number
        
        // Split the date into components
        let components = splitDate.split(separator: " ")
        guard let weekday = components.first else {
            print("Error: No weekday found in splitDate")
            return
        }
        let day = components.count > 1 ? components[1] : ""
        
        // Create an attributed string
        let attributedText = NSMutableAttributedString()
        
        // Add the weekday part
        attributedText.append(NSAttributedString(string: "\(weekday)\n", attributes: [
            .font: weekdayFont,
            .foregroundColor: UIColor.darkGray // Optional: Set weekday color
        ]))
        
        // Add the day part
        attributedText.append(NSAttributedString(string: "\(day)", attributes: [
            .font: dayFont,
            .foregroundColor: UIColor.black // Optional: Set day color
        ]))
        
        // Set paragraph style for centered alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        if currectndate != ""{
            toDateLbl.attributedText = attributedText
            fromDateLbl.attributedText = attributedText
        }
        
        if dateSelection == false{
            todateBtn.setTitle(date, for: .normal)
            toDateLbl.attributedText = attributedText
            
        }else{
            fromDateLbl.attributedText = attributedText
            fromdateBtn.setTitle(date, for: .normal)
        }
        //        pickerDateLbl.numberOfLines = 0
    }
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "EnterTextHere".translated()
        placeholderLabel.font = textview.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8) // Adjust padding
        textview.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !textview.text.isEmpty // Hide if text exists
    }
    func setupdatePicker() {
        // Initialize the date picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker.backgroundColor = .white
        datePicker.isHidden = true // Initially hidden
        // Initialize and configure Done button
        doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.isHidden = true
        doneButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        self.view.addSubview(doneButton)
    }
    @objc func doneButtonTapped() {
        let dateFormatter = DateFormatter()
        let dateOnlyFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE d MMM yyyy"
        // Set the date-only format (e.g., "Tue 3")
        dateOnlyFormatter.dateFormat = "EEE d"
        // Get the selected date and time
        let selectedDate = datePicker.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        let dateOnly = dateOnlyFormatter.string(from: selectedDate)   // "Tue 3"
        
        // Pass the formatted values to the dateSet method
        dateSet(formattedDate, dateOnly,"")
        
        datePicker.isHidden = true
        doneButton.isHidden = true
        activeButton = nil
    }
    func StyleAndTranslater(){
        //MARK: Translate
        HeadingLabel.text =  "Compose NoticeBoard".translated()
       
        
        //MARK: UI Design
        //        SubmitBtn.layer.cornerRadius = Colornames.CORadius10
        //        textfield.layer.cornerRadius = Colornames.CORadius10
        //        textfield.layer.borderWidth = 0.8
        //        textfield.layer.borderColor = UIColor.black.cgColor
        
        //MARK: Label Font
        HeadingLabel.setFont(style: .header, size: FontSize.HeaderSize)
        toDate.setFont(style: .body, size: FontSize.BodySize)
        toDate.setFont(style: .body, size: FontSize.BodySize)
        createDateLbl.setFont(style: .body, size: FontSize.BodySize)
        addPhotoLbl.setFont(style: .body, size: FontSize.BodySize)
        enterDetails.setFont(style: .body, size: FontSize.BodySize)
        setTitle.setFont(style: .body, size: FontSize.BodySize)
        
        
        todateBtn.setTitleFont(style: .body, size: 12)
        fromdateBtn.setTitleFont(style: .body, size: 12)
        addPhotoLbl.text = "AddPhotos".translated()
        
        setTitle.text = "EventTitle".translated()
        eventTxt.placeholder = "egYogaEvent".translated()
        enterDetails.text = "EventDetails".translated()
        setAttributedText(for: addPhotoLbl, with: "AddPhotos1".translated(), firstString: "AddPhotos".translated(), secondString: "Optional".translated(), color1: .black, color2: .lightGray)
        
        //MARK: Label Font
        //        SubmitBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
    }
    
    func SendNotice(){
        textview.text = "Type content here"
        textfield.text = "Type News Topiccc"
        textview.textColor = .lightGray
    }
    
    func resendFromHistory(){
        textview.text = desc
        textview.textColor = .black
        textfield.text = title1
        SubmitBtn.backgroundColor = .button
        code = 1
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
        
    }
    
    @IBAction func fromDate(_ sender: UIButton) {
        showTimePicker(for: sender, date: true)
        dateSelection = true
    }
    
    @IBAction func toDate(_ sender: UIButton) {
        showTimePicker(for: sender, date: false)
        dateSelection = false
    }
    
    
    @IBAction func BackClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
    
    func keyboardDionebtn(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        //        placeTxt.inputAccessoryView = toolbar
        //        eventTxt.inputAccessoryView = toolbar
        //        contentTxtView.inputAccessoryView = toolbar
    }
    @objc func doneKeyboard() {
        view.endEditing(true)  // Dismiss the keyboard
    }
    
    
    func setAttributedText(for label: UILabel, with text: String, firstString: String, secondString: String, color1: UIColor, color2: UIColor) {
        print(text)
        print(firstString)
        print(secondString)
        guard text.contains(firstString), text.contains(secondString) else { return } // Ensure both substrings exist in the text
        
        // Find ranges of the substrings
        let firstRange = (text as NSString).range(of: firstString)
        let secondRange = (text as NSString).range(of: secondString)
        
        // Create a mutable attributed string
        let attributedString = NSMutableAttributedString(string: text)
        
        // Apply colors to the respective ranges
        attributedString.addAttribute(.foregroundColor, value: color1, range: firstRange)
        attributedString.addAttribute(.foregroundColor, value: color2, range: secondRange)
        
        // Set the attributed string to the label
        label.attributedText = attributedString
    }
    
    
    func showTimePicker(for button: UIButton, date: Bool) {
        activeButton = button // Track which button is being updated
        
        // Position the time picker or date picker below the button
        let buttonFrame = button.convert(button.bounds, to: self.view)
        // Show the date picker
        datePicker.isHidden = false
        doneButton.isHidden = false
        // Set the frame for the datePicker and make sure it’s within bounds
        let pickerYPosition = buttonFrame.minY - 310
        datePicker.frame = CGRect(x: (self.view.frame.width - 300) / 2, y: pickerYPosition, width: 300, height: 300)
        
        // Set appearance for datePicker
        datePicker.backgroundColor = .white
        datePicker.layer.shadowColor = UIColor.black.cgColor
        datePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        datePicker.layer.shadowRadius = 5
        datePicker.layer.shadowOpacity = 0.3
        datePicker.layer.cornerRadius = 20
        
        // Position the Done button at the bottom-right of the picker
        doneButton.frame = CGRect(x: datePicker.frame.maxX - 80, y: pickerYPosition + datePicker.frame.height - 40, width: 70, height: 30)
        
        // Add datePicker to the view (ensure it’s in the view hierarchy)
        self.view.addSubview(datePicker)
        self.view.addSubview(doneButton)
        
        
    }
    
    //    func textViewDidBeginEditing(_ textView: UITextView) {
    //
    //        if textview.text == "Type content here"{
    //            textView.text = nil
    //        }
    //
    //        if textfield.text?.isEmpty == false && textview.text.isEmpty == false{
    //            SubmitBtn.backgroundColor = .button
    //        }
    //        else{
    //            SubmitBtn.backgroundColor = .systemGray4
    //        }
    //    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textview.text.isEmpty == true{
            textview.text = "Type content here"
            textview.textColor = .lightGray
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty // Toggle visibility
        adjustTextViewHeightWithConstraint(textView)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Calculate the new length of the text
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        if updatedText.count <= 500 {
            contentCount.text = "\(updatedText.count) of 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "Alert", message: "Reach Your Limit", on: self)
            //            contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    
    func adjustTextViewHeightWithConstraint(_ textView: UITextView) {
        // Calculate the size needed for the text
        if textView.text.isEmpty {
            // Set default height to 60
            textViewHeightConstraint.constant = 60
        } else {
            // Calculate the size needed for the text
            let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            textViewHeightConstraint.constant = sizeThatFits.height
        }
        textView.layoutIfNeeded() // Refresh the layout
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
extension SenderNoticeBoardVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    //
    //    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //
    //        if selectedImages.count != 0 && selectedImages.count <= 3{
    //
    //            collectionHeight.constant = 120
    //        }
    //
    //        if selectedImages.count > 3{
    //            collectionHeight.constant = 240
    //        }
    //        if selectedImages.count == 0{
    //            collectionHeight.constant = 0
    //        }
    //
    //               return selectedImages.count
    //
    //
    //           }
    //
    //
    //
    //           func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //
    //               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
    //
    //               cell.imageViews.image = selectedImages[indexPath.item]
    //
    //               return cell
    //
    //           }
    //
    //
    //
    //           // MARK: - UICollectionView Delegate
    //
    //           func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //
    //               // Delete the selected image
    //
    //               selectedImages.remove(at: indexPath.item)
    //
    //               collectionView.deleteItems(at: [indexPath])
    //
    //           }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = costomView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: "AttachmentCVCell", for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        }else{
            let cell = costomView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: "ImageCvCell", for: indexPath) as! ImageCvCell
            cell.delegate = self
            cell.deleteBtn.tag = indexPath.item - 1
            if selectedImages.count > indexPath.item - 1 {
                // Assign the image starting from the second image in the selectedImages array
                cell.imageViews.image = selectedImages[indexPath.item - 1]
            } else {
                cell.imageViews.image = nil
            }
            if selectedImages.count <= 2{
                collectionViewHeght.constant = 120
            }else{
                collectionViewHeght.constant = 220
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (costomView.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
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
        }else{
            if selectedImages.count > indexPath.item - 1 {
                let vc = PreviewImageVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                
                // Safe unwrapping of imgView before assigning
                vc.img = selectedImages[indexPath.item - 1]
                //
                present(vc, animated: true)
            }

               

            

        }

        

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {

            controller.dismiss(animated: true, completion: nil)

        }


}

@available(iOS 14.0, *)
extension SenderNoticeBoardVC : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if code == 0{
            if selectedImages.count != 0 && selectedImages.count <= 3{
                
                collectionHeight.constant = 120
            }
            
            else if selectedImages.count > 3{
                collectionHeight.constant = 240
            }
            
            else if selectedImages.count == 0 {
                collectionHeight.constant = 0
            }
            
            return selectedImages.count
        }

        else{
            
            if items.count != 0 && items.count <= 3{
                
                collectionHeight.constant = 120
            }
            
            else if items.count > 3{
                collectionHeight.constant = 240
            }
            
            else if items.count == 0{
                collectionHeight.constant = 0
            }
            return items.count+selectedImages.count
        }
               

           }

           

           func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
               
               print("itemsCount",items.count)

               if code == 0{
                   cell.imageViews.image = selectedImages[indexPath.item]
                   cell.TrashIcon.isHidden = false
               }else {
                   print("fsghwdgvdhbdvgdgvegvgveh")
                   
                   if indexPath.item < items.count {
                       cell.TrashIcon.isHidden = true
                       cell.imageViews.sd_setImage(with: URL(string: items[indexPath.item] ?? ""), placeholderImage: UIImage(named: ""))
                   }
                   if indexPath.item >= items.count{
                       
                       var selindex = indexPath.item - items.count
                       cell.imageViews.image = selectedImages[selindex]
//                       let count = selectedImages.count
//                       print("Selected Images Count",selectedImages.count)
//                       for i in 0..<count {
//                           print("indexindex",i)
//                           cell.imageViews.image = selectedImages[i]
//                           cell.TrashIcon.isHidden = false
//                       }

                   }
                
               }

               return cell

           }

           

           // MARK: - UICollectionView Delegate

           func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

               // Delete the selected image
               if indexPath.item >= items.count{
                   
                   var selindex = indexPath.item - items.count
                   
                   //selectedImages.remove(at: indexPath.item)
                   selectedImages.remove(at: selindex)
                   
                   collectionView.deleteItems(at: [indexPath])
               }

           }

           

           

        

    }



    @available(iOS 14.0, *)

    extension SenderNoticeBoardVC: UICollectionViewDelegateFlowLayout {

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want

            return CGSize(width: width, height: width)

        }
    }
    
}

