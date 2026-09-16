//
//  AmountBreakdownCardCell.swift
//  paymentProofDesign
//
//  Created by Senior iOS UI/UX Designer on 04/09/26.
//

import UIKit

final class AmountBreakdownCardCell: UITableViewCell {

    @IBOutlet weak var totalFeeLbl: UILabel!
    static let reuseIdentifier = "AmountBreakdownCardCell"

    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var userEnteredAmountLabel: UILabel!
    @IBOutlet weak var aiDetectedAmountLabel: UILabel!
    @IBOutlet weak var differenceAmountLabel: UILabel!

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
        totalFeeLbl.text  = item.totalAmount
        userEnteredAmountLabel.text = item.userEnterAmount
        aiDetectedAmountLabel.text = item.aiDetectedAmount
//        differenceAmountLabel.text = item.differenceAmount
    }
}
