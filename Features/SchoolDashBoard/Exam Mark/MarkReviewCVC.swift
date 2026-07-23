//
//  MarkReviewCVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/12/25.
//

import UIKit

class MarkReviewCVC: UICollectionViewCell {

    @IBOutlet weak var overallstack: UIStackView!
    @IBOutlet weak var maxMarkLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var subColumnsStack: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearRubricBoxes()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        addLeftBorder()
    }

    func configure(title: String, subtitle: String = "", max_Mark: String) {
        configure(title: title, subtitle: subtitle, max_Mark: max_Mark, rubrics: nil)
    }


    func configure(title: String,
                   subtitle: String = "",
                   max_Mark: String,
                   rubrics: [RubricMark]?) {

        headerLbl.text = title
        subjectLbl.text = subtitle
        subjectLbl.isHidden = subtitle.isEmpty

        clearRubricBoxes()

        guard let rubrics = rubrics, !rubrics.isEmpty else {
            // OLD behaviour: plain single column, no sub-columns
            maxMarkLbl.isHidden = false
            maxMarkLbl.text = max_Mark
            subColumnsStack.isHidden = true
            return
        }

        maxMarkLbl.isHidden = true
        subColumnsStack.isHidden = false
        subColumnsStack.axis = .horizontal
        subColumnsStack.distribution = .fillEqually
        subColumnsStack.alignment = .fill
        subColumnsStack.spacing = 0

        for rubric in rubrics {
            let box = makeRubricBox(
                name: rubric.displayName ?? rubric.name ?? "",
                maxMark: rubric.max_mark ?? "0"
            )
            subColumnsStack.addArrangedSubview(box)
        }
    }

    private func clearRubricBoxes() {
        subColumnsStack?.arrangedSubviews.forEach {
            subColumnsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    private func makeRubricBox(name: String, maxMark: String) -> UIView {
        let container = UIView()
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.separator.cgColor
        container.backgroundColor = .clear

        let nameLbl = UILabel()
        nameLbl.text = name
        nameLbl.font = .systemFont(ofSize: 12, weight: .medium)
        nameLbl.textAlignment = .center
        nameLbl.numberOfLines = 2
        nameLbl.adjustsFontSizeToFitWidth = true
        nameLbl.minimumScaleFactor = 0.8

        let maxLbl = UILabel()
        maxLbl.text = "Max: \(maxMark)"
        maxLbl.font = .systemFont(ofSize: 10)
        maxLbl.textAlignment = .center
        maxLbl.textColor = .secondaryLabel

        let vStack = UIStackView(arrangedSubviews: [nameLbl, maxLbl])
        vStack.axis = .vertical
        vStack.alignment = .fill
        vStack.spacing = 2
        vStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -2)
        ])

        return container
    }
    private func addLeftBorder() {

        // Remove old border if reused
        overallstack.layer.sublayers?.removeAll(where: { $0.name == "leftBorder" })

        let border = CALayer()
        border.name = "leftBorder"
        border.backgroundColor = UIColor.separator.cgColor
        border.frame = CGRect(
            x: 0,
            y: 0,
            width: 1,
            height: overallstack.bounds.height
        )

        overallstack.layer.addSublayer(border)
    }
}
