//
//  SelectedLSRWSubmissionVC.swift
//  School Chimes
//
//  Created by Chandhru on 07/07/25.
//

import UIKit
import DropDown

// MARK: - Enum
enum ReportData {
    case filterList([Overview])
    case monthlyReport(MonthlyReport)
    case studentList([SkillSubmission])
}

// MARK: - ViewController
class SelectedLSRWSubmissionVC: UIViewController, FilterDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var nodataImg: UIImageView!
    
    // MARK: - Properties
    private var reportData: [ReportData]?
    private var currentData: PerformanceData?   // ✅ store API response
    let dropDown = DropDown()
    var monthId: Int = 1
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableCells()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 10
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        dropDownView.setShadow(cornerRadius: 4)
        
        // Set current month in label
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        monthId = Calendar.current.component(.month, from: date)
        monthLbl.text = dateFormatter.string(from: date)
        
        // Dropdown tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        dropDownView.isUserInteractionEnabled = true
        dropDownView.addGestureRecognizer(tapGesture)
        
        getSubmission()
    }
    
    // MARK: - Dropdown
    @objc func viewTapped() {
        dropDown.dataSource = Calendar.current.monthSymbols
        dropDown.anchorView = dropDownView
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDown.anchorView?.plainView.bounds.height ?? 0)
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            self?.monthLbl.text = item
            self?.monthId = index + 1
            self?.getSubmission()
        }
        dropDown.show()
    }
    
    private func registerTableCells() {
        tableView.register(UINib(nibName: "LSRWReportTVC", bundle: nil), forCellReuseIdentifier: "LSRWReportTVC")
        tableView.register(UINib(nibName: "LSRWProgressTVC", bundle: nil), forCellReuseIdentifier: "LSRWProgressTVC")
        tableView.register(UINib(nibName: "LSRWTaskTVC", bundle: nil), forCellReuseIdentifier: "LSRWTaskTVC")
    }
    
    // MARK: - API Call
    func getSubmission() {
        APIService.shared.makeApi(
            url: ServiceUrl.lms_api_lsrw_stats,
            parameters: ["month_id": monthId],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<SkillResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status, let data = response.data.first {
                    DispatchQueue.main.async {
                        self?.nodataImg.isHidden = true
                        self?.mapResponseToReportData(data: data)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.reportData = nil
                        self?.nodataImg.isHidden = false
                        self?.tableView.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    private func mapResponseToReportData(data: PerformanceData) {
        self.currentData = data
        var newReportData: [ReportData] = []

        let totalWeeks = weeksInMonth(month: monthId)
        var weeklyReports: [PerformanceReport] = Array(repeating: PerformanceReport(title: "", percentage: 0), count: totalWeeks)

        let readingDetails = data.reading?.details ?? []
        let listeningDetails = data.listening?.details ?? []
        let speakingDetails = data.speaking?.details ?? []
        let writingDetails = data.writing?.details ?? []

        let allDetails = readingDetails + listeningDetails + speakingDetails + writingDetails
        // Group by week
        var weekWise: [Int: (submitted: Int, total: Int)] = [:]

        for detail in allDetails {
            guard let dateStr = detail.student_submited_on,
                  let week = weekOfMonth(from: dateStr) else { continue }

            let submitted = detail.submitted_count ?? 0
            let total = detail.member_count ?? 0

            let prev = weekWise[week] ?? (0,0)
            weekWise[week] = (prev.submitted + submitted, prev.total + total)
        }

        // Fill weekly reports
        for week in 1...totalWeeks {
            let info = weekWise[week] ?? (0,0)
            let percentage = info.total > 0 ? Int((Double(info.submitted) / Double(info.total)) * 100) : 0
            weeklyReports[week-1] = PerformanceReport(title: "Week \(week)", percentage: percentage)
        }

        let topPerformers = getTopPerformers(from: data)
        let monthlyReport = MonthlyReport(weeklyReport: weeklyReports, topPerformance: topPerformers)

        let studentList = data.today_submitted ?? []
        let uniqueStudentList = filterArray(studentList:studentList)
        var filterArray: [Overview] = []
        if let todaySubmitted = data.today_submitted {
            filterArray.append(Overview(title: "Today Submitted", value: "", subtitle: "\(todaySubmitted.count) Students"))
        }
        if let listening = data.listening {
            filterArray.append(Overview(title: "Listening", value: listening.over_all_percentage ?? "0%", subtitle: "\(listening.student_count ?? "0") Students"))
        }
        if let speaking = data.speaking {
            filterArray.append(Overview(title: "Speaking", value: speaking.over_all_percentage ?? "0%", subtitle: "\(speaking.student_count ?? "0") Students"))
        }
        if let reading = data.reading {
            filterArray.append(Overview(title: "Reading", value: reading.over_all_percentage ?? "0%", subtitle: "\(reading.student_count ?? "0") Students"))
        }
        if let writing = data.writing {
            filterArray.append(Overview(title: "Writing", value: writing.over_all_percentage ?? "0%", subtitle: "\(writing.student_count ?? "0") Students"))
        }

        // ✅ Final Report Data
        newReportData.append(.filterList(filterArray))
        newReportData.append(.monthlyReport(monthlyReport))
        newReportData.append(.studentList(uniqueStudentList))

        self.reportData = newReportData
        self.tableView.reloadData()
    }
//
//    private func mapResponseToReportData(data: PerformanceData) {
//        self.currentData = data
//        var newReportData: [ReportData] = []
//
//        // ✅ Weekly Reports — comparing across all categories
//        let totalWeeks = weeksInMonth(month: monthId)
//        var weeklyReports: [PerformanceReport] = []
//print("totalWeeks ==>",totalWeeks)
//        for week in 1...totalWeeks {
//            // Reading
//            let readingDetail = data.reading?.details?[safe: week - 1]
//            let readingSubmitted = readingDetail?.submitted_count ?? 0
//            let readingTotal = readingDetail?.member_count ?? 0
//
//            // Listening
//            let listeningDetail = data.listening?.details?[safe: week - 1]
//            let listeningSubmitted = listeningDetail?.submitted_count ?? 0
//            let listeningTotal = listeningDetail?.member_count ?? 0
//
//            // Speaking
//            let speakingDetail = data.speaking?.details?[safe: week - 1]
//            let speakingSubmitted = speakingDetail?.submitted_count ?? 0
//            let speakingTotal = speakingDetail?.member_count ?? 0
//
//            // Writing
//            let writingDetail = data.writing?.details?[safe: week - 1]
//            let writingSubmitted = writingDetail?.submitted_count ?? 0
//            let writingTotal = writingDetail?.member_count ?? 0
//
//            let totalSubmitted = readingSubmitted + listeningSubmitted + speakingSubmitted + writingSubmitted
//            let totalMembers = readingTotal + listeningTotal + speakingTotal + writingTotal
//
//            let percentage = totalMembers > 0 ? Int((Double(totalSubmitted) / Double(totalMembers)) * 100) : 0
//            weeklyReports.append(PerformanceReport(title: "Week \(week)", percentage: percentage))
//        }
//
//        let topPerformers = getTopPerformers(from: data)
//
//        let monthlyReport = MonthlyReport(
//            weeklyReport: weeklyReports,
//            topPerformance: topPerformers
//        )
//        let studentList = data.today_submitted ?? []
//
//        // ✅ Map Categories → Overview
//        var filterArray: [Overview] = []
//        if let todaySubmitted = data.today_submitted {
//            filterArray.append(Overview(title: "Today Submitted", value: "", subtitle: "\(todaySubmitted.count) Students"))
//        }
//        if let listening = data.listening {
//            filterArray.append(Overview(title: "Listening", value: listening.over_all_percentage ?? "0%", subtitle: "\(listening.student_count ?? "0") Students"))
//        }
//        if let speaking = data.speaking {
//            filterArray.append(Overview(title: "Speaking", value: speaking.over_all_percentage ?? "0%", subtitle: "\(speaking.student_count ?? "0") Students"))
//        }
//        if let reading = data.reading {
//            filterArray.append(Overview(title: "Reading", value: reading.over_all_percentage ?? "0%", subtitle: "\(reading.student_count ?? "0") Students"))
//        }
//        if let writing = data.writing {
//            filterArray.append(Overview(title: "Writing", value: writing.over_all_percentage ?? "0%", subtitle: "\(writing.student_count ?? "0") Students"))
//        }
//
//        // ✅ Final Report Data
//        newReportData.append(.filterList(filterArray))
//        newReportData.append(.monthlyReport(monthlyReport))
//        newReportData.append(.studentList(studentList))
//
//        self.reportData = newReportData
//        self.tableView.reloadData()
//    }

    func getTopPerformers(from data: PerformanceData) -> [TopReport] {
        let readingDetails = data.reading?.details ?? []
        let writingDetails = data.writing?.details ?? []
        let speakingDetails = data.speaking?.details ?? []
        let listeningDetails = data.listening?.details ?? []
        
        let allDetails = readingDetails + writingDetails + speakingDetails + listeningDetails
        
        var studentScores: [String: [Double]] = [:]
        
        for submission in allDetails {
            guard
                let name = submission.student_name,
                let stdSec = submission.std_sec,
                let remarkStr = submission.remark
            else { continue }
            
            // 🔹 Clean remark → remove % + trim
            let cleaned = remarkStr.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)
            
            guard let percentage = Double(cleaned), percentage > 0 else { continue }
            
            let key = "\(name)_\(stdSec)"
            studentScores[key, default: []].append(percentage)
        }
        
        var reports: [TopReport] = studentScores.compactMap { key, scores in
            let components = key.split(separator: "_")
            guard components.count >= 2 else { return nil }
            
            let name = String(components[0])
            let stdSec = String(components[1])
            
            return TopReport(
                name: name,
                studentClass: stdSec,
                section: "",
                percentage: scores.max() ?? 0
            )
        }
        
        reports.sort { $0.percentage > $1.percentage }
        
        return Array(reports.prefix(4))
    }

//    // MARK: - Weeks in Current Month (Days ÷ 7)
//    func weeksInMonth(month: Int) -> Int {
//        let calendar = Calendar.current
//        let date = Date()
//        let currentYear = calendar.component(.year, from: date)
//        
//        // Create the start date of the given month
//        var components = DateComponents()
//        components.year = currentYear
//        components.month = month
//        components.day = 1
//        
//        guard let startOfMonth = calendar.date(from: components),
//              let monthRange = calendar.range(of: .day, in: .month, for: startOfMonth) else {
//            return 0
//        }
//        
//        let days = monthRange.count
//        let weeks = Int(ceil(Double(days) / 7.0))
//        return weeks
//    }
    func weekOfMonth(from dateString: String, format: String = "dd-MM-yyyy") -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = .current
        
        guard let date = formatter.date(from: dateString) else { return nil }
        return Calendar.current.component(.weekOfMonth, from: date)
    }

    // MARK: - Weeks in Current Month
    func weeksInMonth(month: Int) -> Int {
        let calendar = Calendar.current
        let date = Date()
        let currentYear = calendar.component(.year, from: date)
        
        // Create the start date of the given month and current year
        var components = DateComponents()
        components.year = currentYear
        components.month = month
        components.day = 1
        
        guard let startOfMonth = calendar.date(from: components),
              let monthRange = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return 0
        }
        
        // Calculate the end date of the month
        let endOfMonth = calendar.date(byAdding: .day, value: monthRange.count - 1, to: startOfMonth)!
        
        // Get the week numbers
        let startWeek = calendar.component(.weekOfMonth, from: startOfMonth)
        let endWeek = calendar.component(.weekOfMonth, from: endOfMonth)
        
        return endWeek - startWeek + 1
    }

    
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - FilterDelegate
    func selectedIndex(index: Int?) {
        navigate(index: index)
    }
    
    func navigate(index: Int?) {
        guard let index = index, let currentData = currentData else { return }
        
        switch index {
        case 0: updateStudentList(with: filterArray(studentList:currentData.today_submitted ?? []))
        case 1: updateStudentList(with: filterArray(studentList:currentData.listening?.details ?? []))
        case 2: updateStudentList(with: filterArray(studentList:currentData.speaking?.details ?? []))
        case 3: updateStudentList(with: filterArray(studentList:currentData.reading?.details ?? []))
        case 4: updateStudentList(with: filterArray(studentList:currentData.writing?.details ?? []))
        default: break
        }
    }
    func filterArray(studentList: [SkillSubmission]) -> [SkillSubmission] {
        var seenIds = Set<String>()
        let uniqueStudentList = studentList.filter { student in
            guard let id = student.id else { return false }
            if seenIds.contains(id) {
                return false
            } else {
                seenIds.insert(id)
                return true
            }
        }
        return uniqueStudentList
    }
    private func updateStudentList(with students: [SkillSubmission]) {
        guard var reportData = reportData else { return }
        
        if let index = reportData.firstIndex(where: {
            if case .studentList = $0 { return true }
            return false
        }) {
            reportData[index] = .studentList(students)
        }
        
        self.reportData = reportData
        tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
    }
}

