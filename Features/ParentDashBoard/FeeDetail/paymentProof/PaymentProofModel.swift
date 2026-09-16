//
//  PaymentProofModel.swift
//  paymentProofDesign
//
//  Created by Senior iOS UI/UX Designer on 04/09/26.
//

import Foundation
import UIKit

// MARK: - API Response Root
struct PaymentProofAPIResponse: Codable {
    let status: Bool
    let message: String
    let data: [PaymentProofDataGroup]
}

// MARK: - Data Group
struct PaymentProofDataGroup: Codable {
    let studentDetails: paymentProofStudentDetails
    let paymentDetails: [PaymentDetailItem]
    
    enum CodingKeys: String, CodingKey {
        case studentDetails = "student_details"
        case paymentDetails = "payment_details"
    }
}

// MARK: - Student Details
struct paymentProofStudentDetails: Codable {
    let studentID: String
    let studentName: String
    let className: String
    let sectionName: String
    
    enum CodingKeys: String, CodingKey {
        case studentID = "student_id"
        case studentName = "student_name"
        case className = "class_name"
        case sectionName = "section_name"
    }
    
    var formattedClassSection: String {
        return "Class \(className) - Sec \(sectionName)"
    }
    
    var formattedStudentID: String {
        return "ID: \(studentID)"
    }
}

// MARK: - Payment Status Enum
enum PaymentValidationStatus: String {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        }
    }
    
    var uppercaseName: String {
        return rawValue.uppercased()
    }
    
    var indicatorColor: UIColor {
        switch self {
        case .approved:
            return UIColor(red: 0.06, green: 0.72, blue: 0.51, alpha: 1.0) // #10B981
        case .rejected:
            return UIColor(red: 0.94, green: 0.27, blue: 0.27, alpha: 1.0) // #EF4444
        case .pending:
            return UIColor(red: 0.96, green: 0.62, blue: 0.13, alpha: 1.0) // #F59E0B
        }
    }
    
    var statusTextColor: UIColor {
        switch self {
        case .approved:
            return UIColor(red: 0.05, green: 0.65, blue: 0.46, alpha: 1.0)
        case .rejected:
            return UIColor(red: 0.88, green: 0.20, blue: 0.20, alpha: 1.0)
        case .pending:
            return UIColor(red: 0.85, green: 0.47, blue: 0.05, alpha: 1.0)
        }
    }
}

// MARK: - Dynamic Multi-Country Currency Utility
public final class CurrencyUtility {
    
    /// Global dynamically detected currency symbol for the current dataset / session.
    public static var detectedCurrencySymbol: String = ""
    
    /// Returns the active currency symbol, defaulting to the device's current locale symbol if nothing was detected yet.
    public static var currentCurrencySymbol: String {
        if !detectedCurrencySymbol.isEmpty {
            return detectedCurrencySymbol
        }
        return Locale.current.currencySymbol ?? ""
    }
    
    /// Dynamically extracts the currency symbol or prefix/suffix from a given string.
    /// Examples: "$50.00" -> "$", "AED 500.00" -> "AED ", "€ 20.00" -> "€ ", "£100.00" -> "£"
    public static func extractCurrencySymbol(from text: String?) -> String {
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return ""
        }
        
        // Find index of first decimal digit
        if let firstDigitIndex = text.firstIndex(where: { $0.isNumber }) {
            let prefix = String(text[..<firstDigitIndex])
            let cleanedPrefix = prefix.replacingOccurrences(of: "-", with: "")
                                      .replacingOccurrences(of: "+", with: "")
            let trimmedPrefix = cleanedPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedPrefix.isEmpty {
                return prefix.hasSuffix(" ") ? "\(trimmedPrefix) " : trimmedPrefix
            }
            
            // If prefix is empty (e.g. "1,000.00 €"), check suffix after last digit
            if let lastDigitIndex = text.lastIndex(where: { $0.isNumber }) {
                let nextIndex = text.index(after: lastDigitIndex)
                if nextIndex < text.endIndex {
                    let suffix = String(text[nextIndex...])
                    let trimmedSuffix = suffix.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedSuffix.isEmpty {
                        return suffix.hasPrefix(" ") ? " \(trimmedSuffix)" : trimmedSuffix
                    }
                }
            }
        }
        
