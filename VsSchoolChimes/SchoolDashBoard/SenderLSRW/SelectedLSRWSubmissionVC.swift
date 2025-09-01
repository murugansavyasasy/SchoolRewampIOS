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
        tableView.register(UINib(nibName: "LSRWPerformenceTVC", bundle: nil), forCellReuseIdentifier: "LSRWPerformenceTVC")
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

        // ✅ Weekly Reports
        let totalWeeks = weeksInCurrentMonth()
        var weeklyReports: [PerformanceReport] = []
        for week in 1...totalWeeks {
            if let detail = data.reading?.details?[safe: week - 1] {
                let submitted = detail.submitted_count ?? 0
                let total = detail.memberCount ?? 0
                let percentage = total > 0 ? Int((Double(submitted) / Double(total)) * 100) : 0
                weeklyReports.append(PerformanceReport(title: "Week \(week)", percentage: percentage))
            } else {
                weeklyReports.append(PerformanceReport(title: "Week \(week)", percentage: 0))
            }
        }

        // ✅ Top Performers (all categories combined)
        let topPerformers = getTopPerformers(from: data)

        let monthlyReport = MonthlyReport(
            weeklyReport: weeklyReports,
            topPerformance: topPerformers
        )

        // ✅ Today Submitted → Student List
        let studentList = data.today_submitted ?? []

        // ✅ Map Categories → Overview
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
        newReportData.append(.studentList(studentList))

        self.reportData = newReportData
        self.tableView.reloadData()
    }
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

    
    // MARK: - Weeks in Current Month
    func weeksInCurrentMonth() -> Int {
        let calendar = Calendar.current
        let date = Date()
        guard let monthRange = calendar.range(of: .day, in: .month, for: date) else { return 4 }
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let endOfMonth = calendar.date(byAdding: .day, value: monthRange.count - 1, to: startOfMonth)!
        
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
        case 0: updateStudentList(with: currentData.today_submitted ?? [])
        case 1: updateStudentList(with: currentData.listening?.details ?? [])
        case 2: updateStudentList(with: currentData.speaking?.details ?? [])
        case 3: updateStudentList(with: currentData.reading?.details ?? [])
        case 4: updateStudentList(with: currentData.writing?.details ?? [])
        default: break
        }
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
            cell.configure(with: filters, selectedIndex: 0)
            cell.delegate = self
            return cell
            
        case .monthlyReport(let monthly):
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWReportTVC", for: indexPath) as! LSRWReportTVC
            cell.confic(weeklyReports: monthly.weeklyReport, topPerformers: monthly.topPerformance)
            return cell
            
        case .studentList(let students):
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWPerformenceTVC", for: indexPath) as! LSRWPerformenceTVC
            let student = students[indexPath.row]
            
            if let firstLetter = student.student_name?.first {
                cell.initialBtn.setTitle(String(firstLetter).uppercased(), for: .normal)
            } else {
                cell.initialBtn.setTitle("-", for: .normal)
            }
            
            cell.nameLbl.text = student.student_name
            cell.classLbl.text = student.std_sec
            cell.pesantageProgress.isHidden = true
            cell.persantageLbl.text = student.remark
            cell.persantageLbl.textColor = .systemGreen
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGroupedBackground
        
        let label = UILabel(frame: CGRect(x: 16, y: 8, width: tableView.frame.width - 32, height: 20))
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        switch reportData?[section] {
        case .monthlyReport: label.text = "Monthly Report"
        case .studentList: label.text = "Students"
        default: label.text = ""
        }
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 30
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
