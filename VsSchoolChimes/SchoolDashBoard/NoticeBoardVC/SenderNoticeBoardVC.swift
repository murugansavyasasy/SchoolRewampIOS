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
class SenderNoticeBoardVC: UIViewController, UITextViewDelegate, UITextFieldDelegate,UIDocumentPickerDelegate, DeleteImge, Datepicker {
    
    func date(date: String) {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yy"
            let DayDate = dateFormatter.date(from: date)!
            // Change to output format
            dateFormatter.dateFormat = "EEE dd"
            let outputDateString = dateFormatter.string(from: DayDate)
            
            if dateSelection == true{
                fromdateBtn.setTitle(date, for: .normal)
                setFormattedDate(outputDateString, label: fromDateLbl)

            }else{
                todateBtn.setTitle(date, for: .normal)
                setFormattedDate(outputDateString, label: toDateLbl)
            }
        }
    
  
    @IBOutlet weak var HeadingLabel: UILabel!
    @IBOutlet weak var textview: UITextView!
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
    var Title = ""
    var desript = ""
    var url : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupdatePicker()
        setInitialButtonTitles()
        setupPlaceholder()
        keyboardDionebtn()
        StyleAndTranslater()
        imageSelection()
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
        
        
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    override func viewWillAppear(_ animated: Bool) {
        if desript != ""{
            textview.text = desript
            placeholderLabel.isHidden = !Title.isEmpty
            contentCount.text = "\(textview.text.count) of 500"
        }
        if Title != ""{
            eventTxt.text =  Title
            
        }
    }
    func imageSelection(){
        photoPickManager.onImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            selectedImages.append(contentsOf: images)
            
            print("selectedImage", selectedImages)
         /*   let images = images*/ // Array of images
            let presignedURLs = ["https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/2024-12-24/6063/file%3A///private/var/mobile/Containers/Data/Application/00E089B8-D267-441E-AAD4-3E35A102A925/tmp/vc_-5851419880403543277.png?Content-Type=image&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA2NK3YMVHFMO66GYP%2F20241224%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Date=20241224T072154Z&X-Amz-Expires=90&X-Amz-Signature=786c9921f6135bf05cfd40390a3d62b43972895f224ac83c26dee7de1effce6a&X-Amz-SignedHeaders=host"] // Corresponding presigned URLs

            photoPickManager.getImageURLUsingPresignedURL(images: images, presignedURLs: presignedURLs) { uploadedURLs in
                print("Uploaded image URLs: \(uploadedURLs)")
            }

            
            //            for image in images {
            //                print("Selected image: \(image)")
//                            photoPickManager.uploadAWS(image: image)
            //            }
            
            
            
            costomView.imageCollectionview.reloadData()
        }
        photoPickManager.pdfUrl = { [weak self] pdfurl in
            guard let self = self else { return }
            selectedImages.removeAll()
            url = pdfurl.absoluteURL
            selectedImages.append(ImageName.pdf!)
//            setAttributedText(for: addPhotoLbl, with: CommonStringFile.AddPdfoptional.translated(), firstString: CommonStringFile.AddPdf.translated(), secondString:CommonStringFile.Optional.translated(), color1: .black, color2: .lightGray)
            //            url = URL(string:pdfurl)
            //            photoPickManager.uploadPDFFileToAWS(pdfData: pdfData ?? Data())
            costomView.imageCollectionview.reloadData()
        }
        photoPickManager.onCameraImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            selectedImages.append(images)
            costomView.imageCollectionview.reloadData()
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
        placeholderLabel.text = CommonStringFile.Description.translated()
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
        doneButton.setTitle(AlertstringFile.Done, for: .normal)
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
        HeadingLabel.text =  MenuTapbar.ComposeNotifications.translated()
        
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
        addPhotoLbl.text = CommonStringFile.UploadImagepdf.translated()
        
