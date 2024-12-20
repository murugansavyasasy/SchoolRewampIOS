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
class EventsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UITextViewDelegate ,UIDocumentPickerDelegate, DeleteImge{
    func deleteImage(index: Int) {
        
        selectedImages.remove(at: index)
        costomView.imageCollectionview.reloadData()
        
        
    }
    
    
    
   
    @IBOutlet weak var addItemView: UIStackView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var effect:UIVisualEffect!
    @IBOutlet weak var eventTxt: UITextField!
    @IBOutlet weak var EventTtleLbl: UILabel!
    @IBOutlet weak var placeTxt: UITextField!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        effect = visualEffectView.effect
//        visualEffectView.effect = nil
//        addItemView.isHidden = true
        setupTimePicker()
        setupdatePicker()
        setInitialButtonTitles()
        registerCell()
        setupPlaceholder()
        keyboardDionebtn()
        imageSelection()
        
    }
    
    
    
//    func animateIn() {
//        self.view.addSubview(addItemView)
//        addItemView.center = self.view.center
//        
//        addItemView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
//        addItemView.alpha = 0
//        
//        UIView.animate(withDuration: 0.4) {
//            self.visualEffectView.effect = self.effect
//            self.addItemView.alpha = 1
//            self.addItemView.transform = CGAffineTransform.identity
//        }
//        
//    }
//    
//    
//    func animateOut () {
//        UIView.animate(withDuration: 0.3, animations: {
//            self.addItemView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
//            self.addItemView.alpha = 0
//            
//            self.visualEffectView.effect = nil
//            
//        }) { (success:Bool) in
//                self.addItemView.removeFromSuperview()
//        }
//    }
    func imageSelection(){
        photoPickManager.onImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            selectedImages.append(contentsOf: images)
            costomView.imageCollectionview.reloadData()
        }
        photoPickManager.pdfUrl = { [weak self] pdfurl in
            guard let self = self else { return }
            selectedImages.removeAll()
            url = pdfurl.absoluteURL
            selectedImages.append(ImageName.pdf!)
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
        timeBtn.setTitle(formattedTime, for: .normal)
        todate.setTitle(formattedDate, for: .normal)
        Totime.setTitle(formattedTime, for: .normal)
        dateBtn.setTitle(formattedDate, for: .normal)
        // Set the date and time to the date button
        dateSet(formattedDate, dateOnly,dateOnly)
    }
    
    
    func registerCell(){
        costomView.imageCollectionview.delegate = self
        costomView.imageCollectionview.dataSource = self
        contentTxtView.delegate = self
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
        
        calanderBtn.layer.cornerRadius = 10
        placeLbl.setFont(style:.body, size: FontSize.BodySize)
        placeLbl.text = CommonStringFile.Venue
        addPhotoLbl.text = CommonStringFile.AddPhotos
        eventDeatail.text = CommonStringFile.EventDetails
        EventTtleLbl.text = CommonStringFile.EventTitle
        placeTxt.placeholder = CommonStringFile.egChennai
        eventTxt.placeholder = CommonStringFile.egYogaEvent
        
        setAttributedText(for: addPhotoLbl, with: CommonStringFile.AddPhotos1, firstString: CommonStringFile.AddPhotos, secondString: CommonStringFile.Optional, color1: .black, color2: .lightGray)
        
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
            pickerDateLbl.attributedText = attributedText
        }
        
        if dateSelection == false{
            todate.setTitle(date, for: .normal)
            toDateLbl.attributedText = attributedText
            
        }else{
            pickerDateLbl.attributedText = attributedText
            dateBtn.setTitle(date, for: .normal)
        }
        pickerDateLbl.numberOfLines = 0
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
    
    func keyboardDionebtn(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: AlertstringFile.Done, style: .done, target: self, action: #selector(doneKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        placeTxt.inputAccessoryView = toolbar
        eventTxt.inputAccessoryView = toolbar
        contentTxtView.inputAccessoryView = toolbar
    }
    @objc func doneKeyboard() {
        view.endEditing(true)  // Dismiss the keyboard
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
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            //            contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    
    // Helper function to count sentences
    func countSentences(in text: String) -> Int {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sentences = trimmedText.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        return sentences.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
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
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.EnterTextHere
        placeholderLabel.font = contentTxtView.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8) // Adjust padding
        contentTxtView.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !contentTxtView.text.isEmpty // Hide if text exists
    }
    
    @IBAction func datepicker(_ sender: UIButton) {
        showTimePicker(for: sender, date: true)
        dateSelection = true
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
        showTimePicker(for: sender, date: true)
        dateSelection = false
    }
    @IBAction func chooseSchool(_ sender: UIButton) {
        if placeTxt.text?.count != 0 && eventTxt.text?.count != 0 && contentTxtView.text?.count != 0{
            let vc = SelectRecipientVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "Alert", message: AlertstringFile.Fill_All_Required_Fields, on: self)
        }
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    
    
    
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
            
            
            
//            addItemView.isHidden = false
            
            let alertController = UIAlertController(title: AlertstringFile.Select, message: AlertstringFile.Chooseanoption, preferredStyle: .actionSheet)
            //
            // Camera option
            let cameraAction = UIAlertAction(title: AlertstringFile.Camera, style: .default) { [self] _ in
                openCamera()
            }
            alertController.addAction(cameraAction)
            
            // Gallery option
            let galleryAction = UIAlertAction(title: AlertstringFile.Gallery, style: .default) { [self] _ in
                //
                selectImages()
                //
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
            
//            animateIn()
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
            photoPickManager.presentPhotoPicker(from: self, selectionLimit: 5 - selectedImages.count )
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message:AlertstringFile.Already_Reach_Your_Limit, on: self)
            
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
        doneButton.setTitle(AlertstringFile.Done
                            , for: .normal)
        doneButton.isHidden = true
        doneButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        self.view.addSubview(doneButton)
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
        timePicker.isHidden = true
        doneButton.isHidden = true
        activeButton = nil
    }
    
    func showTimePicker(for button: UIButton, date: Bool) {
        activeButton = button // Track which button is being updated
        
        // Position the time picker or date picker below the button
        let buttonFrame = button.convert(button.bounds, to: self.view)
        
        if date {
            // Show the date picker
            datePicker.isHidden = false
            doneButton.isHidden = false
            doneButton2.isHidden = true
            timePicker.isHidden = true
            // Set the frame for the datePicker and make sure it’s within bounds
            let pickerYPosition = view.frame.minY + 110
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
        } else {
            // Show the time picker
            timePicker.isHidden = false
            doneButton2.isHidden = false
            datePicker.isHidden = true
            doneButton.isHidden = true
            // Set the frame for the timePicker
            //            let pickerYPosition = buttonFrame.maxY + 10
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
