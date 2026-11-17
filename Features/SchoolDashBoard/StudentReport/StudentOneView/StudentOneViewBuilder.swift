//
//  StudentOneViewBuilder.swift
//  School Chimes
//
//  Turns the One View API results into table sections for each tab.
//  Field meanings follow the One View API explorer (field definitions card).
//  Visual rows: .ring (fee / attendance share), .tiles (counts), .bar (marks, terms, exams).
//

import UIKit

struct StudentOneViewBuilder {
    /// Successful results by API.
    let results: [OneViewAPI: FeeRecord]
    /// Server message for APIs that failed ("" = worked but returned no data).
    let errors: [OneViewAPI: String]
    /// Name / class from the student list, used until the profile API answers.
    let fallbackName: String
    let fallbackClass: String

    func sections(for tab: OneViewTab) -> [OneViewSection] {
        switch tab {
        case .overview: return overview()
        case .profile: return profile()
        case .fees: return fees()
        case .exams: return exams()
        case .attendance: return attendance()
        case .transport: return transport()
        case .hostel: return hostel()
        case .certificates: return certificates()
        case .wellbeing: return wellbeing()
        }
    }

    // MARK: - Helpers

    private func number(_ text: String) -> Double? { Double(text.trimmingCharacters(in: .whitespaces)) }

    private func fraction(_ percentText: String) -> CGFloat {
        CGFloat(min(max((number(percentText) ?? 0) / 100, 0), 1))
    }

    private func pct(_ text: String) -> String {
        guard let v = number(text) else { return text.isEmpty ? "-" : text }
        return v == v.rounded() ? "\(Int(v))%" : String(format: "%.1f%%", v)
    }

    private func orDash(_ text: String) -> String { text.isEmpty ? "-" : text }

    private func join(_ parts: [String], _ sep: String = "  ·  ") -> String {
        parts.filter { !$0.isEmpty }.joined(separator: sep)
    }

    private func count(_ text: String) -> Int { Int(text) ?? 0 }

    /// Section with only the server message, or nil when the API simply has no data.
    private func failure(_ api: OneViewAPI, title: String?) -> OneViewSection? {
        guard let msg = errors[api], !msg.isEmpty else { return nil }
        return OneViewSection(title: title, rows: [.item(OneViewItem(title: msg, tone: .neutral))])
    }

    private func empty(_ text: String) -> OneViewRow { .item(OneViewItem(title: text, tone: .neutral)) }

    private func keyValues(_ pairs: [(String, String)]) -> [OneViewRow] {
        pairs.filter { !$0.1.isEmpty }.map { .keyValue(key: $0.0, value: $0.1) }
    }

    /// Shows only the last 4 digits of an ID number such as Aadhaar.
    private func masked(_ text: String) -> String {
        guard text.count > 4 else { return text }
        return "•••• " + String(text.suffix(4))
    }

    /// Paid / discount / pending ring from three money strings.
    private func feeRing(caption: String, total: String, paid: String, discount: String, pending: String, note: String) -> OneViewRow {
        let t = FeeAmount.value(total)
        let p = FeeAmount.value(paid), d = FeeAmount.value(discount), q = FeeAmount.value(pending)
        let base = t > 0 ? t : max(p + d + q, 1)
        let paidPct = Int((p / base * 100).rounded())
        return .ring(caption: caption, value: orDash(pending), note: note.isEmpty ? "\("Total".translated()) \(orDash(total))" : note,
                     center: "\(paidPct)%", centerCaption: "paid".translated(),
                     segments: [OneViewSegment(title: "Paid".translated(), value: orDash(paid), fraction: CGFloat(p / base), color: OneViewPalette.paid),
                                OneViewSegment(title: "Discount".translated(), value: orDash(discount), fraction: CGFloat(d / base), color: OneViewPalette.discount),
                                OneViewSegment(title: "Pending".translated(), value: orDash(pending), fraction: CGFloat(q / base), color: OneViewPalette.pending)])
    }

