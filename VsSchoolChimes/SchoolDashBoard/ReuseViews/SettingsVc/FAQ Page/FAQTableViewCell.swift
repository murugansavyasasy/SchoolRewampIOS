
//  FAQTableViewCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 05/11/24.
//

import UIKit

class FAQTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ArrowImgview: UIButton!
    @IBOutlet weak var AnswerLbl: UILabel!
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Styling
        cellView.layer.cornerRadius = Colornames.CORadius10
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellView.layer.shadowRadius = 3
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor.gray.cgColor
        cellView.layer.masksToBounds = false
        
        QuestionLabel.setFont(style: .title, size: FontSize.TitleSize)
        AnswerLbl.setFont(style: .body, size: FontSize.BodySize)
        AnswerLbl.numberOfLines = 0
        AnswerLbl.isHidden = true
    }
    
    func configure(question: String?, answers: [String]?, isSelected: Bool) {
        QuestionLabel.text = question
        AnswerLbl.isHidden = !isSelected
        guard let answers = answers else {
            AnswerLbl.text = nil
            return
        }
        let bullet = "🔹 "
        let bulletText = answers.map { "\(bullet)\($0)" }.joined(separator: "\n")
        AnswerLbl.text = bulletText
    }
    
    func toggleLabelVisibility(isSelected: Bool) {
        AnswerLbl.isHidden = !isSelected
        let image = isSelected ? UIImage(systemName: "arrowtriangle.up.fill"): UIImage(systemName: "arrowtriangle.down.fill")
        ArrowImgview.setImage(image, for: .normal)
    }
}