        return ""
    }
    
    /// Updates the global detected currency symbol if a valid symbol is present.
    @discardableResult
    public static func updateDetectedSymbol(from text: String?) -> String {
        let extracted = extractCurrencySymbol(from: text)
        if !extracted.isEmpty {
            detectedCurrencySymbol = extracted
            return extracted
        }
        return currentCurrencySymbol
    }
    
    /// Parses any currency-formatted string into a numeric Double value safely.
    /// Works regardless of currency symbols, codes, spaces, or commas.
    public static func parseNumericValue(from text: String?) -> Double {
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return 0.0
        }
        
        var cleaned = ""
        var hasDecimal = false
        var isNegative = false
        
        for (index, char) in text.enumerated() {
            if char == "-" && index == 0 {
                isNegative = true
            } else if char.isNumber {
                cleaned.append(char)
            } else if char == "." && !hasDecimal {
                cleaned.append(char)
                hasDecimal = true
            }
        }
        
        if !isNegative && text.contains("-") {
            isNegative = true
        }
        
        guard let val = Double(cleaned) else { return 0.0 }
        return isNegative ? -val : val
    }
    
    /// Formats a numeric Double value with a currency symbol.
    /// Uses 2 decimal places and standard group separators.
    public static func formatAmount(_ value: Double, currencySymbol: String? = nil) -> String {
        let sym: String
        if let custom = currencySymbol, !custom.isEmpty {
            sym = custom
            if detectedCurrencySymbol.isEmpty {
                detectedCurrencySymbol = custom
            }
        } else {
            sym = currentCurrencySymbol
        }
        
        let trimmedSymbol = sym.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedSymbol.isEmpty {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = trimmedSymbol
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if var formatted = formatter.string(from: NSNumber(value: value)) {
            formatted = formatted.replacingOccurrences(of: "\u{a0}", with: " ")
            if sym.hasSuffix(" ") && formatted.hasPrefix(trimmedSymbol) && !formatted.hasPrefix("\(trimmedSymbol) ") {
                formatted = formatted.replacingOccurrences(of: trimmedSymbol, with: "\(trimmedSymbol) ")
            }
            return formatted
        }
        
        let numStr = String(format: "%.2f", value)
        return "\(sym)\(numStr)"
    }
    
    /// Returns formatted zero amount in the current or specified currency.
    public static func zeroAmount(currencySymbol: String? = nil) -> String {
        return formatAmount(0.0, currencySymbol: currencySymbol)
    }
}

// MARK: - Fee Details Container
struct FeeDetailsContainer: Codable {
    let term: [TermFeeGroup]?
    let others: [OtherFeeGroup]?
    let carryover: [CarryoverFeeGroup]?
    let transport: [TransportFeeGroup]?
    let hostel: [HostelFeeGroup]?
    let quantity: [QuantityFeeGroup]?
}

// MARK: - Term Fee Group
struct TermFeeGroup: Codable {
    let termName: String?
    let termID: String?
    let feesDetails: [TermFeeDetail]?
    
    enum CodingKeys: String, CodingKey {
        case termName = "term_name"
        case termID = "term_id"
        case feesDetails = "fees_details"
    }
    
  
    
    var displayAmount: String {
        var total: Double = 0.0
        var detectedSym: String? = nil
        feesDetails?.forEach { fee in
            if detectedSym == nil {
                let s = CurrencyUtility.extractCurrencySymbol(from: fee.amountToBePaid ?? fee.feeAmount)
                if !s.isEmpty { detectedSym = s }
            }
            total += CurrencyUtility.parseNumericValue(from: fee.amountToBePaid ?? fee.feeAmount)
        }
        return CurrencyUtility.formatAmount(total, currencySymbol: detectedSym)
    }
}


