//
//  PtmCV.swift
//  School Chimes
//
//  Created by Lakshmanan on 12/08/25.
//

import UIKit

class PtmCV: UICollectionViewCell {

    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var MeetingNameLbl: UILabel!
    @IBOutlet weak var standardLbl: UILabel!
    @IBOutlet weak var modeLbl: UILabel!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var imgCountBtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellview.layer.cornerRadius = 8
        
        MeetingNameLbl.setFont(style: .title, size: FontSize.BodySize)
        standardLbl.setFont(style: .body, size: FontSize.BodySize)
        modeLbl.setFont(style: .body, size: FontSize.BodySize)
        timeLbl.setFont(style: .body, size: FontSize.BodySize)
        dateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        img1.layer.cornerRadius = 15
        img2.layer.cornerRadius = 15
        img3.layer.cornerRadius = 15
        imgCountBtn.layer.cornerRadius = 15
        iconImage.layer.cornerRadius = iconImage.frame.width / 2
    }

}
