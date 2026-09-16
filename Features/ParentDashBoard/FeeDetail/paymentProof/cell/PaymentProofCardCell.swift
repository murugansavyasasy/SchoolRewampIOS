//
//  PaymentProofCardCell.swift
//  paymentProofDesign
//
//  Created by Senior iOS UI/UX Designer on 04/09/26.
//

import UIKit

final class PaymentProofCardCell: UITableViewCell {

    static let reuseIdentifier = "PaymentProofCardCell"

    @IBOutlet weak var validateOnLbl: UILabel!
    // MARK: - IBOutlets
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var statusIndicatorView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var aiSparkleImageView: UIImageView!
    @IBOutlet weak var metadataLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var disclosureImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardStyle()
    }

    private func setupCardStyle() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card Container Styling
        cardBackgroundView.backgroundColor = .white
        cardBackgroundView.layer.cornerRadius = 16.0
        cardBackgroundView.layer.borderWidth = 1.0
        cardBackgroundView.layer.borderColor = UIColor(red: 0.90, green: 0.93, blue: 0.96, alpha: 1.0).cgColor // #E5ECF5

        // Elevation Drop Shadow
        cardBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cardBackgroundView.layer.shadowOpacity = 0.04
        cardBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardBackgroundView.layer.shadowRadius = 6.0
        cardBackgroundView.layer.masksToBounds = false

        // Status Indicator Circle
        statusIndicatorView.layer.cornerRadius = 5.0
        statusIndicatorView.layer.masksToBounds = true

        // Chevron Styling
        disclosureImageView.tintColor = UIColor(red: 0.65, green: 0.70, blue: 0.78, alpha: 1.0)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.cardBackgroundView.transform = highlighted ? CGAffineTransform(scaleX: 0.985, y: 0.985) : .identity
            self.cardBackgroundView.backgroundColor = highlighted ? UIColor(red: 0.97, green: 0.98, blue: 1.0, alpha: 1.0) : .white
        }
    }

    func configure(with item: PaymentDetailItem) {
        // Amount
        amountLabel.text = item.cleanAmount

        // AI Mismatch Sparkle Badge (Visible when AI detected amount differs)
        aiSparkleImageView.isHidden = true
        aiSparkleImageView.tintColor = UIColor(red: 0.85, green: 0.55, blue: 0.08, alpha: 1.0) // Gold/Amber

        let proof = "proof".translated()
        let validate = "Validate By :".translated()
        let createon = "Created On :".translated()
        if item.validationStatus.rawValue == "pending"{
            metadataLabel.text = "\(String(item.proofUploaded.count)) \(proof)"
        }else{
            metadataLabel.text = "\(validate) \(item.validatedBy + " · " + String(item.proofUploaded.count)) \(proof)"
        }
       
        validateOnLbl.text = "\(createon)\( item.createdOn)"
       
    
        // Status Label & Indicator Dot
        let status = item.validationStatus
        statusIndicatorView.backgroundColor = status.indicatorColor
        statusLabel.text = status.displayName
        statusLabel.textColor = status.statusTextColor
    }
}