    /// Present / absent ring.
    private func attendanceRing(caption: String, present: String, absent: String, note: String) -> OneViewRow {
        .ring(caption: caption, value: pct(present), note: note, center: pct(present), centerCaption: "present".translated(),
              segments: [OneViewSegment(title: "Present".translated(), value: pct(present), fraction: fraction(present), color: OneViewPalette.paid),
                         OneViewSegment(title: "Absent".translated(), value: pct(absent), fraction: fraction(absent), color: OneViewPalette.absent)])
    }

    private func toneFor(percent: Double?) -> OneViewTone {
        guard let p = percent else { return .neutral }
        return p >= 75 ? .good : (p >= 50 ? .warn : .bad)
    }

    private var header: OneViewRow {
        let p = results[.profile]
        let name = join([p?.s("student_name") ?? "", p?.s("last_name") ?? ""], " ")
        let classSection = join([p?.s("class_name") ?? "", p?.s("section_name") ?? ""], " - ")
        let adm = p?.s("admission_no") ?? "", roll = p?.s("roll_no") ?? ""
        let line1 = join([adm.isEmpty ? "" : "\("Adm.".translated()) \(adm)", roll.isEmpty ? "" : "\("Roll".translated()) \(roll)"])
        let house = p?.s("house_group_name") ?? ""
        return .header(name: name.isEmpty ? fallbackName : name,
                       line1: line1.isEmpty ? fallbackClass : line1,
                       line2: join([classSection.isEmpty ? fallbackClass : classSection, house]),
                       photo: p?.s("photo_path") ?? "")
    }

    // MARK: - Overview

