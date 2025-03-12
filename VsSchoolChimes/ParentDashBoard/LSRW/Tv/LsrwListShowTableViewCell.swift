//
//  LsrwListShowTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/20/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class LsrwListShowTableViewCell: UITableViewCell {

    @IBOutlet weak var TitleDefLbl: UILabel!
    
    @IBOutlet weak var DescriptionDefLbl: UILabel!
    
    @IBOutlet weak var SubjectDefLbl: UILabel!
    
    @IBOutlet weak var SubmitedOnDefLbl: UILabel!
    
    @IBOutlet weak var typeLbl: UILabel!
    
    @IBOutlet weak var SentbyDefLbl: UILabel!
    @IBOutlet weak var takingSkillHeight: NSLayoutConstraint!
    @IBOutlet weak var submittedHeadingLbl: UILabel!
    @IBOutlet weak var takingSkillView: UIView!
    @IBOutlet weak var takingSkillBtn: UIButton!
    @IBOutlet weak var sentByLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var submittedOnLbl: UILabel!
    @IBOutlet weak var subLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        typeLbl.text = "Take Listening Skill"
        
        TitleDefLbl.setFont(style: .body, size: FontSize.BodySize)
        titleLbl.setFont(style: .body, size: FontSize.BodySize)
        DescriptionDefLbl.setFont(style: .body, size: FontSize.BodySize)
        descLbl.setFont(style: .body, size: FontSize.BodySize)
        SubjectDefLbl.setFont(style: .body, size: FontSize.BodySize)
        subLbl.setFont(style: .body, size: FontSize.BodySize)
        SubmitedOnDefLbl.setFont(style: .body, size: FontSize.BodySize)
        submittedOnLbl.setFont(style: .body, size: FontSize.BodySize)
        SentbyDefLbl.setFont(style: .body, size: FontSize.BodySize)
        sentByLbl.setFont(style: .body, size: FontSize.BodySize)
        typeLbl.setFont(style: .body, size: FontSize.BodySize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
