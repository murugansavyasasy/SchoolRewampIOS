//
//  MarkAttendenceVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 13/12/24.
//

import UIKit
//import DropDown
import FSCalendar
import MarqueeLabel

@available(iOS 14.0, *)
class MarkAttendenceVC: UIViewController {
    
  
    
    @IBOutlet weak var scrollingLbl: MarqueeLabel!
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var noSearchDataLbl: UILabel!
    @IBOutlet weak var LatePresentageLbl: UILabel!
    @IBOutlet weak var ODperesentageLbl: UILabel!
    @IBOutlet weak var absentPresentageLbl: UILabel!
    @IBOutlet weak var PresentPresentageLbl: UILabel!
    @IBOutlet weak var notTakenView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backBtnName: UIButton!
    @IBOutlet weak var QuickStatus: UIButton!
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
    
    @IBOutlet weak var notTakenLbl: UILabel!
    let formatter = DateFormatter()
    let customdate = DateFormatter()
    let standardDropdown = DropDown()
    let SectionDropdown = DropDown()
    let AcademicDropdown = DropDown()
    let StaffDetails = UserDefaultFileManager.get_staff_Details()
    var attendenceReport : [AttendanceDataList]?
    var FilteredReport : [AttendanceDataList]?
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
        notTakenView.layer.cornerRadius = 8
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let currentDateString = formatter.string(from: Date())
        selectedDate = currentDateString
    
        dateDayLbl.text = currentDateString
        
        
        if let date = formatter.date(from: selectedDate) {
            let showFormatter = DateFormatter()
            showFormatter.dateFormat = "EE MMM dd, yyyy"
            
            let formattedDate = showFormatter.string(from: date)
            print(formattedDate)  // Example: Mon Sep 22, 2025
            dateDayLbl.text = formattedDate
        }
        
