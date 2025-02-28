//
//  OnlineMeetingVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 05/12/24.
//

import UIKit
import EventKit
import DropDown

@available(iOS 14.0, *)
class OnlineMeetingVC: UIViewController, ReminderCellDelegate, Datepicker {
    
    func date(date: String) {
        
        if DateSelection == true {
            DateBtn.setTitle(date, for: .normal)
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "dd MMM yy"
            let Date = dateformatter.date(from: date)
            dateformatter.dateFormat = "EEE d"
            let customdate = dateformatter.string(from: Date!)
            setFormattedDate(customdate, label: customDateLbl)
        }else{
            TimeBtn.setTitle(date, for: .normal)
        }
    }
    
    
    @IBOutlet weak var ReciverviewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var ButtonStackHeight: NSLayoutConstraint!
    @IBOutlet weak var TextViewheight: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var Gradientview: UIStackView!
    @IBOutlet weak var receiverView: UIView!
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var LinkTxtfld: UITextField!
    @IBOutlet weak var SubmitBtn: UIButton!
    @IBOutlet weak var TimeBtn: UIButton!
    @IBOutlet weak var DateBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var selectMeetingView: UIView!
    @IBOutlet weak var LettercountLbl: UILabel!
    @IBOutlet weak var DescriptTxtview: UITextView!
    @IBOutlet weak var DetailsLbl: UILabel!
    @IBOutlet weak var titleTxtfld: UITextField!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var viewBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var MeetingLinkLbl: UILabel!
    @IBOutlet weak var MeetingtypeLbl: UILabel!
    @IBOutlet weak var customDateLbl: UILabel!
    @IBOutlet weak var CustomDateBtn: HalfColorButton!
    @IBOutlet weak var NameStandardStackview: UIStackView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    
    let eventStore = EKEventStore()
    var data = ["Parents meeting", "Google Meeting", "Annual day Discussion"]
    let assetColors: [String] = ["meetingcolour1", /*"priortitClr1",*/ "meetcolour2"]
    let gradientcolour : [String] = ["MeetGradient1", /*"gradient2",*/ "MeetGradient2"]
    var datePicker : UIDatePicker!
    var timePicker : UIDatePicker!
    var doneButton : UIButton!
    var doneButton2 : UIButton!
    var dropDown = DropDown()
    let customdate = DateFormatter()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    var passvalue = 1
    var DateSelection = true //True for date & false for time
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
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
        
        
        
        StyleAndTranslater()
        setupTimePicker()
        keyboardDonebtn()
        
        DescriptTxtview.delegate = self
        
        gradientcolours(button: createBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        createBtn.setTitleColor(UIColor.white, for: .normal)
        
        if passvalue == 2{
            Gradientview.isHidden = true
            ButtonStackHeight.constant = 0
            createView.isHidden = true
            receiverView.isHidden = false
            receiverView.alpha = 1
            ReciverviewTopConstraint.constant = 0
            NameStandardStackview.isHidden = false
        }else {
            receiverView.isHidden = true
            createView.isHidden = false
            NameStandardStackview.isHidden = true

        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MeetingDropdown))
        selectMeetingView.addGestureRecognizer(tap)
        
