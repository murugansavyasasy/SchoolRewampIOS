//
//  StudentFinancialTVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/03/26.
//

import UIKit

class StudentFinancialTVC: UITableViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var paidProgressView: UIProgressView!
    @IBOutlet weak var paidPercentageLbl: UILabel!
    @IBOutlet weak var paidAmountLbl: UILabel!
    @IBOutlet weak var tatalAmmountLbl: UILabel!
    @IBOutlet weak var pendingAmmountLbl: UILabel!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var paidView: UIView!
    @IBOutlet weak var pendingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    private func setupUI() {
        outerView.setShadow()
        totalView.layer.cornerRadius = 16
        paidView.layer.cornerRadius = 16
        pendingView.layer.cornerRadius = 16
        totalView.layer.borderWidth = 1
        totalView.layer.borderColor = UIColor.blue.withAlphaComponent(0.15).cgColor
        totalView.clipsToBounds = true
        paidView.clipsToBounds = true
        pendingView.clipsToBounds = true
        pendingView.layer.borderWidth = 1
        pendingView.layer.borderColor = UIColor.red.withAlphaComponent(0.15).cgColor
        paidView.layer.borderWidth = 1
        paidView.layer.borderColor = UIColor.green.withAlphaComponent(0.15).cgColor
        paidProgressView.layer.cornerRadius = 6
        paidProgressView.clipsToBounds = true
    }
    func configure(data: FeesOverview?) {
        
        guard let data = data else { return }
        
        let total = data.totalAmount ?? 0
        let paid = data.paidAmount ?? 0
        let pending = data.pendingAmount ?? 0
        let progress = data.paymentProgress ?? 0
        
        // Amount Labels
        tatalAmmountLbl.text = "₹\(formatAmount(total))"
        paidAmountLbl.text = "₹\(formatAmount(paid))"
        pendingAmmountLbl.text = "₹\(formatAmount(pending))"
        
        // Percentage Label
        paidPercentageLbl.text = "\(Int(progress))% Paid"
        let progressValue = Float(progress / 100)
        paidProgressView.setProgress(progressValue, animated: true)
        
        setupUI()
    }
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}