        AttendaceSectionStac.isHidden = true
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
                UINib(nibName: "ReportAttCell", bundle: nil),
                forCellReuseIdentifier: "ReportAttCell"
            )

    }
    
    func startContinuousMarquee(_ label: UILabel, speed: Double = 40) {

        label.layer.removeAllAnimations()

        let textWidth = label.intrinsicContentSize.width
        let labelWidth = label.bounds.width

        // If text fits inside, no scroll
        if textWidth <= labelWidth { return }

        // Place label starting at X = 0
        label.frame.origin.x = 0

        let totalDistance = textWidth + labelWidth
        let duration = totalDistance / speed   // speed = pts per second

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [.curveLinear, .repeat],
                       animations: {

            // Move fully to the left & off screen
            label.frame.origin.x = -textWidth

        }, completion: nil)
    }


    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        // Shift your main view slightly up
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardHeight / 2.5
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // Move view back to normal
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @IBAction func searchActBtn(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected{
            SearchBar.isHidden = false
            SearchBar.becomeFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
            sender.tintColor = .label
        }else{
            
            SearchBar.isHidden = true
            sender.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            sender.tintColor = .black
            noSearchDataLbl.isHidden = true
            searchImage.isHidden = true
            SearchBar.resignFirstResponder()
            SearchBar.searchTextField.text = ""
            FilteredReport = attendenceReport
            TV.reloadData()
            
        }
        
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
        calendar.appearance.selectionColor = .primery
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
        attendancedefault.isHidden = false
        reportFullView.isHidden = true
        MarkAbsentiesBtn.isHidden = false
        IsMarkAttendaceSelected = true
        notTakenView.isHidden = true
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
        
    @IBAction func InfoBtnAct(_ sender: UIButton) {
        let popoverVC = PopoverViewVC(nibName: nil, bundle: nil)
            
        popoverVC.configureButtons(with: [
            ("FN", "ForeNoon", .blue),
            ("AN", "AfterNoon", .blue),
            ("P",  "Present", .systemGreen),
            ("A",  "Absent", .systemRed),
            ("OD", "On Duty", .systemBlue),
            ("LA", "Late", .systemOrange),
            ("-",  "Not Taken", .systemGray)
        ], type: .badge)
            showPopover(from: sender, contentVC: popoverVC)
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
    
        
    }
    
    @IBAction func halfDayBtnAct(_ sender: UIButton) {
        FirsthalfAct()
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
   

    @objc func FirsthalfAct(){
        user_inputs.attendance_type = "H"
        user_inputs.session_type = "FH"
        user_inputs.all_present = "F"
        
    }
    @objc func SecondhalfAct(){
        user_inputs.attendance_type = "H"
        user_inputs.session_type = "SH"
        user_inputs.all_present = "F"
        
        
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
            // Update the label inside the UIView
            sectionLbl.text = item
            sectionId = SectionData?[index].id ?? ""
            if  IsMarkAttendaceSelected != true{
                student_attendance_report()
            }
           
        }
    }
    
   
    @IBAction func BackBtnAct(_ sender: Any) {dismiss(animated: true)}
    
//    @IBAction func AllPresentAct(_ sender: Any) {
//        
//        user_inputs.class_id  = StandardId
//        user_inputs.section_id  = sectionId
//        let alert = CustomAlert()
//        alert.showAlertCancel(title: "", message: AlertstringFile.Mark_All_as_Present, actionLbl1: "Ok", actionLbl2: "Cancel", on: self, onOk: {self.markAttendaceApi()} , onNo: {print("Canceled")})
//    }
    
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
        
        let vc = AttendanceMarkingVC(nibName: nil, bundle: nil)
        vc.selected_sectionID = sectionId
        vc.selectedAcadimicYearId = AcademicYearId
        vc.StandardString = standardLbl.text ?? ""
        vc.SectionString = sectionLbl.text ?? ""
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
                    }else{
                        CustomAlert.showAlertWithOkAction(
                                title: AlertstringFile.Alert_title,
                                message: successMessage.message ?? "",
                                on: self) {
                                self.dismiss(animated: true)
                            }
                        
                        notTakenView.isHidden = false
                        BottomView.isHidden = true
                      
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
        presentPeretageLbl.text = ""
        absentPersentage.text = ""
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
                        attendenceReport = successMessage.data?.first?.attd_report ?? []
                        FilteredReport = attendenceReport
                        reportFullView.isHidden = false
                        notTakenView.isHidden = true
                        scrollingLbl.isHidden = true
                        if let message = successMessage.data?.first?.holiday_message,
                           !message.isEmpty {
                            DispatchQueue.main.async { [self] in
                                scrollingLbl.isHidden = false
                                scrollingLbl.type = .continuous
                                   scrollingLbl.speed = .duration(18.0)   // Slower scroll
                                   scrollingLbl.fadeLength = 10.0
                                   scrollingLbl.trailingBuffer = 30.0
                                   scrollingLbl.text = "📢Important Note: " + message
                            }
                        }

                        updateAttendancePercentages()
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
                        attendenceReport = successMessage.data?.first?.attd_report ?? []
                        FilteredReport = attendenceReport
                        reportFullView.isHidden = true
                        notTakenView.isHidden = false
                        notTakenLbl.text = successMessage.message ?? ""
                        TV.reloadData()
                        updateTableHeight()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func updateAttendancePercentages() {
        guard let data = FilteredReport else { return }

        let total = Double(data.count)
        var present = 0.0
        var absent = 0.0
        var od = 0.0
        var late = 0.0

        for item in data {
            guard let status = item.att_status else { continue }
            let parts = status.components(separatedBy: "/")

            if parts.count == 2 {
                let first = parts[0]
                let second = parts[1]

                // 1️⃣ Case: second half missing ("P/-")
                if second == "-" {
                    switch first {
                    case "P":
                        present += 1.0
                    case "A":
                        absent += 1.0
                    case "OD":
                        od += 1.0
                    case "P~":
                        late += 1.0
                    default:
                        break
                    }

                // 2️⃣ Case: first half missing ("-/P")
                } else if first == "-" {
                    switch second {
                    case "P":
                        present += 1.0
                    case "A":
                        absent += 1.0
                    case "OD":
                        od += 1.0
                    case "P~":
                        late += 1.0
                    default:
                        break
                    }

                // 3️⃣ Normal half-day logic (each half 0.5)
                } else {
                    for part in parts {
                        switch part {
                        case "P":
                            present += 0.5
                        case "A":
                            absent += 0.5
                        case "OD":
                            od += 0.5
                        case "P~":
                            late += 0.5
                        default:
                            break
                        }
                    }
                }
            }
        }

        // Convert to percentage
        let presentPercent = (present / total) * 100
        let absentPercent = (absent / total) * 100
        let odPercent = (od / total) * 100
        let latePercent = (late / total) * 100

        // Update UI labels
        PresentPresentageLbl.text = String(format: "%.1f%%", presentPercent)
        absentPresentageLbl.text = String(format: "%.1f%%", absentPercent)
        ODperesentageLbl.text = String(format: "%.1f%%", odPercent)
        LatePresentageLbl.text = String(format: "%.1f%%", latePercent)
    }

    
}

