//
//  TakeReadingSkillTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/21/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class TakeReadingSkillTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ViewattachmentLbl: UILabel!
    
    @IBOutlet weak var TypeDefLbl: UILabel!
    @IBOutlet weak var AttachmentDefLbl: UILabel!
    @IBOutlet weak var viewAttac: UIView!
    
    
    @IBOutlet weak var typeLbl: UILabel!
    
    @IBOutlet weak var attachmentLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewAttac.layer.cornerRadius = 10
        ViewattachmentLbl.setFont(style: .title, size: FontSize.TitleSize)
        AttachmentDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        attachmentLbl.setFont(style: .title, size: FontSize.TitleSize)
        typeLbl.setFont(style: .title, size: FontSize.TitleSize)
        TypeDefLbl.setFont(style: .body, size: FontSize.BodySize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
