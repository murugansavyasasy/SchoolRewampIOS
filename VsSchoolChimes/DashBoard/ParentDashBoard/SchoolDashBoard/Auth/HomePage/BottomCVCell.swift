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
    
    var image = UIImage()
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
        
        //MenuImgView.image = image
    }
    override func prepareForReuse() {
        super.prepareForReuse()
       shimmersViewss.animateView(enable: false)
        // Reset image and label to default values
        MenuImgView.image = nil // Or a placeholder image
        MenuLbl.text = "" // Or any default text
    }
//    func setImg(img : UIImage){
//        image = img
//        MenuImgView.image = img
//    }
    
    

}