struct TermFeeDetail: Codable {
    let feeID: String?
    let feeName: String?
    let feeAmount: String?
    let discountAvailed: String?
    let actualPaid: String?
    let amountToBePaid: String?
    
    enum CodingKeys: String, CodingKey {
        case feeID = "fee_id"
        case feeName = "fee_name"
        case feeAmount = "fee_amount"
        case discountAvailed = "discount_availed"
        case actualPaid = "actual_paid"
        case amountToBePaid = "amount_to_be_paid"
    }
    
    var displayAmount: String {
        return PaymentProofDataLoader.formatCurrency(amountToBePaid ?? feeAmount)
    }
    
    var displayFeeAmount: String {
        return PaymentProofDataLoader.formatCurrency(feeAmount ?? amountToBePaid)
    }
    
    var displayDiscount: String {
        return PaymentProofDataLoader.formatCurrency(discountAvailed)
    }
    
    var displayPaid: String {
        return PaymentProofDataLoader.formatCurrency(actualPaid)
    }
}

// MARK: - Other Fee Group
struct OtherFeeGroup: Codable {
    let feeName: String?
    let feeAmount: String?
    let discountAvailed: String?
    let actualPaid: String?
    let amountToBePaid: String?
    let monthDetails: [OtherMonthDetail]?
    
    enum CodingKeys: String, CodingKey {
        case feeName = "fee_name"
        case feeAmount = "fee_amount"
        case discountAvailed = "discount_availed"
        case actualPaid = "actual_paid"
        case amountToBePaid = "amount_to_be_paid"
        case monthDetails = "month_details"
    }
    
    var displayAmount: String {
        return PaymentProofDataLoader.formatCurrency(amountToBePaid ?? feeAmount)
    }

    var displayFeeAmount: String {
        return PaymentProofDataLoader.formatCurrency(feeAmount ?? amountToBePaid)
    }

    var displayDiscount: String {
        return PaymentProofDataLoader.formatCurrency(discountAvailed)
    }

    var displayPaid: String {
        return PaymentProofDataLoader.formatCurrency(actualPaid)
    }
}

struct OtherMonthDetail: Codable {
    let monthName: String?
    let amountPerMonth: String?
    let discountAmount: String?
    let paid: String?
    let amountToBePaid: String?
    let pending: String?
    
    enum CodingKeys: String, CodingKey {
        case monthName = "month_name"
        case amountPerMonth = "amount_per_month"
        case discountAmount = "discount_amount"
        case paid
        case amountToBePaid = "amount_to_be_paid"
        case pending = "pending"
    }
    
    var displayAmount: String {
        return PaymentProofDataLoader.formatCurrency(amountToBePaid ?? "-")
    }

    var displayFeeAmount: String {
        return PaymentProofDataLoader.formatCurrency(amountPerMonth ?? "-")
    }

    var displaypending: String {
        return PaymentProofDataLoader.formatCurrency(pending)
    }

    var displayPaid: String {
        return PaymentProofDataLoader.formatCurrency(paid)
    }
    
    var displayMonth: String {
        guard let name = monthName, !name.isEmpty else { return "Month" }
        return name.capitalized
    }
}

