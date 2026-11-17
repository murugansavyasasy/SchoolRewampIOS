//
//  StudentFeeDetailsModels.swift
//  School Chimes
//
//  Response of fee/api/fee-details/student-fee-details ("Fee details loaded.")
//  and the display model the Student Fee Details screen shows.
//
//  The response is decoded leniently (any value can be a string, number, bool,
//  array or object) because several categories arrive empty in the samples
//  (term, transport, hostel, quantity), so their exact field names are read
//  from a list of likely keys instead of a fixed struct.
//

import UIKit

// MARK: - Lenient JSON value

enum FeeJSON: Codable {
    case string(String), number(Double), bool(Bool), array([FeeJSON]), object([String: FeeJSON]), null

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let v = try? c.decode(Bool.self) { self = .bool(v) }
        else if let v = try? c.decode(Double.self) { self = .number(v) }
        else if let v = try? c.decode(String.self) { self = .string(v) }
        else if let v = try? c.decode([FeeJSON].self) { self = .array(v) }
        else if let v = try? c.decode([String: FeeJSON].self) { self = .object(v) }
        else { self = .null }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .string(let v): try c.encode(v)
        case .number(let v): try c.encode(v)
        case .bool(let v): try c.encode(v)
        case .array(let v): try c.encode(v)
        case .object(let v): try c.encode(v)
        case .null: try c.encodeNil()
        }
    }

    /// Text form of a scalar value; nil for arrays, objects and null.
    var text: String? {
        switch self {
        case .string(let s): return s
        case .number(let d): return (d == d.rounded() && abs(d) < 1e15) ? String(Int(d)) : String(d)
        case .bool(let b): return b ? "Yes" : "No"
        default: return nil
        }
    }

    var array: [FeeJSON] {
        if case .array(let a) = self { return a }
        return []
    }

    var object: [String: FeeJSON]? {
        if case .object(let o) = self { return o }
        return nil
    }
}

/// One JSON object with helpers to read the first non-empty value of several possible keys.
struct FeeRecord {
    let raw: [String: FeeJSON]

    func text(_ keys: String...) -> String? {
        for k in keys {
            if let t = raw[k]?.text?.trimmingCharacters(in: .whitespaces), !t.isEmpty { return t }
        }
        return nil
    }

    func records(_ keys: String...) -> [FeeRecord] {
        for k in keys {
            let list = (raw[k]?.array ?? []).compactMap { $0.object }.map(FeeRecord.init)
            if !list.isEmpty { return list }
        }
        return []
    }
}

// MARK: - Response

struct StudentFeeDetailsResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [FeeJSON]?

    /// The first data object, parsed for display.
    var details: StudentFeeDetails? {
        guard let obj = data?.first?.object else { return nil }
        return StudentFeeDetails(FeeRecord(raw: obj))
    }
}

// MARK: - Display model

struct StudentFeeSummary {
    let total: String
    let paid: String
    let discount: String
    let pending: String

    /// Paid share of the total, 0...1.
    var paidFraction: Float {
        let t = FeeAmount.value(total)
        return t > 0 ? Float(min(max(FeeAmount.value(paid) / t, 0), 1)) : 0
    }
}

struct StudentFeeRow {
    let title: String
    let subtitle: String
    let amounts: String           // "Fee ₹… · Paid ₹… · Discount ₹…"
    let status: StudentFeeRowStatus
    let pendingCaption: String
    let pending: String
    let breakdown: [(String, String)]
}

struct StudentFeeCategory {
    let title: String
    let totalPending: String
    let rows: [StudentFeeRow]
}

enum StudentFeeRowStatus {
    case paid, partial, pending, other(String)

    init(raw: String?, paid: Double, pending: Double) {
        switch (raw ?? "").lowercased().replacingOccurrences(of: "_", with: " ") {
        case "paid", "completed", "complete": self = .paid
        case "partial", "partially paid", "partly paid": self = .partial
        case "pending", "unpaid", "due": self = (paid > 0 && pending > 0) ? .partial : .pending
        case "":
            if pending <= 0 { self = .paid }
            else if paid > 0 { self = .partial }
            else { self = .pending }
        default: self = .other(raw ?? "")
        }
    }

