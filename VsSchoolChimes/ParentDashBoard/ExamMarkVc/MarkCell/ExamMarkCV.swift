//
//  ExamMarkCV.swift
//  VsSchoolChimes
//
//  Created by Admin on 25/12/24.
//

import UIKit

class ExamMarkCV: UICollectionViewCell {

    @IBOutlet weak var viewprogessLbl: UILabel!
    @IBOutlet weak var ViewProgress: UIView!
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
        ViewProgress.layer.cornerRadius = 10
        
        viewMarksLbl.text = ExamStringFile.viewMarks
        viewprogessLbl.text = ExamStringFile.viewProgress
        
        ExamLbl.setFont(style: .title, size: FontSize.TitleSize)
        viewMarksLbl.setFont(style: .title, size: FontSize.TitleSize)
        viewprogessLbl.setFont(style: .title, size: FontSize.TitleSize)
    }

}
