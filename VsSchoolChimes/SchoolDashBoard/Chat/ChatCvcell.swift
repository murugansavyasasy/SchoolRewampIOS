//
//  ChatCvcell.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/01/25.
//

import UIKit

class ChatCvcell: UICollectionViewCell {

    @IBOutlet weak var CellView: UIView!
    @IBOutlet weak var InteractBtn: UIButton!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var profileImgview: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NameLbl.setFont(style: .title, size: FontSize.TitleSize)
        SubjectLbl.setFont(style: .title, size: FontSize.TitleSize)
        InteractBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        profileImgview.layer.cornerRadius = profileImgview.frame.width/2
        InteractBtn.layer.cornerRadius = 10
        CellView.layer.cornerRadius = 10
        CellView.layer.borderWidth = 1
        CellView.layer.borderColor = UIColor.lightGray.cgColor
    }

}
