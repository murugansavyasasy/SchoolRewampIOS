//
//  StudentFeeShared.swift
//  School Chimes
//
//  Shared helpers for the Student Fee Details screen:
//  hex colours, the status pill label used in StudentFeeRowCell.xib,
//  and amount parsing/formatting for "₹11,230.00" style strings.
//

import UIKit

// MARK: - Colours

extension UIColor {
    /// "F59E0B" → UIColor
    convenience init(feeHex hex: String) {
        let v = Int(hex, radix: 16) ?? 0
        self.init(red: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255, blue: CGFloat(v & 0xFF) / 255, alpha: 1)
    }
}

enum StudentFeeColor {
    static let ink = UIColor(feeHex: "1E293B")
    static let muted = UIColor(feeHex: "64748B")
    static let orange = UIColor(feeHex: "F59E0B")
    static let green = UIColor(feeHex: "10B981")
    static let red = UIColor(feeHex: "EF4444")
    static let slate = UIColor(feeHex: "94A3B8")
}

// MARK: - Status pill (custom class used in StudentFeeRowCell.xib)

final class StudentFeePillLabel: UILabel {
    var inset = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)

    override func drawText(in rect: CGRect) { super.drawText(in: rect.inset(by: inset)) }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + inset.left + inset.right, height: s.height + inset.top + inset.bottom)
    }
}

// MARK: - Amount helpers

enum FeeAmount {
    static func value(_ text: String?) -> Double {
        guard let text = text else { return 0 }
        let cleaned = text.filter { "0123456789.-".contains($0) }
        return Double(cleaned) ?? 0
    }

    static func symbol(_ text: String?) -> String {
        guard let text = text, let i = text.firstIndex(where: { $0.isNumber || $0 == "-" }) else { return "" }
        return String(text[..<i]).trimmingCharacters(in: .whitespaces)
    }

    static func format(_ value: Double, symbol: String) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "en_IN")
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return symbol + (f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value))
    }

    /// Adds amount strings and keeps the first currency symbol found.
    static func sum(_ texts: [String]) -> String {
        let sym = texts.lazy.map { symbol($0) }.first { !$0.isEmpty } ?? ""
        return format(texts.reduce(0) { $0 + value($1) }, symbol: sym)
    }

    /// Discount comes as "0" or "₹0.00"; show a plain number with the symbol when missing.
    static func display(_ text: String?) -> String {
        guard let t = text, !t.isEmpty else { return "-" }
        return symbol(t).isEmpty ? format(value(t), symbol: "") : t
    }
}