// MARK: - Carryover Fee Group
struct CarryoverFeeGroup: Codable {
    let id: String?
    let feeName: String?
    let feeGroupTypeName: String? // "2025-2026"
    let amountToBePaid: String?
    let carryOverFee: [CarryoverItem]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case feeName = "fee_name"
        case feeGroupTypeName = "fee_group_type_name"
        case amountToBePaid = "amount_to_be_paid"
        case carryOverFee = "carry_over_fee"
    }
    
    var displayAmount: String {
        return PaymentProofDataLoader.formatCurrency(amountToBePaid)
    }
    
    var detailedGroups: [CarryoverGroupDetail] {
        guard let rawItems = carryOverFee else { return [] }
        var groupOrder: [String] = []
        
        class GroupAccumulator {
            var totalPending: Double = 0
            var totalFee: Double = 0
            var totalDiscount: Double = 0
            var totalPaid: Double = 0
            var termRows: [CarryoverTermRow] = []
        }
        var groups: [String: GroupAccumulator] = [:]
        
        var detectedSym: String? = nil
        
        for item in rawItems {
            guard let name = item.feeName else { continue }
            let termName = item.feeGroupTypeName ?? "Term"
            
            if detectedSym == nil {
                let s = CurrencyUtility.extractCurrencySymbol(from: item.pendingAmount ?? item.feeAmount)
                if !s.isEmpty { detectedSym = s }
            }
            
            let pendingVal = CurrencyUtility.parseNumericValue(from: item.pendingAmount ?? item.feeAmount)
            let feeVal = CurrencyUtility.parseNumericValue(from: item.feeAmount ?? item.pendingAmount)
            let discVal = CurrencyUtility.parseNumericValue(from: item.discountAmount)
            let paidVal = CurrencyUtility.parseNumericValue(from: item.paidAmount)
            
            let displayAmt = PaymentProofDataLoader.formatCurrency(item.pendingAmount ?? item.feeAmount)
            let displayFee = PaymentProofDataLoader.formatCurrency(item.feeAmount ?? item.pendingAmount)
            let displayDisc = PaymentProofDataLoader.formatCurrency(item.discountAmount)
            let displayPaid = PaymentProofDataLoader.formatCurrency(item.paidAmount)
            
            if groups[name] == nil {
                groupOrder.append(name)
                groups[name] = GroupAccumulator()
            }
            
            groups[name]?.totalPending += pendingVal
            groups[name]?.totalFee += feeVal
            groups[name]?.totalDiscount += discVal
            groups[name]?.totalPaid += paidVal
            
            let row = CarryoverTermRow(
                termName: "– \(termName)",
                amount: displayAmt,
                feeAmount: displayFee,
                discount: displayDisc,
                paid: displayPaid
            )
            groups[name]?.termRows.append(row)
        }
        
        return groupOrder.compactMap { name in
            guard let acc = groups[name] else { return nil }
            let totalAmtStr = CurrencyUtility.formatAmount(acc.totalPending, currencySymbol: detectedSym)
            let totalFeeStr = CurrencyUtility.formatAmount(acc.totalFee, currencySymbol: detectedSym)
            let totalDiscStr = CurrencyUtility.formatAmount(acc.totalDiscount, currencySymbol: detectedSym)
            let totalPaidStr = CurrencyUtility.formatAmount(acc.totalPaid, currencySymbol: detectedSym)
            
            return CarryoverGroupDetail(
                feeName: name,
                totalAmount: totalAmtStr,
                totalFeeAmount: totalFeeStr,
                totalDiscount: totalDiscStr,
                totalPaid: totalPaidStr,
                termRows: acc.termRows
            )
        }
    }
}

struct CarryoverItem: Codable {
    let feeGroupTypeName: String? // "Term 1", "Term 2"
    let feeName: String?
    let feeAmount: String?
    let pendingAmount: String?
    let paidAmount: String?
    let discountAmount: String?
    
    enum CodingKeys: String, CodingKey {
        case feeGroupTypeName = "fee_group_type_name"
        case feeName = "fee_name"
        case feeAmount = "fee_amount"
        case pendingAmount = "pending_amount"
        case paidAmount = "paid_amount"
        case discountAmount = "discount_amount"
    }
}

// MARK: - Transport Fee Group
struct TransportFeeGroup: Codable {
    let routeName: String? // "Hanumanthawaka route"
    let stopName: String?
    let routeFeeTypeName: String? // "2 WAY TRIP "
    let actualAmount: String?
    let paidAmount: String?
    let pendingAmount: String?
    let discountGiven: String?
    let busMonthDetails: [BusMonthDetail]?
    
