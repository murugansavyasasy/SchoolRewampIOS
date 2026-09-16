//
//  ProofThumbnailCell.swift
//  paymentProofDesign
//
//  Created by Senior iOS UI/UX Designer on 04/09/26.
//

import UIKit

final class ProofThumbnailCell: UICollectionViewCell {

    static let reuseIdentifier = "ProofThumbnailCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var badgeContainerView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var tapOverlayButton: UIButton!

    private var openURLHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        containerView.backgroundColor = UIColor(red: 0.945, green: 0.961, blue: 0.976, alpha: 1.0) // #F1F5F9
        containerView.layer.cornerRadius = 14.0
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor(red: 0.886, green: 0.914, blue: 0.941, alpha: 1.0).cgColor // #E2E8F0
        containerView.layer.masksToBounds = true

        badgeContainerView.backgroundColor = UIColor(red: 0.863, green: 0.918, blue: 0.996, alpha: 1.0) // #DBEAFE
        badgeContainerView.layer.cornerRadius = 10.0
        badgeContainerView.layer.masksToBounds = true

        badgeLabel.textColor = UIColor(red: 0.145, green: 0.388, blue: 0.922, alpha: 1.0) // #2563EB
        badgeLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)

        fileNameLabel.textColor = UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1.0) // #0F172A
        fileNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        fileInfoLabel.textColor = UIColor(red: 0.392, green: 0.455, blue: 0.545, alpha: 1.0) // #64748B
        fileInfoLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    }

    func configure(with proof: ProofUploadedItem, onOpen: (() -> Void)?) {
        fileNameLabel.text = proof.displayName
        badgeLabel.text = proof.badgeText
        fileInfoLabel.text = proof.subtitleText
        self.openURLHandler = onOpen
    }

    @IBAction func cardTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        openURLHandler?()
    }
}
