//
//  LSRWTvCell.swift
//  VsSchoolChimes
//
//  Created by MacBook on 17/02/25.
//

import UIKit

class LSRWTvCell: UITableViewCell {
    
    @IBOutlet weak var takeSkillBtn: UIButton!
    @IBOutlet weak var CellView: UIViewX!
    
    @IBOutlet weak var TitleLbl: UILabel!
    
    @IBOutlet weak var DescriptionLbl: UILabel!
    
    @IBOutlet weak var SubjectLbl: UILabel!
    
    @IBOutlet weak var SubmittedLbl: UILabel!
    
    @IBOutlet weak var SentbyLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        CellView.layer.cornerRadius = 10
        CellView.backgroundColor = .white
        CellView.layer.shadowColor = UIColor.black.cgColor
        CellView.layer.shadowOpacity = 0.5
        CellView.layer.shadowOffset = CGSize(width: 4, height: 4)
        CellView.layer.shadowRadius = 3
        CellView.layer.masksToBounds = false
        CellView.layer.borderWidth = 0.5
        CellView.layer.borderColor = UIColor.lightGray.cgColor
       
        takeSkillBtn.layer.cornerRadius = 10
        takeSkillBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        SubjectLbl.setFont(style: .title, size: FontSize.BodySize)
        SubmittedLbl.setFont(style: .body, size: FontSize.BodySize)
        SentbyLbl.setFont(style: .body, size: FontSize.BodySize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
