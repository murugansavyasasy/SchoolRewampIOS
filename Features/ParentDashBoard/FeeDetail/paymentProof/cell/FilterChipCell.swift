//
//  FilterChipCell.swift
//  paymentProofDesign
//
//  Created by Senior iOS UI/UX Designer on 04/09/26.
//

import UIKit

final class FilterChipCell: UICollectionViewCell {

    static let reuseIdentifier = "FilterChipCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        containerView.layer.cornerRadius = 18.0
        containerView.layer.masksToBounds = true
    }

    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        if isSelected {
            // Selected Pill: Brand Blue with White text
            containerView.backgroundColor = UIColor(red: 0.12, green: 0.47, blue: 0.95, alpha: 1.0) // #1E78F2
            titleLabel.textColor = .white
            titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        } else {
            // Unselected Pill: Light lavender-slate with dark slate text
            containerView.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1.0) // #EDF2F7
            titleLabel.textColor = UIColor(red: 0.33, green: 0.39, blue: 0.49, alpha: 1.0) // #54647D
            titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
    }
}
