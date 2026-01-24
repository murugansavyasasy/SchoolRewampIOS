//
//  NewAbsenteesViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 23/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import FSCalendar

class NewAbsenteesViewController: UIViewController, UIGestureRecognizerDelegate, call {
    func callMobileNumber(indexPath: Int) {
        makePhoneCall(to: absentStudentData[indexPath].primary_mobile ?? "")
    }
    
    
   
    @IBOutlet weak var totalAbsentBtn: UIButton!
    @IBOutlet weak var noRecordView: UIView!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var mothView: UIView!
    @IBOutlet weak var mothLbl: UILabel!
    @IBOutlet weak var studentLbl: UILabel!
    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var calanderHeighnt: NSLayoutConstraint!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var progres: UIProgressView!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var tvHeight: NSLayoutConstraint!
    @IBOutlet weak var abesentCountLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var sectionLbl: UILabel!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var calanderFulView: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var cvIcon: UICollectionView!
    
    var ClickID = 0
    var absentData: [AbsenteeDate]?
    var class_wiseData: [ClassWise]?
    var sectionwiseData: [SectionBasedList]?
    let StaffDetails = UserDefaultFileManager.get_staff_Details()
    var eventDates: [Date] = []
    var sectionWiseArray: [SectionAbsentees] = []
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateInputs.dd_MM_yyyy
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    var absentStudentData: [AbsentisReportStudent] = []
    var selectedDate: String?
    var Class  = "Class : "
    var Section = "Section : "
    var Absent   = "Absent : "
    var Absentees   = "Absentees : "
    var Total_students   = "Total students : "
    var month: String = ""
    var year: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noRecordView.layer.cornerRadius = 8
        BackBtn.applyBackButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: StaffDetails?.school_name ?? "")
        
        totalAbsentBtn.layer.cornerRadius = totalAbsentBtn.frame.height / 2
        totalAbsentBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        updateMonthLabel()
        dateLbl.isHidden = true
        cvIcon.isHidden = true
        infoStack.isHidden = true
        Tv.isHidden = true
        fullview.backgroundColor = .clear
        studentLbl.isHidden = true
        let formatter = DateFormatter()
        formatter.dateFormat = DateOutPut.EE_MMM_dd_yyyy
        // current date string in dd-MM-yyyy
        let currentDateString = formatter.string(from: Date())
        dateLbl.text = currentDateString
        calanderFulView.layer.cornerRadius = 10
        calendar.delegate = self
        calendar.dataSource = self
        scrollview.delegate = self
        scrollview.alwaysBounceVertical = true
        calendar.appearance.headerTitleColor = .systemBlue
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.selectionColor = .error
        calendar.appearance.todayColor = UIColor.error.withAlphaComponent(0.6)
        calendar.placeholderType = .none
        calendar.headerHeight = 0
        calendar.allowsMultipleSelection = false
        calendar.scrollEnabled = false
        mothView.layer.cornerRadius = 10
        fullview.layer.cornerRadius = 10
        cvIcon.register(UINib(nibName: CellConfingName.CVIconCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.CVIconCollectionViewCell)
        Tv.register(UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ClassTableViewCell)
        cvIcon.dataSource = self
        cvIcon.delegate = self
        Tv.dataSource = self
        Tv.delegate = self
        
        let currentDate = Date()
        let calendar = Calendar.current

        let month = String(calendar.component(.month, from: currentDate))
        let year = String(calendar.component(.year, from: currentDate))

        self.month = month
        self.year = year
        print(month) // e.g. "4"
        print(year)  // e.g. "2025"

        Absentees_Response()
    }
    
    @IBAction func BackAct() {
        dismiss(animated: true)
    }
    
    func makePhoneCall(to phoneNumber: String) {
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(phoneCallURL) {
                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func Absentees_Response() {
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_api_attendance_get_absentees_count_by_date, parameters: ["month_id": month ,"year_id" : year], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<AbsenteesResponse, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.absentData = response.data
                    self.class_wiseData = self.absentData?.first?.class_wise ?? []
                    self.eventDates.removeAll()
                    if let data = response.data {
                        for item in data {
                            if let total = item.total_absentees,
                               let totalInt = Int(total),
                               totalInt > 0,
                               let dateStr = item.date,
                               let date = self.dateFormatter.date(from: dateStr) {
                                self.eventDates.append(date)}}}
                    
                    let today = Date()
                    let calendar = Calendar.current
                    let hasEventToday = self.eventDates.contains { eventDate in
                        calendar.isDate(eventDate, inSameDayAs: today)}
                    
                    if !hasEventToday {
                        self.dateLbl.isHidden = !hasEventToday
                        self.cvIcon.isHidden = !hasEventToday
                        self.infoStack.isHidden = !hasEventToday
                        self.Tv.isHidden = !hasEventToday
                        self.fullview.isHidden = true
                        self.noRecordView.isHidden = false
                        self.noRecordLbl.text = MenuStringFile.No_Absentees_Report_from_this_date
                        self.studentLbl.isHidden = true
                    }else{
                        self.studentLbl.isHidden = false
                        self.dateLbl.isHidden = false
                        self.cvIcon.isHidden = false
                        self.infoStack.isHidden = false
                        self.Tv.isHidden = false
                        self.fullview.backgroundColor = .white
                        self.fullview.isHidden = false
                        self.noRecordView.isHidden = true
                        let formatter = DateFormatter()
                        formatter.dateFormat = DateInputs.dd_MM_yyyy
                        let currentDateString = formatter.string(from: Date())
                        if let ids = self.getClassAndSectionID(
                            for: currentDateString) {
                            self.AbsentStudent(
                                sectionId:ids.sectionID ?? "" ,
                                date: currentDateString,
                                standarId: ids.classID ?? "")}
                        if let info = self.getAbsenteeInfo(
                            for: currentDateString) {self.updateProgress(
                                absentees: "\(info.totalAbsentees)",
                                total: "\(info.studentCounts)")}}
                    self.calendar.reloadData()
                    if let firstDate = self.absentData?.first?.date {
                        self.filterData(for: firstDate)
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error fetching absentees:", error.localizedDescription)
                    self.fullview.isHidden = true
                    self.noRecordView.isHidden = false
                    self.noRecordLbl.text = error.localizedDescription
                }
            }
        }
    }
    
    func noRecord(){
        self.studentLbl.isHidden = false
        self.dateLbl.isHidden = false
        self.cvIcon.isHidden = false
        self.infoStack.isHidden = false
        self.Tv.isHidden = false
        self.fullview.backgroundColor = .white
        self.fullview.isHidden = false
        self.noRecordView.isHidden = true
    }
    func setAbsentButtonTitle(totalAbsent: String) {
        let titleText = "Total Absent: \(totalAbsent)"

        let attributedString = NSMutableAttributedString(
            string: titleText,
            attributes: [
                .foregroundColor: UIColor.black
            ]
        )

        let countRange = (titleText as NSString).range(of: "\(totalAbsent)")
        attributedString.addAttributes(
            [
                .foregroundColor: UIColor.red
            ],
            range: countRange
        )

        totalAbsentBtn.setAttributedTitle(attributedString, for: .normal)
    }
    
    func filterData(for date: String) {
        guard let allData = self.absentData else { return }
        let filteredClassWise = allData.filter { $0.date == date }
        self.sectionWiseArray = flattenClassWiseData(classData: filteredClassWise.first?.class_wise ?? [])
        classNameLbl.text =  (
            sectionWiseArray.first?.class_name ?? ""
        )
        sectionLbl.text =  (
            sectionWiseArray.first?.section_name ?? ""
        )
        self.cvIcon.reloadData()
    }
    
    func flattenClassWiseData(classData: [ClassWise]) -> [SectionAbsentees] {
        var flatArray: [SectionAbsentees] = []
        for cls in classData {
            // ✅ Optional unwrap
            for section in cls.section_wise ?? [] {
                let item = SectionAbsentees(
                    class_name: cls.class_name ?? "",
                    class_id: cls.class_id ?? "",
                    section_name: section.section_name ?? "",
                    section_id: section.section_id ?? "",
                    total_absentees: section.total_absentees ?? "", student_counts: section.student_counts ?? "")
                flatArray.append(item)
            }
        }
        return flatArray
    }
    
    
    func AbsentStudent(sectionId: String, date: String,standarId:String) {
        let param = [
            AbsenteesReportStringFile.absent_on: date,
            AbsenteesReportStringFile.section_id: sectionId,
            AbsenteesReportStringFile.standard_id: standarId
        ]
        APIService.shared.makeApi(
            url: ServiceUrl.stud_attd_api_attendance_get_absentees_students_by_date,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: StaffDetails?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<AbsentisReportStudentResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.absentStudentData = response.data
                    self.Tv.reloadData()
                    self.updateTableHeight()
                case .failure(let error):
                    print("API error: \(error.localizedDescription)")
                    
                }
            }
        }
    }
    
    
}

