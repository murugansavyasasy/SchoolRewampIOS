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
        outerView.setShadow()
        statusBtn.clipsToBounds = true
    }
    func configureInstallment(data: InstallmentBreakdown?) {
        iconBtn.isHidden = true
        transactionStack.isHidden = true
        guard let data = data else { return }
        
        feesNameLbl.text = data.installmentName
        dateLbl.text = "Due: \(data.dueDate ?? "")"
        feesamoiuntLbl.text = "₹\(formatAmount(data.amount ?? 0))"
        
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
    func configurePayment(data: PaymentHistory?) {
        
        guard let data = data else { return }
        
        iconBtn.isHidden = false
        transactionStack.isHidden = false
        
        feesNameLbl.text = data.paymentMode
        transactionIdLbl.text = data.paymentId
        dateLbl.text = data.paymentDate
        feesamoiuntLbl.text = "₹\(formatAmount(data.amount ?? 0))"
        
        statusBtn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        statusBtn.setTitleColor(.systemBlue, for: .normal)
        statusBtn.tintColor = .systemBlue
        iconBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        iconBtn.setImage(resizedSymbol(name: "checkmark.circle.fill"), for: .normal)
        iconBtn.tintColor = .systemGreen
        
        let mode = data.paymentMode?.lowercased() ?? ""
        
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