    enum CodingKeys: String, CodingKey {
        case routeName = "route_name"
        case stopName = "stop_name"
        case routeFeeTypeName = "route_fee_type_name"
        case actualAmount = "actual_amount"
        case paidAmount = "paid_amount"
        case pendingAmount = "pending_amount"
        case discountGiven = "discount_given"
        case busMonthDetails = "bus_month_details"
    }
    
    var cleanRouteName: String {
        return routeName?.replacingOccurrences(of: " route", with: "", options: .caseInsensitive).capitalized ?? "Hanumanthawaka"
    }
    
    var formattedGroupTitle: String {
        let route = routeName ?? "Route"
        let trip = routeFeeTypeName?.trimmingCharacters(in: .whitespaces).capitalized ?? ""
        return trip.isEmpty ? route : "\(route) · \(trip)"
    }
    
    var displayAmount: String {
        return PaymentProofDataLoader.formatCurrency(pendingAmount ?? "-")
    }

    var displayFeeAmount: String {
        return PaymentProofDataLoader.formatCurrency(actualAmount ?? pendingAmount)
    }

    var displayDiscount: String {
        return PaymentProofDataLoader.formatCurrency(discountGiven)
    }

    var displayPaid: String {
        return PaymentProofDataLoader.formatCurrency(paidAmount)
    }
}

struct BusMonthDetail: Codable {
    let monthName: String?
    let feeAmount: String?
    let discountAmount: String?
    let paidAmount: String?
    let pendingAmount: String?
    
    enum CodingKeys: String, CodingKey {
        case monthName = "month_name"
        case feeAmount = "fee_amount"
        case discountAmount = "discount_amount"
        case paidAmount = "paid_amount"
        case pendingAmount = "pending_amount"
    }
    
    var displayAmount: String {
        return PaymentProofDataLoader.formatCurrency(pendingAmount ?? "-")
    }

    var displayFeeAmount: String {
        return PaymentProofDataLoader.formatCurrency(feeAmount ?? "-")
    }

    var displayDiscount: String {
        return PaymentProofDataLoader.formatCurrency(pendingAmount)
    }

    var displayPaid: String {
        return PaymentProofDataLoader.formatCurrency(paidAmount)
    }
    
    var displayMonth: String {
        guard let name = monthName, !name.isEmpty else { return "Month" }
        return name.capitalized
    }
}

// MARK: - Hostel Fee Group
struct HostelFeeGroup: Codable {
    let hostelName: String?
    let roomNo: String?
    let bedNo: String?
    let actualAmount: String?
    let pendingAmount: String?
    let paidAmount: String?
    let discountAmount: String?
    let month_details: [HostelMonthDetail]?
    
    enum CodingKeys: String, CodingKey {
        case hostelName = "hostel_name"
        case roomNo = "room_no"
        case bedNo = "bed_no"
        case actualAmount = "actual_amount"
        case pendingAmount = "pending_amount"
        case paidAmount = "paid_amount"
        case discountAmount = "discount_amount"
        case month_details = "month_details"
    }
    
    var formattedTitle: String {
        let name = hostelName?.capitalized ?? "Boys 1"
        let room = roomNo ?? "2"
        let bed = bedNo ?? "B4"
        return "Hostel - \(name) (Room \(room), \(bed))"
    }

    var formattedGroupTitle: String {
        let name = hostelName ?? "Hostel"
        let room = roomNo ?? ""
        let bed = bedNo ?? ""
        if !room.isEmpty && !bed.isEmpty {
            return "\(name) (Room \(room), Bed \(bed))"
        } else if !room.isEmpty {
            return "\(name) (Room \(room))"
        }
        return name
    }
    
    var displayAmount: String {
        return PaymentProofDataLoader.formatCurrency(pendingAmount ?? actualAmount)
    }

    var displayFeeAmount: String {
        return PaymentProofDataLoader.formatCurrency(actualAmount ?? pendingAmount)
    }

    var displayDiscount: String {
        return PaymentProofDataLoader.formatCurrency(discountAmount)
    }

