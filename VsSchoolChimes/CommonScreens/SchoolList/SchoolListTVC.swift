//
//  SchoolListTVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 22/03/25.
//

import UIKit

class SchoolListTVC: UITableViewCell {

    @IBOutlet weak var arrowWidth: NSLayoutConstraint!
    @IBOutlet weak var selectBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var schoolRelignLangLbl: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        showPopUpEffect()
    }
    
    
    func showPopUpEffect() {
        contentView.transform = CGAffineTransform(
            scaleX: 0.8,
            y: 0.8
        ) // Start smaller
        contentView.alpha = 0 // Start invisible

        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.contentView.transform = CGAffineTransform.identity // Restore to original size
            self.contentView.alpha = 1 // Make it visible
        })
    }
}
