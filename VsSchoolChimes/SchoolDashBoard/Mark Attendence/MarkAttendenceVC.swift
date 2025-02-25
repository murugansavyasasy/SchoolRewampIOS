//
//  MarkAttendenceVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 13/12/24.
//

import UIKit
import DropDown

@available(iOS 14.0, *)
class MarkAttendenceVC: UIViewController, Datepicker {
    
    func date(date: String) {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yy"
            let DayDate = dateFormatter.date(from: date)!
            // Change to output format
            dateFormatter.dateFormat = "EEE dd"
            let outputDateString = dateFormatter.string(from: DayDate)
            
           DateBtn.setTitle(date, for: .normal)
           setFormattedDate(outputDateString, label: CustomDateLbl)

        }
    

    @IBOutlet weak var attendtypeStackToAttendmarkStackBottom: NSLayoutConstraint!
    @IBOutlet weak var AttendStackToStandardTop: NSLayoutConstraint!
    @IBOutlet weak var SessionviewHeight: NSLayoutConstraint!
    @IBOutlet weak var AttendTypeHeight: NSLayoutConstraint!
    @IBOutlet weak var AttendancetypeView: UIView!
    @IBOutlet weak var SessionView: UIView!
    @IBOutlet weak var secondHalfCheckImg: UIImageView!
    @IBOutlet weak var FirsthalfCheckImg: UIImageView!
    @IBOutlet weak var SecondHalfView: UIView!
    @IBOutlet weak var FirstHalfView: UIView!
    @IBOutlet weak var SelectSessionDefaultLbl: UILabel!
    @IBOutlet weak var SelectAttendanceTypeLbl: UILabel!
    @IBOutlet weak var selectStandardandSectionDefaultLbl: UILabel!
    @IBOutlet weak var selectDateDefautLbl: UILabel!
   
    @IBOutlet weak var CustumDateBtn: UIButton!
    @IBOutlet weak var CustomDateLbl: UILabel!
    @IBOutlet weak var HalfdayImgview: UIImageView!
    @IBOutlet weak var FulldayImgview: UIImageView!
    @IBOutlet weak var HalfdayView: UIView!
    @IBOutlet weak var FulldayView: UIView!
    @IBOutlet weak var sectionLbl: UILabel!
    @IBOutlet weak var standardLbl: UILabel!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var markAllPresentBtn: UIButton!
    @IBOutlet weak var MarkAbsentiesBtn: UIButton!
    @IBOutlet weak var SectionView: UIView!
    @IBOutlet weak var standardView: UIView!
    @IBOutlet weak var AttendRecordBtn: UIButton!
    @IBOutlet weak var MarkAttendBtn: UIButton!
    @IBOutlet weak var ButtonStackview: UIStackView!
    @IBOutlet weak var TV: UITableView!
    
    @IBOutlet weak var DateBtn: UIButton!
    
    @IBOutlet weak var AttendTypeStackView: UIStackView!
    
    var activeButton: UIButton?
    var datePicker: UIDatePicker!
    var doneButton: UIButton!
    let formatter = DateFormatter()
    let customdate = DateFormatter()
    let status = [true,true,false,true,false,false]
    let standardDropdown = DropDown()
    let SectionDropdown = DropDown()
    let TypeDropdown = DropDown()
    let SessionDropdown = DropDown()
    
    var id = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customdate.dateFormat = "EEE d"
        let customdatestring = customdate.string(from: Date())
        setFormattedDate(customdatestring, label: CustomDateLbl)
        
        formatter.dateFormat = "EEE d MMM yyyy"
        let dateBtntitle = formatter.string(from: Date())
        DateBtn.setTitle(dateBtntitle, for: .normal)
        
        markAllPresentBtn.backgroundColor = .systemGray3
        MarkAbsentiesBtn.backgroundColor = .lightGray
        //applyVerticalGradientToButton(button: CustumDateBtn)
//        calenderview.applyGradient(
//            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
//            startPoint: CGPoint(x: 1, y: 0.5),
//            endPoint: CGPoint(x: 0, y: 0.5)
//        )
        orLabel.setFont(style: .body, size: FontSize.BodySize)
        ButtonStackview.layer.cornerRadius = 20
        AttendRecordBtn.layer.cornerRadius = 20
        MarkAttendBtn.layer.cornerRadius = 20
        MarkAbsentiesBtn.layer.cornerRadius = 10
       // AttendenceTypeView.layer.cornerRadius = 10
        standardView.layer.cornerRadius = 10
        SectionView.layer.cornerRadius = 10
        standardView.layer.borderWidth = 1
        standardView.layer.borderColor = UIColor.lightGray.cgColor
        SectionView.layer.borderWidth = 1
        SectionView.layer.borderColor = UIColor.lightGray.cgColor
        