    var title: String {
        switch self {
        case .paid: return "Paid".translated()
        case .partial: return "Partially paid".translated()
        case .pending: return "Pending".translated()
        case .other(let s): return s.capitalized
        }
    }

    var color: UIColor {
        switch self {
        case .paid: return StudentFeeColor.green
        case .partial: return UIColor(feeHex: "2563EB")
        case .pending: return StudentFeeColor.orange
        case .other: return StudentFeeColor.slate
        }
    }
}

struct StudentFeeDetails {
    let summary: StudentFeeSummary
    let categories: [StudentFeeCategory]

    var isEmpty: Bool { categories.isEmpty }

    init(_ root: FeeRecord) {
        let pendingWord = "Pending".translated()

        func amounts(_ r: FeeRecord, feeKeys: [String]) -> (fee: String?, paid: String?, discount: String?, pending: String?) {
            let fee = feeKeys.lazy.compactMap { r.text($0) }.first
            return (fee,
                    r.text("paid_amount", "actual_paid", "paid"),
                    r.text("discount_amount", "discount_given", "discount_availed", "discount"),
                    r.text("pending_amount", "amount_to_be_paid", "pending", "balance_amount"))
        }

        func amountLine(fee: String?, paid: String?, discount: String?, feeWord: String = "Fee") -> String {
            "\(feeWord.translated()) \(fee ?? "-")  ·  \("Paid".translated()) \(paid ?? "-")  ·  \("Discount".translated()) \(FeeAmount.display(discount))"
        }

        /// Month rows (others / transport / hostel) and payments already made.
        func breakdown(_ r: FeeRecord) -> [(String, String)] {
            var lines: [(String, String)] = []
            for m in r.records("month_details", "bus_month_details", "month_wise_fee", "months") {
                let amt = m.text("fee_amount", "amount_per_month", "actual_amount", "amount") ?? "-"
                let pend = m.text("pending_amount", "pending", "amount_to_be_paid") ?? "-"
                lines.append((m.text("month_name", "month") ?? "-", "\(amt)  (\(pendingWord) \(pend))"))
            }
            for (i, p) in r.records("paid_details", "payment_details", "payments").enumerated() {
                let date = p.text("paid_date", "paid_on", "payment_date", "date", "created_on")
                let amt = p.text("paid_amount", "amount_given", "amount", "amount_paid")
                let mode = p.text("payment_mode", "mode")
                let receipt = p.text("receipt_no", "receipt_number", "bill_no").map { "#\($0)" }
                let disc = p.text("discount_amount").flatMap { FeeAmount.value($0) > 0 ? "\("Discount".translated()) \($0)" : nil }
                let title = ["\("Payment".translated()) \(i + 1)", date].compactMap { $0 }.joined(separator: "  ·  ")
                var value = [amt, mode, disc, receipt].compactMap { $0 }.joined(separator: "  ·  ")
                if value.isEmpty {
                    value = p.raw.compactMap { k, v in v.text.map { "\(k): \($0)" } }.sorted().joined(separator: ", ")
                }
                lines.append((title, value))
            }
            return lines
        }

        func row(_ r: FeeRecord, title: String, subtitle: [String?], feeKeys: [String], feeWord: String = "Fee",
                 extra: [(String, String)] = []) -> StudentFeeRow {
            let a = amounts(r, feeKeys: feeKeys)
            return StudentFeeRow(
                title: title,
                subtitle: subtitle.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: "  ·  "),
                amounts: amountLine(fee: a.fee, paid: a.paid, discount: a.discount, feeWord: feeWord),
                status: StudentFeeRowStatus(raw: r.text("status", "payment_status"),
                                            paid: FeeAmount.value(a.paid), pending: FeeAmount.value(a.pending)),
                pendingCaption: pendingWord,
                pending: a.pending ?? "-",
                breakdown: extra + breakdown(r))
        }

