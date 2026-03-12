//
//  StudentReportDashboardVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/03/26.
//

import UIKit

class StudentReportDashboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var reportTable: UITableView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var classLbl: UILabel!
    var reportData:StudentReportDashBoard?
    override func viewDidLoad() {
        super.viewDidLoad()

        reportTable.register(UINib(nibName: "StudentPerfomenceTVC", bundle: nil), forCellReuseIdentifier: "StudentPerfomenceTVC")
        reportTable.register(UINib(nibName: "StudentFinancialTVC", bundle: nil), forCellReuseIdentifier: "StudentFinancialTVC")
        reportTable.register(UINib(nibName: "ExamPermamenceTVC", bundle: nil), forCellReuseIdentifier: "ExamPermamenceTVC")
        reportTable.register(UINib(nibName: "AttendenceOverviewTVC", bundle: nil), forCellReuseIdentifier: "AttendenceOverviewTVC")
        reportTable.register(UINib(nibName: "PaymentHistoryTVC", bundle: nil), forCellReuseIdentifier: "PaymentHistoryTVC")
        reportTable.rowHeight = UITableView.automaticDimension
        reportTable.delegate = self
        reportTable.dataSource = self

        loadDummyData()
    }
    private func loadDummyData() {
        
        studentNameLbl.text = "Arun Kumar"
        classLbl.text = "Class 10 - A"
        
        reportData = StudentReportDashBoard(
            
            Academic_Performance: AcademicPerformance(
                overallPercentage: 87,
                grade: "A",
                gpa: 3.8,
                attendancePercentage: 92,
                classRank: 5,
                totalStudents: 42
            ),
            
            ExamPerformance: ExamPerformance(
                improvementPercentage: 14,
                highestScore: 92,
                highestExamName: "Final Exam",
                exams: [
                    ExamScore(examName: "Unit 1", score: 78),
                    ExamScore(examName: "Midterm", score: 85),
                    ExamScore(examName: "Unit 2", score: 82),
                    ExamScore(examName: "Final", score: 92)
                ]
            ),
            
            SubjectWisePerformance: SubjectWisePerformance(
                strongestSubject: "Mathematics",
                weakestSubject: "Computer",
                subjects: [
                    SubjectPerformance(subjectName: "Math", marks: 95, grade: "A+"),
                    SubjectPerformance(subjectName: "Science", marks: 88, grade: "A"),
                    SubjectPerformance(subjectName: "English", marks: 84, grade: "B+"),
                    SubjectPerformance(subjectName: "Computer", marks: 72, grade: "C+")
                ]
            ),
            
            AttendanceOverview: AttendanceOverview(
                attendancePercentage: 92,
                presentDays: 138,
                absentDays: 8,
                leaveDays: 4,
                weeklyAttendance: [
                    DayAttendance(dayName: "Sun", date: 1, status: .holiday),
                    DayAttendance(dayName: "Mon", date: 2, status: .present),
                    DayAttendance(dayName: "Tue", date: 3, status: .present),
                    DayAttendance(dayName: "Wed", date: 4, status: .absent),
                    DayAttendance(dayName: "Thu", date: 5, status: .present),
                    DayAttendance(dayName: "Fri", date: 6, status: .leave),
                    DayAttendance(dayName: "Sat", date: 7, status: .holiday)
                ]
            ),
            
            FeesOverview: FeesOverview(
                totalAmount: 60000,
                paidAmount: 45000,
                pendingAmount: 15000,
                paymentProgress: 75
            ),
            
            InstallmentBreakdown: [
                InstallmentBreakdown(
                    installmentName: "Term 1 Fees",
                    dueDate: "10 Jan 2026",
                    amount: 20000,
                    status: .paid
                ),
                InstallmentBreakdown(
                    installmentName: "Term 2 Fees",
                    dueDate: "10 Apr 2026",
                    amount: 20000,
                    status: .pending
                ),
                InstallmentBreakdown(
                    installmentName: "Term 3 Fees",
                    dueDate: "10 Jul 2026",
                    amount: 20000,
                    status: .overdue
                )
            ],
            
            PaymentHistory: [
                PaymentHistory(
                    paymentId: "TXN001",
                    paymentDate: "10 Jan 2026",
                    amount: 20000,
                    paymentMode: "UPI"
                ),
                PaymentHistory(
                    paymentId: "TXN002",
                    paymentDate: "12 Feb 2026",
                    amount: 15000,
                    paymentMode: "Card"
                ),
                PaymentHistory(
                    paymentId: "TXN003",
                    paymentDate: "15 Mar 2026",
                    amount: 10000,
                    paymentMode: "Cash"
                )
            ]
        )
        reportTable.reloadData()
    }
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return DashboardSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sectionType = DashboardSection(rawValue: section) else { return 0 }
        
        switch sectionType {
            
        case .academic:
            return reportData?.Academic_Performance == nil ? 0 : 1
            
        case .examPerformance:
            return reportData?.ExamPerformance == nil ? 0 : 1
            
        case .subjectWise:
            return reportData?.SubjectWisePerformance == nil ? 0 : 1
            
        case .attendance:
            return reportData?.AttendanceOverview == nil ? 0 : 1
            
        case .fees:
            return reportData?.FeesOverview == nil ? 0 : 1
            
        case .installment:
            return reportData?.InstallmentBreakdown?.count ?? 0
            
        case .paymentHistory:
            return reportData?.PaymentHistory?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let sectionType = DashboardSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
            
        case .academic:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StudentPerfomenceTVC", for: indexPath) as! StudentPerfomenceTVC
            cell.configure(data: reportData?.Academic_Performance)
            return cell
            
        case .examPerformance:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExamPermamenceTVC", for: indexPath) as! ExamPermamenceTVC
            cell.configureExam(data: reportData?.ExamPerformance)
            return cell
            
        case .subjectWise:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExamPermamenceTVC", for: indexPath) as! ExamPermamenceTVC
            cell.configureSubject(data: reportData?.SubjectWisePerformance)
            return cell
            
        case .attendance:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttendenceOverviewTVC", for: indexPath) as! AttendenceOverviewTVC
            cell.configure(data: reportData?.AttendanceOverview)
            return cell
            
        case .fees:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StudentFinancialTVC", for: indexPath) as! StudentFinancialTVC
            cell.configure(data: reportData?.FeesOverview)
            return cell
            
        case .installment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentHistoryTVC", for: indexPath) as! PaymentHistoryTVC
            let installment = reportData?.InstallmentBreakdown?[indexPath.row]
            cell.configureInstallment(data: installment)
            return cell
            
        case .paymentHistory:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentHistoryTVC", for: indexPath) as! PaymentHistoryTVC
            let payment = reportData?.PaymentHistory?[indexPath.row]
            cell.configurePayment(data: payment)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sectionType = DashboardSection(rawValue: section) else { return nil }
        
        switch sectionType {
            
        case .installment:
            return "Installment Breakdown"
            
        case .paymentHistory:
            return "Payment History"
            
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard let sectionType = DashboardSection(rawValue: section) else { return 0 }
        
        switch sectionType {
            
        case .installment, .paymentHistory:
            return 40
            
        default:
            return 0.01
        }
    }
}
struct StudentReportDashBoard:Codable{
    var Academic_Performance:AcademicPerformance?
    var ExamPerformance:ExamPerformance?
    var SubjectWisePerformance:SubjectWisePerformance?
    var AttendanceOverview:AttendanceOverview?
    var FeesOverview:FeesOverview?
    var InstallmentBreakdown:[InstallmentBreakdown]?
    var PaymentHistory:[PaymentHistory]?
}
struct AcademicPerformance: Codable {
    var overallPercentage: Double?
    var grade: String?
    var gpa: Double?
    var attendancePercentage: Double?
    var classRank: Int?
    var totalStudents: Int?
}
struct ExamPerformance: Codable {
    var improvementPercentage: Double?
    var highestScore: Double?
    var highestExamName: String?
    var exams: [ExamScore]?
}