    private func overview() -> [OneViewSection] {
        var out = [OneViewSection(title: nil, rows: [header])]

        // Quick numbers across the summaries
        var quick: [OneViewTile] = []
        if let a = results[.attendanceWellbeingSummary], let att = a.obj("attendance") {
            let present = number(att.s("present_percentage"))
            quick.append(OneViewTile(title: "Attendance".translated(), value: pct(att.s("present_percentage")), symbol: "calendar.badge.checkmark", tone: toneFor(percent: present)))
        }
        if let c = results[.certificateExamSummary], !c.s("exam_name").isEmpty {
            quick.append(OneViewTile(title: c.s("exam_name"), value: orDash(c.s("exam_total")), symbol: "chart.bar.fill", tone: .info))
        }
        if let f = results[.feeSummary]?.obj("fee") {
            let pending = FeeAmount.value(f.s("pending_amount"))
            quick.append(OneViewTile(title: "Fee pending".translated(), value: orDash(f.s("pending_amount")), symbol: "indianrupeesign.circle.fill", tone: pending > 0 ? .warn : .good))
        }
        if let c = results[.certificateExamSummary] {
            quick.append(OneViewTile(title: "Certificates".translated(), value: orDash(c.s("certificate_count")), symbol: "doc.text.fill", tone: .info))
        }
        if !quick.isEmpty { out.append(OneViewSection(title: "At a glance".translated(), rows: [.tiles(Array(quick.prefix(4)))])) }

        if let f = results[.feeSummary] {
            var rows: [OneViewRow] = []
            if let fee = f.obj("fee") {
                rows.append(feeRing(caption: "School fee pending".translated(), total: fee.s("total_amount"), paid: fee.s("paid_amount"),
                                    discount: fee.s("discount_amount"), pending: fee.s("pending_amount"), note: ""))
            }
            if let t = f.obj("transport"), !(t.s("paid_amount").isEmpty && t.s("pending_amount").isEmpty) {
                let p = FeeAmount.value(t.s("paid_amount")), q = FeeAmount.value(t.s("pending_amount"))
                rows.append(.bar(OneViewBar(title: "Transport".translated(), value: "\(orDash(t.s("pending_amount"))) \("due".translated())",
                                            subtitle: join(["\("Paid".translated()) \(orDash(t.s("paid_amount")))", t.s("month_given")]),
                                            fraction: p + q > 0 ? CGFloat(p / (p + q)) : 0, tone: .good)))
            }
            if let h = f.obj("hostel"), !(h.s("paid_amount").isEmpty && h.s("pending_amount").isEmpty) {
                let p = FeeAmount.value(h.s("paid_amount")), q = FeeAmount.value(h.s("pending_amount"))
                rows.append(.bar(OneViewBar(title: join(["Hostel".translated(), h.s("hostel_name")]), value: "\(orDash(h.s("pending_amount"))) \("due".translated())",
                                            subtitle: "\("Paid".translated()) \(orDash(h.s("paid_amount")))",
                                            fraction: p + q > 0 ? CGFloat(p / (p + q)) : 0, tone: .good)))
            }
            if !rows.isEmpty { out.append(OneViewSection(title: "Fees".translated(), rows: rows)) }
        } else if let f = failure(.feeSummary, title: "Fees".translated()) { out.append(f) }

        if let a = results[.attendanceWellbeingSummary] {
            var rows: [OneViewRow] = []
            if let att = a.obj("attendance") {
                rows.append(attendanceRing(caption: "Attendance this year".translated(), present: att.s("present_percentage"),
                                           absent: att.s("absent_percentage"), note: ""))
            }
            rows.append(.tiles([
                OneViewTile(title: "Accomplishments".translated(), value: orDash(a.s("accomplishment_count")), symbol: "trophy.fill", tone: .good),
                OneViewTile(title: "Positive behaviour".translated(), value: orDash(a.s("positive_behaviour_count")), symbol: "hand.thumbsup.fill", tone: .info),
                OneViewTile(title: "Negative incidents".translated(), value: orDash(a.s("negative_incident_count")), symbol: "exclamationmark.triangle.fill", tone: .warn),
                OneViewTile(title: "Indiscipline".translated(), value: orDash(a.s("indisciplinary_activity_count")), symbol: "xmark.octagon.fill", tone: .bad)
            ]))
            out.append(OneViewSection(title: "Attendance and well-being".translated(), rows: rows))
        } else if let f = failure(.attendanceWellbeingSummary, title: "Attendance and well-being".translated()) { out.append(f) }

        if let c = results[.certificateExamSummary] {
            let certs = c.list("certificates")
            let total = max(certs.reduce(0) { $0 + count($1.s("count")) }, 1)
            var rows: [OneViewRow] = certs.map { x in
                .bar(OneViewBar(title: x.s("certificate_name"), value: orDash(x.s("count")),
                                fraction: CGFloat(count(x.s("count"))) / CGFloat(total), tone: .info))
            }
            if rows.isEmpty { rows = [empty("No certificates issued.".translated())] }
            out.append(OneViewSection(title: "Certificates issued".translated(), rows: rows))
        } else if let f = failure(.certificateExamSummary, title: "Exams and certificates".translated()) { out.append(f) }

        return out
    }

    // MARK: - Profile