    var displayPaid: String {
        return PaymentProofDataLoader.formatCurrency(paidAmount)
    }
}

struct HostelMonthDetail: Codable {
    let monthName: String?
    let actualAmount: String?
    let pendingAmount: String?
    let discountAmount: String?
    let paidAmount: String?
    
    enum CodingKeys: String, CodingKey {
        case monthName = "month_name"
        case actualAmount = "actual_amount"
        case pendingAmount = "pending_amount"
        case discountAmount = "discount_amount"
        case paidAmount = "paid_amount"
    }
    
    var displayAmount: String {
        return PaymentProofDataLoader.formatCurrency(pendingAmount ?? "")
    }

    var displayFeeAmount: String {
        return PaymentProofDataLoader.formatCurrency(actualAmount ?? "")
    }

    var displayDiscount: String {
        return PaymentProofDataLoader.formatCurrency(pendingAmount)
    }

    var displayPaid: String {
        return PaymentProofDataLoader.formatCurrency(paidAmount)
    }
    
    var displayMonth: String {
        guard let name = monthName, !name.isEmpty else { return "Month" }
        return name.capitalized
    }
}

// MARK: - Quantity Fee Group
struct QuantityFeeGroup: Codable {
    let feeName: String?
    let qomGiven: String?
    let amountToBePaid: String?
    let uom_price  : String?
    enum CodingKeys: String, CodingKey {
        case feeName = "fee_name"
        case qomGiven = "qom_given"
        case amountToBePaid = "amount_to_be_paid"
        case uom_price = "uom_price"
    }
    
    var displayAmount: String {
        return PaymentProofDataLoader.formatCurrency(amountToBePaid)
    }

    var displayuom_price: String {
        return PaymentProofDataLoader.formatCurrency(uom_price)
    }

    var displayDiscount: String {
        return CurrencyUtility.zeroAmount()
    }

    var displayPaid: String {
        return CurrencyUtility.zeroAmount()
    }
}

// MARK: - Payment Detail Item
struct PaymentDetailItem: Codable {
    let totalAmount: String
    let aiDetectedAmount: String
    let userEnterAmount: String
    let isPaymentValidated: String
    let validatedBy: String
    let validatedOn: String
    let paymentID: String
    let proofUploaded: [ProofUploadedItem]
    let createdOn: String
    let remarks: String
    let proofDetails: [ProofDetailInfo]
    let feeDetails: FeeDetailsContainer?
    
    enum CodingKeys: String, CodingKey {
        case totalAmount = "total_amount"
        case aiDetectedAmount = "ai_detected_amount"
        case userEnterAmount = "user_enter_amount"
        case isPaymentValidated = "is_payment_validated"
        case validatedBy = "validated_by"
        case validatedOn = "validated_on"
        case paymentID = "payment_id"
        case proofUploaded = "proof_uploaded"
        case createdOn = "created_on"
        case remarks
        case proofDetails = "proof_details"
        case feeDetails = "fee_details"
    }
    
    var validationStatus: PaymentValidationStatus {
        return PaymentValidationStatus(rawValue: isPaymentValidated.lowercased()) ?? .pending
    }
    
