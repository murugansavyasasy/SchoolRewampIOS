//
//  ExamMarkCV.swift
//  VsSchoolChimes
//
//  Created by Admin on 25/12/24.
//

import UIKit

class ExamMarkCV: UICollectionViewCell {

    
    @IBOutlet weak var viewMarksBtn: UIButton!
    @IBOutlet weak var viewProgressBtn: UIButton!
    @IBOutlet weak var ExamLbl: UILabel!
    @IBOutlet weak var bgImgview: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
    var onViewMark : ( () -> Void)?
    var OnViewProgress : ( () -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellView.layer.cornerRadius = 10
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor.gray.cgColor
        
        viewMarksBtn.layer.cornerRadius = 10
        viewProgressBtn.layer.cornerRadius = 10
        
        viewMarksBtn.setTitle(ExamStringFile.viewMarks.translated(), for: .normal)
        viewProgressBtn.setTitle(ExamStringFile.viewProgress.translated(), for: .normal)
        
        ExamLbl.setFont(style: .title, size: FontSize.TitleSize)
        viewMarksBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
        viewProgressBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
    }
    
    
    @IBAction func viewMarksAct(_ sender: Any) {
        
        onViewMark?()
    }
    @IBAction func viewProgressAct(_ sender: Any) {
        
        OnViewProgress?()
    }
    
}