    private func profile() -> [OneViewSection] {
        guard let p = results[.profile] else {
            return [failure(.profile, title: nil) ?? OneViewSection(title: nil, rows: [empty("No profile details.".translated())])]
        }
        let x = p.obj("additional_details")
        let ax: (String) -> String = { x?.s($0) ?? "" }
        var out = [OneViewSection(title: nil, rows: [header])]

        var chips: [OneViewTile] = []
        if !p.s("blood_group_name").isEmpty { chips.append(OneViewTile(title: "Blood group".translated(), value: p.s("blood_group_name"), symbol: "drop.fill", tone: .bad)) }
        if !p.s("dob").isEmpty { chips.append(OneViewTile(title: "Date of birth".translated(), value: p.s("dob"), symbol: "gift.fill", tone: .info)) }
        chips.append(OneViewTile(title: "Bus student".translated(), value: orDash(p.s("is_bus_student")), symbol: "bus.fill", tone: p.s("is_bus_student") == "Yes" ? .good : .neutral))
        chips.append(OneViewTile(title: "Hostel student".translated(), value: orDash(p.s("is_hostel_student")), symbol: "bed.double.fill", tone: p.s("is_hostel_student") == "Yes" ? .good : .neutral))
        out.append(OneViewSection(title: nil, rows: [.tiles(Array(chips.prefix(4)))]))

        let groups: [(String, [(String, String)])] = [
            ("Student".translated(), [
                ("Admission no".translated(), p.s("admission_no")), ("Roll no".translated(), p.s("roll_no")),
                ("Gender".translated(), p.s("gender")), ("Student type".translated(), p.s("student_type")),
                ("House".translated(), p.s("house_group_name").isEmpty ? p.s("house_or_group") : p.s("house_group_name")),
                ("Fee category".translated(), p.s("fee_category_name")), ("Joined in".translated(), p.s("joining_class_name")),
                ("Admission date".translated(), p.s("admission_date")), ("Medium".translated(), p.s("medium")),
                ("Religion".translated(), p.s("religion")), ("Community".translated(), p.s("community_name")),
                ("Nationality".translated(), p.s("nationality")), ("Mother tongue".translated(), ax("mother_language"))]),
            ("Contact".translated(), [
                ("Mobile".translated(), p.s("primary_mobile")), ("Secondary mobile".translated(), p.s("secondary_mobile")),
                ("WhatsApp".translated(), p.s("whatsapp_number")), ("Email".translated(), p.s("email")),
                ("Address".translated(), join([p.s("residental_address"), p.s("residental_city"), p.s("residental_state"), p.s("residental_pincode")], ", "))]),
            ("Parents and guardian".translated(), [
                ("Father".translated(), p.s("father_name")), ("Father's mobile".translated(), ax("father_mobile")),
                ("Father's occupation".translated(), p.s("father_occupation")),
                ("Mother".translated(), p.s("mother_name")), ("Mother's mobile".translated(), ax("mother_mobile")),
                ("Mother's occupation".translated(), p.s("mother_occupation")),
                ("Guardian".translated(), ax("guardian_name")), ("Guardian's contact".translated(), ax("guardian_contact"))]),
            ("ID numbers".translated(), [
                ("EMIS".translated(), p.s("emis_number")), ("PEN".translated(), p.s("pen_number")),
                ("APAAR".translated(), ax("student_apaar_no")), ("Aadhaar".translated(), masked(p.s("student_adhaar_number"))),
                ("RTE".translated(), p.s("rte_number")), ("SATS / STS".translated(), p.s("sts_number")),
                ("GR number".translated(), ax("gr_number"))]),
            ("Health".translated(), [
                ("Height".translated(), p.s("height")), ("Weight".translated(), p.s("weight")),
                ("Medical condition".translated(), p.s("medical_condition")), ("Vaccination".translated(), p.s("vaccination")),
                ("Identification mark".translated(), join([p.s("mark_identification_a"), p.s("mark_identification_b")], "; "))]),
            ("Previous school".translated(), [
                ("School".translated(), p.s("school_and_location")), ("Class".translated(), p.s("class_previously")),
                ("Year".translated(), p.s("year_of_study")), ("Result".translated(), p.s("percentage_or_grade")),
                ("TC number".translated(), p.s("leaving_certificate_no"))]),
            ("Interests".translated(), [
                ("Achievements".translated(), p.s("acheivements")), ("Hobbies".translated(), p.s("hobbies")),
                ("Remarks".translated(), p.s("remarks"))])
        ]
        for (title, pairs) in groups {
            let rows = keyValues(pairs)
            if !rows.isEmpty { out.append(OneViewSection(title: title, rows: rows)) }
        }
        let siblings = p.list("sibling_details").map { s -> OneViewRow in
            .item(OneViewItem(title: join([s.s("student_name"), s.s("last_name")], " "),
                              subtitle: join([s.s("class_name"), s.s("section_name")], " - ")))
        }
        if !siblings.isEmpty { out.append(OneViewSection(title: "Siblings".translated(), rows: siblings)) }
        return out
    }

    // MARK: - Fees

