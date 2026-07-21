//
//  PaymentHistoryTVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/03/26.
//

import UIKit

class PaymentHistoryTVC: UITableViewCell {
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var transactionIdLbl: UILabel!
    @IBOutlet weak var transactionStack: UIStackView!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var feesNameLbl: UILabel!
    @IBOutlet weak var feesamoiuntLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    private func setupUI() {
        statusBtn.layer.cornerRadius = statusBtn.frame.height/2
        iconBtn.layer.cornerRadius = iconBtn.frame.height/2
        statusBtn.clipsToBounds = true
        feesamoiuntLbl.numberOfLines = 0
        feesamoiuntLbl.lineBreakMode = .byWordWrapping
    }
    func configureInstallment(data: CarryoverBreakdown?) {
        iconBtn.isHidden = true
        transactionStack.isHidden = true
        guard let data = data else { return }
        
        feesNameLbl.text = data.fee_name
        dateLbl.text = "Due: \(data.due_date ?? "")"
        feesamoiuntLbl.text = "₹\(formatAmount(data.m_feeamount ?? 0))"
        setAmountLabel(paid: data.paid_amount ?? 0, discount: data.discount_amount ?? 0, pending: data.pending_amount ?? 0)
        switch data.status {
            
        case .paid:
            statusBtn.setTitle("Paid", for: .normal)
            statusBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            statusBtn.setTitleColor(.systemGreen, for: .normal)
            iconBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            iconBtn.tintColor = .systemGreen
            
        case .pending:
            statusBtn.setTitle("Pending", for: .normal)
            statusBtn.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            statusBtn.setTitleColor(.systemOrange, for: .normal)
            iconBtn.setImage(UIImage(systemName: "clock.fill"), for: .normal)
            iconBtn.tintColor = .systemOrange
            
        case .overdue:
            statusBtn.setTitle("Overdue", for: .normal)
            statusBtn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            statusBtn.setTitleColor(.systemRed, for: .normal)
            iconBtn.setImage(UIImage(systemName: "exclamationmark.circle.fill"), for: .normal)
            iconBtn.tintColor = .systemRed
            
        case .none:
            break
        }
    }
    func setAmountLabel(paid: Double?, discount: Double?, pending: Double?) {

        var parts: [String] = []

        if let paid = paid, paid != 0 {
            parts.append("Paid: ₹\(paid)")
        }
        if let pending = pending, pending != 0 {
            parts.append("Pending: ₹\(pending)")
        }
        if let discount = discount, discount != 0 {
            parts.append("(Disc: ₹\(discount))")
        }
        let finalText = parts.joined(separator: "  ")
        let attributed = NSMutableAttributedString(string: finalText)

        // Apply styles only if text exists
        for part in parts {
            let range = (finalText as NSString).range(of: part)

            if part.contains("Paid") {
                attributed.addAttributes([
                    .foregroundColor: UIColor.systemGreen,
                    .font: UIFont.boldSystemFont(ofSize: 14)
                ], range: range)
            } else if part.contains("Disc") {
                attributed.addAttributes([
                    .foregroundColor: UIColor.systemPurple,
                    .font: UIFont.systemFont(ofSize: 13, weight: .medium)
                ], range: range)
            } else if part.contains("Pending") {
                attributed.addAttributes([
                    .foregroundColor: UIColor.systemRed,
                    .font: UIFont.boldSystemFont(ofSize: 14)
                ], range: range)
            }
        }
        feesamoiuntLbl.numberOfLines = 0
        feesamoiuntLbl.lineBreakMode = .byWordWrapping
        feesamoiuntLbl.attributedText = attributed
    }
    
    func configurePayment(data: PaymentHistory?) {
        
        guard let data = data else { return }
        
        iconBtn.isHidden = false
        transactionStack.isHidden = false
        
        feesNameLbl.text = data.payment_mode
        transactionIdLbl.text = data.paymentId
        dateLbl.text = data.paid_date
//        feesamoiuntLbl.text = "₹\(formatAmount(data.paid_amount ?? 0))"
        setAmountLabel(paid: data.paid_amount ?? 0, discount: data.discount_amount ?? 0, pending: data.pending_amount ?? 0)
        statusBtn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        statusBtn.setTitleColor(.systemBlue, for: .normal)
        statusBtn.tintColor = .systemBlue
        iconBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        iconBtn.setImage(resizedSymbol(name: "checkmark.circle.fill"), for: .normal)
        iconBtn.tintColor = .systemGreen
        
        let mode = data.payment_mode?.lowercased() ?? ""
        
        switch mode {
            
        case "cash":
            statusBtn.setImage(resizedSymbol(name: "banknote.fill"), for: .normal)
            statusBtn.setTitle(" Cash", for: .normal)
            
        default:
            statusBtn.setImage(resizedSymbol(name: "creditcard.fill"), for: .normal)
            statusBtn.setTitle(" \(mode.capitalized)", for: .normal)
        }
    }
    private func resizedSymbol(name: String) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        return UIImage(systemName: name, withConfiguration: config)?
            .withRenderingMode(.alwaysTemplate)
    }
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}
