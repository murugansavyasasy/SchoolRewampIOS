//
//  ExamMarkTvCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 22/07/25.
//

import UIKit

class ExamMarkTvCell: UITableViewCell {

    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var SubjectMarkBtn: UIButton!
    @IBOutlet weak var MainStack: UIStackView!
    @IBOutlet weak var headerLbl: UILabel!
    
    var splitData: [SplitMark] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerLbl.setFont(style: .title, size: FontSize.TitleSize)
        subjectLbl.setFont(style: .body, size: FontSize.TitleSize)
        SubjectMarkBtn.setTitleFont(style: .body, size: FontSize.BodySize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(data: [SplitMark]){

        for (index, subview) in MainStack.arrangedSubviews.enumerated() {
            if index > 1 {
                MainStack.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
        }
        
        for item in data {
            
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 5
            stack.alignment = .fill
            stack.distribution = .equalSpacing
            stack.translatesAutoresizingMaskIntoConstraints = false
            
            let markLabel = UILabel()
            markLabel.numberOfLines = 0
            markLabel.lineBreakMode = .byWordWrapping
            markLabel.textAlignment = .left
            markLabel.textColor = .black.withAlphaComponent(0.8)
            markLabel.setFont(style: .body, size: 12)
            markLabel.adjustsFontSizeToFitWidth = false
            markLabel.text = "\(item.mark_obtained ?? "") / \(item.max_mark ?? "")"
            
            let nameLabel = UILabel()
            nameLabel.numberOfLines = 0
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.textAlignment = .right
            nameLabel.textColor = .black.withAlphaComponent(0.8)
            nameLabel.setFont(style: .body, size: 12)
            nameLabel.adjustsFontSizeToFitWidth = false
            nameLabel.text = item.name
            
            stack.addArrangedSubview(nameLabel)
            stack.addArrangedSubview(markLabel)
            MainStack.addArrangedSubview(stack)
            
            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: MainStack.leadingAnchor, constant: 20),
                stack.trailingAnchor.constraint(equalTo: MainStack.trailingAnchor, constant: -8)
            ])
        }
    }
    
    func configureGroup(data: [SubGroup]){
        
        for (index, subview) in MainStack.arrangedSubviews.enumerated() {
            if index > 1 {
                MainStack.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
        }
        
        for item in data {
            
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 5
            stack.alignment = .fill
            stack.distribution = .equalSpacing
            stack.translatesAutoresizingMaskIntoConstraints = false
            
            let markLabel = UILabel()
            markLabel.numberOfLines = 0
            markLabel.lineBreakMode = .byWordWrapping
            markLabel.textAlignment = .left
            markLabel.textColor = .black.withAlphaComponent(0.8)
            markLabel.setFont(style: .body, size: 12)
            markLabel.adjustsFontSizeToFitWidth = false
            markLabel.text = item.mark
            
            let nameLabel = UILabel()
            nameLabel.numberOfLines = 0
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.textAlignment = .right
            nameLabel.textColor = .black.withAlphaComponent(0.8)
            nameLabel.setFont(style: .body, size: 12)
            nameLabel.adjustsFontSizeToFitWidth = false
            nameLabel.text = item.name
            
            stack.addArrangedSubview(nameLabel)
            stack.addArrangedSubview(markLabel)
            MainStack.addArrangedSubview(stack)
            
            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: MainStack.leadingAnchor, constant: 20),
                stack.trailingAnchor.constraint(equalTo: MainStack.trailingAnchor, constant: -8)
            ])
        }
    }
    
    func colorForPercentage(_ percentage: Double) -> UIColor {
        switch percentage {
        case 0...20:
            return UIColor.systemRed.withAlphaComponent(0.8)
        case 21...40:
            return UIColor.systemOrange.withAlphaComponent(0.8)
        case 41...60:
            return UIColor.systemYellow.withAlphaComponent(0.8)
        case 61...100:
            return UIColor.systemGreen.withAlphaComponent(0.8)
        case 1...99:
            return UIColor.systemOrange.withAlphaComponent(0.8)
        case 100:
            return UIColor.systemGreen.withAlphaComponent(0.8)
        default:
            return UIColor.lightGray // Default color (0% or invalid input)
        }
    }

    func updateButtonColour(for percentage: Double) {
        switch percentage {
        case 0..<50:
            SubjectMarkBtn.tintColor = .systemRed
        case 50..<75:
            SubjectMarkBtn.tintColor = .systemOrange
        case 75...100:
            SubjectMarkBtn.tintColor = .systemGreen
        default:
            SubjectMarkBtn.tintColor = .systemBlue
        }
    }

       
}


//for view in CertificationsStack.arrangedSubviews{
//    
//    if view != CertificationsStack.arrangedSubviews.first {
//        CertificationsStack.removeArrangedSubview(view)
//        view.removeFromSuperview()
//    }
//}
//
//for Certificate in certificates{
//    
//    let label = UILabel()
//    label.text = (Certificate.courseName ?? "") + " - " + (Certificate.institute ?? "") + " - " + (Certificate.duration ?? "")
//    label.setFont(style: .semibold, size: FontSize.body)
//    label.numberOfLines = 0
//    label.textColor = .label
//    CertificationsStack.addArrangedSubview(label)
//}
