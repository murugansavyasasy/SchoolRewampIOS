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
        
        bgView.layer.cornerRadius = 10
        bgView.layer.borderWidth = 0.5
        bgView.layer.borderColor = UIColor.gray.cgColor
    }

}