        setTitle.text = CommonStringFile.EventTitle.translated()
        eventTxt.placeholder = CommonStringFile.Title.translated()
        enterDetails.text = CommonStringFile.EventDetails.translated()
        setAttributedText(for: addPhotoLbl, with: CommonStringFile.UploadImagepdfoptional.translated(), firstString: CommonStringFile.UploadImagepdf.translated(), secondString:CommonStringFile.Optional.translated(), color1: .black, color2: .lightGray)
        
    }
    
    
    @IBAction func SubmitAction(_ sender: Any) {
        
        let vc = SelectRecipientVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    @IBAction func fromDate(_ sender: UIButton) {
        //showTimePicker(for: sender, date: true)
        dateSelection = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func toDate(_ sender: UIButton) {
       // showTimePicker(for: sender, date: false)
        dateSelection = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    func setFormattedDate(_ date: String, label: UILabel) {
           let weekdayFont = UIFont.systemFont(ofSize: 12) // Smaller font for weekday
           let dayFont = UIFont.boldSystemFont(ofSize: 22)  // Larger font for day number
           
           // Function to create an attributed string from a given date
           func createAttributedText(from date: String) -> NSMutableAttributedString {
               let components = date.split(separator: " ")
               guard components.count > 1 else {
                   print("Error: Invalid date format")
                   return NSMutableAttributedString()
               }
               
               let day = components[0]
               let month = components[1]
               
               let attributedText = NSMutableAttributedString()
               attributedText.append(NSAttributedString(string: "\(day)\n", attributes: [
                   .font: weekdayFont,
                   .foregroundColor: UIColor.darkGray
               ]))
               attributedText.append(NSAttributedString(string: "\(month)", attributes: [
                   .font: dayFont,
                   .foregroundColor: UIColor.black
               ]))
               
               // Set paragraph style for centered alignment
               let paragraphStyle = NSMutableParagraphStyle()
               paragraphStyle.alignment = .center
               attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
               
               return attributedText
           }
           
           // Create attributed text and set to label
           label.attributedText = createAttributedText(from: date)
           label.numberOfLines = 0
       }
    
    
    @IBAction func BackClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func next(_ sender: UIButton) {
        
        let vc = SelectRecipientVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
    
    func keyboardDionebtn(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: AlertstringFile.Done, style: .done, target: self, action: #selector(doneKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        eventTxt.inputAccessoryView = toolbar
        textview.inputAccessoryView = toolbar
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textview.text.isEmpty == true{
            textview.text = CommonStringFile.Description.translated()
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
            alert.showAlert(title: "", message: AlertstringFile.Reach_Your_Limit, on: self)
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
    
    func selectImages() {
        if selectedImages.count != 5{
            photoPickManager.presentPhotoPicker(from: self, selectionLimit: 5 - selectedImages.count )
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func openCamera(){
        if selectedImages.count != 5{
            photoPickManager.openCamera(from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    func selectPDF() {
        photoPickManager.pickPDF(from: self)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        costomView.imageCollectionview.reloadData()
    }
    
}

@available(iOS 14.0, *)
extension SenderNoticeBoardVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = costomView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell, for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        }else{
            let cell = costomView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
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
            let alertController = UIAlertController(title: AlertstringFile.Select, message: AlertstringFile.Chooseanoption, preferredStyle: .actionSheet)
            let cameraAction = UIAlertAction(title:AlertstringFile.Camera, style: .default) { [self] _ in
                openCamera()
            }
            alertController.addAction(cameraAction)
            let galleryAction = UIAlertAction(title: AlertstringFile.Gallery, style: .default) { [self] _ in
                selectImages()
            }
            alertController.addAction(galleryAction)
            let pdfAction = UIAlertAction(title: AlertstringFile.PDF, style: .default) { [self] _ in
                
                selectPDF()
            }
            alertController.addAction(pdfAction)
            let cancelAction = UIAlertAction(title:AlertstringFile.Cancel, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            if selectedImages.count > indexPath.item - 1 {
                let vc = PreviewImageVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                vc.selectedFileURL = url
                vc.img = selectedImages[indexPath.item - 1]
                present(vc, animated: true)
            }
            
        }
        
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            
            controller.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
}

