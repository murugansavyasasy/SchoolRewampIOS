
//  FAQTableViewCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 05/11/24.
//

import UIKit

class FAQTableViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var ArrowImgview: UIImageView!
    @IBOutlet weak var AnswerLbl: UILabel!
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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
        AnswerLbl.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        if selected == true{
//            AnswerLbl.isHidden = false
//        }else{
//            AnswerLbl.isHidden = true
//        }
      
    }
    
    func toggleLabelVisibility(isSelected: Bool) {
        AnswerLbl.isHidden = !isSelected
        }
    
    
}
