//
//  ExamMarkCV.swift
//  VsSchoolChimes
//
//  Created by Admin on 25/12/24.
//

import UIKit

class ExamMarkCV: UICollectionViewCell {

    @IBOutlet weak var viewMarksLbl: UILabel!
    @IBOutlet weak var ViewMarkBtnview: UIView!
    @IBOutlet weak var ExamLbl: UILabel!
    @IBOutlet weak var bgImgview: UIImageView!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellView.layer.cornerRadius = 10
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor.gray.cgColor
        
        ViewMarkBtnview.layer.cornerRadius = 10
        
        ExamLbl.setFont(style: .title, size: FontSize.TitleSize)
        viewMarksLbl.setFont(style: .title, size: FontSize.TitleSize)
    }

}
