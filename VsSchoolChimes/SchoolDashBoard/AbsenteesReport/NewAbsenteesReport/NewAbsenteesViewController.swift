//
//  NewAbsenteesViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 23/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import FSCalendar

class NewAbsenteesViewController: UIViewController, UIGestureRecognizerDelegate {
    
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
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    var absentStudentData: [AbsentisReportStudent] = []
    var selectedDate: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        

        BackBtn.applyBackButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: StaffDetails?.school_name ?? "")
        dateLbl.isHidden = true
        cvIcon.isHidden = true
        infoStack.isHidden = true
        Tv.isHidden = true
        fullview.backgroundColor = .clear
        studentLbl.isHidden = true
       
        
        calanderFulView.layer.cornerRadius = 10

        calendar.delegate = self
        calendar.dataSource = self
        scrollview.delegate = self
        scrollview.alwaysBounceVertical = true
//        calendar.appearance.todayColor = .clear
//        calendar.appearance.titleTodayColor = .label
    calendar.allowsMultipleSelection = false
        fullview.layer.cornerRadius = 10
        cvIcon.register(UINib(nibName: CellConfingName.CVIconCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.CVIconCollectionViewCell)
        Tv.register(UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ClassTableViewCell)
        
        cvIcon.dataSource = self
        cvIcon.delegate = self
//        
        Tv.dataSource = self
        Tv.delegate = self
        
        Absentees_Response()
        
        
    }
    
    @IBAction func BackAct() {
        dismiss(animated: true)
    }
    
    func Absentees_Response() {
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_api_attendance_get_absentees_count_by_date, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "") { [weak self] (result: Result<AbsenteesResponse, Error>) in
            
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
                                self.eventDates.append(date)
                            }
                        }
                    }
                    
                    self.calendar.reloadData()
                
                    
                    if let firstDate = self.absentData?.first?.date {
                        self.filterData(for: firstDate)
                    }
                    
                    
                    let today = Date()
                    let calendar = Calendar.current
                    let hasEventToday = self.eventDates.contains { eventDate in
                        calendar.isDate(eventDate, inSameDayAs: today)
                    }
                    
                    if !hasEventToday {
                        print("No absentee event today.")
                        self.dateLbl.isHidden = !hasEventToday
                        self.cvIcon.isHidden = !hasEventToday
                        self.infoStack.isHidden = !hasEventToday
                        self.Tv.isHidden = !hasEventToday
                        self.fullview.backgroundColor = .clear
                        self.studentLbl.text = "No Absentees found today"
                        self.studentLbl.isHidden = false
                        self.studentLbl.textAlignment = .center
                    }else{
                        
                        self.dateLbl.isHidden = false
                        self.cvIcon.isHidden = false
                        self.infoStack.isHidden = false
                        self.Tv.isHidden = false
                        self.fullview.backgroundColor = .white
                        self.studentLbl.text = "👨🏻‍🎓 Absent  students list"
                        self.studentLbl.textAlignment = .left
                        self.studentLbl.isHidden = false
                        
                    }
                    
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error fetching absentees:", error.localizedDescription)
                }
            }
        }
    }
    
    func filterData(for date: String) {
        guard let allData = self.absentData else { return }

        let filteredClassWise = allData.filter { $0.date == date }
        
        self.sectionWiseArray = flattenClassWiseData(classData: filteredClassWise.first?.class_wise ?? [])
        classNameLbl.text = "Class : " + (
            sectionWiseArray.first?.class_name ?? ""
        )
        sectionLbl.text = "Section : " + (
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
                    total_absentees: section.total_absentees ?? "", student_counts: cls.student_counts ?? ""
                )
                flatArray.append(item)
            }
        }
        return flatArray
    }
    
    
    func AbsentStudent(sectionId: String, date: String) {
//        if #available(iOS 15.0, *) {
//            showLottieProgressLoader(animationName: "loader (2)")
//        }

        let param = [
            AbsenteesReportStringFile.absent_on: date,
            AbsenteesReportStringFile.section_id: sectionId
        ]

        APIService.shared.makeApi(
            url: ServiceUrl.stud_attd_api_attendance_get_absentees_students_by_date,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: StaffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<AbsentisReportStudentResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }

//                if #available(iOS 15.0, *) {
//                    self.hideLottieProgressLoader()
//                }

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
        cell.standardLbl.text = "Class : " + data.class_name
        cell.sectionLbl.text = "Section : " + data.section_name
        cell.absentCountLbl.text =  " Absent : " +  data.total_absentees + " / " +  data.student_counts
        
        
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
            classNameLbl.text = "Class : " + data.class_name
            sectionLbl.text = "Section : " + data.section_name
            abesentCountLbl.text = "Absentees : \(data.total_absentees)"
            totalLbl.text = "Total students : \(data.student_counts)"
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
        
//        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ClickID = indexPath.row
        
        let data = sectionWiseArray[indexPath.item]
        classNameLbl.text = "Class : " + data.class_name
        sectionLbl.text = "Section : " + data.section_name
        cvIcon.reloadData()
        
        updateProgress(
            absentees: data.total_absentees,
            total: data.student_counts
        )
        AbsentStudent(sectionId:data.section_id , date: selectedDate ?? "" )
        
        abesentCountLbl.text = "Absentees : \(data.total_absentees)"
        totalLbl.text = "Total students : \(data.student_counts)"
       
        
//        Tv.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 110)
    }
    
    
    func updateProgress(absentees: String, total: String) {
        // String → Float convert
        let absentCount = Float(absentees) ?? 0
        let totalCount = Float(total) ?? 1  // avoid divide by zero
        
        let progressValue = absentCount / totalCount
        
        progres.setProgress(progressValue, animated: true)   // 0.0 to 1.0 range
        
        
        // Optional: progress color change
        progres.progressTintColor = .systemRed
        progres.trackTintColor = .systemGreen
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
        cell.StatusBtn.setTitle("Call", for: .normal)
        cell.StatusBtn.backgroundColor = .systemBlue
        cell.addmissionLbl.isHidden = data.admission_no ==  "" ? true : false
        cell.addmissionLbl.text =  "admission no: " + (data.admission_no ?? "")
       
//        if let urlStr = data.photo_path, let url = URL(string: urlStr) {
//            cell.profileImage.sd_setImage(with: url, placeholderImage: UIImage(systemName: "globe"))
//        }
        
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
    
    
}
// MARK: - Data Models

