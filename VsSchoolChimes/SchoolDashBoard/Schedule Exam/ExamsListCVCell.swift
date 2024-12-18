//
//  ExamsListCVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 17/12/24.
//

import UIKit

class ExamsListCVCell: UICollectionViewCell {

    @IBOutlet weak var deletBtn: UIButton!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var outerView: UIView!
    var examSchedul:[ExamsSchedule]?
    var scheduDelegate:ScheduleDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        subjectName.setFont(style: .body, size: FontSize.BodySize)
    }
    @IBAction func deleteBtn(_ sender: UIButton) {
        
        examSchedul?[sender.tag].date = ""
        examSchedul?[sender.tag].mark = ""
        examSchedul?[sender.tag].session = ""
        examSchedul?[sender.tag].subjectSyllabus = ""
        examSchedul?[sender.tag].isSelected = false
        scheduDelegate?.schedulSubject(ExamsSchedule:examSchedul!, delete: true)

    }
    
}