    private func fees() -> [OneViewSection] {
        var out: [OneViewSection] = []

        if let d = results[.feeDetails] {
            out.append(OneViewSection(title: nil, rows: [
                feeRing(caption: "Fee pending".translated(), total: d.s("total_fee_amount"), paid: d.s("total_paid_amount"),
                        discount: d.s("total_discount_amount"), pending: d.s("total_pending_amount"), note: "")
            ]))
            let fees = d.list("fees").map { f -> OneViewRow in
                let amount = FeeAmount.value(f.s("amount"))
                let settled = FeeAmount.value(f.s("student_paid")) + FeeAmount.value(f.s("discount_given"))
                let paid = f.s("pending_status") == "1"
                let notAssigned = f.s("pending_amount").isEmpty
                let payments = f.list("paid_details").map { "\($0.s("paid_date")) \($0.s("paid_amount"))" }
                return .bar(OneViewBar(
                    title: join([f.s("fee_name"), f.s("fee_group_type_name")]),
                    value: notAssigned ? "Not assigned".translated() : (paid ? "Paid".translated() : "\(f.s("pending_amount")) \("due".translated())"),
                    subtitle: join(["\("Fee".translated()) \(orDash(f.s("amount")))", "\("Paid".translated()) \(orDash(f.s("student_paid")))",
                                    f.s("discount_given").isEmpty ? "" : "\("Discount".translated()) \(f.s("discount_given"))",
                                    payments.isEmpty ? "" : "\("Last paid".translated()) \(payments.last ?? "")"]),
                    fraction: amount > 0 ? CGFloat(settled / amount) : 0,
                    tone: notAssigned ? .neutral : (paid ? .good : .warn)))
            }
            out.append(OneViewSection(title: "Fee details".translated(), rows: fees.isEmpty ? [empty("No fees assigned.".translated())] : fees))
        } else if let f = failure(.feeDetails, title: "Fee details".translated()) { out.append(f) }

        if let r = results[.receipts] {
            let rows = r.list("receipts").map { x -> OneViewRow in
                .item(OneViewItem(title: x.s("invoice_no"), subtitle: x.s("invoice_date"), value: x.s("paid_amount"),
                                  status: x.s("invoice_path").isEmpty ? "" : "PDF", tone: .info, url: x.s("invoice_path")))
            }
            out.append(OneViewSection(title: "Receipts".translated(), rows: rows.isEmpty ? [empty("No receipts yet.".translated())] : rows))
        } else if let f = failure(.receipts, title: "Receipts".translated()) { out.append(f) }

        if let o = results[.onlinePayments] {
            let rows = o.list("payments").map { x -> OneViewRow in
                .item(OneViewItem(title: x.s("receipt_no"), subtitle: join([x.s("receipt_date"), x.s("provider").capitalized]),
                                  detail: join([x.s("order_id").isEmpty ? "" : "Order \(x.s("order_id"))", x.s("transaction_id").isEmpty ? "" : "Txn \(x.s("transaction_id"))"]),
                                  value: x.s("receipt_amount"), status: "Online".translated(), tone: .good))
            }
            out.append(OneViewSection(title: "Online payments".translated(), rows: rows.isEmpty ? [empty("No online payments.".translated())] : rows))
        } else if let f = failure(.onlinePayments, title: "Online payments".translated()) { out.append(f) }

        if let dc = results[.discounts] {
            let rows = dc.list("discounts").map { x -> OneViewRow in
                .item(OneViewItem(title: x.s("discount_type"), subtitle: join([x.s("fee_name"), x.s("fee_group_type_name")]),
                                  detail: x.s("created_date"), value: x.s("discount_amount"), status: "Discount".translated(), tone: .info))
            }
            let n = dc.s("count")
            out.append(OneViewSection(title: "\("Discounts".translated())\(n.isEmpty ? "" : " (\(n))")",
                                      rows: rows.isEmpty ? [empty("No discounts.".translated())] : rows))
        } else if let f = failure(.discounts, title: "Discounts".translated()) { out.append(f) }

        return out
    }

    // MARK: - Exams