    var cleanAmount: String {
        return totalAmount.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var currencySymbol: String {
        let sym = CurrencyUtility.extractCurrencySymbol(from: totalAmount)
        if !sym.isEmpty {
            CurrencyUtility.updateDetectedSymbol(from: sym)
            return sym
        }
        return CurrencyUtility.currentCurrencySymbol
    }
    
    // Difference calculation between user entered and AI detected amount
    var differenceAmount: String {
        let aiNum = CurrencyUtility.parseNumericValue(from: aiDetectedAmount)
        let userNum = CurrencyUtility.parseNumericValue(from: userEnterAmount)
        
        guard aiNum > 0 || userNum > 0 else {
            return CurrencyUtility.zeroAmount(currencySymbol: currencySymbol)
        }
        let diff = abs(userNum - aiNum)
        return CurrencyUtility.formatAmount(diff, currencySymbol: currencySymbol)
    }
    
    var hasAIMismatch: Bool {
        let aiNum = CurrencyUtility.parseNumericValue(from: aiDetectedAmount)
        let userNum = CurrencyUtility.parseNumericValue(from: userEnterAmount)
        
        return aiNum != userNum && aiNum > 0
    }
    
    var shortDate: String {
        if let firstPart = createdOn.components(separatedBy: " ").first {
            let components = firstPart.components(separatedBy: "-")
            if components.count >= 2 {
                return "\(components[0])-\(components[1])"
            }
            return String(firstPart.prefix(5))
        }
        return createdOn
    }
    
    var cleanValidator: String? {
        guard !validatedBy.isEmpty else { return nil }
        let trimmed = validatedBy.replacingOccurrences(of: "6063_", with: "")
        return trimmed.capitalized
    }
    
    var photosCountText: String {
        let count = proofUploaded.count
        return "\(count) \(count == 1 ? "photo" : "photos")"
    }
    
    var metadataSubtitle: String {
        var parts: [String] = [shortDate]
        if let validator = cleanValidator {
            parts.append(validator)
        }
        parts.append(photosCountText)
        return parts.joined(separator: " · ")
    }
    
    // Category Totals
    var termCategoryTotal: String {
        var total: Double = 0.0
        feeDetails?.term?.forEach { term in
            term.feesDetails?.forEach { fee in
                total += CurrencyUtility.parseNumericValue(from: fee.amountToBePaid ?? fee.feeAmount)
            }
        }
        return CurrencyUtility.formatAmount(total, currencySymbol: currencySymbol)
    }
    
    var othersCategoryTotal: String {
        var total: Double = 0.0
        feeDetails?.others?.forEach { other in
            total += CurrencyUtility.parseNumericValue(from: other.amountToBePaid ?? other.feeAmount)
        }
        return CurrencyUtility.formatAmount(total, currencySymbol: currencySymbol)
    }
    
    var carryoverGroupTypeName: String {
        return feeDetails?.carryover?.first?.feeGroupTypeName ?? ""
    }

    var carryoverCategoryTotal: String {
        guard let list = feeDetails?.carryover, !list.isEmpty else {
            return CurrencyUtility.zeroAmount(currencySymbol: currencySymbol)
        }
        var total: Double = 0.0
        for item in list {
            total += CurrencyUtility.parseNumericValue(from: item.amountToBePaid)
        }
        return CurrencyUtility.formatAmount(total, currencySymbol: currencySymbol)
    }
    
    var transportCategoryTotal: String {
        guard let list = feeDetails?.transport, !list.isEmpty else {
            return CurrencyUtility.zeroAmount(currencySymbol: currencySymbol)
        }
        var total: Double = 0.0
        for item in list {
            total += CurrencyUtility.parseNumericValue(from: item.actualAmount)
        }
        return CurrencyUtility.formatAmount(total, currencySymbol: currencySymbol)
    }
    
    var hostelCategoryTotal: String {
        guard let list = feeDetails?.hostel, !list.isEmpty else {
            return CurrencyUtility.zeroAmount(currencySymbol: currencySymbol)
        }
        var total: Double = 0.0
        for item in list {
            total += CurrencyUtility.parseNumericValue(from: item.actualAmount)
        }
        return CurrencyUtility.formatAmount(total, currencySymbol: currencySymbol)
    }
    
    var quantityCategoryTotal: String {
        var total: Double = 0.0
        feeDetails?.quantity?.forEach { qty in
            total += CurrencyUtility.parseNumericValue(from: qty.amountToBePaid)
        }
        return CurrencyUtility.formatAmount(total, currencySymbol: currencySymbol)
    }

    // Detailed Carryover Groups matching Screenshot 3
    var detailedCarryoverGroups: [CarryoverGroupDetail] {
        return feeDetails?.carryover?.first?.detailedGroups ?? []
    }
    
    // Carryover grouped items: combines "Term 1" and "Term 2" items for backward compatibility
    var groupedCarryoverItems: [(title: String, amount: String)] {
        return detailedCarryoverGroups.map { ($0.feeName, $0.totalAmount) }
    }
}

// MARK: - Carryover Group Detail Structure
struct CarryoverTermRow {
    let termName: String
    let amount: String
    let feeAmount: String
    let discount: String
    let paid: String
//    let pending_amount: String
}

struct CarryoverGroupDetail {
    let feeName: String
    let totalAmount: String
    let totalFeeAmount: String
    let totalDiscount: String
    let totalPaid: String
    let termRows: [CarryoverTermRow]
    
}

// MARK: - Proof Uploaded
struct ProofUploadedItem: Codable {
    let awsURL: String
    let fileName: String
    let originalFileName: String
    let type : String
    enum CodingKeys: String, CodingKey {
        case awsURL = "url"
        case fileName = "file_name"
        case originalFileName = "original_file_name"
        case type = "type"
    }

