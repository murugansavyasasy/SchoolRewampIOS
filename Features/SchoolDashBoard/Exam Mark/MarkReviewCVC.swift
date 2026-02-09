//
//  MarkReviewCVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/12/25.
//

import UIKit

class MarkReviewCVC: UICollectionViewCell {
    
    @IBOutlet weak var maxMarkLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configure(title: String, subtitle: String = "",max_Mark:String) {
        headerLbl.text = title
        maxMarkLbl.text = max_Mark
        subjectLbl.text = subtitle
        subjectLbl.isHidden = subtitle.isEmpty
    }
}
