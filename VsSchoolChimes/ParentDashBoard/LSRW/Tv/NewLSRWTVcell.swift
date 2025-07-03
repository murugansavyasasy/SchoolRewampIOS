//
//  NewLSRWTVcell.swift
//  VsSchoolChimes
//
//  Created by MacBook on 24/02/25.
//

import UIKit

class NewLSRWTVcell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var Subject: UIButton!
    @IBOutlet weak var Date: UIButton!
    @IBOutlet weak var StaffName: UIButton!
    @IBOutlet weak var SkillType: UIButton!
    @IBOutlet weak var TakeSkillBtn: UIButton!
    @IBOutlet weak var iconBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 10
        cellView.backgroundColor = .white
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellView.layer.shadowRadius = 3
        cellView.layer.masksToBounds = false
        cellView.layer.borderWidth = 0.5
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        iconBtn.setImage( UIImage(systemName: "headphones"), for: .normal)
        iconBtn.tintColor = .white
        iconBtn.layer.cornerRadius = 8
        StaffName.layer.cornerRadius = 8
        SkillType.layer.cornerRadius = 8
        Subject.layer.cornerRadius = 8
        Date.layer.cornerRadius = 8
        TakeSkillBtn.layer.cornerRadius = 10
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        Subject.setTitleFont(style: .body, size: FontSize.BodySize)
        Date.setTitleFont(style: .body, size: FontSize.BodySize)
        StaffName.setTitleFont(style: .body, size: FontSize.BodySize)
        SkillType.setTitleFont(style: .body, size: FontSize.BodySize)
        TakeSkillBtn.setTitleFont(style: .primary, size: FontSize.BodySize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