struct ExamScore: Codable {
    var examName: String?
    var score: Double?
}
struct SubjectWisePerformance: Codable {
    var strongestSubject: String?
    var weakestSubject: String?
    var subjects: [SubjectPerformance]?
}

struct SubjectPerformance: Codable {
    var subjectName: String
    var marks: Double
    var grade: String
}
struct AttendanceOverview: Codable {
    var attendancePercentage: Double?
    var presentDays: Int?
    var absentDays: Int?
    var leaveDays: Int?
    var weeklyAttendance: [DayAttendance]?
}

struct DayAttendance: Codable {
    var dayName: String?
    var date: Int?
    var status: AttendanceStatus?
}

enum AttendanceStatus: String, Codable {
    case present
    case absent
    case leave
    case holiday
}
struct FeesOverview: Codable {
    var totalAmount: Double?
    var paidAmount: Double?
    var pendingAmount: Double?
    var paymentProgress: Double?
}
struct InstallmentBreakdown: Codable {
    var installmentName: String?
    var dueDate: String?
    var amount: Double?
    var status: InstallmentStatus?
}

enum InstallmentStatus: String, Codable {
    case paid
    case pending
    case overdue
}
struct PaymentHistory: Codable {
    var paymentId: String?
    var paymentDate: String?
    var amount: Double?
    var paymentMode: String?
}
enum DashboardSection: Int, CaseIterable {
    case academic
    case examPerformance
    case subjectWise
    case attendance
    case fees
    case installment
    case paymentHistory
}
