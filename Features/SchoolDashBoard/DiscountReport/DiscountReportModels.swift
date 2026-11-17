//
//  DiscountReportModels.swift
//  School Chimes
//
//  Principal side: Discount menu → fee/api/fee-report/discount-report
//  Response models (lenient: any field may be missing, a string or a number)
//  and the display model the screen binds to.
//

import UIKit

// MARK: - Lenient text value

/// Decodes "2", 2 or 2.0 into a String so a type change on the server does not break the screen.
struct DiscountText: Codable {
    let text: String

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let s = try? c.decode(String.self) { text = s }
        else if let i = try? c.decode(Int.self) { text = String(i) }
        else if let d = try? c.decode(Double.self) { text = String(d) }
        else { text = "" }
    }

//    func encode(to encoder: Encoder) throws {
//        var c = encoder.singleValueContainer()
//        try c.encode(text)
//    }
}

private extension Optional where Wrapped == DiscountText {
    var value: String { (self?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
}

// MARK: - Response

struct DiscountReportResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [DiscountReportData]?
}

struct DiscountTypeResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [DiscountTypeData]?
}

struct DiscountTypeData: Codable {
        let id: String?
        let discount_name: String?
        let type: String?
        let type_name: String?
}


struct DiscountReportData: Codable {
    let discount_details: [DiscountCategoryData]?
    let total_count: DiscountText?
    let total_discount: DiscountText?
    let total_subsidy: DiscountText?
    let student_data_count: DiscountText?
    let total_discount_and_subsidy: DiscountText?
}

struct DiscountCategoryData: Codable {
    let category: DiscountText?
    let count: DiscountText?
    let total: DiscountText?
    let type_name: String?
    let discount_data: [DiscountEntryData]?
}

struct DiscountEntryData: Codable {
    let student_name: DiscountText?
    let admission_no: DiscountText?
    let gender: DiscountText?
    let class_name: DiscountText?
    let section_name: DiscountText?
    let fee_group_name: DiscountText?
    let fee_name: DiscountText?
    let given_date: DiscountText?
    let given_by: DiscountText?
    let discount_used: DiscountText?
    let remarks: DiscountText?
    let amount: DiscountText?
    
}

// MARK: - Request filter

/// `type` query parameter.
enum DiscountFilterType: String, CaseIterable {
    case all = "0"
    case discount = "1"
    case subsidy = "2"

    var title: String {
        switch self {
        case .all: return "All types".translated()
        case .discount: return "Discount".translated()
        case .subsidy: return "Subsidy".translated()
        }
    }
}

// MARK: - Display model

/// "D - Spot Discount" → discount, "S - RTE" → subsidy.
enum DiscountKind {
    case discount, subsidy, other

    var title: String {
        switch self {
        case .discount: return "Discount".translated()
        case .subsidy: return "Subsidy".translated()
        case .other: return "Other".translated()
        }
    }


    var color: UIColor {
        switch self {
        case .discount: return StudentFeeColor.orange
        case .subsidy: return UIColor(feeHex: "2563EB")
        case .other: return StudentFeeColor.muted
        }
    }
}

struct DiscountEntry {
    let name: String
    let meta: String        // "SS-7440 · VII - A"
    let fee: String         // "Hostel Fee · Hostel"
    let given: String       // "26-08-2026 04:10 PM · by vs2020"
    let remarks: String
    let amount: String
}

struct DiscountCategory {
    let kind: DiscountKind
    let name: String        // "Spot Discount"
    let count: String
    let total: String
    let entries: [DiscountEntry]
}

struct DiscountReport {
    let total: String
    let total_discount_and_subsidy: String
    let count: String
    let discountTotal: String
    let subsidyTotal: String
    let categories: [DiscountCategory]
    