    var displayName: String {
        return originalFileName.isEmpty ? fileName : originalFileName
    }

    var badgeText: String {
        let name = displayName.lowercased()
        if name.hasSuffix(".pdf") {
            return "PDF"
        } else if name.hasSuffix(".doc") || name.hasSuffix(".docx") {
            return "DOC"
        } else {
            return "IMG"
        }
    }

    var subtitleText: String {
        let name = displayName.lowercased()
        let type = name.hasSuffix(".pdf") ? "PDF" : "IMAGE"
        let hash = abs(fileName.hashValue) % 35 + 14
        return "\(hash) KB.\(type)"
    }
}

// MARK: - Proof Detail Info
struct ProofDetailInfo: Codable {
    let paymentStatus: String
    let receiptType: String
    let paymentMethod: String
    let upiProvider: String
    let receiptDate: String
    let validationMessage: String
    let transactionID: String
    let referenceNumber: String
    let paidAmount: String
    let receiptTime: String
    let bankName: String
    let payerName: String
    let payeeName: String
    let upiID: String
    let accountNumber: String
    let failureReason: String
    let confidence: Int
    
    enum CodingKeys: String, CodingKey {
        case paymentStatus = "payment_status"
        case receiptType = "receipt_type"
        case paymentMethod = "payment_method"
        case upiProvider = "upi_provider"
        case receiptDate = "receipt_date"
        case validationMessage = "validation_message"
        case transactionID = "transaction_id"
        case referenceNumber = "reference_number"
        case paidAmount = "paid_amount"
        case receiptTime = "receipt_time"
        case bankName = "bank_name"
        case payerName = "payer_name"
        case payeeName = "payee_name"
        case upiID = "upi_id"
        case accountNumber = "account_number"
        case failureReason = "failure_reason"
        case confidence
    }
    
    var formattedProviderBank: String {
        let prov = upiProvider.isEmpty ? "UPI Payment" : upiProvider
        let bank = bankName.isEmpty ? "" : " · \(bankName)"
        return "\(prov)\(bank)"
    }
    
    var formattedPaidAmount: String {
        return PaymentProofDataLoader.formatCurrency(paidAmount)
    }
    
    var formattedTime: String {
        return receiptTime.uppercased()
    }
}

// MARK: - Data Loader Utility
final class PaymentProofDataLoader {
    static func formatCurrency(_ raw: String?) -> String {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return CurrencyUtility.zeroAmount()
        }
        guard raw.contains(where: { $0.isNumber }) else {
            return raw
        }
        let sym = CurrencyUtility.extractCurrencySymbol(from: raw)
        let effectiveSym = sym.isEmpty ? CurrencyUtility.currentCurrencySymbol : sym
        let val = CurrencyUtility.parseNumericValue(from: raw)
        return CurrencyUtility.formatAmount(val, currencySymbol: effectiveSym)
    }

    
}
