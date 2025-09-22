//
//  MarkAttendenceVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 13/12/24.
//

import UIKit
import DropDown
import FSCalendar

@available(iOS 14.0, *)
class MarkAttendenceVC: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backBtnName: UIButton!
    @IBOutlet weak var graphDownImg: UIImageView!
    @IBOutlet weak var graphUpImg: UIImageView!
    @IBOutlet weak var dateDayLbl: UILabel!
   
    @IBOutlet weak var absentPersentage: UILabel!
    @IBOutlet weak var presentPeretageLbl: UILabel!
    @IBOutlet weak var AttendaceSectionStac: UIStackView!
    @IBOutlet weak var attendaceTypeStack: UIStackView!
    @IBOutlet weak var attendancedefault: UILabel!
    @IBOutlet weak var reportFullView: UIView!
    @IBOutlet weak var tvHeight: NSLayoutConstraint!
    @IBOutlet weak var AcademicYearLbl: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var mnthLbl: UILabel!
    @IBOutlet weak var calanderFulView: UIView!
   
    @IBOutlet weak var AcademicYearView: UIView!
    @IBOutlet weak var SearchbarHeight: NSLayoutConstraint!
    @IBOutlet weak var SearchBar: UISearchBar!
    
   
   
    @IBOutlet weak var absentView: UIView!
    @IBOutlet weak var presentView: UIView!
   
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var HalfDayBtn: UIButton!
   
    @IBOutlet weak var FulldayBtn: UIButton!
   
    @IBOutlet weak var selectStandardandSectionDefaultLbl: UILabel!
   
    @IBOutlet weak var sectionLbl: UILabel!
    @IBOutlet weak var standardLbl: UILabel!
   
    @IBOutlet weak var MarkAbsentiesBtn: UIButton!
    @IBOutlet weak var SectionView: UIView!
    @IBOutlet weak var standardView: UIView!
    @IBOutlet weak var TV: UITableView!
 
    @IBOutlet weak var MarkAttendanceBtn: UIButton!
    @IBOutlet weak var ReportsBtn: UIButton!
    
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
    var selectedDate = ""
    var alert = CustomAlert()
    var IsMarkAttendaceSelected : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BottomView.layer.cornerRadius = 8
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let currentDateString = formatter.string(from: Date())
        selectedDate = currentDateString
        dateDayLbl.text = currentDateString
        updateMonthLabel()
        UIupdate()
        get_Academic_year()
        SearchBar.searchTextField.addDoneButton()
        backBtnName.applyBackButton()
       
        addUnderline(to: MarkAttendanceBtn, unselectedButton: ReportsBtn)
        let AcademicTap = UITapGestureRecognizer(target: self, action: #selector(Select_Academic_Year))
        AcademicYearView.addGestureRecognizer(AcademicTap)
        
        let standardTap = UITapGestureRecognizer(target: self, action: #selector(SelectStandard))
        standardView.addGestureRecognizer(standardTap)
        
        let sectionTap = UITapGestureRecognizer(target: self, action: #selector(SelectSection))
        SectionView.addGestureRecognizer(sectionTap)
        TV.register(
                UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil),
                forCellReuseIdentifier: CellConfingName.ClassTableViewCell
            )

    }
    
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    func updateTableHeight() {
        TV.layoutIfNeeded()
        tvHeight.constant = TV.contentSize.height
    }
    
    func UIupdate() {
        
        TV.isHidden = true
        
        backBtnName
            .configureAsBackButton(
                firstLine: MenuStringFile.selectedMenuName,
                secondLine: StaffDetails?.school_name ?? ""
            )
        AttendaceSectionStac.isHidden = true
        applyDesign(element: standardView)
        applyDesign(element: SectionView)
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        reportFullView.layer.cornerRadius = 10
        MarkAbsentiesBtn.layer.cornerRadius = 10
        MarkAbsentiesBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        selectStandardandSectionDefaultLbl.setFont(style: .title, size: FontSize.TitleSize)
        standardView.layer.cornerRadius =  5
        standardView.layer.borderWidth = 1
        standardView.layer.borderColor =  UIColor.primery.cgColor
        SectionView.layer.cornerRadius = 5
        SectionView.layer.borderWidth =  1
        SectionView.layer.borderColor =  UIColor.primery.cgColor
        FulldayBtn.backgroundColor = .systemBlue.withAlphaComponent(0.8)
        FulldayBtn.layer.cornerRadius = 8
        HalfDayBtn.backgroundColor = .systemGray4
        HalfDayBtn.layer.cornerRadius = 8
        calanderFulView.layer.cornerRadius = 10
        monthView.layer.cornerRadius = 10
//        myScrollView.delegate = self
        calendar.delegate = self
        calendar.dataSource = self
        
        presentView.setShadow()
        absentView.setShadow()
        AcademicYearView.setShadow()
        calendar.appearance.headerTitleColor = .systemBlue
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.selectionColor = .systemRed
        calendar.placeholderType = .none
        calendar.headerHeight = 0
        calendar.allowsMultipleSelection = false
        fulldayAction()
    }
    // MARK: - Date Selection
    func dateSelect(_ date: String?) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMM yy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE" // Full weekday name (e.g., Monday, Sunday)
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var selectedDate = Date()
        if let dateStr = date, !dateStr.isEmpty {
            selectedDate = inputFormatter.date(from: dateStr) ?? Date()
        }
      
    }
    
    func applyDesign(element: UIView,radius:Int = 10){
        
        element.layer.cornerRadius = 10
        element.layer.borderWidth = 1
        element.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    
    
    
    @IBAction func MarkAttendanceAct(_ sender: Any) {
        addUnderline(to: MarkAttendanceBtn, unselectedButton: ReportsBtn)
        reportFullView.isHidden = true
        attendaceTypeStack.isHidden = false
        AttendaceSectionStac.isHidden = false
        attendancedefault.isHidden = false
        reportFullView.isHidden = true
        MarkAbsentiesBtn.isHidden = false
        IsMarkAttendaceSelected = true
    }
    
    @IBAction func ReportsAct(_ sender: Any) {
        
        addUnderline(to: ReportsBtn, unselectedButton: MarkAttendanceBtn)
        student_attendance_report()
        attendaceTypeStack.isHidden = true
        AttendaceSectionStac.isHidden = true
        attendancedefault.isHidden = true
        reportFullView.isHidden = false
        absentView.setShadow()
        presentView.setShadow()
        SearchBar.isHidden = true
        MarkAbsentiesBtn.isHidden = true
        IsMarkAttendaceSelected = false
        
       
    }
    
    func addUnderline(to selectedButton: UIButton, unselectedButton: UIButton) {
        // Remove underline from both buttons
        [selectedButton, unselectedButton].forEach { button in
            button.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
            button.tintColor = .black
        }
        
        // Add underline to the selected button
        selectedButton.tintColor = .systemBlue
        let underline = UIView()
        underline.tag = 999
        underline.backgroundColor = .systemBlue
        underline.translatesAutoresizingMaskIntoConstraints = false
        selectedButton.addSubview(underline)
        
        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: selectedButton.bottomAnchor)
        ])
    }
    
    
    @IBAction func fullDayBtnAct(_ sender: UIButton) {
        
        FulldayBtn.backgroundColor = .systemBlue.withAlphaComponent(0.8)
        HalfDayBtn.backgroundColor = .systemGray4
        AttendaceSectionStac.isHidden = true
        fulldayAction()
        FirsthalfAct()
    
        
    }
    
    @IBAction func halfDayBtnAct(_ sender: UIButton) {
        
        FulldayBtn.backgroundColor = .systemGray4
        HalfDayBtn.backgroundColor = .systemBlue.withAlphaComponent(0.8)
        AttendaceSectionStac.isHidden = false
        
    }
    
    
    @IBAction func segmentAct(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            FirsthalfAct()
        }else{
            SecondhalfAct()
        }
    }
    @objc func fulldayAction(){
        user_inputs.attendance_type = "F"
        user_inputs.session_type = ""
        user_inputs.all_present = "T"
        //FulldayImgview.image = UIImage(named: "checked_Tick")
      
    }
    @objc func HalfdayAction(){
        
        user_inputs.attendance_type = "H"
        user_inputs.session_type = ""
        user_inputs.all_present = "T"
        
        
    }
    @objc func FirsthalfAct(){
        user_inputs.attendance_type = "H"
        user_inputs.session_type = "FH"
        user_inputs.all_present = "T"
        
    }
    @objc func SecondhalfAct(){
        user_inputs.attendance_type = "H"
        user_inputs.session_type = "SH"
        user_inputs.all_present = "T"
        
        
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
            guard let self = self else { return }
            // Update the label inside the standardView
            standardLbl.text =  item
            StandardId = StandardData?[index].id ?? ""
            SectionList.removeAll()
            for i in 0..<(StandardData?[index].sections?.count ?? 0) {
                
                SectionList.append(StandardData?[index].sections?[i].name ?? "")
            }
            
            sectionLbl.text = StandardData?[index].sections?.first?.name ?? ""
            sectionId = StandardData?[index].sections?.first?.id ?? ""
            SectionData = StandardData?[index].sections
            
//            if let year = AcademicYearId {
//                Get_Standards(yearid: year)
//            }
            
            if  IsMarkAttendaceSelected != true{
                student_attendance_report()
            }
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
            if  IsMarkAttendaceSelected != true{
                student_attendance_report()
            }
           
        }
    }
    
   
    @IBAction func BackBtnAct(_ sender: Any) {dismiss(animated: true)}
    
    @IBAction func AllPresentAct(_ sender: Any) {
        
        user_inputs.class_id  = StandardId
        user_inputs.section_id  = sectionId
        let alert = CustomAlert()
        alert.showAlertCancel(title: "", message: AlertstringFile.Mark_All_as_Present, actionLbl1: "Ok", actionLbl2: "Cancel", on: self, onOk: {self.markAttendaceApi()} , onNo: {print("Canceled")})
    }
    
    func markAttendaceApi(){
        APIService.shared.makeApi(url:ServiceUrl.attendance_send_absentees_sms_with_session_type, parameters:[
                
                MarkAttendenceStringFile.student_id: [],
                MarkAttendenceStringFile.class_id: user_inputs.class_id,
                MarkAttendenceStringFile.section_id: user_inputs.section_id,
                MarkAttendenceStringFile.all_present: user_inputs.all_present,
                MarkAttendenceStringFile.attendance_type: user_inputs.attendance_type,
                MarkAttendenceStringFile.session_type: user_inputs.session_type,
                MarkAttendenceStringFile.attendance_date: user_inputs.attendance_date
                
            ] , type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "" ){ [self] (result : Result<CommonApiSuc,Error>) in
                
                switch result {
                case.success(let succesmessage) :
                    if succesmessage.status == true {
                        DispatchQueue.main.async { [self] in
                            CustomAlert.showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self) {
                                    self.dismiss(animated: true)
                                }
                        }
                    }else {
                        DispatchQueue.main.async {
                            CustomAlert.showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self){
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
        user_inputs.section_id = sectionId
        user_inputs.class_id = StandardId
        user_inputs.attendance_date = selectedDate
        
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
//                        student_attendance_report()
                        
                    }else{
                        CustomAlert.showAlertWithOkAction(
                                title: AlertstringFile.Alert_title,
                                message: successMessage.message ?? "",
                                on: self) {
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
        
        
        
        let Param = [
            AttendanceReportStringFile.from_date :  selectedDate,
            AttendanceReportStringFile.to_date : selectedDate,
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
                        
                        // ✅ Calculate counts
                        let totalCount = attendenceReport?.count
                        let presentCount = attendenceReport?.filter {
                            $0.att_status == "P"
                        }.count
                        let absentCount = attendenceReport?.filter {
                            $0.att_status == "A"
                        }.count
                        
                        // ✅ Percentages
                        let presentPercentage = totalCount ?? 0 > 0 ? (
                            Double(presentCount ?? 0) / Double(totalCount ?? 0)
                        ) * 100 : 0
                        let absentPercentage = totalCount ?? 0 > 0 ? (
                            Double(absentCount ?? 0) / Double(totalCount ?? 0)
                        ) * 100 : 0
                        
                    
                        
                        presentPeretageLbl.text = "\(presentPercentage.rounded(.down))%"
                        absentPersentage.text = "\(absentPercentage.rounded(.down))%"
                        
                        if Int(presentPercentage.rounded(.down)) == 100 {
                            
                            graphDownImg.image = UIImage(named: "presentGraps")
                            graphDownImg.image = UIImage(named: "AbsentGraph")
//                            absent
                            
                        } else if Int(presentPercentage.rounded(.down)) == Int(absentPercentage.rounded(.down)) {
                            let value = Int(presentPercentage.rounded(.down))
                          
                            graphDownImg.image = UIImage(named: "presentGraps")
                            graphDownImg.image = UIImage(named: "AbsentGraph")
                            
                        } else if presentPercentage < absentPercentage {
                            
                            graphDownImg.image = UIImage(named: "presentGraps")
                            
                            graphDownImg.tintColor = .green
                            graphUpImg.image = UIImage(named: "AbsentGraph")
                            graphUpImg.tintColor = .red
                            
                        } else if presentPercentage > absentPercentage {
                            
                            
                            graphDownImg.image = UIImage(named: "AbsentGraph")
                            
                            graphDownImg.tintColor = .red
                            graphUpImg.image = UIImage(named: "presentGraps")
                            graphUpImg.tintColor = .green
                            
                        }else {
                            // default case
                            presentPeretageLbl.text = "\(Int(presentPercentage.rounded(.down)))%"
                            absentPersentage.text = "\(Int(absentPercentage.rounded(.down)))%"
                        }

                        
                        
                        // ✅ Table reload
                        TV.isHidden = false
                        reportFullView.isHidden = false
                        TV.dataSource = self
                        TV.delegate = self
                        TV.reloadData()
                        DispatchQueue.main.async { [self] in
                            updateTableHeight()
                        }
                    }
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                        attendenceReport = successMessage.data
                        FilteredReport = attendenceReport
                        alert.showAlert(
                            title: AlertstringFile.Alert_title,
                            message:  successMessage.message ?? "" + "\n" + " on this date",
                            on: self
                        )
                        reportFullView.isHidden = true
                        TV.reloadData()
                        updateTableHeight()
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
        
        let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.ClassTableViewCell, for: indexPath) as! QuizSubmisionTvCell
        
        
        cell.nameLbl.text = FilteredReport?[indexPath.row].student_name
        cell.classLbl.text = "admission no : " + (FilteredReport?[indexPath.row].admission_no ?? "")
        if FilteredReport?[indexPath.row].att_status == "P"{
            cell.StatusBtn.setTitle("Present", for: .normal)
            cell.StatusBtn.backgroundColor = .systemGreen
        }else{
            cell.StatusBtn.setTitle("Absent", for: .normal)
            cell.StatusBtn.backgroundColor = .systemRed.withAlphaComponent(0.8)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateTableHeight()
        }
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
@available(iOS 14.0, *)
extension MarkAttendenceVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
   
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
       
        let filterFormatter = DateFormatter()
        filterFormatter.dateFormat = "dd-MM-yyyy"
        
        let showFormatter = DateFormatter()
        showFormatter.dateFormat = "MMMM dd, yyyy"
        
        let selectedDateForFilter = filterFormatter.string(from: date)
        let selectedDateForLabel = showFormatter.string(from: date)
        selectedDate = selectedDateForFilter
        print("Selected Date (Filter): \(selectedDateForFilter)")
        print("Selected Date (Label): \(selectedDateForLabel)")
        dateDayLbl.text = selectedDateForLabel
        print("mark attendance  \(MarkAttendanceBtn.isSelected)")
        if IsMarkAttendaceSelected !=  true{
            student_attendance_report()
        }
        
        
        
    }
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date(timeIntervalSince1970: 0) // very old date
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            return date <= Date()
        }
    
    
   

    @IBAction func nextMonthTapped(_ sender: UIButton) {
        moveCurrentPage(isNext: true)
    }

    @IBAction func prevMonthTapped(_ sender: UIButton) {
        moveCurrentPage(isNext: false)
    }

    func moveCurrentPage(isNext: Bool) {
        let current = calendar.currentPage
        var dateComponents = DateComponents()
        dateComponents.month = isNext ? 1 : -1
        
        let newDate = Calendar.current.date(byAdding: dateComponents, to: current)!
        calendar.setCurrentPage(newDate, animated: true)
        
        updateMonthLabel()
    }
    
   
    
    func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"   // Example: "September 2025"
        mnthLbl.text = formatter.string(from: calendar.currentPage)
    }


}
