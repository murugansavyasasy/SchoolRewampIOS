//
//  LessonViewTvCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 17/06/25.
//

import UIKit

class LessonViewTvCell: UITableViewCell {

    @IBOutlet weak var ProgressView: UIView!
    @IBOutlet weak var Baseview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with details: [LessonDetailItem]) {
        // Remove any previous stack view if it exists (using tag)
        Baseview.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        
        // Create a vertical stack view
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.tag = 999 // Tag it so we can identify and remove it later

        // Populate the stack with detail rows
        for detail in details {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.alignment = .top
            rowStack.distribution = .fill

            let nameLabel = UILabel()
            nameLabel.text = detail.name
            nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
            nameLabel.numberOfLines = 0
            nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

            let valueLabel = UILabel()
            valueLabel.text = detail.value
            valueLabel.font = UIFont.systemFont(ofSize: 14)
            valueLabel.numberOfLines = 0
            valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

            rowStack.addArrangedSubview(nameLabel)
            rowStack.addArrangedSubview(valueLabel)
            mainStack.addArrangedSubview(rowStack)
        }

        // Add the stack to Baseview
        Baseview.addSubview(mainStack)

        // Layout constraints to place mainStack above ProgressView
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: Baseview.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: Baseview.leadingAnchor, constant: 8),
            mainStack.trailingAnchor.constraint(equalTo: Baseview.trailingAnchor, constant: -8),
            mainStack.bottomAnchor.constraint(equalTo: ProgressView.topAnchor, constant: -8)
        ])
    }

}
