//
//  BottomCVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class BottomCVCell: UICollectionViewCell {

    @IBOutlet weak var shimmersViewss: ShimmerView!
    
    
    @IBOutlet weak var MenuLbl: UILabel!
    @IBOutlet weak var MenuImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
      
        
        shimmersViewss.layer.cornerRadius = 12
    
        self.shimmersViewss.animateView(enable: true)
       
      
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 4, height: 4)
        contentView.layer.shadowRadius = 3
        contentView.layer.masksToBounds = false
    }

}
