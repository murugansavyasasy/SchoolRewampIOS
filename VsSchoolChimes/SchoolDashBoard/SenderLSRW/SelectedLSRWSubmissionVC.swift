//
//  SelectedLSRWSubmissionVC.swift
//  School Chimes
//
//  Created by Chandhru on 07/07/25.
//

import UIKit
import DropDown

class SelectedLSRWSubmissionVC: UIViewController {
    
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropDownView: UIView!
    private var reportData: ReportData?
    let dropDown = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableCells()
        setupDummyData()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 10
            }
        tableView.delegate = self
        tableView.dataSource = self
        dropDownView.setShadow(cornerRadius: 4)
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"   // Full month name (e.g., "August")
        monthLbl.text = dateFormatter.string(from: date)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        dropDownView.isUserInteractionEnabled = true
        dropDownView.addGestureRecognizer(tapGesture)
    }
    @objc func viewTapped() {
        dropDown.dataSource = [
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December"
        ]
        dropDown.anchorView = dropDownView
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDown.anchorView?.plainView.bounds.height ?? 0)
        dropDown.selectionAction = { [weak self] (_, item: String) in
            self?.monthLbl.text = item
        }
        dropDown.show()
       }
    private func registerTableCells() {
        tableView.register(UINib(nibName: "LSRWReportTVC", bundle: nil), forCellReuseIdentifier: "LSRWReportTVC")
        tableView.register(UINib(nibName: "LSRWProgressTVC", bundle: nil), forCellReuseIdentifier: "LSRWProgressTVC")
        tableView.register(UINib(nibName: "LSRWPerformenceTVC", bundle: nil), forCellReuseIdentifier: "LSRWPerformenceTVC")
    }
    
    private func setupDummyData() {
        let filters = [
            Overview(title: "Listening", value: "85%", subtitle: "28 students"),
            Overview(title: "Speaking", value: "78%", subtitle: "25 students"),
            Overview(title: "Reading", value: "92%", subtitle: "30 students"),
            Overview(title: "Writing", value: "88%", subtitle: "27 students")
        ]
        
        let weeklyReports = [
            PerformanceReport(title: "Week 1", percentage: 70),
            PerformanceReport(title: "Week 2", percentage: 80),
            PerformanceReport(title: "Week 3", percentage: 90),
            PerformanceReport(title: "Week 4", percentage: 85)
        ]
        
        let topPerformers = [
            TopReport(name: "Arun Kumar", studentClass: "10", section: "A", percentage: 95.5),
            TopReport(name: "Divya", studentClass: "10", section: "B", percentage: 93.0),
            TopReport(name: "Rahul", studentClass: "9", section: "A", percentage: 92.5)
        ]
        
        let students = [
            Student(id: 1, name: "Arun Kumar", studentClass: "10"),
            Student(id: 2, name: "Divya", studentClass: "10"),
            Student(id: 3, name: "Rahul", studentClass: "9")
        ]
        
        reportData = ReportData(
            filterList: filters,
            monthlyReport: MonthlyReport(weeklyReport: weeklyReports, topPerformance: topPerformers),
            studentList: students
        )
        
        tableView.reloadData()
    }
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

// MARK: - UITableView Delegate & DataSource
extension SelectedLSRWSubmissionVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // filterList, monthlyReport, studentList
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reportData = reportData else { return 0 }
        
        switch section {
        case 0: return 1
        case 1:
            return 1
        case 2: return reportData.studentList.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reportData = reportData else { return UITableViewCell() }
        
        switch indexPath.section {
        case 0: // Filter List
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWProgressTVC", for: indexPath) as! LSRWProgressTVC
            let item = reportData.filterList
            cell.configure(with: item,selectedIndex:0)
            return cell
            
        case 1:
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWReportTVC", for: indexPath) as! LSRWReportTVC
                let item = reportData.monthlyReport
            cell.confic(weeklyReports: item.weeklyReport, topPerformers: item.topPerformance)
                return cell
        case 2: // Student List
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWPerformenceTVC", for: indexPath) as! LSRWPerformenceTVC
            if let firstLetter = reportData.studentList[indexPath.row].name?.first {
                cell.initialBtn.setTitle(String(firstLetter).uppercased(), for: .normal)
            } else {
                cell.initialBtn.setTitle("-", for: .normal)
            }
            cell.nameLbl.text = reportData.studentList[indexPath.row].name
            cell.classLbl.text = reportData.studentList[indexPath.row].studentClass
            cell.pesantageProgress.isHidden = true
            cell.persantageLbl.isHidden = true
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil // removes unwanted space
        }

        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGroupedBackground

        let label = UILabel(frame: CGRect(x: 16, y: 8, width: tableView.frame.width - 32, height: 20))
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray

        if section == 1 {
            label.text = "Monthly Report"
        } else if section == 2 {
            label.text = "Students"
        }

        headerView.addSubview(label)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 30 // standard height for others
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 120
        case 1:
            return 230
        case 2:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }
}


// MARK: - Root JSON
struct ReportData: Codable {
    let filterList: [Overview]
    let monthlyReport: MonthlyReport
    let studentList: [Student]
}

// MARK: - Monthly Report
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

// MARK: - Student
struct Student: Codable {
    let id: Int
    let name: String?
    let studentClass: String
}
