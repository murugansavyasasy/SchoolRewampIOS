//
//  TransactionDetailCardCell.swift
//  paymentProofDesign
//
//  Created by Senior iOS UI/UX Designer on 04/09/26.
//

import UIKit

final class TransactionDetailCardCell: UITableViewCell {

    static let reuseIdentifier = "TransactionDetailCardCell"
    @IBOutlet weak var reasonLbl: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var reasonView: UIView!
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var providerBankLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    @IBOutlet weak var dateValueLabel: UILabel!
    
    @IBOutlet weak var transactionIDValueLabel: UILabel!
    @IBOutlet weak var refNumberValueLabel: UILabel!
    
    @IBOutlet weak var payerValueLabel: UILabel!
    @IBOutlet weak var payeeValueLabel: UILabel!
    
    @IBOutlet weak var confidenceValueLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardStyle()
    }

    private func setupCardStyle() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardBackgroundView.backgroundColor = .white
        cardBackgroundView.layer.cornerRadius = 16.0
        cardBackgroundView.layer.borderWidth = 1.0
        cardBackgroundView.layer.borderColor = UIColor(red: 0.90, green: 0.93, blue: 0.96, alpha: 1.0).cgColor

        cardBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cardBackgroundView.layer.shadowOpacity = 0.04
        cardBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardBackgroundView.layer.shadowRadius = 6.0
        cardBackgroundView.layer.masksToBounds = false
    }

    func configure(with detail: ProofDetailInfo, showSectionHeader: Bool, totalReceiptsCount: Int) {
        sectionHeaderLabel.isHidden = !showSectionHeader
        if showSectionHeader {
            sectionHeaderLabel.text = "TRANSACTION DETAILS (\(totalReceiptsCount) \(totalReceiptsCount == 1 ? "RECEIPT DETECTED" : "RECEIPTS DETECTED"))"
        }

        providerBankLabel.text = detail.formattedProviderBank
        paymentMethodLabel.text = detail.paymentMethod.uppercased() == "UPI" ? "UPI Payment" : detail.paymentMethod.capitalized

        amountValueLabel.text = detail.formattedPaidAmount
        dateValueLabel.text = detail.receiptDate.isEmpty ? "—" : detail.receiptDate

        transactionIDValueLabel.text = detail.transactionID.isEmpty ? "—" : detail.transactionID
        refNumberValueLabel.text = detail.referenceNumber.isEmpty ? "—" : detail.referenceNumber

        payerValueLabel.text = detail.payerName.isEmpty ? "—" : detail.payerName
        payeeValueLabel.text = detail.payeeName.isEmpty ? "—" : detail.payeeName
        if detail.failureReason == "" {
            lineView.isHidden = true
            reasonView.isHidden = true
        }else{
            lineView.isHidden = false
            reasonView.isHidden = false
            reasonLbl.text = "Reason:\(detail.failureReason)"
        }
        statusLbl.text  = detail.paymentStatus.uppercased()
         if detail.paymentStatus.uppercased() == "SUCCESS" {
            statusLbl.textColor = .systemGreen
        }
         else {
            statusLbl.textColor = .systemRed
        }
        
        timeValueLabel.text = detail.receiptTime.isEmpty ? "—" : detail.receiptTime
    }
}
