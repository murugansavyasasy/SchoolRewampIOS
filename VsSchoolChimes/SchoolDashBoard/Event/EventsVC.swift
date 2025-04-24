//
//  EventsVC.swift
//  VsSchoolChimes
//
//  Created by admin on 02/12/24.
//

import UIKit
import AWSCore
import AWSS3

protocol DeleteImge{
    func deleteImage(index:Int)
}
@available(iOS 14.0, *)
class EventsVC: UIViewController, UIDocumentPickerDelegate, DeleteImge, Datepicker{
    
    func date(date: String) {
        
        // Change to output format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yy"
        let DayDate = dateFormatter.date(from: date)!
        // Change to output format
        dateFormatter.dateFormat = "EEE dd"
        let outputDateString = dateFormatter.string(from: DayDate)
        
        if dateSelection == true{
            todate.setTitle(date, for: .normal)
            setFormattedDate(outputDateString, label: toDateLbl)
            
        }else{
            dateBtn.setTitle(date, for: .normal)
            setFormattedDate(outputDateString, label: pickerDateLbl)
        }
    }
    
    func deleteImage(index: Int) {
        
        selectedImages.remove(at: index)
        costomView.imageCollectionview.reloadData()
    }
    var effect:UIVisualEffect!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var eventTxt: UITextField!
    @IBOutlet weak var EventTtleLbl: UILabel!
    @IBOutlet weak var placeTxt: UITextField!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var costomView: ImageSelection!
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var pickerDateLbl: UILabel!
    @IBOutlet weak var calander2Btn: HalfColorButton!
    @IBOutlet weak var ToLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var TxtOuterview: UIView!
    @IBOutlet weak var contentCount: UILabel!
    @IBOutlet weak var eventDeatail: UILabel!
    @IBOutlet weak var addPhotoLbl: UILabel!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var todate: UIButton!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var calanderBtn: HalfColorButton!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var Totime: UIButton!
    var placeholderLabel: UILabel!
    var activeButton: UIButton?
    var timePicker: UIDatePicker!
    var datePicker: UIDatePicker!
    var doneButton: UIButton!
    var doneButton2: UIButton!
    var time = "Jan\n15"
    var dateSelection = false
    var url : URL?
    let photoPickManager = PhotoPickerManager.shared
    var selectedImages: [UIImage] = []
    var convertedImagesUrlArray = NSMutableArray()
    var imageUrlArray = NSMutableArray()
    var pdfData : Data? = nil
    let AlertMessage = AlertstringFile()
    var isKeyboardVisible = false
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var initialHeight : CGFloat = 60
    var maxHeight : CGFloat = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTxt.applyRightTxt()
        EventTtleLbl.applyRightTxt()
        placeTxt.applyRightTxt()
        subTitleLbl.applyRightTxt()
        placeLbl.applyRightTxt()
        contentTxtView.applyRightTxt()
        pickerDateLbl.applyRightTxt()
        ToLbl.applyRightTxt()
        contentCount.applyRightTxt()
        eventDeatail.applyRightTxt()
        addPhotoLbl.applyRightTxt()
        toDateLbl.applyRightTxt()
        fromLbl.applyRightTxt()
        eventTxt.applyRightTxt()
        StyleAndTranslate()
        setupTimePicker()
        setInitialButtonTitles()
        registerCell()
        setupPlaceholder()
        placeTxt.addDoneButton()
        eventTxt.addDoneButton()
        contentTxtView.addDoneButton()
        imageSelection()
        
        // Add observers for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }

