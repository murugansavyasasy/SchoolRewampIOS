//
//  StudentReportDashboardVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/03/26.
//

import UIKit

class StudentReportDashboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FeeSectionReloadDelegate{
    func reloadSection() {
        
        reportTable.beginUpdates()
        reportTable.endUpdates()
    }
    @IBOutlet weak var reportTable: UITableView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var classLbl: UILabel!
    var reportData:FeeData1?
    var isInstallmentExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reportTable.register(UINib(nibName: "StudentPerfomenceTVC", bundle: nil), forCellReuseIdentifier: "StudentPerfomenceTVC")
        reportTable.register(UINib(nibName: "StudentFinancialTVC", bundle: nil), forCellReuseIdentifier: "StudentFinancialTVC")
        reportTable.register(UINib(nibName: "ExamPermamenceTVC", bundle: nil), forCellReuseIdentifier: "ExamPermamenceTVC")
        reportTable.register(UINib(nibName: "AttendenceOverviewTVC", bundle: nil), forCellReuseIdentifier: "AttendenceOverviewTVC")
        reportTable.register(UINib(nibName: "PaymentHistoryTVC", bundle: nil), forCellReuseIdentifier: "PaymentHistoryTVC")
        reportTable.register(UINib(nibName: "SectionHeaderView", bundle: nil), forCellReuseIdentifier: "SectionHeaderView")
        reportTable.rowHeight = UITableView.automaticDimension
        reportTable.delegate = self
        reportTable.dataSource = self