@available(iOS 14.0, *)
extension MarkAttendenceVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FilteredReport?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TV.dequeueReusableCell(withIdentifier: "ReportAttCell", for: indexPath) as! ReportAttCell
        
        cell.selectionStyle = .none
        cell.StudentLbl.text = FilteredReport?[indexPath.row].student_name
        cell.admissionLbl.text = "admission no : " + (
            FilteredReport?[indexPath.row].admission_no ?? "")
        cell.rollNumberLbl.isHidden =  (
            (FilteredReport?[indexPath.row].roll_no) == ""
        ) ? true : false
        
        cell.rollNumberLbl.text = "Roll No : " + (FilteredReport?[indexPath.row].roll_no ?? "")
        if let attStatus = FilteredReport?[indexPath.row].att_status {
            let parts = attStatus.components(separatedBy: "/")
            
            // Expecting formats like "P/A", "OD/OD", "P~/P", etc.
            if parts.count == 2 {
                let fnInfo = getStatusInfo(for: parts[0])
                let anInfo = getStatusInfo(for: parts[1])
                
                cell.FnBtnName.setTitle(fnInfo.0, for: .normal)
                cell.FnBtnName.backgroundColor = fnInfo.1
                
                cell.AnBtnName.setTitle(anInfo.0, for: .normal)
                cell.AnBtnName.backgroundColor = anInfo.1
            } else {
                // Fallback if format is unexpected
                cell.FnBtnName.setTitle("-", for: .normal)
                cell.FnBtnName.backgroundColor = .lightGray
                cell.AnBtnName.setTitle("-", for: .normal)
                cell.AnBtnName.backgroundColor = .lightGray
            }
        }
        
        
        return cell
    }
    
    
    // Helper function to map code -> (Title, Color)
    func getStatusInfo(for status: String) -> (String, UIColor) {
        switch status {
        case "P":
            return ("P", .systemGreen)
        case "A":
            return ("A", .error)
        case "OD":
            return ("OD", .systemBlue)
        case "P~":
            return ("LA", .button)
        default:
            return ("-", .lightGray)
        }
    }

    // Inside cellForRowAt:
   

    
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
        } else {
            let text = searchText.lowercased()
            
            FilteredReport = attendenceReport?.filter { AttenenceReportData in
                (AttenenceReportData.student_name?.lowercased().contains(text) ?? false) ||
                (AttenenceReportData.admission_no?.lowercased().contains(text) ?? false)
            }
        }
        
        // Reload table view smoothly without animation
        UIView.performWithoutAnimation {
            TV.reloadData()
            TV.layoutIfNeeded()
        }
        
        // Check if filtered data is empty
        let isEmpty = (FilteredReport?.isEmpty ?? true)
        if isEmpty {
            // Optional UI handling
            noSearchDataLbl.isHidden = false
            searchImage.isHidden = false
            noSearchDataLbl.text = "No Student Data Found"
        } else {
            noSearchDataLbl.isHidden = true
            searchImage.isHidden = true
        }
    }

}
@available(iOS 14.0, *)
extension MarkAttendenceVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
   
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
       
        let filterFormatter = DateFormatter()
        filterFormatter.dateFormat = "dd-MM-yyyy"
        
        let showFormatter = DateFormatter()
        showFormatter.dateFormat = "EE MMM dd, yyyy"
        
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
@available(iOS 14.0, *)
extension MarkAttendenceVC: UIPopoverPresentationControllerDelegate {
    func showPopover(from sender: UIView, contentVC: UIViewController) {
        contentVC.modalPresentationStyle = .popover
        contentVC.preferredContentSize = CGSize(width: 180, height: 225)
        
        if let popover = contentVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .left
            popover.delegate = self
            popover.backgroundColor = .white
        }

        if UIDevice.current.userInterfaceIdiom == .phone {
            contentVC.modalPresentationStyle = .overFullScreen
            contentVC.view.backgroundColor = .white/*UIColor(white: 0, alpha: 0.3)*/
        }

        present(contentVC, animated: true)
    }

    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
