//
//  LessonViewTvCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 17/06/25.
//

import UIKit

class LessonViewTvCell: UITableViewCell {

    @IBOutlet weak var ProgressStack: UIStackView!
    @IBOutlet weak var ProgressView: UIView!
    @IBOutlet weak var Baseview: UIView!
    @IBOutlet weak var ProgressView2: UIView!
    @IBOutlet weak var ProgressImage: UIImageView!
    @IBOutlet weak var StatusLbl: UILabel!
    @IBOutlet weak var EditBtn: UIButton!
    @IBOutlet weak var DeleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ProgressView.isHidden = true
        Baseview.layer.cornerRadius = 10.0
        Baseview.layer.masksToBounds = false
        Baseview.layer.shadowColor = UIColor.black.cgColor
        Baseview.layer.shadowOpacity = 0.2
        Baseview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Baseview.layer.shadowRadius = 6
        Baseview.layer.borderColor = UIColor.lightGray.cgColor
        Baseview.layer.borderWidth = 0.5
        Baseview.backgroundColor = .white
        
        ProgressView2.layer.cornerRadius = 10
        ProgressView2.layer.borderWidth = 2
        ProgressView2.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.8).cgColor
        ProgressView2.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        
        DeleteBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        EditBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        DeleteBtn.layer.cornerRadius = 10
        EditBtn.layer.cornerRadius = 10
        StatusLbl.setFont(style: .title, size: FontSize.HeaderSize)
        
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
        mainStack.spacing = 6
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.tag = 999 // Tag it so we can identify and remove it later

        // Populate the stack with detail rows
        for detail in details {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.alignment = .top
            rowStack.distribution = .fill

            let nameLabel = UILabel()
            nameLabel.text = detail.name
            nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
            nameLabel.numberOfLines = 0
            nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

            let colonLabel = UILabel()
            colonLabel.text = ":"
            colonLabel.font = UIFont(name: "Poppins-Medium", size: 14)
            colonLabel.setContentHuggingPriority(.required, for: .horizontal)

            let valueLabel = UILabel()
            valueLabel.text = detail.value
            valueLabel.font = UIFont(name: "Poppins-Medium", size: 14)
            valueLabel.numberOfLines = 0
            valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

            rowStack.addArrangedSubview(nameLabel)
            rowStack.addArrangedSubview(colonLabel)
            rowStack.addArrangedSubview(valueLabel)
            mainStack.addArrangedSubview(rowStack)
        }

        // Add the stack to Baseview
        Baseview.addSubview(mainStack)

        // Layout constraints to place mainStack above ProgressView
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: Baseview.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: Baseview.leadingAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: Baseview.trailingAnchor, constant: -10),
            mainStack.bottomAnchor.constraint(equalTo: ProgressStack.topAnchor, constant: -8)
        ])
    }


}