    private func exams() -> [OneViewSection] {
        var out: [OneViewSection] = []
        if let m = results[.markAnalysis] {
            let overall = m.list("overall")
            if let last = overall.last {
                let p = last.s("percentage")
                out.append(OneViewSection(title: nil, rows: [
                    .ring(caption: last.s("exam_name"), value: "\(orDash(last.s("exam_total"))) / \(orDash(last.s("max_marks")))",
                          note: last.s("grade").isEmpty ? "" : "\("Grade".translated()) \(last.s("grade"))",
                          center: pct(p), centerCaption: "score".translated(),
                          segments: [OneViewSegment(title: "Scored".translated(), value: orDash(last.s("exam_total")), fraction: fraction(p),
                                                    color: (number(p) ?? 0) >= 50 ? OneViewPalette.paid : OneViewPalette.pending)])
                ]))
            }
            if overall.count > 1 {
                out.append(OneViewSection(title: "Exam trend".translated(), rows: overall.map { x -> OneViewRow in
                    let p = number(x.s("percentage"))
                    return .bar(OneViewBar(title: x.s("exam_name"), value: pct(x.s("percentage")),
                                           subtitle: join(["\(orDash(x.s("exam_total"))) / \(orDash(x.s("max_marks")))", x.s("grade").isEmpty ? "" : "\("Grade".translated()) \(x.s("grade"))"]),
                                           fraction: fraction(x.s("percentage")), tone: toneFor(percent: p)))
                }))
            }
            let subjects = m.list("subjects").map { sub -> OneViewRow in
                let marks = sub.list("marks")
                let latest = marks.last
                let got = number(latest?.s("marks") ?? ""), max = number(latest?.s("max_marks") ?? "")
                let absent = latest?.s("marks").uppercased() == "AB"
                let percent = (got != nil && (max ?? 0) > 0) ? got! / max! * 100 : nil
                let line = marks.map { "\($0.s("exam_name")) \(orDash($0.s("marks")))/\(orDash($0.s("max_marks")))" }
                let split = sub.list("split_up").compactMap { sp -> String? in
                    let given = sp.list("marks").filter { !$0.s("marks").isEmpty }.map { "\($0.s("marks"))/\($0.s("max_marks"))" }
                    return given.isEmpty ? nil : "\(sp.s("name")) \(given.joined(separator: ", "))"
                }
                let grade = latest?.s("grade") ?? ""
                return .bar(OneViewBar(
                    title: sub.s("subject_name"),
                    value: absent ? "Absent".translated() : join([latest.map { "\(orDash($0.s("marks")))/\(orDash($0.s("max_marks")))" } ?? "", grade], "  "),
                    subtitle: join([line.joined(separator: "  ·  "), split.joined(separator: "  ·  ")], "\n"),
                    fraction: CGFloat((percent ?? 0) / 100),
                    tone: absent ? .bad : toneFor(percent: percent)))
            }
            let latestName = overall.last?.s("exam_name") ?? ""
            out.append(OneViewSection(title: latestName.isEmpty ? "Subjects".translated() : "\("Subjects".translated()) · \(latestName)",
                                      rows: subjects.isEmpty ? [empty("No marks uploaded yet.".translated())] : subjects))
        } else if let f = failure(.markAnalysis, title: "Subjects".translated()) { out.append(f) }

        if let e = results[.examList] {
            let rows = e.list("exams").enumerated().map { (i, x) -> OneViewRow in
                .item(OneViewItem(title: x.s("exam_name"), subtitle: "\("Exam".translated()) \(i + 1)", status: "Marks uploaded".translated(), tone: .good))
            }
            out.append(OneViewSection(title: "Exams with marks".translated(), rows: rows.isEmpty ? [empty("No exams yet.".translated())] : rows))
        } else if let f = failure(.examList, title: "Exams with marks".translated()) { out.append(f) }
        return out
    }

    // MARK: - Attendance