    init?(_ response: DiscountReportResponse?) {
        guard response?.status == true, let d = response?.data?.first else { return nil }

        categories = (d.discount_details ?? []).map { c in
            let (kind, name) = DiscountReport.split(c.type_name ?? "",c.category.value)
            let entries = (c.discount_data ?? []).map(DiscountReport.entry)
            return DiscountCategory(kind: kind, name: name,
                                    count: c.count.value.isEmpty ? "\(entries.count)" : c.count.value,
                                    total: c.total.value.isEmpty ? FeeAmount.sum(entries.map { $0.amount }) : c.total.value,
                                    entries: entries)
        }
        let allTotals = categories.map { $0.total }
        total = d.total_discount.value.isEmpty ? FeeAmount.sum(allTotals) : d.total_discount.value
        let serverCount = d.student_data_count.value.isEmpty ? d.total_count.value : d.student_data_count.value
        count = serverCount.isEmpty ? "\(categories.reduce(0) { $0 + $1.entries.count })" : serverCount
        let symbol = FeeAmount.symbol(total)
        let cats = categories
        func sum(_ kind: DiscountKind) -> String {
            let v = cats.filter { $0.kind == kind }.reduce(0) { $0 + FeeAmount.value($1.total) }
            return FeeAmount.format(v, symbol: symbol)
        }
        // Prefer the totals the server sends; add up the categories only when a field is missing.
        discountTotal = d.total_discount.value.isEmpty ? sum(.discount) : d.total_discount.value
        subsidyTotal = d.total_subsidy.value.isEmpty ? sum(.subsidy) : d.total_subsidy.value
        if d.total_discount_and_subsidy.value.isEmpty {
            let both = FeeAmount.value(discountTotal) + FeeAmount.value(subsidyTotal)
            total_discount_and_subsidy = FeeAmount.format(both, symbol: symbol)
        } else {
            total_discount_and_subsidy = d.total_discount_and_subsidy.value
        }
        
        }
    
    var isEmpty: Bool { categories.allSatisfy { $0.entries.isEmpty } }

    /// "D - Spot Discount" → (.discount, "Spot Discount"); "S - S - RTE" → (.subsidy, "S - RTE").
    private static func split(_ type_name: String,_ category: String) -> (DiscountKind, String) {
//        guard let r = category.range(of: " - ") else { return (.other, category.isEmpty ? "-" : category) }
//        let code = category[..<r.lowerBound].trimmingCharacters(in: .whitespaces).uppercased()
//        let name = String(category[r.upperBound...]).trimmingCharacters(in: .whitespaces)
//        switch code {
//        case "D": return (.discount, name)
//        case "S": return (.subsidy, name)
//        default: return (.other, category)
//        }
        if type_name == "Discount"{
            return (.discount, category)
        }else if type_name == "Subsidy"{
            
            return (.subsidy,category )
        }
        else{
            return (.other,category)
        }
        
    }

    private static func entry(_ e: DiscountEntryData) -> DiscountEntry {
        let classSection = [e.class_name.value, e.section_name.value].filter { !$0.isEmpty }.joined(separator: " - ")
        let meta = [e.admission_no.value, classSection, e.gender.value.capitalized]
            .filter { !$0.isEmpty }.joined(separator: "  ·  ")
        let group = e.fee_group_name.value, feeName = e.fee_name.value
        let fee = (group == feeName || feeName.isEmpty) ? group : [group, feeName].filter { !$0.isEmpty }.joined(separator: "  ·  ")
        let by = e.given_by.value.isEmpty ? "" : "\("by".translated()) \(e.given_by.value)"
        let given = [e.given_date.value, by].filter { !$0.isEmpty }.joined(separator: "  ·  ")
        return DiscountEntry(name: e.student_name.value.isEmpty ? "-" : e.student_name.value,
                             meta: meta, fee: fee.isEmpty ? "-" : fee, given: given,
                             remarks: e.remarks.value,
                             amount: e.amount.value.isEmpty ? "-" : e.amount.value)
    }
}
