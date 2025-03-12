//
//  QuizTVcell.swift
//  VsSchoolChimes
//
//  Created by Admin on 17/01/25.
//

import UIKit

class QuizTVcell: UITableViewCell {

    @IBOutlet weak var LevelStackview: UIStackView!
    @IBOutlet weak var CorrectAnsStack: UIStackView!
    @IBOutlet weak var IncorrectAnsStack: UIStackView!
    @IBOutlet weak var TitleStack: UIStackView!
    @IBOutlet weak var StartBtn: UIButton!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var TotalMarksDefLbl: UILabel!
    @IBOutlet weak var TotalQuestionDefLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var SentbyDefLbl: UILabel!
    @IBOutlet weak var NumberOfLevelDefLbl: UILabel!
    @IBOutlet weak var SubjectDefLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var NumberoflvlLbl: UILabel!
    @IBOutlet weak var SentbyLbl: UILabel!
    @IBOutlet weak var TotalQuestionLbl: UILabel!
    @IBOutlet weak var TotalMarksLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        CorrectAnsStack.isHidden = true
        IncorrectAnsStack.isHidden = true
        TitleStack.isHidden = true
        LevelStackview.isHidden = true
        
        TitleLbl.setFont(style: .body, size: FontSize.BodySize)
        SubjectDefLbl.setFont(style: .body, size: FontSize.BodySize)
        SubjectLbl.setFont(style: .body, size: FontSize.BodySize)
        SentbyDefLbl.setFont(style: .body, size: FontSize.BodySize)
        SentbyLbl.setFont(style: .body, size: FontSize.BodySize)
        NumberOfLevelDefLbl.setFont(style: .body, size: FontSize.BodySize)
        NumberoflvlLbl.setFont(style: .body, size: FontSize.BodySize)
        TotalMarksDefLbl.setFont(style: .body, size: FontSize.BodySize)
        TotalMarksLbl.setFont(style: .body, size: FontSize.BodySize)
        TotalQuestionDefLbl.setFont(style: .body, size: FontSize.BodySize)
        TotalQuestionLbl.setFont(style: .body, size: FontSize.BodySize)
        
        cellView.layer.cornerRadius = 10
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellView.layer.shadowRadius = 3
        cellView.layer.masksToBounds = false
        StartBtn.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