    private func attendance() -> [OneViewSection] {
        var out: [OneViewSection] = []
        if let a = results[.attendancePercentage] {
            let o = a.obj("overall")
            out.append(OneViewSection(title: nil, rows: [
                attendanceRing(caption: "Overall attendance".translated(), present: o?.s("present_percentage") ?? "",
                               absent: o?.s("absent_percentage") ?? "", note: "")
            ]))
            let terms = a.list("terms")
            if !terms.isEmpty {
                out.append(OneViewSection(title: "By term".translated(), rows: terms.map { t -> OneViewRow in
                    let p = number(t.s("present_percentage"))
                    return .bar(OneViewBar(title: t.s("name"), value: pct(t.s("present_percentage")),
                                           subtitle: "\("Absent".translated()) \(pct(t.s("absent_percentage")))",
                                           fraction: fraction(t.s("present_percentage")), tone: toneFor(percent: p)))
                }))
            }
        } else if let f = failure(.attendancePercentage, title: "Attendance".translated()) { out.append(f) }

        if let l = results[.leaveRequests] {
            let list = l.list("leave_requests")
            let approved = list.filter { $0.s("status_id") == "1" }.count
            let rejected = list.filter { $0.s("status_id") == "2" }.count
            let days = list.filter { $0.s("status_id") == "1" }.reduce(0) { $0 + count($1.s("no_of_days")) }
            var rows: [OneViewRow] = [.tiles([
                OneViewTile(title: "Approved".translated(), value: "\(approved)", symbol: "checkmark.circle.fill", tone: .good),
                OneViewTile(title: "Waiting".translated(), value: "\(list.count - approved - rejected)", symbol: "clock.fill", tone: .warn),
                OneViewTile(title: "Rejected".translated(), value: "\(rejected)", symbol: "xmark.circle.fill", tone: .bad),
                OneViewTile(title: "Days on leave".translated(), value: "\(days)", symbol: "calendar", tone: .info)
            ])]
            rows += list.map { x -> OneViewRow in
                let tone: OneViewTone = x.s("status_id") == "1" ? .good : (x.s("status_id") == "2" ? .bad : .warn)
                let d = x.s("no_of_days")
                return .item(OneViewItem(title: x.s("reason").isEmpty ? "Leave".translated() : x.s("reason"),
                                         subtitle: x.s("from_date") == x.s("to_date") ? x.s("from_date") : "\(x.s("from_date")) – \(x.s("to_date"))",
                                         detail: "\("Applied on".translated()) \(x.s("applied_on"))",
                                         value: d.isEmpty ? "" : "\(d) \(d == "1" ? "day".translated() : "days".translated())",
                                         status: x.s("status").isEmpty ? "Waiting".translated() : x.s("status"), tone: tone))
            }
            if list.isEmpty { rows = [empty("No leave requests.".translated())] }
            out.append(OneViewSection(title: "Leave requests".translated(), rows: rows))
        } else if let f = failure(.leaveRequests, title: "Leave requests".translated()) { out.append(f) }

        if let w = results[.workingDays] {
            let names = w.list("terms").map { $0.s("name") }
            if !names.isEmpty {
                out.append(OneViewSection(title: "Working-day terms".translated(), rows: [.keyValue(key: "Terms".translated(), value: names.joined(separator: ", "))]))
            }
        } else if let f = failure(.workingDays, title: "Working-day terms".translated()) { out.append(f) }
        return out
    }

    // MARK: - Transport / hostel

    private func transport() -> [OneViewSection] {
        guard let t = results[.transport] else {
            return [failure(.transport, title: nil) ?? OneViewSection(title: nil, rows: [empty("Not a bus student.".translated())])]
        }
        return [
            OneViewSection(title: nil, rows: [
                feeRing(caption: "Transport fee pending".translated(), total: t.s("total_fee_amount"), paid: t.s("total_paid_amount"),
                        discount: t.s("total_discount_amount"), pending: t.s("total_pending_amount"),
                        note: t.s("month_given").isEmpty ? "" : "\("Paid for".translated()) \(t.s("month_given"))")
            ]),
            OneViewSection(title: "Bus pass".translated(), rows: [.tiles([
                OneViewTile(title: "Route".translated(), value: orDash(t.s("route_name")), symbol: "map.fill", tone: .info),
                OneViewTile(title: "Stop".translated(), value: orDash(t.s("stop_name")), symbol: "mappin.circle.fill", tone: .good),
                OneViewTile(title: "Fee type".translated(), value: orDash(t.s("route_fee_type_name")), symbol: "arrow.left.arrow.right", tone: .neutral),
                OneViewTile(title: "Months paid".translated(), value: orDash(t.s("month_given")), symbol: "calendar", tone: .warn)
            ])])
        ]
    }