// MARK: - UICollectionViewDelegate & DataSource
extension NewAbsenteesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionWiseArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.CVIconCollectionViewCell, for: indexPath) as? scetionCvcell else {
            return UICollectionViewCell()
        }
        let data = sectionWiseArray[indexPath.item]
        cell.standardLbl.text = Class + data.class_name
        cell.sectionLbl.text = Section + data.section_name
        cell.absentCountLbl.text =  Absent +  data.total_absentees + " / " +  data.student_counts
        if ClickID == indexPath.row  {
            cell.fullview.backgroundColor = .primery
            cell.fullview.layer.cornerRadius = 10
            cell.absentFullview.layer.cornerRadius = 5
            cell.standardLbl.textColor = .white
            cell.sectionLbl.textAlignment = .center
            cell.standardLbl.textAlignment = .center
            cell.absentCountLbl.textAlignment = .center
            cell.progress.isHidden = false
            cell.updateProgress(absentees:data.total_absentees , total: data.student_counts)
            cell.sectionLbl.textColor = .white
            cell.absentCountLbl.textColor = .primery
            classNameLbl.text =  data.class_name
            sectionLbl.text =  data.section_name
            abesentCountLbl.text =  Absentees + "\(data.total_absentees)"
            totalLbl.text = Absentees + "\(data.student_counts)"
            cell.absentFullview.backgroundColor = .attendence
        } else {
            cell.fullview.backgroundColor = .systemGray6
            cell.fullview.layer.cornerRadius = 10
            cell.progress.isHidden = true
            cell.sectionLbl.textAlignment = .left
            cell.standardLbl.textAlignment = .left
            cell.absentCountLbl.textAlignment = .left
            cell.standardLbl.textColor = .black
            cell.sectionLbl.textColor = .black
            cell.absentCountLbl.textColor = .black
            cell.absentFullview.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ClickID = indexPath.row
        let data = sectionWiseArray[indexPath.item]
        classNameLbl.text =  data.class_name
        sectionLbl.text =  data.section_name
        cvIcon.reloadData()
        updateProgress(
            absentees: data.total_absentees,
            total: data.student_counts)
        self.AbsentStudent(
            sectionId:data.section_id ,
            date: selectedDate ?? "",
            standarId: data.class_id)
        abesentCountLbl.text = Absentees + "\(data.total_absentees)"
        totalLbl.text = Total_students + "\(data.student_counts)"
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 110)
    }
    
    func updateProgress(absentees: String, total: String) {
        let absentCount = Float(absentees) ?? 0
        let totalCount = Float(total) ?? 1  // avoid divide by zero
        let progressValue = absentCount / totalCount
        progres.setProgress(progressValue, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension NewAbsenteesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return absentStudentData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ClassTableViewCell, for: indexPath) as? QuizSubmisionTvCell else {
            return UITableViewCell()
        }
        let data = absentStudentData[indexPath.row]
        cell.nameLbl.text = data.student_name
        cell.classLbl.text = data.roll_no
        cell.addmissionLbl.isHidden = data.admission_no ==  "" ? true : false
        cell.addmissionLbl.text =  MenuStringFile.admission_no + (data.admission_no ?? "")
        if data.photo_path == nil || data.photo_path == "" {
            cell.profileImage.tintColor = .error
            if data.gender == "male"{
                cell.profileImage.image = UIImage(named: "malesss")
                cell.profileImage.tintColor = .primery.withAlphaComponent(0.8)
            }else{
                cell.profileImage.image = UIImage(named: "FemaleGender")
                cell.profileImage.tintColor = .systemPink.withAlphaComponent(0.6)
            }
        }else{
            cell.profileImage.tintColor = .clear
            cell.profileImage.sd_setImage(with: URL(string: data.photo_path ?? ""), placeholderImage: UIImage(named: "placeholder"))}
        cell.StatusBtn.isHidden = true
        cell.separatorView.isHidden = false
        cell.FNStack.isHidden = false
        cell.ANStack.isHidden = false
        
        if let attStatus = absentStudentData[indexPath.row].attd_status {
            let parts = attStatus.components(separatedBy: "/")
            // Expecting formats like "P/A", "OD/OD", "P~/P", etc.
            if parts.count == 2 {
                let fnInfo = getStatusInfo(for: parts[0])
                let anInfo = getStatusInfo(for: parts[1])
                cell.FNBtn.setTitle(fnInfo.0, for: .normal)
                cell.FNBtn.backgroundColor = fnInfo.1
                cell.ANBtn.setTitle(anInfo.0, for: .normal)
                cell.ANBtn.backgroundColor = anInfo.1
            } else {
                // Fallback if format is unexpected
                cell.FNBtn.setTitle("-", for: .normal)
                cell.FNBtn.backgroundColor = .lightGray
                cell.ANBtn.setTitle("-", for: .normal)
                cell.ANBtn.backgroundColor = .lightGray
            }
        }
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    func updateTableHeight() {
        Tv.layoutIfNeeded()
        tvHeight.constant = Tv.contentSize.height
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateTableHeight()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
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
}
// MARK: - Data Models

extension NewAbsenteesViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance,UIScrollViewDelegate {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if eventDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            return 1 // show dot
        }
        return 0
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if eventDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            return [.error]  // dot color
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let hasEvent = eventDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
        if hasEvent {
            return true
        } else {
            fullview.isHidden = true
            noRecordView.isHidden = false
            noRecordLbl.text = MenuStringFile.No_Absentees_Report_from_this_date
            return false
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        ClickID = 0
        dateLbl.isHidden = false
        cvIcon.isHidden = false
        infoStack.isHidden = false
        Tv.isHidden = false
        fullview.backgroundColor = .white
        studentLbl.isHidden = false
        studentLbl.text = MenuStringFile.Absent_students_list
        let filterFormatter = DateFormatter()
        filterFormatter.dateFormat = DateInputs.dd_MM_yyyy
        let showFormatter = DateFormatter()
        showFormatter.dateFormat = DateOutPut.EE_MMM_dd_yyyy
        let selectedDateForFilter = filterFormatter.string(from: date)
        let selectedDateForLabel = showFormatter.string(from: date)
        // UILabel update
        dateLbl.text = selectedDateForLabel
        selectedDate = selectedDateForFilter
        // Data filter
        filterData(for: selectedDateForFilter)
        if let ids = self.getClassAndSectionID(
            for: selectedDate ?? ""
        ) {self.AbsentStudent(
            sectionId:ids.sectionID ?? "" ,
            date: selectedDate ?? "",
            standarId: ids.classID ?? "")}
        if let info = getAbsenteeInfo(for: selectedDateForFilter) {
            noRecordView.isHidden = true
            fullview.isHidden = false
            updateProgress(
                absentees: "\(info.totalAbsentees)",
                total: "\(info.studentCounts)")
        } else {
            noRecordView.isHidden = false
            fullview.isHidden = true
        }
        
    }
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date(timeIntervalSince1970: 0) // very old date
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calanderHeighnt.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    @IBAction func nextMonthTapped(_ sender: UIButton) {
        moveCurrentPage(isNext: true)
    }
    
    @IBAction func prevMonthTapped(_ sender: UIButton) {
        moveCurrentPage(isNext: false)
    }
    
//    func moveCurrentPage(isNext: Bool) {
//        let current = calendar.currentPage
//        var dateComponents = DateComponents()
//        dateComponents.month = isNext ? 1 : -1
//        //let newDate = Calendar.current.date(byAdding: dateComponents, to: current)!
//        guard let newDate = Calendar.current.date(byAdding: dateComponents, to: current) else {  return }
//        calendar.setCurrentPage(newDate, animated: true)
//        updateMonthLabel()
//    }
    
    func moveCurrentPage(isNext: Bool) {
        let currentPage = calendar.currentPage

        var dateComponents = DateComponents()
        dateComponents.month = isNext ? 1 : -1

        guard let newDate = Calendar.current.date(byAdding: dateComponents, to: currentPage) else {
            return
        }

        // 1. Remove currently selected date (if any)
        if let selectedDate = calendar.selectedDate {
            calendar.deselect(selectedDate)
        }

        calendar.setCurrentPage(newDate, animated: true)

        // 2. If moved to the current month, select today
        let today = Date()
        if Calendar.current.isDate(newDate, equalTo: today, toGranularity: .month) {
            calendar.select(today)
            let showFormatter = DateFormatter()
                showFormatter.dateFormat = DateOutPut.EE_MMM_dd_yyyy
            let selectedDateForLabel = showFormatter.string(from: today)
            dateLbl.text = selectedDateForLabel
        }

        updateMonthLabel()
    }

    
    func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = DateInputs.MMMM_yyyy   // Example: "September 2025"
        mothLbl.text = formatter.string(from: calendar.currentPage)
        let date = calendar.currentPage

        guard let text = mothLbl.text else { return }

        // DateFormatter to read "MMMM yyyy"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "MMMM yyyy"
        formatter2.locale = Locale(identifier: "en_US_POSIX")

        if let date = formatter2.date(from: text) {

            let calendar = Calendar.current

            let month = String(calendar.component(.month, from: date))
            let year  = String(calendar.component(.year, from: date))
            self.month = month
            self.year = year
        }

        Absentees_Response()
        //dateLbl.text =
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 {
            calendar.setScope(.week, animated: true)
        } else if velocity.y < 0 {
            calendar.setScope(.month, animated: true)
        }
    }
    
    func getClassAndSectionID(for selectedDate: String) -> (classID: String?, sectionID: String?)? {
        guard let absentData = absentData else { return nil }
        if let matchedDate = absentData.first(where: { $0.date == selectedDate }) {
            let classID = matchedDate.class_wise?.first?.class_id
            let sectionID = matchedDate.class_wise?.first?.section_wise?.first?.section_id
            return (classID, sectionID)
        }
        return nil
    }
    func getAbsenteeInfo(for selectedDate: String) -> (totalAbsentees: Int, studentCounts: Int)? {
        guard let absentData = absentData else { return nil }
        // Find the matching date entry
        if let matchedDate = absentData.first(where: { $0.date == selectedDate }),
           let classWiseList = matchedDate.class_wise {
            
            DispatchQueue.main.async {
                self.setAbsentButtonTitle(totalAbsent: matchedDate.total_absentees ?? "")
            }
            var totalAbs = 0
            var totalStu = 0
            // Loop through all classes and sections
            for classItem in classWiseList {
                if let sectionList = classItem.section_wise {
                    for section in sectionList {
                        let abs = Int(section.total_absentees ?? "0") ?? 0
                        let stu = Int(section.student_counts ?? "0") ?? 0
                        totalAbs += abs
                        totalStu += stu
                    }
                }
            }
            return (totalAbs, totalStu)
        }
        return nil
    }
}


struct SectionBasedList {
    let className: String
    let section_id: String
    let sectionName: String
    let absentCount: String
    let date: String
}

struct SectionAbsentees: Codable {
    let class_name: String
    let class_id: String
    let section_name: String
    let section_id: String
    let total_absentees: String
    let student_counts: String
}
