//
//  ExamReportsTVC.swift
//  School Chimes
//
//  Created by Chandhru on 01/07/26.
//

import UIKit

class ExamReportsTVC: UITableViewCell {

    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var sendbyLbl: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var classSectionStack: UIStackView!
    @IBOutlet weak var arrowBtn: UIButton!

    private let classChip = PaddingLabel()
    private let dateChip = PaddingLabel()

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear

        outerView.layer.cornerRadius = 22
        outerView.backgroundColor = .white

        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.06
        outerView.layer.shadowRadius = 12
        outerView.layer.shadowOffset = CGSize(width: 0, height: 6)

        setupChips()

        iconBtn.layer.cornerRadius = 22
        arrowBtn.layer.cornerRadius = 16
    }

    private func setupChips() {

        classChip.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.1)
        classChip.textColor = UIColor.systemIndigo

        dateChip.backgroundColor = UIColor.systemGray6
        dateChip.textColor = UIColor.darkGray

        [(classChip), (dateChip)].forEach { (label: PaddingLabel) in
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            label.clipsToBounds = true
            label.layer.cornerRadius = 14

            classSectionStack.addArrangedSubview(label)
        }
    }

    func configure(
        sectionName: String,
        dateText: String,
        session: String,
        status: String,
        iconTint: UIColor
    ) {

        tittleLbl.text = sectionName
        sendbyLbl.text = status

        classChip.text = "📚 \(sectionName)"

        dateChip.text =
        "🕐 \(dateText) • \(session)"

        iconBtn.backgroundColor = iconTint
        arrowBtn.backgroundColor =
        iconTint.withAlphaComponent(0.15)

        iconBtn.setImage(
            UIImage(systemName: "doc.text.fill"),
            for: .normal
        )

        iconBtn.tintColor = .white

        arrowBtn.setImage(
            UIImage(systemName: "chevron.right"),
            for: .normal
        )

        arrowBtn.tintColor = iconTint
    }
}
class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}
