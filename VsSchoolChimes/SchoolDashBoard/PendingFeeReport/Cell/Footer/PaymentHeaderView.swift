//
//  PaymentHeaderView.swift
//  School Chimes
//
//  Created by Chandhru on 14/06/25.
//

import UIKit

class PaymentHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        outerView.backgroundColor = .systemGray6
//        outerView.layer.cornerRadius = 8
//        outerView.layer.masksToBounds = false // ✅ Important: must be false for shadow
//
//        // 💥 Shadow settings
//        outerView.layer.shadowColor = UIColor.black.cgColor
//        outerView.layer.shadowOpacity = 0.2 // subtle and clean
//        outerView.layer.shadowOffset = CGSize(width: 0, height: 4)
//        outerView.layer.shadowRadius = 8
//        applyShadowAndCornerRadius(to: outerView,backgroundColor: .systemGray6)
    }
    func applyShadowAndCornerRadius(
        to view: UIView,
        cornerRadius: CGFloat = 8,
        shadowColor: UIColor = UIColor.black,
        shadowOffset: CGSize = CGSize(width: 0, height: 4),
        shadowOpacity: Float = 0.1,
        shadowRadius: CGFloat = 8,
        backgroundColor: UIColor = .systemGray6
    ) {
        view.backgroundColor = backgroundColor
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = false

        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = shadowRadius
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        // 💡 Improves performance and ensures shadow respects corner radius
        view.layer.shadowPath = UIBezierPath(
            roundedRect: view.bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadowAndCornerRadius(to: outerView)
    }

}
