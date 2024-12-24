//
//  LeveCreateVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
@available(iOS 14.0, *)
class LeveCreateVC: UIViewController,UITextViewDelegate, DeleteImge{
    
    var placeholderLabel: UILabel!
    var activeButton: UIButton?
    var timePicker: UIDatePicker!
    var datePicker: UIDatePicker!
    var doneButton: UIButton!
    var doneButton2: UIButton!
    var time = "Jan\n15"
    var dateSelection = false
    let photoPickManager = PhotoPickerManager.shared
    var selectedImages: [UIImage] = []
    var url : URL?
    @IBOutlet weak var dayCount: UILabel!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var ReasonLbl: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var calanderBtn: HalfColorButton!
    @IBOutlet weak var calander2Btn: HalfColorButton!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var todate: UIButton!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var ToLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var TxtOuterview: UIView!
    @IBOutlet weak var contentCount: UILabel!
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var costomView: ImageSelection!
    @IBOutlet weak var outerView: UIView!
    var LeaveRequest:LeaveRequest?
    var currentdate:String?
    var isKeyboardVisible = false
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTxtView.delegate = self
        
        costomView.imageCollectionview.delegate = self
        costomView.imageCollectionview.dataSource = self
        imageSelection()
        setupPlaceholder()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        contentTxtView.delegate = self
        uiConfic()
        setupdatePicker()
        setInitialButtonTitles()
        keyboardDionebtn()
        selectedImages.removeAll()
        costomView.imageCollectionview.reloadData()
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
    
    func uiConfic(){
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
        
        
        ToLbl.setFont(style:.body, size: FontSize.BodySize)
        ToLbl.text = CommonStringFile.To
        headerTitle.setFont(style:.body, size: FontSize.BodySize)
        headerTitle.text = CommonStringFile.CreateLeaveRequest
        ReasonLbl.setFont(style:.body, size: FontSize.BodySize)
        fromLbl.setFont(style:.body, size: FontSize.BodySize)
        fromLbl.text = CommonStringFile.From
        dayCount.setFont(style:.header, size: FontSize.BodySize)
        dateBtn.setTitleFont(style: .body, size: 12)
        todate.setTitleFont(style: .body, size: 12)
        contentTxtView.text = LeaveRequest?.reson
        contentCount.text = LeaveRequest?.reson != nil ? "\(LeaveRequest?.reson.count ?? 0) of 500" : "0 of 500"
        if LeaveRequest?.reson != nil{
            placeholderLabel.isHidden = true
        }
        calanderBtn.layer.cornerRadius = 10

    }
    @objc func keyboardWillShow(_ notification: Notification) {
        guard !isKeyboardVisible else { return } // Prevent unnecessary animations
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            isKeyboardVisible = true
            UIView.animate(withDuration: 0.3) {
                // Move outerView 20 points from the top
                self.outerView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + 200)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard isKeyboardVisible else { return } // Ensure this logic runs only if the keyboard is open
        isKeyboardVisible = false
        UIView.animate(withDuration: 0.3) {
            self.outerView.transform = .identity // Reset position
        }
    }
    
    //MARK: BUTTON TITLE CURRENT TIME
    func setInitialButtonTitles() {
        let dateFormatter = DateFormatter()
        let dateOnlyFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yy"
        dateOnlyFormatter.dateFormat = "EEE d"
        
        let currentDate = Date() // Current date and time
       
        let formattedDate = dateFormatter.string(from: currentDate)
        self.currentdate = formattedDate
        // Check if LeaveRequest is available and set button titles accordingly
        if let leaveRequest = LeaveRequest {
            todate.setTitle(leaveRequest.toDate ?? "", for: .normal)
            dateBtn.setTitle(leaveRequest.fromDate ?? "", for: .normal)
            dateSet(leaveRequest.fromDate ?? "", leaveRequest.toDate ?? "", formattedDate)
        } else {
            
            datePicker.minimumDate = Date() // Ensure From Date starts from today
            // Handle case where LeaveRequest is nil (if necessary)
//            todate.setTitle(formattedDate, for: .normal)
            dateBtn.setTitle(formattedDate, for: .normal)
            todate.setTitle("Select To Date", for: .normal)
            dayCount.isHidden = true
            dateSet(currentdate ?? "", currentdate ?? "", formattedDate)
        }
    }
    
    // Function to update the date labels with formatted text
    func dateSet(_ fromDate: String, _ toDate: String, _ currentDate: String) {
        // Fonts for different parts
        let weekdayFont = UIFont.systemFont(ofSize: 12) // Smaller font for weekday
        let dayFont = UIFont.boldSystemFont(ofSize: 22)  // Larger font for day number
        
        // Function to create an attributed string for a date
        func createAttributedText(from date: String) -> NSMutableAttributedString {
            let components = date.split(separator: " ")
            guard components.count > 1 else {
                print("Error: Invalid date format")
                return NSMutableAttributedString()
            }
            let weekday = components[1]
            let day = components[0]
            
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(string: "\(weekday)\n", attributes: [
                .font: weekdayFont,
                .foregroundColor: UIColor.darkGray
            ]))
            attributedText.append(NSAttributedString(string: "\(day)", attributes: [
                .font: dayFont,
                .foregroundColor: UIColor.black
            ]))
            
            // Set paragraph style for centered alignment
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
            
            return attributedText
        }
        
