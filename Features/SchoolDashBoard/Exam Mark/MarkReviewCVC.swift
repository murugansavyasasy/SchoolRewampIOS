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

    private var leftBorderView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLeftBorder()
    }

    private func setupLeftBorder() {
        let border = UIView()
        border.backgroundColor = .separator
        border.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(border)

        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            border.topAnchor.constraint(equalTo: contentView.topAnchor),
            border.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            border.widthAnchor.constraint(equalToConstant: 1)
        ])
        leftBorderView = border
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearRubricBoxes()
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
}
