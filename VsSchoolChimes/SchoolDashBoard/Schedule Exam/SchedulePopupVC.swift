//
//  SchedulePopupVC.swift
//  VsSchoolChimes
//
//  Created by admin on 17/12/24.
//

import UIKit
import DropDown
protocol ScheduleDelegate{
    func schedulSubject(ExamsSchedule:[ExamsSchedule],delete:Bool,index:Int)
}
class SchedulePopupVC: UIViewController,UITextViewDelegate {
    @IBOutlet weak var txtFld: UITextField!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var sessionBtn: UIButton!
    @IBOutlet weak var txtSyllobs: UITextView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var SchedulBtn: UIButton!
    @IBOutlet weak var markLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var sessionLbl: UILabel!
    @IBOutlet weak var SubjectSyllabus: UILabel!
    @IBOutlet weak var sessionView: UIView!
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var heighttxt: NSLayoutConstraint!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var subjectImg: UIImageView!
    var examSchedul:ExamsSchedule?
    var finalArray = [ExamsSchedule]()
    var scheduDelegate:ScheduleDelegate?
    var index = 0
    var datePicker: UIDatePicker!
    var doneButton: UIButton!
    var sessionDropdown = DropDown()
    var isKeyboardVisible = false
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSyllobs.delegate = self
        uiConficuration()
        txtFld.addDoneButton()
        txtSyllobs.addDoneButton()
        // Add observers for the keyboard notifications
         NotificationCenter.default.addObserver(self,
                                                selector: #selector(keyboardWillShow(_:)),
                                                name: UIResponder.keyboardWillShowNotification,
                                                object: nil)
         
         NotificationCenter.default.addObserver(self,
                                                selector: #selector(keyboardWillHide(_:)),
                                                name: UIResponder.keyboardWillHideNotification,
                                                object: nil)
    }
    func uiConficuration(){
        outerView.layer.cornerRadius = 10
        SchedulBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        sessionView.layer.cornerRadius = 8
        txtSyllobs.layer.cornerRadius = 8
        subjectImg.image = UIImage(named: examSchedul?.imageName ?? "")
        subjectName.text = examSchedul?.subjectName
        SubjectSyllabus.setFont(style: .body, size: FontSize.BodySize)
        subjectName.setFont(style: .body, size: FontSize.BodySize)
        sessionLbl.setFont(style: .body, size: FontSize.BodySize)
        dateLbl.setFont(style: .body, size: FontSize.BodySize)
        markLbl.setFont(style: .body, size: FontSize.BodySize)
        SchedulBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        cancelBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        txtFld.text = examSchedul?.mark
        txtSyllobs.text = examSchedul?.subjectSyllabus
        setupdatePicker()
        if examSchedul?.date == ""{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy"
            let selectedDate = Date()
            let formattedDate = dateFormatter.string(from: selectedDate)
            dateBtn.setTitle(formattedDate, for: .normal)
        }else{
            dateBtn.setTitle(examSchedul?.date, for: .normal)
        }
        self.sessionBtn.setTitle(examSchedul?.session, for: .normal)
        adjustTextViewHeightWithConstraint(txtSyllobs)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        guard !isKeyboardVisible else { return } // Prevent unnecessary animations
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            isKeyboardVisible = true
            UIView.animate(withDuration: 0.3) {
                // Move outerView 20 points from the top
                self.outerView.transform = CGAffineTransform(translationX: 0, y: -self.outerView.frame.origin.y + 100)
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

    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeightWithConstraint(textView)
    }
    func adjustTextViewHeightWithConstraint(_ textView: UITextView) {
        if textView.text.isEmpty {
            // Set default height to 40 if the text is empty
            heighttxt.constant = 40
        } else {
            // Calculate the size needed for the text
            let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            // Restrict the height to a maximum of 90
            heighttxt.constant = min(sizeThatFits.height, 90)
        }
        textView.layoutIfNeeded() // Refresh the layout
    }

    @IBAction func schedule(_ sender: Any) {
        examSchedul?.date = dateBtn.titleLabel?.text ?? ""
        examSchedul?.mark = txtFld.text ?? ""
        examSchedul?.session = sessionBtn.titleLabel?.text ?? ""
        examSchedul?.subjectSyllabus = txtSyllobs.text ?? ""
        examSchedul?.isSelected = true
        if let selectedArr = examSchedul{
            finalArray.append(selectedArr)
        }
        
        scheduDelegate?.schedulSubject(ExamsSchedule:finalArray, delete: false, index: index)
        dismiss(animated: false)
    }
    @IBAction func sessionSelection(_ sender: UIButton) {
        view.endEditing(true)  // Dismiss the keyboard
        keyboardWillHide(Notification(name: UIResponder.keyboardWillHideNotification))
        sessionDropdown.dataSource = ["FN","AN"]
        sessionDropdown.anchorView = sessionView
        sessionDropdown.bottomOffset = CGPoint(x: 0, y: sessionView.bounds.height)
        sessionDropdown.direction = .bottom
        sessionDropdown.width = sessionView.bounds.width
        sessionDropdown.show()
        sessionDropdown.selectionAction = { [self] (index: Int, item: String) in
            self.sessionBtn.setTitle(item, for: .normal)
            if let label = self.sessionDropdown.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self.sessionBtn.setTitle(item.translated(), for: .normal)
            }
        }
    }
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: false)
       
    }
    
    @IBAction func dateselect(_ sender: UIButton) {
        showTimePicker(for: sender)
    }
    func showTimePicker(for button: UIButton) {
        
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
    @objc func doneButtonTapped() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        let selectedDate = datePicker.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        examSchedul?.date = formattedDate
        dateBtn.setTitle(formattedDate, for: .normal)
        datePicker.isHidden = true
        doneButton.isHidden = true
    }
}