        loadDummyData()
    }
    private func loadDummyData() {

        studentNameLbl.text = "Arun Kumar"
        classLbl.text = "Class 10 - A"

        reportData = FeeData1(

            summary: FeeSummary(
                total_amount: 90000,
                total_paid: 55000,
                total_discount: 2000,
                total_pending: 33000,
                paymentProgress: 61
            ),

            transport_fee: TransportFee(
                actual_amount: 12000,
                paid_amount: 6000,
                discount_amount: 0,
                pending_amount: 6000,
                route_name: "Route 5",
                stop_name: "Anna Nagar",
                vehicle_no: "TN 01 AB 1234",
                paid_details: nil
            ),

            hostel_fee: TermFee(
                id: 4,
                fee_name: "Hostel Fee",
                term_name: nil,
                term_id: nil,
                actual_amount: 15000,
                paid_amount: 5000,
                discount_amount: 0,
                pending_amount: 10000,
                status: .pending,
                hostel_name: "SSS Boys Hostel",
                room_no: "2",
                bed_no: "B2",
                isExpand: false,
                breakDown: nil,
                paid_details: nil
            ),

            paymentHistory: [
                PaymentHistory(
                    paymentId: "TXN001",
                    paid_date: "10 Jan 2026",
                    pending_amount: 40000,
                    paid_amount: 20000,
                    amount_given: 20000,
                    discount_amount: 0,
                    in_progress: 0,
                    payment_mode: "UPI"
                ),
                PaymentHistory(
                    paymentId: "TXN002",
                    paid_date: "12 Feb 2026",
                    pending_amount: 25000,
                    paid_amount: 15000,
                    amount_given: 15000,
                    discount_amount: 0,
                    in_progress: 0,
                    payment_mode: "Card"
                )
            ],

            quantity_fees: TermFee(
                id: 5,
                fee_name: "Book Fee",
                term_name: "Term 1",
                term_id: 1,
                actual_amount: 8000,
                paid_amount: 4000,
                discount_amount: 0,
                pending_amount: 4000,
                status: .pending,
                hostel_name: nil,
                room_no: nil,
                bed_no: nil,
                isExpand: false,
                breakDown: nil,
                paid_details: nil
            ),

            other_fees: TermFee(
                id: 2,
                fee_name: "Other Fees",
                term_name: "Miscellaneous",
                term_id: nil,
                actual_amount: 6000,
                paid_amount: 2000,
                discount_amount: 0,
                pending_amount: 4000,
                status: .pending,
                hostel_name: nil,
                room_no :nil,
                bed_no: nil,
                isExpand: false,
                breakDown: [
                    CarryoverBreakdown(
                        fee_group_type_id: 1,
                        fee_group_type_name: "Sports",
                        fee_id: 10,
                        fee_name: "Sports Fee",
                        m_feeamount: 2000,
                        discount_amount:300,
                        paid_amount: 2000,
                        pending_amount: 0,
                        due_date: "15 Jan 2026",
                        status: .paid
                    ),
                    CarryoverBreakdown(
                        fee_group_type_id: 2,
                        fee_group_type_name: "Cultural",
                        fee_id: 11,
                        fee_name: "Cultural Fee",
                        m_feeamount: 2000,
                        discount_amount:300,
                        paid_amount: 0,
                        pending_amount: 2000,
                        due_date: "15 Feb 2026",
                        status: .pending
                    )
                ],
                paid_details: nil
            ),

            carryover_fees: TermFee(
                id: 3,
                fee_name: "Previous Year Due",
                term_name: "2024",
                term_id: nil,
                actual_amount: 5000,
                paid_amount: 1000,
                discount_amount: 0,
                pending_amount: 4000,
                status: .pending,
                hostel_name: nil,
                room_no: nil,
                bed_no: nil,
                isExpand: false,
                breakDown: nil,
                paid_details: nil
            ),

            term_fees: TermFee(
                id: 1,
                fee_name: "Tuition Fee",
                term_name: "Term 1",
                term_id: 1,
                actual_amount: 20000,
                paid_amount: 10000,
                discount_amount: 0,
                pending_amount: 10000,
                status: .pending,
                hostel_name: nil,
                room_no: nil,
                bed_no: nil,
                isExpand: false,
                breakDown: [
                    CarryoverBreakdown(
                        fee_group_type_id: 1,
                        fee_group_type_name: "Installment 1",
                        fee_id: 1,
                        fee_name: "Admission Fee",
                        m_feeamount: 5000,
                        discount_amount:300,
                        paid_amount: 5000,
                        pending_amount: 0,
                        due_date: "10 Jan 2026",
                        status: .paid
                    ),
                    CarryoverBreakdown(
                        fee_group_type_id: 2,
                        fee_group_type_name: "Installment 2",
                        fee_id: 2,
                        fee_name: "Lab Fee",
                        m_feeamount: 5000,
                        discount_amount:300,
                        paid_amount: 3000,
                        pending_amount: 2000,
                        due_date: "10 Feb 2026",
                        status: .pending
                    )
                ],
                paid_details: nil
            ),

            Academic_Performance: AcademicPerformance(
                overallPercentage: 87.5,
                grade: "A",
                gpa: 8.9,
                attendancePercentage: 92,
                classRank: 5,
                totalStudents: 40
            ),

            ExamPerformance: ExamPerformance(
                improvementPercentage: 8.5,
                highestScore: 96,
                highestExamName: "Quarterly",
                exams: [
                    ExamScore(examName: "Unit Test 1", score: 82),
                    ExamScore(examName: "Quarterly", score: 96)
                ]
            ),

            SubjectWisePerformance: SubjectWisePerformance(
                strongestSubject: "Mathematics",
                weakestSubject: "Physics",
                subjects: [
                    SubjectPerformance(subjectName: "Maths", marks: 95, grade: "A+"),
                    SubjectPerformance(subjectName: "Physics", marks: 70, grade: "B"),
                    SubjectPerformance(subjectName: "Chemistry", marks: 88, grade: "A"),
                    SubjectPerformance(subjectName: "Biology", marks: 82, grade: "A"),
                    SubjectPerformance(subjectName: "English", marks: 90, grade: "A+")
                ]
            ),

            AttendanceOverview: AttendanceOverview(
                attendancePercentage: 92,
                presentDays: 180,
                absentDays: 10,
                leaveDays: 5,
                weeklyAttendance: [
                    DayAttendance(dayName: "Mon", date: 1, status: .present),
                    DayAttendance(dayName: "Tue", date: 2, status: .present),
                    DayAttendance(dayName: "Wed", date: 3, status: .absent)
                ]
            )
        )

        reportTable.reloadData()
    }

    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return DashboardSection.allCases.count
    }
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

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

        case .summary:
            return reportData?.summary == nil ? 0 : 1

        case .termFees:
            return reportData?.term_fees == nil ? 0 : 1

        case .otherFees:
            return reportData?.other_fees == nil ? 0 : 1

        case .carryoverFees:
            return reportData?.carryover_fees == nil ? 0 : 1

        case .quantityFees:
            return reportData?.quantity_fees == nil ? 0 : 1

        case .paymentHistory:
            return reportData?.paymentHistory?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let sectionType = DashboardSection(rawValue: indexPath.section) else { return }

        switch sectionType {

        case .termFees:
            if reportData?.term_fees?.breakDown != nil {
                reportData?.term_fees?.isExpand?.toggle()
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }

        case .otherFees:
            if reportData?.other_fees?.breakDown != nil {
                reportData?.other_fees?.isExpand?.toggle()
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }

        case .carryoverFees:
            if reportData?.carryover_fees?.breakDown != nil {
                reportData?.carryover_fees?.isExpand?.toggle()
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }

        case .quantityFees:
            if reportData?.quantity_fees?.breakDown != nil {
                reportData?.quantity_fees?.isExpand?.toggle()
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }

        default:
            break
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
            
        case .summary:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StudentFinancialTVC", for: indexPath) as! StudentFinancialTVC
            cell.configure(data: reportData?.summary)
            return cell
        case .paymentHistory:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentHistoryTVC", for: indexPath) as! PaymentHistoryTVC
            let payment = reportData?.paymentHistory?[indexPath.row]
        
            cell.configurePayment(data: payment)
            cell.outerView.setShadow()
            return cell
        case .termFees:

            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
            let installment = reportData?.term_fees
            cell.setAmountLabel(paid: installment?.actual_amount ?? 0, discount: installment?.discount_amount ?? 0, pending: installment?.pending_amount ?? 0)
            if installment?.isExpand == true {
                cell.confic(breakDown: installment?.breakDown ?? [])
            } else {
                cell.confic(breakDown: [])
            }
            let image = installment?.isExpand ?? false ? UIImage(systemName: "chevron.up"):UIImage(systemName: "chevron.down")
            cell.arrowIcon.setImage(image, for: .normal)
            cell.arrowIcon.isHidden = installment?.breakDown == nil
            if let status = installment?.status{
                statusView(status: status, btn: cell.statusLbl, iconBtn: cell.arrowImg)
            }
            cell.delegate = self
            return cell
        case .otherFees:

            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
            let installment = reportData?.other_fees

            cell.confic(breakDown: installment?.isExpand == true ? installment?.breakDown ?? [] : [])
            cell.setAmountLabel(paid: installment?.actual_amount ?? 0, discount: installment?.discount_amount ?? 0, pending: installment?.pending_amount ?? 0)
            let image = installment?.isExpand ?? false ? UIImage(systemName: "chevron.up"):UIImage(systemName: "chevron.down")
            cell.arrowIcon.setImage(image, for: .normal)
            cell.arrowIcon.isHidden = installment?.breakDown == nil
            if let status = installment?.status{
                statusView(status: status, btn: cell.statusLbl, iconBtn: cell.arrowImg)
            }
            cell.delegate = self
            return cell


        case .carryoverFees:

            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
            let installment = reportData?.carryover_fees

            cell.confic(breakDown: installment?.isExpand == true ? installment?.breakDown ?? [] : [])
            cell.setAmountLabel(paid: installment?.actual_amount ?? 0, discount: installment?.discount_amount ?? 0, pending: installment?.pending_amount ?? 0)
            let image = installment?.isExpand ?? false ? UIImage(systemName: "chevron.up"):UIImage(systemName: "chevron.down")
            cell.arrowIcon.setImage(image, for: .normal)
            cell.arrowIcon.isHidden = installment?.breakDown == nil
            if let status = installment?.status{
                statusView(status: status, btn: cell.statusLbl, iconBtn: cell.arrowImg)
            }
            cell.delegate = self
            return cell


        case .quantityFees:

            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
            let installment = reportData?.quantity_fees

            cell.confic(breakDown: installment?.isExpand == true ? installment?.breakDown ?? [] : [])
            cell.setAmountLabel(paid: installment?.actual_amount ?? 0, discount: installment?.discount_amount ?? 0, pending: installment?.pending_amount ?? 0)
            let image = installment?.isExpand ?? false ? UIImage(systemName: "chevron.up"):UIImage(systemName: "chevron.down")
            cell.arrowIcon.setImage(image, for: .normal)
            cell.arrowIcon.isHidden = installment?.breakDown == nil
            if let status = installment?.status{
                statusView(status: status, btn: cell.statusLbl, iconBtn: cell.arrowImg)
            }
            cell.delegate = self
            return cell
        }
    }
    func statusView(status: InstallmentStatus, btn: UIButton, iconBtn: UIButton) {
        switch status {
            
        case .paid:
            btn.setTitle("Paid", for: .normal)
            btn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            btn.setTitleColor(.systemGreen, for: .normal)
            iconBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            iconBtn.tintColor = .systemGreen
            iconBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)

        case .pending:
            btn.setTitle("Pending", for: .normal)
            btn.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            btn.setTitleColor(.systemOrange, for: .normal)
            iconBtn.setImage(UIImage(systemName: "clock.fill"), for: .normal)
            iconBtn.tintColor = .systemOrange
            iconBtn.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)

        case .overdue:
            btn.setTitle("Overdue", for: .normal)
            btn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            btn.setTitleColor(.systemRed, for: .normal)
            iconBtn.setImage(UIImage(systemName: "exclamationmark.circle.fill"), for: .normal)
            iconBtn.tintColor = .systemRed
            iconBtn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sectionType = DashboardSection(rawValue: section) else { return nil }
        
        switch sectionType {
            
        case .paymentHistory:
            return "Payment History"
            
        default:
            return nil
        }
    }
   
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


