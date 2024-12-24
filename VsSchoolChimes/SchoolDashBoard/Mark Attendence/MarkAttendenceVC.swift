//
//  MarkAttendenceVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 13/12/24.
//

import UIKit
import DropDown

class MarkAttendenceVC: UIViewController {

    @IBOutlet weak var AttendTypeLbl: UILabel!
    @IBOutlet weak var sectionLbl: UILabel!
    @IBOutlet weak var standardLbl: UILabel!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var markAllPresentBtn: UIButton!
    @IBOutlet weak var calenderimgHeight: NSLayoutConstraint!
    @IBOutlet weak var DateViewheight: NSLayoutConstraint!
    @IBOutlet weak var calenderHeight: NSLayoutConstraint!
    @IBOutlet weak var MarkAbsentiesBtn: UIButton!
    @IBOutlet weak var AttendenceTypeView: UIView!
    @IBOutlet weak var SectionView: UIView!
    @IBOutlet weak var standardView: UIView!
    @IBOutlet weak var AttendRecordBtn: UIButton!
    @IBOutlet weak var MarkAttendBtn: UIButton!
    @IBOutlet weak var ButtonStackview: UIStackView!
    @IBOutlet weak var TV: UITableView!
    @IBOutlet weak var calenderview: UIView!
    
    @IBOutlet weak var DateBtn: UIButton!
    
    
    @IBOutlet weak var sessionLbl: UILabel!
    @IBOutlet weak var sessionView: UIView!
    
    let formatter = DateFormatter()
    let status = [true,true,false,true,false,false]
    let standardDropdown = DropDown()
    let SectionDropdown = DropDown()
    let TypeDropdown = DropDown()
    let SessionDropdown = DropDown()
    
    var id = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ButtonStackview.layer.cornerRadius = 20
        AttendRecordBtn.layer.cornerRadius = 20
        MarkAttendBtn.layer.cornerRadius = 20
        MarkAbsentiesBtn.layer.cornerRadius = 10
        AttendenceTypeView.layer.cornerRadius = 10
        standardView.layer.cornerRadius = 10
        SectionView.layer.cornerRadius = 10
        markAllPresentBtn.layer.cornerRadius = 10
        
        calenderimgHeight.constant = 0
        DateViewheight.constant = 0
        DateBtn.isHidden = true
        
        gradientcolours(button: MarkAttendBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        MarkAttendBtn.setTitleColor(UIColor.white, for: .normal)
        
        gradientcolours(button: AttendRecordBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        AttendRecordBtn.setTitleColor(UIColor.black, for: .normal)
        
        calenderview.layer.cornerRadius = 10
        calenderview.layer.borderWidth = 1
        calenderview.layer.borderColor = UIColor.lightGray.cgColor

        showDatepicker()
        
        
        let standardTap = UITapGestureRecognizer(target: self, action: #selector(SelectStandard))
        standardView.addGestureRecognizer(standardTap)
        
        let sectionTap = UITapGestureRecognizer(target: self, action: #selector(SelectSection))
        SectionView.addGestureRecognizer(sectionTap)
        
        let AttendenceTap = UITapGestureRecognizer(target: self, action: #selector(SelectType))
        AttendenceTypeView.addGestureRecognizer(AttendenceTap)
        
        let SessionTap = UITapGestureRecognizer(target: self, action: #selector(SelectSession))
        sessionView.addGestureRecognizer(SessionTap)
        
        let nib = UINib(nibName: CellConfingName.AttendenceReportTVCell, bundle: nil)
        TV.register(nib, forCellReuseIdentifier: CellConfingName.AttendenceReportTVCell)
        
//        TV.delegate = self
//        TV.dataSource = self
        
    }
    
    func showDatepicker(){
        
        // Create a UIDatePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        // Use inline display style for iOS 14+
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        
        // Set maximum date to today
        datePicker.maximumDate = Date()
        
        // Calculate minimum date (30 days before today)
        let calendar = Calendar.current
        if let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) {
            datePicker.minimumDate = thirtyDaysAgo
        }
        
        
        // Scale down the entire calendar
        datePicker.transform = CGAffineTransform(scaleX: 0.75, y: 0.65) // Adjust scaling factors
        
        // Set frame and center it in the container view
        datePicker.frame = calenderview.bounds
        datePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the date picker to the container view
        calenderview.addSubview(datePicker)
        
        
        // Handle date selection
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        
        formatter.dateFormat = "EEE d MMM yyyy"
        print("Selected date: \(formatter.string(from: sender.date))")
        
        let label = formatter.string(from: sender.date)
        
        if id == 1 {
            calenderimgHeight.constant = 38
            DateViewheight.constant = 25
            calenderHeight.constant = 0
            calenderview.isHidden = true
            DateBtn.isHidden = false
            DateBtn.setTitle(label, for: .normal)
            DateBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            // calenderHeight.constant = 260
        }
        
    }
    
    @IBAction func SelectStandard() {
        // Setup dropdown anchor and data source
        standardDropdown.anchorView = standardView
        standardDropdown.dataSource = ["8th", "9th", "10th", "11th"]
        standardDropdown.bottomOffset = CGPoint(x: 0, y: standardView.bounds.height)
        
        // Show the dropdown
        standardDropdown.show()
        
        // Handle the selection
        standardDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return } // Safely unwrap self
            
            print("Selected item: \(item) at index: \(index)")
            
            // Update the label inside the standardView
            if let label = self.standardView.subviews.compactMap({ $0 as? UILabel }).first {
                label.text = item
            }
            
            // Perform additional actions when ID == 1
            if self.id == 1 {
                self.calenderview.isHidden = true
                self.calenderHeight.constant = 0
                
                self.TV.isHidden = false
                self.TV.delegate = self
                self.TV.dataSource = self
                self.TV.reloadData()
            }
        }
    }

    @IBAction func SelectSection() {
        SectionDropdown.anchorView = SectionView
        SectionDropdown.dataSource = ["A", "B", "C", "D"]
        SectionDropdown.show()
        SectionDropdown.bottomOffset = CGPoint(x: 0, y: SectionView.bounds.height)
        
        SectionDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            print("Selected item: \(item) at index: \(index)")
            
            // Update the label inside the UIView
            if let label = self.SectionView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
            }
            
            if self.id == 1 { // Explicit use of 'self' here
                calenderview.isHidden = true
                calenderHeight.constant = 0
                self.TV.isHidden = false
                self.TV.delegate = self
                self.TV.dataSource = self
                self.TV.reloadData()
            }
        }
    }

