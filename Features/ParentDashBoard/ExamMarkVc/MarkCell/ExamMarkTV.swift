//
//  ExamMarkTV.swift
//  VsSchoolChimes
//
//  Created by Admin on 24/12/24.
//

import UIKit

class ExamMarkTV: UITableViewCell {

    @IBOutlet weak var stackHeight: NSLayoutConstraint!
    @IBOutlet weak var ArrowImageview: UIImageView!
    @IBOutlet weak var MarksStackview: UIStackView!
    @IBOutlet weak var PracticalLbl: UILabel!
    @IBOutlet weak var TheoryLbl: UILabel!
    @IBOutlet weak var progessBar: UIProgressView!
    @IBOutlet weak var MarkLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        MarkLbl.setFont(style: .title, size: FontSize.TitleSize)
        SubjectLbl.setFont(style: .title, size: FontSize.TitleSize)
        TheoryLbl.setFont(style: .body, size: FontSize.BodySize)
        PracticalLbl.setFont(style: .body, size: FontSize.BodySize)
        TheoryLbl.isHidden = true
        PracticalLbl.isHidden = true
        //MarkLbl.setFont(style: .title, size: FontSize.TitleSize)
        showPopUpEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showPopUpEffect() {
        cellView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // Start smaller
        cellView.alpha = 0 // Start invisible

        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.cellView.transform = CGAffineTransform.identity // Restore to original size
            self.cellView.alpha = 1 // Make it visible
        })
    }

    
}
