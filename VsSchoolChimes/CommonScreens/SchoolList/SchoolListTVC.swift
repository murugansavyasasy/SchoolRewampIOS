//
//  SchoolListTVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 22/03/25.
//

import UIKit
import SDWebImage
class SchoolListTVC: UITableViewCell {

    @IBOutlet weak var SchoolImgView: UIImageView!
    @IBOutlet weak var outlinView: UIView!
    @IBOutlet weak var schoolIconBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
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
        outerView.layer.cornerRadius = 8
        outlinView.setShadow(cornerRadius: 10)
        schoolIconBtn.setShadow(cornerRadius: schoolIconBtn.frame.width/2)
    }
 
    func showPopUpEffect() {
        // Ensure the cell remains interactive
        contentView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        
        // Start with a smaller scale and invisible
        contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        contentView.alpha = 0
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
            self.contentView.transform = CGAffineTransform.identity // Restore to original size
            self.contentView.alpha = 1 // Make it visible
        }, completion: nil)
    }
}