    @IBAction func SelectType(){
        TypeDropdown.anchorView = AttendenceTypeView
        TypeDropdown.dataSource = ["Full Day", "Half Day"]
        TypeDropdown.show()
        TypeDropdown.bottomOffset = CGPoint(x: 0, y: AttendenceTypeView.bounds.height)
        
        TypeDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            // Update the label inside the UIView
            if let label = self?.AttendenceTypeView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
            }
            
            if self!.AttendTypeLbl.text == "Half Day"{
                self?.sessionView.isHidden = false
            }
            else{
                self?.sessionView.isHidden = true
            }
        }
    }
    
    @IBAction func SelectSession(){
        
        SessionDropdown.anchorView = sessionView
        SessionDropdown.dataSource = ["First Half", "Second Half"]
        SessionDropdown.show()
        SessionDropdown.bottomOffset = CGPoint(x: 0, y: sessionView.bounds.height)
        
        SessionDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            // Update the label inside the UIView
            if let label = self?.sessionView.subviews.first(where: { $0 is UILabel }) as? UILabel {
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
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    @IBAction func MarkBtnAct(_ sender: Any) {
        
        id = 0
        TV.isHidden = true
        calenderimgHeight.constant = 0
        DateViewheight.constant = 0
        DateBtn.isHidden = true
        calenderview.isHidden = false
        calenderHeight.constant = 260
        
        gradientcolours(button: MarkAttendBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        MarkAttendBtn.setTitleColor(UIColor.white, for: .normal)
        
        gradientcolours(button: AttendRecordBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        AttendRecordBtn.setTitleColor(UIColor.black, for: .normal)
        
        AttendenceTypeView.isHidden = false
        MarkAbsentiesBtn.isHidden = false
        markAllPresentBtn.isHidden = false
        stackview.isHidden = false
        
    }
    
    @IBAction func ReportBtnAct(_ sender: Any) {
        id = 1
        calenderview.isHidden = true
        calenderimgHeight.constant = 38
        DateViewheight.constant = 25
        DateBtn.isHidden = false
        formatter.dateFormat = "EEE d MMM yyyy"
        let datelabel = formatter.string(from: Date())
        DateBtn.setTitle(datelabel, for: .normal)
        calenderview.isHidden = true
        calenderHeight.constant = 0
        TV.isHidden = false
        TV.delegate = self
        TV.dataSource = self
        TV.reloadData()
        
        gradientcolours(button: AttendRecordBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        AttendRecordBtn.setTitleColor(UIColor.white, for: .normal)
        
        gradientcolours(button: MarkAttendBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        MarkAttendBtn.setTitleColor(UIColor.black, for: .normal)
        AttendenceTypeView.isHidden = true
        MarkAbsentiesBtn.isHidden = true
        markAllPresentBtn.isHidden = true
        stackview.isHidden = true
    }
    
    
    @IBAction func AllPresentAct(_ sender: Any) {
        if standardLbl.text == "STANDARD" || sectionLbl.text == "SECTION" || AttendTypeLbl.text == "SELECT ATTENDANCE TYPE" {
            
            
        }
        let alert = CustomAlert()
        alert.showAlertCancel(title: "", message: AlertstringFile.Mark_All_as_Present, actionLbl1: "Ok", actionLbl2: "Cancel", on: self, onOk: {print("Attendance marked")} , onNo: {print("Canceled")})
    }
    @IBAction func MarkAbsentAct(_ sender: Any) {
        
        let vc = StudentHistryVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func dateBtnAct(_ sender: Any) {
        if calenderHeight.constant == 0 {
            calenderview.isHidden = false
            calenderHeight.constant = 260
            DateBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        }else{
            calenderview.isHidden = true
            calenderHeight.constant = 0
            DateBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
    }
    
}

extension MarkAttendenceVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.AttendenceReportTVCell, for: indexPath) as! AttendenceReportTVCell
        
        if status[indexPath.row] == true{
            
//            cell.cellView.layer.borderWidth = 1
            cell.cellView.layer.borderColor = UIColor.systemGreen.cgColor
            cell.statusView.backgroundColor = .systemGreen
            cell.statusLbl.text = "Present"
           // cell.cellView.layer.cornerRadius = 10
           // cell.Imgview.image = UIImage(named: "present")
        }
        else{
            
            
            cell.cellView.layer.borderColor = UIColor.systemRed.cgColor
            cell.statusView.backgroundColor = .systemRed
            cell.statusLbl.text = "Absent"
           // cell.Imgview.image = UIImage(named: "Absent")
        }
        
        return cell
        
    }
    
    
    
}
