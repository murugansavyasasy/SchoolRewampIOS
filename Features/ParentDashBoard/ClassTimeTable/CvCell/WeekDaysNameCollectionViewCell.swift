//
//  WeekDaysNameCollectionViewCell.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/19/24.
//

import UIKit

class WeekDaysNameCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var weekDaysNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        weekDaysNameLbl.setFont(style: .title, size: FontSize.TitleSize)
        bgView.layer.cornerRadius = 10
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.white.cgColor
    }

}
