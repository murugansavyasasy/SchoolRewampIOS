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
    @IBOutlet weak var ChooseAcademicYearLbl: UILabel!
    @IBOutlet weak var AcademicYearLbl: UILabel!
    @IBOutlet weak var AcademicYearView: UIView!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    @IBOutlet weak var SearchbarHeight: NSLayoutConstraint!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var AttendancetypeStack: UIStackView!
    @IBOutlet weak var SessionStack: UIStackView!
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
    @IBOutlet weak var TV: UITableView!
    @IBOutlet weak var DateBtn: UIButton!
    @IBOutlet weak var AttendTypeStackView: UIStackView!
    
    let formatter = DateFormatter()
    let customdate = DateFormatter()
    let standardDropdown = DropDown()
    let SectionDropdown = DropDown()
    let AcademicDropdown = DropDown()
    let StaffDetails = UserDefaultFileManager.get_staff_Details()
    var attendenceReport : [AttenenceReportData]?
    var FilteredReport : [AttenenceReportData]?
    var academicYearData : [AcadimicYearData]?
    var StandardData : [StandardDetail]?
    var SectionData : [sectionsDetail]?
    var StandardList : [String] = []
    var SectionList : [String] = []
    var AcademicList : [String] = []
    var AcademicYearId: Int?
    var sectionId = ""
    var StandardId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        applyShadowAndCornerRadius(to: AcademicYearView)
        applyShadowAndCornerRadius(to: SectionView)
        applyShadowAndCornerRadius(to: standardView)
        UIupdate()
        SearchBar.searchTextField.addDoneButton()
        BackBtn.applyBackButton()
        customdate.dateFormat = "EEE d"
        let customdatestring = customdate.string(from: Date())
        setFormattedDate(customdatestring, label: CustomDateLbl)
        formatter.dateFormat = "dd MMM yyyy"
        let dateBtntitle = formatter.string(from: Date())
        DateBtn.setTitle(dateBtntitle, for: .normal)
        
        SessionStack.isHidden = true
        SearchBar.isHidden = true
        
        
        let AcademicTap = UITapGestureRecognizer(target: self, action: #selector(Select_Academic_Year))
        AcademicYearView.addGestureRecognizer(AcademicTap)
        
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
        
        get_Academic_year()
        TV.delegate = self
        TV.dataSource = self
        SearchBar.delegate = self
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
    
    func UIupdate() {
        
        TV.isHidden = true
        
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.MarkAttendance, secondLine: StaffDetails?.school_name ?? "")
        
        applyDesign(element: standardView)
        applyDesign(element: SectionView)
        applyDesign(element: FulldayView)
        applyDesign(element: HalfdayView)
        applyDesign(element: FirstHalfView)
        applyDesign(element: SecondHalfView)
        
        DateBtn.semanticContentAttribute = .forceRightToLeft
        DateBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        
        markAllPresentBtn.backgroundColor = .systemGray3
        MarkAbsentiesBtn.backgroundColor = .lightGray
        MarkAbsentiesBtn.layer.cornerRadius = 10
        
        CustumDateBtn.layer.borderWidth = 1 // Border width
        CustumDateBtn.layer.borderColor = UIColor.gray.cgColor
        markAllPresentBtn.layer.cornerRadius = 10
        
        markAllPresentBtn.isUserInteractionEnabled = false
        MarkAbsentiesBtn.isUserInteractionEnabled = false
        
        markAllPresentBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        MarkAbsentiesBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        DateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        orLabel.setFont(style: .body, size: FontSize.BodySize)
        selectDateDefautLbl.setFont(style: .title, size: FontSize.TitleSize)
        selectStandardandSectionDefaultLbl.setFont(style: .title, size: FontSize.TitleSize)
        SelectSessionDefaultLbl.setFont(style: .title, size: FontSize.TitleSize)
        SelectAttendanceTypeLbl.setFont(style: .title, size: FontSize.TitleSize)
        standardLbl.setFont(style: .title, size: FontSize.TitleSize)
        sectionLbl.setFont(style: .title, size: FontSize.TitleSize)
    }
    
    func applyDesign(element: UIView,radius:Int = 10){
        
        element.layer.cornerRadius = 10
        element.layer.borderWidth = 1
        element.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func SegmentControllerAction(_ sender: Any) {
        
        if SegmentController.selectedSegmentIndex == 0 {
            
            TV.isHidden = true
            SearchBar.isHidden = true
            
            MarkAbsentiesBtn.isHidden = false
            markAllPresentBtn.isHidden = false
            stackview.isHidden = false
            AttendancetypeStack.isHidden = false
            AttendTypeStackView.isHidden = false
            if HalfdayImgview.image == UIImage(named:"RadioCheck"){
                SessionStack.isHidden = false
            }
        }else {
            
            student_attendance_report()

            SearchBar.isHidden = false
            TV.isHidden = false
            TV.delegate = self
            TV.dataSource = self
            TV.reloadData()
            
            MarkAbsentiesBtn.isHidden = true
            markAllPresentBtn.isHidden = true
            stackview.isHidden = true
            SessionStack.isHidden = true
            AttendancetypeStack.isHidden = true
            AttendTypeStackView.isHidden = true
            
        }
    }
    
    @objc func fulldayAction(){
        user_inputs.attendance_type = "F"
        user_inputs.session_type = ""
        user_inputs.all_present = "T"
        //FulldayImgview.image = UIImage(named: "checked_Tick")
        FulldayImgview.image = UIImage(named: "RadioCheck")
        HalfdayImgview.image = UIImage(named: "CheckCircle")
        SessionStack.isHidden = true
        markAllPresentBtn.backgroundColor = .systemGreen
        MarkAbsentiesBtn.backgroundColor = .systemRed
        markAllPresentBtn.isUserInteractionEnabled = true
        MarkAbsentiesBtn.isUserInteractionEnabled = true
    }
    @objc func HalfdayAction(){
    
        user_inputs.attendance_type = "H"
        user_inputs.session_type = ""
        user_inputs.all_present = "T"
        
        //HalfdayImgview.image = UIImage(named: "checked_Tick")
        HalfdayImgview.image = UIImage(named: "RadioCheck")
        FulldayImgview.image = UIImage(named: "CheckCircle")
        SessionStack.isHidden = false
        markAllPresentBtn.backgroundColor = .systemGray3
        MarkAbsentiesBtn.backgroundColor = .lightGray
        FirsthalfCheckImg.image = UIImage(named: "CheckCircle")
        secondHalfCheckImg.image = UIImage(named: "CheckCircle")
        markAllPresentBtn.isUserInteractionEnabled = false
        MarkAbsentiesBtn.isUserInteractionEnabled = false
    }
    @objc func FirsthalfAct(){
        user_inputs.attendance_type = "H"
        user_inputs.session_type = "FH"
        user_inputs.all_present = "T"
        FirsthalfCheckImg.image = UIImage(named: "RadioCheck")
        secondHalfCheckImg.image = UIImage(named: "CheckCircle")
        markAllPresentBtn.backgroundColor = .systemGreen
        MarkAbsentiesBtn.backgroundColor = .systemRed
        markAllPresentBtn.isUserInteractionEnabled = true
        MarkAbsentiesBtn.isUserInteractionEnabled = true
    }
    @objc func SecondhalfAct(){
        user_inputs.attendance_type = "H"
        user_inputs.session_type = "SH"
        user_inputs.all_present = "T"
        secondHalfCheckImg.image = UIImage(named: "RadioCheck")
        FirsthalfCheckImg.image = UIImage(named: "CheckCircle")
        markAllPresentBtn.backgroundColor = .systemGreen
        MarkAbsentiesBtn.backgroundColor = .systemRed
        markAllPresentBtn.isUserInteractionEnabled = true
        MarkAbsentiesBtn.isUserInteractionEnabled = true
        
    }
    
    
    @IBAction func SelectStandard() {
        // Setup dropdown anchor and data source
        standardDropdown.anchorView = standardView
        standardDropdown.dataSource = StandardList
        standardDropdown.bottomOffset = CGPoint(x: 0, y: standardView.bounds.height)
        
        // Show the dropdown
        standardDropdown.show()
        
        // Handle the selection
        standardDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return } // Safely unwrap self
            
            print("Selected item: \(item) at index: \(index)")
            
            // Update the label inside the standardView
            standardLbl.text = item
            StandardId = StandardData?[index].id ?? ""
            SectionList.removeAll()
            for i in 0..<(StandardData?[index].sections?.count ?? 0) {
                
                SectionList.append(StandardData?[index].sections?[i].name ?? "")
            }
        
            sectionLbl.text = "Section"
            sectionId = ""
            SectionData = StandardData?[index].sections
            
            student_attendance_report()
        }
    }
    
    @IBAction func Select_Academic_Year() {
        
        AcademicDropdown.anchorView = AcademicYearView
        AcademicDropdown.dataSource = AcademicList
        AcademicDropdown.show()
        AcademicDropdown.bottomOffset = CGPoint(x: 0, y: AcademicYearView.bounds.height)
        
        AcademicDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            print("Selected item: \(item) at index: \(index)")
            
            // Update the label inside the UIView
            AcademicYearLbl.text = item
            AcademicYearId = academicYearData?[index].id
            
            StandardList.removeAll()
            SectionList.removeAll()
            if let year = AcademicYearId {
                Get_Standards(yearid: year)
            }
            
            TV.reloadData()
        }
    }

    @IBAction func SelectSection() {
        SectionDropdown.anchorView = SectionView
        SectionDropdown.dataSource = SectionList
        SectionDropdown.show()
        SectionDropdown.bottomOffset = CGPoint(x: 0, y: SectionView.bounds.height)
        
        SectionDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            print("Selected item: \(item) at index: \(index)")
            
            // Update the label inside the UIView
            sectionLbl.text = item
            sectionId = SectionData?[index].id ?? ""
            student_attendance_report()
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
    
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func AllPresentAct(_ sender: Any) {
        
        user_inputs.class_id  = StandardId
        user_inputs.section_id  = sectionId
        let alert = CustomAlert()
        alert.showAlertCancel(title: "", message: AlertstringFile.Mark_All_as_Present, actionLbl1: "Ok", actionLbl2: "Cancel", on: self, onOk: {self.markAttendaceApi()} , onNo: {print("Canceled")})
    }
    
    
    
    func markAttendaceApi(){
        
        
        APIService.shared
            .makeApi(url: ServiceUrl.attendance_send_absentees_sms_with_session_type, parameters:[
                
                MarkAttendenceStringFile.student_id: [],
                MarkAttendenceStringFile.class_id: user_inputs.class_id,
                MarkAttendenceStringFile.section_id: user_inputs.section_id,
                MarkAttendenceStringFile.all_present: user_inputs.all_present,
                MarkAttendenceStringFile.attendance_type: user_inputs.attendance_type,
                MarkAttendenceStringFile.session_type: user_inputs.session_type,
                MarkAttendenceStringFile.attendance_date: user_inputs.attendance_date
                
            ] , type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "" ){ [self] (
                result : Result<CommonApiSuc,
                Error>
            ) in
                
                switch result {
                    
                case.success(let succesmessage) :
                    
                    if succesmessage.status == true {
                        
                        DispatchQueue.main.async { [self] in
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) {
                                    self.dismiss(animated: true)
                                    
                                }
                            
                        }
                    }else {
                        
                        DispatchQueue.main.async {
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self
                                ){
                                    self.dismiss(animated: true)
                                }
                            
                        }
                    }
                    
                case.failure(let error) :
                    
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
                
            }
        
        
    }
    
    @IBAction func MarkAbsentAct(_ sender: Any) {
        let date = ConvertDateStringSmart(DateBtn.titleLabel?.text ?? "")
        user_inputs.section_id = sectionId
        user_inputs.class_id = StandardId
        user_inputs.attendance_date = date
        
        let vc = StudentHistryVC(nibName: nil, bundle: nil)
        vc.isAttandanceMarkingScreen = true
        vc.selected_sectionID = sectionId
        vc.selectedAcadimicYearId = AcademicYearId
        vc.StandardString = standardLbl.text
        vc.SectionString = sectionLbl.text
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func Get_Standards(yearid: Int) {
        
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [COMMON_PARAMETER.academic_year_id : yearid], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "") { [self] (result:Result <GetStandardsSuc,Error>) in
            
            switch result {
            case .success(let successMessage):
                DispatchQueue.main.async { [self] in
                    if successMessage.status == true{
                        
                    
                            StandardData = successMessage.data
                            StandardData?.enumerated().forEach { index, standard in
                                StandardList.append(standard.name ?? "")
                            }
                            
                            StandardId = StandardData?.first?.id ?? ""
                            
                            if let sections = StandardData?.first?.sections{
                                SectionData = sections
                                for j in 0..<sections.count {
                                    SectionList.append(SectionData?[j].name ?? "")
                                }
                            }
                            sectionId = StandardData?.first?.sections?.first?.id ?? ""
                            
                            standardLbl.text = StandardData?.first?.name
                            sectionLbl.text = StandardData?.first?.sections?.first?.name ?? ""
                            student_attendance_report()
                        
                    }else{
                        CustomAlert
                            .showAlertWithOkAction(
                                title: AlertstringFile.Alert_title,
                                message: successMessage.message ?? "",
                                on: self
                            ) {
                                self.dismiss(animated: true)
                            }
                        sectionId = ""
                        StandardId = ""
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    print(error.localizedDescription)
                    sectionId = ""
                    StandardId = ""
                }
            }
        }
    }
    
    func get_Academic_year() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_recipient_get_academic_year_list, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "") {[self] (result: Result<get_academic_yearSuc,Error>) in
            
            switch result{
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        
                        academicYearData = SuccessMessage.data
                        
                        for i in 0..<(academicYearData?.count ?? 0){
                            
                            if let year = academicYearData?[i].year{
                                AcademicList.append(year)
                            }
                            
                            if academicYearData?[i].current_academic_year == true {
                                AcademicYearLbl.text = academicYearData?[i].year
                                AcademicYearId = academicYearData?[i].id ?? 0
                            }
                        }
                        if let yearId = AcademicYearId {
                            Get_Standards(yearid: yearId)
                        }
                    }
                }
                
            case .failure(let error):
                
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: Attendance report API Call
    func student_attendance_report(){
        
        let date = ConvertDateStringSmart(DateBtn.titleLabel?.text)
        
        let Param = [
            AttendanceReportStringFile.from_date : date,
            AttendanceReportStringFile.to_date : date,
            AttendanceReportStringFile.standard_id : StandardId,
            AttendanceReportStringFile.section_id : sectionId,
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.attendance_student_attendance_report, parameters: Param, type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "") { [self] (result:Result<AttendanceReportResponse,Error>) in
            
            switch result {
                
            case .success(let successMessage):
                
                if successMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        
                        attendenceReport = successMessage.data
                        FilteredReport = attendenceReport
                        TV.reloadData()
                    }
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                        attendenceReport = successMessage.data
                        FilteredReport = attendenceReport
                        TV.reloadData()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

}

@available(iOS 14.0, *)
extension MarkAttendenceVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FilteredReport?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.AttendenceReportTVCell, for: indexPath) as! AttendenceReportTVCell
        
        let report = FilteredReport?[indexPath.row]
        
        cell.NameLbl.text = report?.student_name
        cell.AdmisionNOLbl.text = "Admission No: \(report?.admission_no ?? "")"
        
        if report?.att_status == "P"{
            
           // cell.cellView.layer.borderColor = UIColor.systemGreen.cgColor
            cell.statusView.backgroundColor = .systemGreen
            cell.statusLbl.text = "Present"
        }else if report?.att_status == "Not taken"{
            cell.statusLbl.text = "Not taken"
        }
        else{
           // cell.cellView.layer.borderColor = UIColor.systemRed.cgColor
            cell.statusView.backgroundColor = .systemRed
            cell.statusLbl.text = "Absent"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

@available(iOS 14.0, *)
extension MarkAttendenceVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            FilteredReport = attendenceReport
        }else {
            
            let text = searchText.lowercased()
            
            FilteredReport = attendenceReport?.filter { AttenenceReportData in
                
                (AttenenceReportData.student_name?.lowercased().contains(text) ?? false) ||
                (AttenenceReportData.admission_no?.lowercased().contains(text) ?? false)
            }
        }
        
        TV.reloadData()
    }
}