        // Create attributed text for fromDate and toDate
        let fromAttributedText = createAttributedText(from: fromDate)
        let toAttributedText = createAttributedText(from: toDate)
        
        // Update `fromDateLbl` and `toDateLbl` accordingly
        if !currentDate.isEmpty {
            toDateLbl.attributedText = toAttributedText
            fromDateLbl.attributedText = fromAttributedText
        }
        
        // If both fromDate and toDate exist, update labels
        if fromDate != "" && toDate != "" {
            fromDateLbl.attributedText = fromAttributedText
            toDateLbl.attributedText = toAttributedText
        } else {
            // If dateSelection is false, update toDate and button accordingly
            if dateSelection == false {
                toDateLbl.attributedText = toAttributedText
            } else {
                fromDateLbl.attributedText = fromAttributedText
            }
        }
        
        // Ensure labels are multi-line if needed
        fromDateLbl.numberOfLines = 0
        toDateLbl.numberOfLines = 0
    }
    
    func keyboardDionebtn(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: AlertstringFile.Done, style: .done, target: self, action: #selector(doneKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        contentTxtView.inputAccessoryView = toolbar
    }
    @objc func doneKeyboard() {
        view.endEditing(true)  // Dismiss the keyboard
        keyboardWillHide(Notification(name: UIResponder.keyboardWillHideNotification))
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        placeholderLabel.isHidden = !contentTxtView.text.isEmpty // Toggle visibility
        adjustTextViewHeightWithConstraint(textView)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Calculate the new length of the text
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        if updatedText.count <= 500 {
            placeholderLabel.isHidden = updatedText.count == 0 ? false : true
            contentCount.text = "\(updatedText.count) of 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            //            contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    func adjustTextViewHeightWithConstraint(_ textView: UITextView) {
        // Calculate the size needed for the text
        if textView.text.isEmpty {
            // Set default height to 60
            textViewHeightConstraint.constant = 100
        } else {
            // Calculate the size needed for the text
            let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            if sizeThatFits.height > 80{
                textViewHeightConstraint.constant = sizeThatFits.height
            }
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
    }
    func setupdatePicker() {
        // Initialize the date picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        
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
    
    @IBAction func datepicker(_ sender: UIButton) {
        
        activeButton = sender
        showTimePicker(for: sender, date: true)
        dateSelection = true
    }
    @IBAction func toDate(_ sender: UIButton) {
        activeButton = sender
        showTimePicker(for: sender, date: true)
        dateSelection = false
    }
    func daytCounts(_ fromdate:String,_ todate:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yy"
        var dateCount = ""
        if let startDate = dateFormatter.date(from: fromdate),
           let endDate = dateFormatter.date(from: todate) {
            
            // Calculate the difference in days
            let calendar = Calendar.current
            let dateDifference = calendar.dateComponents([.day], from: startDate, to: endDate)
            
            if let daysBetween = dateDifference.day {
                dateCount = daysBetween < 1 ? "\(daysBetween + 1) \(CommonStringFile.Day)" : "\(daysBetween + 1) \(CommonStringFile.Days)"
               return dateCount
            }
        }
        return dateCount
    }
    
    
    @objc func doneButtonTapped() {
        let dateFormatter = DateFormatter()
        let dateOnlyFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yy"
        // Set the date-only format (e.g., "Tue 3")
        dateOnlyFormatter.dateFormat = "EEE d"
        
        // Get the selected date and time
        let selectedDate = datePicker.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        dateSet(formattedDate, currentdate ?? "", "")
        
        // Hide datePicker, timePicker, and doneButton
        datePicker.isHidden = true
        doneButton.isHidden = true
        
        // Update the correct button based on dateSelection flag
        if dateSelection {
            currentdate = formattedDate
            activeButton?.setTitle(formattedDate, for: .normal)
            datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: datePicker.date)
            dateBtn.setTitle(formattedDate, for: .normal)
            todate.setTitle("Select To Date", for: .normal)
            dayCount.isHidden = true
        } else {
            activeButton?.setTitle(formattedDate, for: .normal)
            todate.setTitle(formattedDate, for: .normal)
            dayCount.isHidden = false
        }
        
        dayCount.text = daytCounts(dateBtn.titleLabel?.text ?? "" , todate.titleLabel?.text ?? "")
        
        // Reset activeButton
        activeButton = nil
        
        
    }
    
    
    func showTimePicker(for button: UIButton, date: Bool) {
        activeButton = button
        // Show the date picker
        datePicker.isHidden = false
        doneButton.isHidden = false
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
        
    }
    
}
@available(iOS 14.0, *)
extension LeveCreateVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
            if selectedImages.count == 0{
                collectionViewHeght.constant = 100
            }
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
             if selectedImages.count <= 3{
                collectionViewHeght.constant = 100
            }else{
                collectionViewHeght.constant = 220
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (costomView.imageCollectionview.frame.width - 30) / 4 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 80)
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
    
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        costomView.imageCollectionview.reloadData()
    }
}
