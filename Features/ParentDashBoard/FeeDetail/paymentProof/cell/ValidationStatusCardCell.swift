//
//  ValidationStatusCardCell.swift
//  paymentProofDesign
//
//  Created by Senior iOS UI/UX Designer on 04/09/26.
//

import UIKit

final class ValidationStatusCardCell: UITableViewCell {

    static let reuseIdentifier = "ValidationStatusCardCell"

    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var statusValueLabel: UILabel!
    @IBOutlet weak var validatedByValueLabel: UILabel!
    @IBOutlet weak var validatedOnValueLabel: UILabel!
    @IBOutlet weak var paymentIDValueLabel: UILabel!
    @IBOutlet weak var createdValueLabel: UILabel!
    @IBOutlet weak var remarksValueLabel: UILabel!

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

    func configure(with item: PaymentDetailItem) {
        let status = item.validationStatus
        statusValueLabel.text = status.displayName
        statusValueLabel.textColor = status.statusTextColor

        validatedByValueLabel.text = item.validatedBy.isEmpty ? "—" : item.validatedBy
        validatedOnValueLabel.text = item.validatedOn.isEmpty ? "—" : item.validatedOn
        paymentIDValueLabel.text = item.paymentID.isEmpty ? "—" : item.paymentID
        createdValueLabel.text = item.createdOn.isEmpty ? "—" : item.createdOn
        remarksValueLabel.text = item.remarks.isEmpty ? "—" : item.remarks
    }
}
