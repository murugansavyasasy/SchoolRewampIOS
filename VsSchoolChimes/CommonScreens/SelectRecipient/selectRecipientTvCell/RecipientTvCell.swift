//
//  RecipientTvCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 21/11/24.
//

import UIKit

class RecipientTvCell: UITableViewCell {

   
    @IBOutlet weak var createdOnlbl: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var checkboxImg: UIImageView!
    
    @IBOutlet weak var outerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        showPopUpEffect()
    }
    
    
//    func showPopUpEffect() {
//        contentView.transform = CGAffineTransform(
//            scaleX: 0.8,
//            y: 0.8
//        ) // Start smaller
//        contentView.alpha = 0 // Start invisible
//
//        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
//            self.contentView.transform = CGAffineTransform.identity // Restore to original size
//            self.contentView.alpha = 1 // Make it visible
//        })
//    }
    
}