extension NewAbsenteesViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance,UIScrollViewDelegate {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        // Check if this date is in eventDates
        if eventDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            return 1 // show dot
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if eventDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            return [.systemTeal]  // dot color
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        // eventDates-ல இருக்கிறதா check பண்ணு
        let hasEvent = eventDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
        
        if hasEvent {
            return true
        } else {
            // Alert show பண்ணு
            let alert = UIAlertController(title: "No Absentees",
                                          message: "This date has no Absentees Report.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
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
        studentLbl.text = "👨🏻‍🎓 Absent  students list"
        studentLbl.textAlignment = .left
        let filterFormatter = DateFormatter()
        filterFormatter.dateFormat = "dd-MM-yyyy"
        
        let showFormatter = DateFormatter()
        showFormatter.dateFormat = "MMMM dd, yyyy"
        
        let selectedDateForFilter = filterFormatter.string(from: date)
        let selectedDateForLabel = showFormatter.string(from: date)
        
        print("Selected Date (Filter): \(selectedDateForFilter)")
        print("Selected Date (Label): \(selectedDateForLabel)")
        
        // UILabel update
        dateLbl.text = selectedDateForLabel
        selectedDate = selectedDateForFilter
        // Data filter
        filterData(for: selectedDateForFilter)
        
        let sectionIDs = getSectionID(for: selectedDate ?? "") ?? ""
        AbsentStudent(sectionId:sectionIDs , date: selectedDate ?? "" )
        
        if let repost = getAbsenteeInfo(for: selectedDateForFilter) {
            
            print("repost.totalAbsentees",repost.totalAbsentees)
            print("repost.studentCounts",repost.studentCounts)
        }
        
        
        if let info = getAbsenteeInfo(for: selectedDateForFilter) {
            
            updateProgress(
                absentees: "\(info.totalAbsentees)",
                total: "\(info.studentCounts)"
                
            )
            
        } else {
            print("No data found for this date")
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
    

    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 {
            // Swipe up → collapse
            calendar.setScope(.week, animated: true)
        } else if velocity.y < 0 {
            // Swipe down → expand
            calendar.setScope(.month, animated: true)
        }
    }
   
    func getSectionID(for selectedDate: String) -> String? {
        guard let absentData = absentData else { return nil }
        
        // அந்த தேதிக்கான data எடு
        if let matchedDate = absentData.first(where: { $0.date == selectedDate }) {
            // முதல் class_wise → முதல் section_wise → section_id
            return matchedDate.class_wise?.first?.section_wise?.first?.section_id
        }
        return nil
    }
    
    func getAbsenteeInfo(for selectedDate: String) -> (totalAbsentees: Int, studentCounts: Int)? {
        guard let absentData = absentData else { return nil }
        
        if let matchedDate = absentData.first(where: { $0.date == selectedDate }),
           let firstClass = matchedDate.class_wise?.first {
            
            let totalStu = Int(firstClass.student_counts ?? "0") ?? 0
            let totalAbs = Int(firstClass.total_absentees ?? "0") ?? 0
            
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