    func imageSelection(){
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            // handle camera image
            selectedImages.append(image)
            costomView.imageCollectionview.reloadData()
        }

        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            selectedImages.append(contentsOf: images)
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            costomView.imageCollectionview.reloadData()
        }

        PhotoPickerManager.shared.onPdfPicked = { [self] data in
            // handle picked PDF
            selectedImages.removeAll()
            url = data.absoluteURL
            selectedImages.append(ImageName.pdf!)
            costomView.imageCollectionview.reloadData()
        }

    }
    
    //MARK: BUTTON TITLE CURRANT TIME
    func setInitialButtonTitles() {
        
        // Set the date format (e.g., "Tue 3 Dec 2024")
        dateFormatter.dateFormat = "EEE d MMM yyyy"
        
        // Set the time format (e.g., "4:30 PM")
        timeFormatter.timeStyle = .short
        
        // Get the current date and time
        let currentDate = Date() // Current date and time
        let nextHourTime = Calendar.current.date(byAdding: .hour, value: 0, to: currentDate) ?? currentDate
        
        let formattedDate = dateFormatter.string(from: currentDate)   // "Tue 3 Dec 2024"
        let formattedTime = timeFormatter.string(from: nextHourTime)
        
        dateFormatter.dateFormat = "EEE d"
        let customDate = dateFormatter.string(from: currentDate)
        
        setFormattedDate(customDate, label: pickerDateLbl)
        setFormattedDate(customDate, label: toDateLbl)
        
        // Set the formatted time to the time button
        timeBtn.setTitle(formattedTime, for: .normal)
        Totime.setTitle(formattedTime, for: .normal)
        todate.setTitle(formattedDate, for: .normal)
        dateBtn.setTitle(formattedDate, for: .normal)
        dateBtn.applyBackButton()
        todate.applyBackButton()
        Totime.applyRightButton()
        timeBtn.applyRightButton()
        contentCount.applyRightTxt()
        contentCount.applyRightTxt()
        contentCount.applyRightTxt()
        contentCount.applyRightTxt()
    }
    
    func StyleAndTranslate(){
        
        //MARK: UI Changes
        TxtOuterview.layer.cornerRadius = 10
        TxtOuterview.layer.borderWidth = 0.5
        TxtOuterview.layer.borderColor = UIColor.black.cgColor
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        calanderBtn.layer.borderWidth = 1 // Border width
        calanderBtn.layer.borderColor = UIColor.gray.cgColor // Border color
        calander2Btn.layer.borderWidth = 1 // Border width
        calander2Btn.layer.borderColor = UIColor.gray.cgColor // Border color
        calander2Btn.layer.cornerRadius = 10
        calanderBtn.layer.cornerRadius = 10 // Add corner radius if needed
        
        EventTtleLbl.setFont(style:.body, size: FontSize.BodySize)
        ToLbl.setFont(style:.body, size: FontSize.BodySize)
        fromLbl.setFont(style:.body, size: FontSize.BodySize)
        subTitleLbl.setFont(style:.body, size: FontSize.BodySize)
        eventDeatail.setFont(style:.body, size: FontSize.BodySize)
        addPhotoLbl.setFont(style:.body, size: FontSize.BodySize)
        Totime.setTitleFont(style: .body, size: 12)
        timeBtn.setTitleFont(style: .body, size: 12)
        dateBtn.setTitleFont(style: .body, size: 12)
        todate.setTitleFont(style: .body, size: 12)
        placeLbl.setFont(style:.body, size: FontSize.BodySize)
        
        subTitleLbl.text = CommonStringFile.CreateEvent.translated()
        placeLbl.text = CommonStringFile.Venue.translated()
        addPhotoLbl.text = CommonStringFile.UploadImagepdfoptional.translated()
        eventDeatail.text = CommonStringFile.EventDetails.translated()
        EventTtleLbl.text = CommonStringFile.EventTitle.translated()
        placeTxt.placeholder = CommonStringFile.egChennai.translated()
        
        setAttributedText(for: addPhotoLbl, with: CommonStringFile.UploadImagepdfoptional.translated(), firstString: CommonStringFile.UploadImagepdf.translated(), secondString: CommonStringFile.Optional.translated(), color1: .black, color2: .lightGray)
    }
    
    func registerCell(){
        costomView.imageCollectionview.delegate = self
        costomView.imageCollectionview.dataSource = self
        contentTxtView.delegate = self
        
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
    
    
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Description.translated()
        placeholderLabel.font = contentTxtView.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8) // Adjust padding
        contentTxtView.applyRightTxt()
        contentTxtView.applyRightTxt(with: placeholderLabel)
        
        contentTxtView.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !contentTxtView.text.isEmpty // Hide if text exists
    }
    
    func setupTimePicker() {
        // Initialize the time picker
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        }
        timePicker.backgroundColor = .white
        timePicker.isHidden = true // Initially hidden
        self.view.addSubview(timePicker)
        
        // Initialize and configure Done button
        doneButton2 = UIButton(type: .system)
        doneButton2.setTitle(AlertstringFile.Done, for: .normal)
        doneButton2.isHidden = true
        doneButton2.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        doneButton2.setTitleColor(.white, for: .normal)
        doneButton2.layer.cornerRadius = 8
        doneButton2.addTarget(self, action: #selector(selectedTime), for: .touchUpInside)
        self.view.addSubview(doneButton2)
    }
    
    @objc func selectedTime() {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let selectedTime = timePicker.date // Selected time from timePicker
        
        let formattedTime = timeFormatter.string(from: selectedTime)
        
        if dateSelection == true{
            Totime.setTitle(formattedTime, for: .normal)
        }else{
            timeBtn.setTitle(formattedTime, for: .normal)
        }
        // Hide the picker and Done button after selection
        timePicker.isHidden = true
        doneButton2.isHidden = true
        activeButton = nil
    }
    

    func showTimePicker(for button: UIButton, date: Bool) {
        activeButton = button // Track which button is being updated
        
        // Position the time picker or date picker below the button
        let buttonFrame = button.convert(button.bounds, to: self.view)
            // Show the time picker
            timePicker.isHidden = false
            doneButton2.isHidden = false

            let pickerYPosition = buttonFrame.minY - 210
            timePicker.frame = CGRect(x: (self.view.frame.width - 250) / 2, y: pickerYPosition, width: 250, height: 200)
            
            // Set appearance for timePicker
            timePicker.backgroundColor = .white
            timePicker.layer.shadowColor = UIColor.black.cgColor
            timePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
            timePicker.layer.shadowRadius = 5
            timePicker.layer.shadowOpacity = 0.3
            timePicker.layer.cornerRadius = 20
            
            // Position the Done button at the bottom-right of the picker
            doneButton2.frame = CGRect(x: timePicker.frame.maxX - 80, y: pickerYPosition + timePicker.frame.height - 40, width: 70, height: 30)
            
            // Add timePicker to the view (ensure it’s in the view hierarchy)
            self.view.addSubview(timePicker)
            self.view.addSubview(doneButton2)
    }
    
    @IBAction func datepicker(_ sender: UIButton) {
        dateSelection = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    @IBAction func Timepicker(_ sender: UIButton) {
        showTimePicker(for: sender, date: false)
        dateSelection = false
    }
    @IBAction func ToTimeBtn(_ sender: UIButton) {
        showTimePicker(for: sender, date: false)
        dateSelection = true
    }
    @IBAction func toDate(_ sender: UIButton) {
        dateSelection = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    @IBAction func chooseSchool(_ sender: UIButton) {
        if placeTxt.text?.count != 0 && eventTxt.text?.count != 0 && contentTxtView.text?.count != 0{
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "Alert", message: AlertstringFile.Fill_All_Required_Fields, on: self)
        }
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
//MARK: Collectionview Delegate Functions
@available(iOS 14.0, *)
extension EventsVC : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
            
            // Camera option
            let cameraAction = UIAlertAction(title: AlertstringFile.Camera, style: .default) { [self] _ in
                openCamera()
            }
            alertController.addAction(cameraAction)
            
            // Gallery option
            let galleryAction = UIAlertAction(title: AlertstringFile.Gallery, style: .default) { [self] _ in
                
                selectImages()
            }
            alertController.addAction(galleryAction)
            
            //             PDF option
            let pdfAction = UIAlertAction(title: AlertstringFile.PDF, style: .default) { [self] _ in
                
                selectPDF()
            }
            alertController.addAction(pdfAction)
            
            // Cancel action
            let cancelAction = UIAlertAction(title: AlertstringFile.Cancel, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        }else{
            if selectedImages.count > indexPath.item - 1 {
                let vc = PreviewImageVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                vc.selectedFileURL = url
                // Safe unwrapping of imgView before assigning
                vc.img = selectedImages[indexPath.item - 1]
                //
                present(vc, animated: true)
            }
        }
    }
    
    func selectImages() {
        if selectedImages.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5 - selectedImages.count), from: self)
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }

    }
    func openCamera(){
        if selectedImages.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func selectPDF() {
        PhotoPickerManager.shared.presentPicker(ofType: .pdf, from: self)
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
}

//MARK: Text view delegate Functions
@available(iOS 14.0, *)
extension EventsVC : UITextViewDelegate {
    
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
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            //            contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty // Toggle visibility
        
        let size = textView.contentSize
        
        // Check if the content exceeds the initial height
        if size.height > initialHeight {
            // Update the height constraint based on content size
            let newHeight = min(size.height, maxHeight) // Cap the height to maxTextViewHeight
            textViewHeightConstraint.constant = newHeight
        }
        
        // Animate the change for smoother UI
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        // Scroll to make the UITextView visible
        scrollToView(textView)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            // Adjust the scroll view content inset
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight+30, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            
            // Ensure the UITextView is visible
            scrollToView(contentTxtView)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Reset the scroll view content inset
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    func scrollToView(_ view: UIView) {
        // Calculate the frame of the view relative to the UIScrollView
        let rect = view.convert(view.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
}



class HalfColorButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create a layer for the 60% background color
        let coloredLayer = CALayer()
        coloredLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height * 0.4) // 60% height
        coloredLayer.backgroundColor = UIColor.white.cgColor // Set the desired color
        
        // Remove old layers to avoid duplication
        self.layer.sublayers?.removeAll(where: { $0 is CALayer })
        // Add the 60% color layer
        self.layer.addSublayer(coloredLayer)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}