        CustumDateBtn.layer.borderWidth = 1 // Border width
        CustumDateBtn.layer.borderColor = UIColor.gray.cgColor
        
        markAllPresentBtn.layer.cornerRadius = 10
        markAllPresentBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        MarkAbsentiesBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        MarkAttendBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        AttendRecordBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        DateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        selectDateDefautLbl.setFont(style: .title, size: FontSize.TitleSize)
        selectStandardandSectionDefaultLbl.setFont(style: .title, size: FontSize.TitleSize)
        SelectSessionDefaultLbl.setFont(style: .title, size: FontSize.TitleSize)
        SelectAttendanceTypeLbl.setFont(style: .title, size: FontSize.TitleSize)
        standardLbl.setFont(style: .title, size: FontSize.TitleSize)
        sectionLbl.setFont(style: .title, size: FontSize.TitleSize)
       // setInitialButtonTitles()
        gradientcolours(button: MarkAttendBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        MarkAttendBtn.setTitleColor(UIColor.white, for: .normal)
        
        gradientcolours(button: AttendRecordBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        AttendRecordBtn.setTitleColor(UIColor.black, for: .normal)
        
        SessionView.isHidden = true

       // setupdatePicker()
        
        FulldayView.layer.borderWidth = 1
        FulldayView.layer.borderColor = UIColor.lightGray.cgColor
        FulldayView.layer.cornerRadius = 10
        
        HalfdayView.layer.borderWidth = 1
        HalfdayView.layer.borderColor = UIColor.lightGray.cgColor
        HalfdayView.layer.cornerRadius = 10
        
        FirstHalfView.layer.borderWidth = 1
        FirstHalfView.layer.borderColor = UIColor.lightGray.cgColor
        FirstHalfView.layer.cornerRadius = 10
        
        SecondHalfView.layer.borderWidth = 1
        SecondHalfView.layer.borderColor = UIColor.lightGray.cgColor
        SecondHalfView.layer.cornerRadius = 10
        
        let standardTap = UITapGestureRecognizer(target: self, action: #selector(SelectStandard))
        standardView.addGestureRecognizer(standardTap)
        
        let sectionTap = UITapGestureRecognizer(target: self, action: #selector(SelectSection))
        SectionView.addGestureRecognizer(sectionTap)
        
        let fulltap = UITapGestureRecognizer(target: self, action: #selector(fulldayAction))
        FulldayView.addGestureRecognizer(fulltap)
        
        let halftap = UITapGestureRecognizer(target: self, action: #selector(HalfdayAction))
        HalfdayView.addGestureRecognizer(halftap)
        HalfdayView.isUserInteractionEnabled = true
        
        let firstTap = UITapGestureRecognizer(target: self, action: #selector(FirsthalfAct))
        FirstHalfView.addGestureRecognizer(firstTap)
        
        let SecondTap = UITapGestureRecognizer(target: self, action: #selector(SecondhalfAct))
        SecondHalfView.addGestureRecognizer(SecondTap)
        
        let nib = UINib(nibName: CellConfingName.AttendenceReportTVCell, bundle: nil)
        TV.register(nib, forCellReuseIdentifier: CellConfingName.AttendenceReportTVCell)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure the gradient resizes with the button
        //CustumDateBtn.layer.sublayers?.first?.frame = CustumDateBtn.bounds
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    @objc func fulldayAction(){
        //FulldayImgview.image = UIImage(named: "checked_Tick")
        FulldayImgview.image = UIImage(named: "RadioCheck")
        HalfdayImgview.image = UIImage(named: "CheckCircle")
        SessionView.isHidden = true
        markAllPresentBtn.backgroundColor = .systemGreen
        MarkAbsentiesBtn.backgroundColor = .systemRed
    }
    @objc func HalfdayAction(){
        //HalfdayImgview.image = UIImage(named: "checked_Tick")
        HalfdayImgview.image = UIImage(named: "RadioCheck")
        FulldayImgview.image = UIImage(named: "CheckCircle")
        SessionView.isHidden = false
        markAllPresentBtn.backgroundColor = .systemGray3
        MarkAbsentiesBtn.backgroundColor = .lightGray
        FirsthalfCheckImg.image = UIImage(named: "CheckCircle")
        secondHalfCheckImg.image = UIImage(named: "CheckCircle")
    }
    @objc func FirsthalfAct(){
        FirsthalfCheckImg.image = UIImage(named: "RadioCheck")
        secondHalfCheckImg.image = UIImage(named: "CheckCircle")
        markAllPresentBtn.backgroundColor = .systemGreen
        MarkAbsentiesBtn.backgroundColor = .systemRed
    }
    @objc func SecondhalfAct(){
        secondHalfCheckImg.image = UIImage(named: "RadioCheck")
        FirsthalfCheckImg.image = UIImage(named: "CheckCircle")
        markAllPresentBtn.backgroundColor = .systemGreen
        MarkAbsentiesBtn.backgroundColor = .systemRed
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
//                self.calenderview.isHidden = true
//                self.calenderHeight.constant = 0
                
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
//                calenderview.isHidden = true
//                calenderHeight.constant = 0
                self.TV.isHidden = false
                self.TV.delegate = self
                self.TV.dataSource = self
                self.TV.reloadData()
            }
        }
    }
    
    @IBAction func DateBtnAct(_ sender: Any) {
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
    
    func applyVerticalGradientToButton(button: UIButton) {
            // Create a gradient layer
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = button.bounds
            
            // Define the colors for the top and bottom halves
//            gradientLayer.colors = [
//                UIColor.red.cgColor,    // Top half color
//                UIColor.blue.cgColor    // Bottom half color
//            ]
        gradientLayer.colors = [
            UIColor.white.cgColor,   // Top half color
            UIColor.systemBlue.cgColor    // Bottom half color
        ]
            
            // Set the gradient direction (vertical)
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)   // Bottom-center

            // Apply the gradient to the button
            button.layer.insertSublayer(gradientLayer, at: 0)
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
//        calenderimgHeight.constant = 0
//        DateViewheight.constant = 0
//        DateBtn.isHidden = true
       // calenderview.isHidden = false
       // calenderHeight.constant = 260
        
        gradientcolours(button: MarkAttendBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        MarkAttendBtn.setTitleColor(UIColor.white, for: .normal)
        
        gradientcolours(button: AttendRecordBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        AttendRecordBtn.setTitleColor(UIColor.black, for: .normal)
        
       // AttendenceTypeView.isHidden = false
        MarkAbsentiesBtn.isHidden = false
        markAllPresentBtn.isHidden = false
        stackview.isHidden = false
        AttendancetypeView.isHidden = false
        AttendTypeStackView.isHidden = false
        AttendStackToStandardTop.constant = 20
        attendtypeStackToAttendmarkStackBottom.constant = 15
        if HalfdayImgview.image == UIImage(named:"RadioCheck"){
            SessionView.isHidden = false
        }
    }
    
    @IBAction func ReportBtnAct(_ sender: Any) {
        id = 1
//        calenderview.isHidden = true
//        calenderimgHeight.constant = 38
//        DateViewheight.constant = 25
//        DateBtn.isHidden = false
        formatter.dateFormat = "EEE d MMM yyyy"
        let datelabel = formatter.string(from: Date())
//        DateBtn.setTitle(datelabel, for: .normal)
//        calenderview.isHidden = true
//        calenderHeight.constant = 0
        TV.isHidden = false
        TV.delegate = self
        TV.dataSource = self
        TV.reloadData()
        
        gradientcolours(button: AttendRecordBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        AttendRecordBtn.setTitleColor(UIColor.white, for: .normal)
        
        gradientcolours(button: MarkAttendBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        MarkAttendBtn.setTitleColor(UIColor.black, for: .normal)
      //  AttendenceTypeView.isHidden = true
        MarkAbsentiesBtn.isHidden = true
        markAllPresentBtn.isHidden = true
        stackview.isHidden = true
        SessionView.isHidden = true
        AttendancetypeView.isHidden = true
        AttendTypeStackView.isHidden = true
        AttendStackToStandardTop.constant = 0
        attendtypeStackToAttendmarkStackBottom.constant = 0
    }
    
    
    @IBAction func AllPresentAct(_ sender: Any) {
        
        let alert = CustomAlert()
        alert.showAlertCancel(title: "", message: AlertstringFile.Mark_All_as_Present, actionLbl1: "Ok", actionLbl2: "Cancel", on: self, onOk: {print("Attendance marked")} , onNo: {print("Canceled")})
    }
    @IBAction func MarkAbsentAct(_ sender: Any) {
        
        let vc = StudentHistryVC(nibName: nil, bundle: nil)
        vc.id = 2
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}

@available(iOS 14.0, *)
extension MarkAttendenceVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.AttendenceReportTVCell, for: indexPath) as! AttendenceReportTVCell
        
        if status[indexPath.row] == true{
            
           // cell.cellView.layer.borderColor = UIColor.systemGreen.cgColor
            cell.statusView.backgroundColor = .systemGreen
            cell.statusLbl.text = "Present"
           
        }
        else{
            
            
           // cell.cellView.layer.borderColor = UIColor.systemRed.cgColor
            cell.statusView.backgroundColor = .systemRed
            cell.statusLbl.text = "Absent"
           
        }
        
        return cell
        
    }
    
    
    
}
