//
//  OnlineMeetingVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 05/12/24.
//

import UIKit
import EventKit
import DropDown

class OnlineMeetingVC: UIViewController, ReminderCellDelegate {
    
    @IBOutlet weak var Gradientview: UIStackView!
    @IBOutlet weak var receiverView: UIView!
    @IBOutlet weak var createView: UIView!
    
    @IBOutlet weak var calenderImgview: UIImageView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        receiverView.isHidden = true
        createView.isHidden = false
        
        StyleAndTranslater()
        createDatepicker()
        setupTimePicker()
        
        DescriptTxtview.delegate = self
        
        gradientcolours(button: createBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        createBtn.setTitleColor(UIColor.white, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MeetingDropdown))
        selectMeetingView.addGestureRecognizer(tap)
        
        let nib  = UINib(nibName: CellConfingName.MeetingsTVcell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.MeetingsTVcell)
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    func StyleAndTranslater() {
        
        //MARK: UI Update
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
        setcustomDate(attributedLbl: customdatestring)
        
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
        alert.addAction(UIAlertAction(title: AlertstringFile.OK, style: .default, handler: { _ in
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
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    func createDatepicker(){
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.backgroundColor = .white
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        
        datePicker.isHidden = true
        self.view.addSubview(datePicker!)
        
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
    
    func showDatepicker(button: UIButton) {
        datePicker.isHidden = false
        doneButton.isHidden = false
        
        let buttonFrame = button.convert(button.bounds, to: self.view)
        
        // Set the frame for the datePicker
        //        let pickerYPosition = buttonFrame.maxY + 10
        //        datePicker.frame = CGRect(x: (self.view.frame.width - 300) / 2, y: pickerYPosition, width: 300, height: 300)
        
        let pickerYPosition = view.frame.minY + 110
        datePicker.frame = CGRect(x: (self.view.frame.width - 300) / 2, y: pickerYPosition, width: 300, height: 300)
        
        // Set appearance for datePicker
        datePicker.backgroundColor = .white
        datePicker.layer.shadowColor = UIColor.black.cgColor
        datePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        datePicker.layer.shadowRadius = 5
        datePicker.layer.shadowOpacity = 0.3
        datePicker.layer.cornerRadius = 20
        
        doneButton.frame = CGRect(x: datePicker.frame.maxX - 80, y: pickerYPosition + datePicker.frame.height - 40, width: 70, height: 30)
        
        // Add both datePicker and Done button to the view
        self.view.addSubview(datePicker)
        self.view.addSubview(doneButton)
    }
    
    @IBAction func doneButtonTapped(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "EEE d MMM yyyy"
        let datelabel = dateFormatter.string(from: datePicker.date)
        
        DateBtn.setTitle(datelabel, for: .normal)
        
        customdate.dateFormat = "EEE d"
        let attributedLbl = customdate.string(from: datePicker.date)
        setcustomDate(attributedLbl: attributedLbl)
        datePicker.isHidden = true
        doneButton.isHidden = true
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
        showDatepicker(button: sender as! UIButton)
    }
    
    @IBAction func SelectdateAct(_ sender: Any) {
        
        showDatepicker(button: sender as! UIButton)
    }
    
    @IBAction func SelectTimeAct(_ sender: Any) {
        
        showTimepicker(button: sender as! UIButton)
    }
    
    func setcustomDate(attributedLbl : String){
        
        let words = attributedLbl.split(separator: " ")
        
        let attributedString = NSMutableAttributedString(string: attributedLbl)
        
        // Define the ranges for the two words
        let firstWordRange = (attributedLbl as NSString).range(of: String(words[0]))
        let secondWordRange = (attributedLbl as NSString).range(of: String(words[1]))
        
        let dayfont = UIFont(name: "Poppins-Medium", size: 14)
        let datefont = UIFont(name: "Poppins-Bold", size: 14)
        
        // Apply color and font to the first word
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: firstWordRange)
        attributedString.addAttribute(.font, value: dayfont, range: firstWordRange)
        
        // Apply  color and font to the second word
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: secondWordRange)
        attributedString.addAttribute(.font, value: datefont, range: secondWordRange)
        
        // Assign the attributed string to the label
        customDateLbl.attributedText = attributedString
        
    }
}

extension OnlineMeetingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.MeetingsTVcell, for: indexPath) as! MeetingsTVcell
        
        let colorName = assetColors[indexPath.row % assetColors.count]
        let colour1 = UIColor(named: colorName)
        let gradient = gradientcolour[indexPath.row % gradientcolour.count]
        let colour2 =  UIColor(named: gradient)
        
        cell.cellview.backgroundColor = colour1
        cell.contentview.backgroundColor = colour2
        cell.indexPath = indexPath
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

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
}