        var categories: [StudentFeeCategory] = []
        func add(_ title: String, _ rows: [StudentFeeRow]) {
            guard !rows.isEmpty else { return }
            categories.append(StudentFeeCategory(title: title.translated(),
                                                 totalPending: FeeAmount.sum(rows.map { $0.pending }),
                                                 rows: rows))
        }
        let feeKeys = ["actual_amount", "fee_amount", "total_amount", "amount"]

        // Term fees
        add("Term fees", root.records("term_fees").map {
            row($0, title: $0.text("fee_name") ?? "-", subtitle: [$0.text("term_name")], feeKeys: feeKeys)
        })

        // Other fees
        add("Other fees", root.records("other_fees").map {
            let term = $0.text("term_name")
            return row($0, title: $0.text("fee_name") ?? "-",
                       subtitle: [term?.lowercased() == "others" ? nil : term], feeKeys: feeKeys)
        })

        // Transport
        add("Transport fees", root.records("transport_fee", "transport_fees").map {
            row($0, title: $0.text("route_name", "fee_name") ?? "Transport".translated(),
                subtitle: [$0.text("stop_name"), $0.text("route_fee_type_name")], feeKeys: feeKeys)
        })

        // Hostel
        add("Hostel fees", root.records("hostel_fee", "hostel_fees").map { h in
            let room = h.text("room_no").map { "\("Room".translated()) \($0)" }
            let bed = h.text("bed_no").map { "\("Bed".translated()) \($0)" }
            return row(h, title: h.text("hostel_name", "fee_name") ?? "Hostel".translated(),
                       subtitle: [room, bed], feeKeys: feeKeys)
        })

        // Carryover (previous years)
        add("Carryover fees", root.records("carryover_fees", "carryover").map { c in
            let items = c.records("break_down", "carry_over_fee_display", "carry_over_fee").map { item -> (String, String) in
                let name = item.text("fee_name") ?? "-"
                let group = item.text("fee_group_type_name") ?? ""
                let label = (group.isEmpty || group == name) ? name : "\(name)  ·  \(group)"
                let fee = item.text("m_feeamount", "fee_amount")
                let paid = item.text("paid_amount")
                let pend = item.text("pending_amount", "total_pending_carriedover")
                let value = [fee.map { "\("Fee".translated()) \($0)" },
                             paid.map { "\("Paid".translated()) \($0)" },
                             pend.map { "\(pendingWord) \($0)" }].compactMap { $0 }.joined(separator: "  ·  ")
                return (label, value.isEmpty ? "-" : value)
            }
            let oldShape = c.text("pending_carried_over") != nil
            return row(c, title: c.text("fee_type", "fee_name") ?? "Previous Year Pending Fee".translated(),
                       subtitle: [c.text("year_name", "fee_group_type_name"), c.text("fee_category_name")],
                       feeKeys: ["actual_amount", "pending_carried_over", "fee_amount"],
                       feeWord: oldShape ? "Carried over" : "Fee", extra: items)
        })

        // Quantity
        add("Quantity fees", root.records("quantity_fees", "quantity").map { q in
            let qty = q.text("qom_given", "quantity")
            let price = q.text("uom_price", "unit_price")
            let sub = (qty != nil || price != nil) ? "\("Quantity".translated()) \(qty ?? "-") × \(price ?? "-")" : nil
            return row(q, title: q.text("fee_name") ?? "-", subtitle: [sub], feeKeys: feeKeys)
        })
        self.categories = categories

        // Summary: from the API, or added up from the rows when it is missing.
        let s = root.raw["summary"]?.object.map(FeeRecord.init)
        let allRows = categories.flatMap { $0.rows }
        self.summary = StudentFeeSummary(
            total: s?.text("total_amount") ?? "-",
            paid: s?.text("total_paid") ?? "-",
            discount: s?.text("total_discount") ?? "-",
            pending: s?.text("total_pending") ?? FeeAmount.sum(allRows.map { $0.pending }))
    }
}