        let nib  = UINib(nibName: CellConfingName.MeetingsTVcell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.MeetingsTVcell)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        if passvalue == 2 {
            view.applyGradient(
                colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                startPoint: CGPoint(x: 1, y: 0.5),
                endPoint: CGPoint(x: 0, y: 0.5)
            )
           
           
        }else {
            view.applyGradient(
                colors: [Colornames.stafGradient, Colornames.stafGradient1],
                startPoint: CGPoint(x: 1, y: 0.5),
                endPoint: CGPoint(x: 0, y: 0.5)
            )
        }
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    
    func StyleAndTranslater() {
        
        //MARK: UI Update
        TextViewheight.constant = initialHeight
        createView.layer.cornerRadius = 10
        createView.layer.shadowColor = UIColor.black.cgColor
        createView.layer.shadowOffset = CGSize(width: 0, height: 2)
        createView.layer.shadowRadius = 5
        createView.layer.shadowOpacity = 0.3
        createView.layer.cornerRadius = 10
        DescriptTxtview.layer.cornerRadius = 10
        DescriptTxtview.layer.borderWidth = 1
        DescriptTxtview.layer.borderColor = UIColor.gray.cgColor
        viewBtn.layer.cornerRadius = 20
        createBtn.layer.cornerRadius = 20
        Gradientview.layer.cornerRadius = 20
        selectMeetingView.layer.cornerRadius = 10
        infoBtn.layer.cornerRadius = 10
        LinkTxtfld.layer.cornerRadius = 10
        LinkTxtfld.layer.borderWidth = 1
        LinkTxtfld.layer.borderColor = UIColor.gray.cgColor
        SubmitBtn.layer.cornerRadius = 10
        DescriptTxtview.text = TexviewStringFile.Enter_Meeting_Description.translated()
        DescriptTxtview.textColor = .lightGray
        CustomDateBtn.layer.cornerRadius = 10
        CustomDateBtn.layer.borderWidth = 1
        CustomDateBtn.layer.borderColor = UIColor.gray.cgColor
        
        customdate.dateFormat = "EEE d"
        let customdatestring = customdate.string(from: Date())
        setFormattedDate(customdatestring, label: customDateLbl)
        
        customdate.dateFormat = "dd MMM yy"
        let dateString = customdate.string(from: Date())
        DateBtn.setTitle(dateString, for: .normal)
      
        
        //MARK: Button Font Style
        SubmitBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        TimeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        DateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        infoBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        viewBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        createBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Label Font Style
        LettercountLbl.setFont(style: .body, size: FontSize.BodySize)
        DetailsLbl.setFont(style: .title, size: FontSize.TitleSize)
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        MeetingtypeLbl.setFont(style: .title, size: FontSize.TitleSize)
        MeetingLinkLbl.setFont(style: .title, size: FontSize.TitleSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Text Field Font Style
        // LinkTxtfld.setFont(style: .body, size: FontSize.BodySize)
        // titleTxtfld.setFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Text View Font Style
        //DescriptTxtview.setFont(style: .body, size: FontSize.BodySize)
    }
    
    @IBAction func MeetingDropdown(){
        dropDown.anchorView = selectMeetingView
        dropDown.dataSource = ["Zoom Meeting", "Google Meet", "Microsoft Teams","Others"]
        dropDown.show()
        dropDown.bottomOffset = CGPoint(x: 0, y: selectMeetingView.bounds.height)
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            // Update the label inside the UIView
            if let label = self?.selectMeetingView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.numberOfLines = 0
                label.text = item
            }
        }
    }
    
    func gradientcolours(button : UIButton,colours : [CGColor]){

        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        // Create and configure the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = button.layer.cornerRadius
        
        // Insert the gradient layer into the button's layer
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func createReminder(for task: String) {
        eventStore.requestAccess(to: .reminder) { [weak self] (granted, error) in
            if let error = error {
                print("Error requesting access: \(error.localizedDescription)")
                return
            }
            
            if granted {
                self?.addReminder(task: task)
            } else {
                print("Access to reminders not granted.")
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: AlertstringFile.PermissionDenied,
                        message: AlertstringFile.enableRemindersAccess,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    func addReminder(task: String) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = task
        reminder.notes = "Task reminder for \(task)"
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date().addingTimeInterval(3600)) // Due in 1 hour
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        do {
            try eventStore.save(reminder, commit: true)
            print("Reminder added for \(task).")
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Success",
                    message: "Reminder added for \(task).",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        } catch {
            print("Failed to save reminder: \(error.localizedDescription)")
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Failed to create reminder.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    func didTapCreateReminder(at indexPath: IndexPath) {
        let taskName = data[indexPath.row]
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Set Reminder",
            message: "Do you want to set a reminder for \(taskName)?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.createReminder(for: taskName)
        }))
        alert.addAction(UIAlertAction(title: AlertstringFile.No, style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func createBtnAct(_ sender: Any) {
        gradientcolours(button: createBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        createBtn.setTitleColor(UIColor.white, for: .normal)
        
        gradientcolours(button: viewBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        viewBtn.setTitleColor(UIColor.black, for: .normal)
        
        receiverView.isHidden = true
        createView.isHidden = false
    }
    
    @IBAction func viewBtnAct(_ sender: Any) {
        
        gradientcolours(button: viewBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        viewBtn.setTitleColor(UIColor.white, for: .normal)
        
        gradientcolours(button: createBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        createBtn.setTitleColor(UIColor.black, for: .normal)
        
        receiverView.isHidden = false
        receiverView.alpha = 1
        createView.isHidden = true
        tableview.reloadData()
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
   
    
    @IBAction func selectedTime(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "h:mm a"
        let Timelabel = dateFormatter.string(from: timePicker.date)
        
        TimeBtn.setTitle(Timelabel, for: .normal)
        
        timePicker.isHidden = true
        doneButton2.isHidden = true
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
        doneButton2.setTitle("Done", for: .normal)
        doneButton2.isHidden = true
        doneButton2.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        doneButton2.setTitleColor(.white, for: .normal)
        doneButton2.layer.cornerRadius = 8
        doneButton2.addTarget(self, action: #selector(selectedTime), for: .touchUpInside)
        self.view.addSubview(doneButton2)
    }
    
    func showTimepicker(button: UIButton){
        timePicker.isHidden = false
        doneButton2.isHidden = false
        datePicker.isHidden = true
        doneButton.isHidden = true
        
        let buttonFrame = button.convert(button.bounds, to: self.view)
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
    
    
    @IBAction func CustomDateBtnAct(_ sender: Any) {
        DateSelection = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func SelectdateAct(_ sender: Any) {
        
        DateSelection = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func SelectTimeAct(_ sender: Any) {
        
        DateSelection = false
        //showTimepicker(button: sender as! UIButton)
        let vc = DatePickerVC(nibName: nil, bundle: nil)
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
}

@available(iOS 14.0, *)
extension OnlineMeetingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.MeetingsTVcell, for: indexPath) as! MeetingsTVcell
        
        let colorName = assetColors[indexPath.row % assetColors.count]
        let colour1 = UIColor(named: colorName)
        let gradient = gradientcolour[indexPath.row % gradientcolour.count]
        cell.cellview.backgroundColor = colour1
        cell.indexPath = indexPath
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

@available(iOS 14.0, *)
extension OnlineMeetingVC : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if DescriptTxtview.text == TexviewStringFile.Enter_Meeting_Description {
            
            DescriptTxtview.text = ""
            DescriptTxtview.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if DescriptTxtview.text == ""{
            DescriptTxtview.text = TexviewStringFile.Enter_Meeting_Description
            DescriptTxtview.textColor = .lightGray
        }
    }
    
    func keyboardDonebtn(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        titleTxtfld.inputAccessoryView = toolbar
        DescriptTxtview.inputAccessoryView = toolbar
    }
        @objc func doneKeyboard() {
            view.endEditing(true)  // Dismiss the keyboard
        }
    
    func textViewDidChange(_ textView: UITextView) {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            let newHeight = min(max(size.height, initialHeight), maxHeight)

            // Update height constraint and scrolling
        TextViewheight.constant = newHeight
        DescriptTxtview.isScrollEnabled = size.height > maxHeight

            // Ensure layout updates
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }

            // Adjust view position with keyboard
            if DescriptTxtview.isFirstResponder {
                self.adjustForKeyboardHeight()
            }
        }

        // Helper to adjust outerView position dynamically
        private func adjustForKeyboardHeight() {
            guard let keyboardFrame = UIResponder.keyboardFrameEndUserInfoKey as? CGRect else { return }
            let availableSpace = self.view.frame.height - keyboardFrame.height
            let textViewBottom = outerView.frame.origin.y + outerView.frame.height

            if textViewBottom > availableSpace {
                let overlap = textViewBottom - availableSpace + 20 // Add some padding
                UIView.animate(withDuration: 0.3) {
                    self.outerView.transform = CGAffineTransform(translationX: 0, y: -overlap)
                }
            }
        }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Current text in the UITextView
        let currentText = textView.text ?? ""
        
        // Compute the new text length
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if newText.count <= 500 {
            LettercountLbl.text = "\(newText.count) of 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            //contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        // Calculate new position considering the dynamic height
        let availableSpace = self.view.frame.height - keyboardFrame.height
        let textViewBottom = outerView.frame.origin.y + outerView.frame.height
        
        if textViewBottom > availableSpace {
            let overlap = textViewBottom - availableSpace - 200 // Add some padding
            UIView.animate(withDuration: 0.3) {
                self.outerView.transform = CGAffineTransform(translationX: 0, y: -overlap)
            }
        }
//        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//            UIView.animate(withDuration: 0.3) {
//                // Move outerView 20 points from the top
//                self.outerView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + 400)
//            }
//        }
    }
    
    // Reset view when keyboard hides
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.outerView.transform = .identity
        }
    }
}
