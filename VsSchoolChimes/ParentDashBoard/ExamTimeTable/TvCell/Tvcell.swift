//
//  Tvcell.swift
//  VsSchoolChimes
//
//  Created by admin on 23/11/24.
//

import UIKit

class Tvcell: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var syllabusBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var markBtn: UIButton!
    @IBOutlet weak var syllabusLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var subjectTitleLbl: UILabel!
    @IBOutlet weak var fullView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        fullView.layer.shadowColor = UIColor.black.cgColor
        fullView.layer.shadowOpacity = 0.5
        fullView.layer.shadowOffset = CGSize(width: 4, height: 4)
        fullView.layer.shadowRadius = 3
        fullView.layer.masksToBounds = false
        setCornerRadius(for: fullView, radius: Colornames.CORadius10)
        setCornerRadius(for: fullView, radius: Colornames.CORadius10)
        setCornerRadius(for: outerView, radius: Colornames.CORadius10)
        markBtn.layer.cornerRadius = Colornames.CORadius10
        syllabusBtn.layer.cornerRadius = 4
        dateBtn.layer.cornerRadius = 4
        fullView.layer.borderWidth = 1
        fullView.layer.borderColor = UIColor.lightGray.cgColor
    }
    func setCornerRadius(for view: UIView, radius: CGFloat) {
        view.layer.cornerRadius = radius
//        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.clipsToBounds = true
    }
    
}