enum InstallmentStatus: String, Codable {
    case paid
    case pending
    case overdue
}
struct PaymentHistory: Codable {
    var paymentId: String?
    var paid_date: String?
    var pending_amount: Double?
    var paid_amount: Double?
    var amount_given: Double?
    var discount_amount: Double?
    var in_progress: Double?
    var payment_mode: String?
}
enum DashboardSection: Int, CaseIterable {

    case academic
    case examPerformance
    case subjectWise
    case attendance
    case summary

    case termFees
    case otherFees
    case carryoverFees
    case quantityFees

    case paymentHistory
}

struct FeeResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: [FeeData1]?
}
struct FeeData1: Decodable {
    
    let summary: FeeSummary?
    let transport_fee: TransportFee?
    let hostel_fee: TermFee?
    let paymentHistory: [PaymentHistory]?
    
    var quantity_fees: TermFee?
    var other_fees: TermFee?
    var carryover_fees: TermFee?
    var term_fees: TermFee?
    
    var Academic_Performance: AcademicPerformance?
    var ExamPerformance: ExamPerformance?
    var SubjectWisePerformance: SubjectWisePerformance?
    var AttendanceOverview: AttendanceOverview?
}
struct TransportFee: Codable {
    var actual_amount: Double?
    var paid_amount: Double?
    var discount_amount: Double?
    var pending_amount: Double?
    var route_name: String?
    var stop_name: String?
    var vehicle_no: String?
    var paid_details: [PaymentHistory]?
}

struct FeeSummary: Codable {
    let total_amount: Double?
    let total_paid: Double?
    let total_discount: Double?
    let total_pending: Double?
    let paymentProgress: Double?
}
struct TermFee: Codable {
    let id: Int?
    let fee_name: String?
    let term_name: String?
    let term_id: Int?
    let actual_amount: Double?
    let paid_amount: Double?
    let discount_amount: Double?
    let pending_amount: Double?
    let status: InstallmentStatus?
    let hostel_name: String?
    let room_no: String?
    let bed_no: String?
    var isExpand : Bool?
    let breakDown: [CarryoverBreakdown]?
    var paid_details: [PaymentHistory]?
}
struct CarryoverBreakdown: Codable {
    let fee_group_type_id: Int?
    let fee_group_type_name: String?
    let fee_id: Int?
    let fee_name: String?
    let m_feeamount: Double?
    let discount_amount: Double?
    let paid_amount: Double?
    let pending_amount: Double?
    var due_date: String?
    let status: InstallmentStatus?
}

