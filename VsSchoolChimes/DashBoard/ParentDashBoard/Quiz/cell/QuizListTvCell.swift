//
//  QuizListTvCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 07/02/25.
//

import UIKit

class QuizListTvCell: UITableViewCell {
    
    @IBOutlet weak var CellView: UIView!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var PlayBtn: UIButton!
    @IBOutlet weak var LevelLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellView.layer.cornerRadius = 10
        CellView.layer.shadowColor = UIColor.black.cgColor
        CellView.layer.shadowOpacity = 0.5
        CellView.layer.shadowOffset = CGSize(width: 4, height: 4)
        CellView.layer.shadowRadius = 3
        CellView.layer.masksToBounds = false
        CellView.layer.borderWidth = 1
        CellView.layer.borderColor = UIColor.gray.cgColor
        
        LevelLbl.layer.masksToBounds = true
        LevelLbl.layer.cornerRadius = 5
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        SubjectLbl.setFont(style: .body, size: FontSize.BodySize)
        LevelLbl.setFont(style: .title, size: FontSize.TitleSize)
        PlayBtn.setTitleFont(style: .body, size: FontSize.TitleSize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
