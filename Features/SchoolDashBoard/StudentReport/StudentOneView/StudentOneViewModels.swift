//
//  StudentOneViewModels.swift
//  School Chimes
//
//  Student Report → tap a student → Student One View.
//  The 18 "student-one-view-report" APIs, their response envelope and the
//  display rows the screen is built from.
//
//  Every response has the same shape: { status, message, data: [ { … } ] }.
//  Values are read leniently through FeeJSON / FeeRecord (StudentFeeDetailsModels.swift)
//  so a field that arrives as a number, an empty string or not at all never breaks the screen.
//

import UIKit

// MARK: - Settings

enum StudentOneViewConfig {
    /// Path in front of every One View API. Change here if the backend mounts the service elsewhere.
    static let pathPrefix = "admin/api/student-one-view-report/"
    /// `true` = show the bundled sample responses (no network). Use it to check the UI only.
    static let useSampleData = true
    /// Value the fee APIs expect for `student_type` (digits and commas).
    static let feeStudentType = "0,1"
}

// MARK: - The 18 APIs

enum OneViewAPI: String, CaseIterable {
    case profile = "profile"
    case attendanceWellbeingSummary = "attendance-wellbeing-summary"
    case certificateExamSummary = "certificate-exam-summary"
    case feeSummary = "fee-summary"
    case feeDetails = "fee-details"
    case receipts = "receipts"
    case onlinePayments = "online-payments"
    case discounts = "discounts"
    case examList = "exam-list"
    case markAnalysis = "mark-analysis"
    case leaveRequests = "leave-requests"
    case workingDays = "working-days"
    case attendancePercentage = "attendance-percentage"
    case transport = "transport"
    case hostel = "hostel"
    case certificates = "certificates"
    case accomplishments = "accomplishments"
    case incidents = "incidents"

    var path: String { StudentOneViewConfig.pathPrefix + rawValue }

    /// Parameters on top of student_id, academic_year_id and country_id.
    var extraParams: [String: Any] {
        switch self {
        case .feeSummary, .feeDetails: return ["student_type": StudentOneViewConfig.feeStudentType]
        case .discounts: return ["limit": 50, "offset": 0, "order_by": 2]
        case .leaveRequests: return ["limit": 50, "offset": 0]
        default: return [:]
        }
    }
}

// MARK: - Response

struct OneViewResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [FeeJSON]?

    /// `status` may arrive as true / 1 / "true"; `data` may be missing.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let raw = try? c.decode(FeeJSON.self, forKey: .status)
        switch raw {
        case .bool(let b)?: status = b
        case .number(let n)?: status = n != 0
        case .string(let t)?: status = ["true", "1", "yes"].contains(t.lowercased())
        default: status = nil
        }
        message = try? c.decode(String.self, forKey: .message)
        data = try? c.decode([FeeJSON].self, forKey: .data)
    }

    /// The first object in `data`, or nil when the call failed or returned nothing.
    var record: FeeRecord? {
        guard status == true, let obj = data?.first?.object else { return nil }
        return FeeRecord(raw: obj)
    }
}

extension FeeRecord {
    /// Text of one key, "" when missing.
    func s(_ key: String) -> String { text(key) ?? "" }
    /// A nested object.
    func obj(_ key: String) -> FeeRecord? { raw[key]?.object.map { FeeRecord(raw: $0) } }
    /// A list of plain strings.
    func strings(_ key: String) -> [String] { (raw[key]?.array ?? []).compactMap { $0.text } }
    /// A list of objects (empty when missing).
    func list(_ key: String) -> [FeeRecord] { records(key) }
}

// MARK: - Tabs

enum OneViewTab: Int, CaseIterable {
    case overview, profile, fees, exams, attendance, transport, hostel, certificates, wellbeing

    var title: String {
        switch self {
        case .overview: return "Overview".translated()
        case .profile: return "Profile".translated()
        case .fees: return "Fees".translated()
        case .exams: return "Exams".translated()
        case .attendance: return "Attendance".translated()
        case .transport: return "Transport".translated()
        case .hostel: return "Hostel".translated()
        case .certificates: return "Certificates".translated()
        case .wellbeing: return "Well-being".translated()
        }
    }

    /// The APIs a tab needs. Every one of the 18 APIs is used by at least one tab.
    var apis: [OneViewAPI] {
        switch self {
        case .overview: return [.profile, .feeSummary, .attendanceWellbeingSummary, .certificateExamSummary]
        case .profile: return [.profile]
        case .fees: return [.feeDetails, .receipts, .onlinePayments, .discounts]
        case .exams: return [.examList, .markAnalysis]
        case .attendance: return [.attendancePercentage, .workingDays, .leaveRequests]
        case .transport: return [.transport]
        case .hostel: return [.hostel]
        case .certificates: return [.certificates]
        case .wellbeing: return [.accomplishments, .incidents]
        }
    }
}

// MARK: - Display rows

enum OneViewTone {
    case good, warn, bad, info, neutral

    var colors: (fg: UIColor, bg: UIColor) {
        switch self {
        case .good: return (UIColor(feeHex: "047857"), UIColor(feeHex: "D1FAE5"))
        case .warn: return (UIColor(feeHex: "B45309"), UIColor(feeHex: "FFEDD5"))
        case .bad: return (UIColor(feeHex: "B91C1C"), UIColor(feeHex: "FEE2E2"))
        case .info: return (UIColor(feeHex: "1F5FD1"), UIColor(feeHex: "E8F0FE"))
        case .neutral: return (UIColor(feeHex: "475569"), UIColor(feeHex: "F1F5F9"))
        }
    }
}

struct OneViewStat {
    let title: String
    let value: String
}

struct OneViewItem {
    var title: String
    var subtitle: String = ""
    var detail: String = ""
    var value: String = ""
    var status: String = ""
    var tone: OneViewTone = .neutral
    /// A file to open when the row is tapped (receipt, certificate).
    var url: String = ""
}

/// One coloured part of a ring (fee paid / discount / pending, present / absent).
struct OneViewSegment {
    let title: String
    let value: String
    let fraction: CGFloat
    let color: UIColor
}

/// A small coloured tile with an SF Symbol, a big number and a caption.
struct OneViewTile {
    let title: String
    let value: String
    let symbol: String
    let tone: OneViewTone
}

/// A labelled horizontal bar (subject %, term attendance %, exam total %).
struct OneViewBar {
    let title: String
    let value: String
    var subtitle: String = ""
    let fraction: CGFloat
    let tone: OneViewTone
}

enum OneViewPalette {
    static let paid = UIColor(feeHex: "10B981")
    static let discount = UIColor(feeHex: "3B82F6")
    static let pending = UIColor(feeHex: "F59E0B")
    static let absent = UIColor(feeHex: "EF4444")
}

enum OneViewRow {
    case header(name: String, line1: String, line2: String, photo: String)
    case ring(caption: String, value: String, note: String, center: String, centerCaption: String, segments: [OneViewSegment])
    case tiles([OneViewTile])
    case bar(OneViewBar)
    case summary(caption: String, value: String, note: String, progress: Float?, stats: [OneViewStat])
    case keyValue(key: String, value: String)
    case item(OneViewItem)
}

struct OneViewSection {
    let title: String?
    let rows: [OneViewRow]
}