// MARK: - UITableView Delegate & DataSource
extension SelectedLSRWSubmissionVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reportData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reportData = reportData else { return 0 }
        switch reportData[section] {
        case .filterList: return 1
        case .monthlyReport: return 1
        case .studentList(let students): return students.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reportData = reportData else { return UITableViewCell() }
        
        switch reportData[indexPath.section] {
        case .filterList(let filters):
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWProgressTVC", for: indexPath) as! LSRWProgressTVC
            cell.configure(with: filters, selectedIndex: 0,selection: true)
            cell.delegate = self
            return cell
            
        case .monthlyReport(let monthly):
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWReportTVC", for: indexPath) as! LSRWReportTVC
            cell.confic(weeklyReports: monthly.weeklyReport, topPerformers: monthly.topPerformance)
            return cell
            
        case .studentList(let students):
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWTaskTVC", for: indexPath) as! LSRWTaskTVC
            let student = students[indexPath.row]
            let task = LSRWTask(
                id: student.id,
                detail_id: student.id,
                title: student.title,
                description: student.description,
                sent_to: student.student_id,
                activity_type: LSRWType(student.activity_type ?? ""),
                subject: student.subject,
                date: student.submission_date,
                time: student.student_submited_on,
                submitted_date: student.student_submited_on,
                is_submitted: student.is_submitted,
                is_unread: nil,
                sent_by: student.student_name,
                created_on: student.created_on,
                iframe: nil,
                file_size: nil,
                thumbnail: nil,
                file_path: student.file_path,
                test: nil,
                submittedCount: student.submitted_count,
                totalCount: student.member_count,
                submitted_average: student.submitted_average
            )
            cell.configure(with: task)
          
//            if let firstLetter = student.student_name?.first {
//                cell.initialBtn.setTitle(String(firstLetter).uppercased(), for: .normal)
//            } else {
//                cell.initialBtn.setTitle("-", for: .normal)
//            }
//            
//            cell.nameLbl.text = student.student_name
//            cell.tittleLbl.isHidden = false
//            cell.tittleLbl.text = student.title
//            cell.descriptionLbl.isHidden = false
//            cell.descriptionLbl.text = student.description
//            cell.classLbl.text = student.std_sec
//            cell.pesantageProgress.isHidden = true
//            cell.persantageLbl.text = student.remark
//            cell.persantageLbl.textColor = .systemGreen
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // No header for first section
        if section == 0 { return nil }
        
        // Check if there's data for this section
        guard let sectionData = reportData?[section] else { return nil }
        
        // Only show header if there is meaningful data
        switch sectionData {
        case .monthlyReport(let report):
            guard !report.weeklyReport.isEmpty else { return nil }
        case .studentList(let students):
            guard !students.isEmpty else { return nil }
        default:
            return nil
        }
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGroupedBackground
        
        let label = UILabel(frame: CGRect(x: 16, y: 8, width: tableView.frame.width - 32, height: 20))
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        
        switch sectionData {
        case .monthlyReport: label.text = "Monthly Report"
        case .studentList: label.text = "Tasks"
        default: label.text = ""
        }
        
        headerView.addSubview(label)
        return headerView
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch reportData?[indexPath.section] {
        case .studentList(let students):
            let student = students[indexPath.row]
            let task = LSRWTask(
                id: student.id,
                detail_id: student.id,
                title: student.title,
                description: student.description,
                sent_to: student.sent_by,
                activity_type: LSRWType(student.activity_type ?? ""),
                subject: student.subject,
                date: student.created_on,
                time: student.student_submited_on,
                submitted_date: student.student_submited_on,
                is_submitted: student.is_submitted,
                is_unread: nil,
                sent_by: student.student_name,
                created_on: student.created_on,
                iframe: nil,
                file_size: nil,
                thumbnail: nil,
                file_path: student.file_path,
                test: nil,
                submittedCount: student.submitted_count,
                totalCount: student.member_count,
                submitted_average: student.submitted_average
            )
            navigateToTaskDetail(task: task)

        default:
            break
        }
    }

    private func navigateToTaskDetail(task: LSRWTask) {
        let vc = LSRWPreviewVC()
        vc.modalPresentationStyle = .fullScreen
        vc.report = task
        present(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch reportData?[indexPath.section] {
        case .filterList: return 120
        case .monthlyReport: return 250
        case .studentList: return UITableView.automaticDimension
        default: return 0
        }
    }
}

// MARK: - Models
struct MonthlyReport: Codable {
    let weeklyReport: [PerformanceReport]
    let topPerformance: [TopReport]
}

struct TopReport: Codable {
    let name: String
    let studentClass: String
    let section: String
    let percentage: Double
}

struct PerformanceReport: Codable {
    let title: String
    let percentage: Int
}

// MARK: - Array Safe Index Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
