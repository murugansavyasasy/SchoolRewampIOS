//
//  ExamReportsTVC.swift
//  School Chimes
//
//  Created by Chandhru on 01/07/26.
//

import UIKit

class ExamReportsTVC: UITableViewCell {
    @IBOutlet weak var standerdLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var sendbyLbl: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var classSectionStack: UIStackView!

    var onSectionTap: ((StaffSection) -> Void)?
    var ontestDeletTap: ((Int) -> Void)?

    private var sections: [StaffSection] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear

        classSectionStack.axis = .horizontal
        classSectionStack.spacing = 10
        classSectionStack.alignment = .center
        classSectionStack.distribution = .fill

        styleCard()
        iconBtn.layer.cornerRadius = 14
        iconBtn.layer.masksToBounds = true
    }

    private func styleCard() {
        outerView.layer.cornerRadius = 8
        outerView.layer.masksToBounds = false
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.06

        innerView.backgroundColor = .clear
        innerView.layer.cornerRadius = 18
        innerView.layer.masksToBounds = true

        tittleLbl.font = .systemFont(ofSize: 17, weight: .bold)
        tittleLbl.textColor = .label

        sendbyLbl.font = .systemFont(ofSize: 13, weight: .medium)
        sendbyLbl.textColor = .secondaryLabel
        deleteBtn.layer.cornerRadius = 14
        deleteBtn.layer.masksToBounds = true

        deleteBtn.backgroundColor = .systemRed.withAlphaComponent(0.08)

        deleteBtn.tintColor = .systemRed

        deleteBtn.layer.borderWidth = 1
        deleteBtn.layer.borderColor =
            UIColor.systemRed.withAlphaComponent(0.25).cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        classSectionStack.arrangedSubviews.forEach {
            classSectionStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        sections = []
        onSectionTap = nil
    }

    func configure(
        examName: String,
        sentBy: String,
        sections: [StaffSection],
        iconTint: UIColor
    ) {
        self.sections = sections

        tittleLbl.text = examName
        sendbyLbl.text = "Sent by: \(sentBy)"
        standerdLbl.text = "Standard: \(sections.first?.class_name ?? "")"

        iconBtn.backgroundColor = iconTint.withAlphaComponent(0.15)
        iconBtn.setImage(UIImage(systemName: "doc.text.fill"), for: .normal)
        iconBtn.tintColor = iconTint
        iconBtn.layer.borderWidth = 1
        iconBtn.layer.borderColor = iconTint.withAlphaComponent(0.25).cgColor

        buildSectionChips(iconTint: iconTint)
    }

    @IBAction func deleteexam(_ sender: UIButton) {
        ontestDeletTap?(sender.tag)
    }
    
    private func makeChipButton(title: String, tint: UIColor) -> UIButton {
        var config = UIButton.Configuration.plain()

        config.title = "Section \(title)"
        config.baseForegroundColor = tint
        config.baseBackgroundColor = .gray.withAlphaComponent(0.05)
        config.cornerStyle = .capsule
        config.background.strokeColor = tint
        config.background.strokeWidth = 1.5
        config.background.backgroundColor = .clear

        config.image = UIImage(systemName: "chevron.forward.circle")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)

        config.contentInsets = NSDirectionalEdgeInsets(
            top: 9,
            leading: 16,
            bottom: 9,
            trailing: 12
        )

        config.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 13, weight: .semibold)
                return outgoing
            }

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.configurationUpdateHandler = { btn in
            var cfg = btn.configuration

            cfg?.background.backgroundColor =
                btn.isHighlighted ? tint.withAlphaComponent(0.15) : .clear

            btn.configuration = cfg
            btn.transform = btn.isHighlighted
                ? CGAffineTransform(scaleX: 0.96, y: 0.96)
                : .identity
        }

        return button
    }
    private func buildSectionChips(iconTint: UIColor) {

        classSectionStack.arrangedSubviews.forEach {
            classSectionStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        classSectionStack.axis = .vertical
        classSectionStack.spacing = 8
        classSectionStack.alignment = .fill

        var currentRow = createRow()
        classSectionStack.addArrangedSubview(currentRow)

        var currentWidth: CGFloat = 0
        let maxWidth = UIScreen.main.bounds.width - 60

        for (index, section) in sections.enumerated() {

            let chip = makeChipButton(
                title: section.section_name ?? "",
                tint: iconTint
            )

            chip.tag = index
            chip.addTarget(
                self,
                action: #selector(chipTapped(_:)),
                for: .touchUpInside
            )

            let chipWidth = chip.intrinsicContentSize.width + 10

            if currentWidth + chipWidth > maxWidth {

                addSpacer(to: currentRow)

                currentRow = createRow()
                classSectionStack.addArrangedSubview(currentRow)

                currentWidth = 0
            }

            currentRow.addArrangedSubview(chip)
            currentWidth += chipWidth
        }

        addSpacer(to: currentRow)
    }

    private func createRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.distribution = .fill
        return row
    }

    private func addSpacer(to stack: UIStackView) {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stack.addArrangedSubview(spacer)
    }
    @objc private func chipTapped(_ sender: UIButton) {
        guard sections.indices.contains(sender.tag) else { return }
        let tappedSection = sections[sender.tag]
        onSectionTap?(tappedSection)
    }
}
