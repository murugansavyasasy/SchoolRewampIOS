//
//  LeveCreateVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

class LeveCreateVC: UIViewController,UITextViewDelegate {
    var placeholderLabel: UILabel!
    var activeButton: UIButton?
    var timePicker: UIDatePicker!
    var datePicker: UIDatePicker!
    var doneButton: UIButton!
    var doneButton2: UIButton!
    var time = "Jan\n15"
    var dateSelection = false
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
    @IBOutlet weak var outerView: UIView!
    var LeaveRequest:LeaveRequest?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupdatePicker()
        setInitialButtonTitles()
        setupPlaceholder()
        keyboardDionebtn()
        
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
   
        
        ToLbl.setFont(style:.body, size: FontSize.BodySize)
        fromLbl.setFont(style:.body, size: FontSize.BodySize)
        dateBtn.setTitleFont(style: .body, size: 12)
        todate.setTitleFont(style: .body, size: 12)
        
        calanderBtn.layer.cornerRadius = 10
        
    }
    //MARK: BUTTON TITLE CURRANT TIME
    func setInitialButtonTitles() {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        let dateOnlyFormatter = DateFormatter()
        
        // Set the date format (e.g., "Tue 3 Dec 2024")
        dateFormatter.dateFormat = "dd MMM yy"
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
//        LeaveRequest
        if LeaveRequest?.toDate != nil{
            todate.setTitle(LeaveRequest?.toDate, for: .normal)
        }else{
            todate.setTitle(formattedDate, for: .normal)
        }
        if LeaveRequest?.fromDate != nil{
            dateBtn.setTitle(LeaveRequest?.fromDate, for: .normal)
        }else{
            dateBtn.setTitle(formattedDate, for: .normal)
        }
        
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
            todate.setTitle(date, for: .normal)
            toDateLbl.attributedText = attributedText
            
        }else{
            fromDateLbl.attributedText = attributedText
            dateBtn.setTitle(date, for: .normal)
        }
        fromDateLbl.numberOfLines = 0
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
        placeholderLabel.isHidden = !contentTxtView.text.isEmpty // Hide if text exists
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
    
    @IBAction func datepicker(_ sender: UIButton) {
        showTimePicker(for: sender, date: true)
        dateSelection = true
    }
    @IBAction func toDate(_ sender: UIButton) {
        showTimePicker(for: sender, date: true)
        dateSelection = false
    }
    
    

    @objc func doneButtonTapped() {
        // Create a DateFormatter and set the desired format
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Locale to ensure consistent date format
        dateFormatter.dateFormat = "dd MMM yy" // Format for "12 Sep 24"
        
        // Get the selected date from the datePicker
        let selectedDate = datePicker.date
        
        // Format the date as "12 Sep 24"
        let formattedDate = dateFormatter.string(from: selectedDate)
        
        // Call the dateSet method with the formatted date
        dateSet(formattedDate, formattedDate, "")
        
        // Hide datePicker, timePicker, and doneButton
        datePicker.isHidden = true
        doneButton.isHidden = true
        
        // Reset activeButton
        activeButton = nil
    }

    
    func showTimePicker(for button: UIButton, date: Bool) {
        activeButton = button // Track which button is being updated
        
        // Position the time picker or date picker below the button
        let buttonFrame = button.convert(button.bounds, to: self.view)
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