    private func hostel() -> [OneViewSection] {
        guard let h = results[.hostel] else {
            return [failure(.hostel, title: nil) ?? OneViewSection(title: nil, rows: [empty("Not a hostel student.".translated())])]
        }
        return [
            OneViewSection(title: nil, rows: [
                feeRing(caption: "Hostel fee pending".translated(), total: h.s("total_fee_amount"), paid: h.s("total_paid_amount"),
                        discount: h.s("total_discount_amount"), pending: h.s("total_pending_amount"), note: h.s("hostel_name"))
            ]),
            OneViewSection(title: "Room".translated(), rows: [.tiles([
                OneViewTile(title: "Room".translated(), value: join([h.s("room_no"), h.s("floor_name")], " · "), symbol: "door.left.hand.open", tone: .info),
                OneViewTile(title: "Bed".translated(), value: orDash(h.s("bed_no")), symbol: "bed.double.fill", tone: .good),
                OneViewTile(title: "Room type".translated(), value: orDash(h.s("room_type")), symbol: "snowflake", tone: .neutral),
                OneViewTile(title: "Mess".translated(), value: orDash(h.s("mess_type")), symbol: "fork.knife", tone: .warn)
            ])])
        ]
    }

    // MARK: - Certificates / well-being

    private func certificates() -> [OneViewSection] {
        guard let c = results[.certificates] else {
            return [failure(.certificates, title: nil) ?? OneViewSection(title: nil, rows: [empty("No certificates issued.".translated())])]
        }
        let list = c.list("certificates")
        let kinds = Set(list.map { $0.s("certificate_name") }).count
        let rows = list.map { x -> OneViewRow in
            .item(OneViewItem(title: x.s("certificate_name"), subtitle: x.s("created_date"),
                              status: x.s("certificate_url").isEmpty ? "" : "PDF", tone: .info, url: x.s("certificate_url")))
        }
        return [
            OneViewSection(title: nil, rows: [.tiles([
                OneViewTile(title: "Issued".translated(), value: orDash(c.s("count")), symbol: "doc.text.fill", tone: .info),
                OneViewTile(title: "Types".translated(), value: "\(kinds)", symbol: "square.stack.3d.up.fill", tone: .good)
            ])]),
            OneViewSection(title: "Certificates issued".translated(), rows: rows.isEmpty ? [empty("No certificates issued.".translated())] : rows)
        ]
    }

    private func wellbeing() -> [OneViewSection] {
        var out: [OneViewSection] = []
        let acc = results[.accomplishments], inc = results[.incidents]
        if acc != nil || inc != nil {
            out.append(OneViewSection(title: nil, rows: [.tiles([
                OneViewTile(title: "Accomplishments".translated(), value: orDash(acc?.s("count") ?? ""), symbol: "trophy.fill", tone: .good),
                OneViewTile(title: "Incidents".translated(), value: orDash(inc?.s("count") ?? ""), symbol: "exclamationmark.triangle.fill", tone: .bad)
            ])]))
        }
        if let a = acc {
            let rows = a.list("accomplishments").map { x -> OneViewRow in
                .item(OneViewItem(title: x.s("accomplishment_type"), subtitle: x.s("accomplishment_date"),
                                  status: x.s("report_type"), tone: .good))
            }
            out.append(OneViewSection(title: "Accomplishments".translated(), rows: rows.isEmpty ? [empty("No accomplishments recorded.".translated())] : rows))
        } else if let f = failure(.accomplishments, title: "Accomplishments".translated()) { out.append(f) }

        if let i = inc {
            let rows = i.list("incidents").map { x -> OneViewRow in
                .item(OneViewItem(title: x.s("incident_type"), subtitle: x.s("incident_date"),
                                  status: x.s("report_type"), tone: .bad))
            }
            out.append(OneViewSection(title: "Incidents".translated(), rows: rows.isEmpty ? [empty("No incidents recorded.".translated())] : rows))
        } else if let f = failure(.incidents, title: "Incidents".translated()) { out.append(f) }
        return out
    }
}
