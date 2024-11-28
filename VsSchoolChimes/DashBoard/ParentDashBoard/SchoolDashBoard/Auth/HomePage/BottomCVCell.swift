//
//  BottomCVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class BottomCVCell: UICollectionViewCell {

    @IBOutlet weak var MenuLabelview: ShimmerView!
    @IBOutlet weak var GradientView: ShimmerView!
    
    @IBOutlet weak var shimmersViewss: ShimmerView!
    
    
    @IBOutlet weak var MenuLbl: UILabel!
    @IBOutlet weak var MenuImgView: UIImageView!
    
    var image = UIImage()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
      
        
        GradientView.layer.cornerRadius = 12
    
        self.GradientView.animateView(enable: true)
//        self.MenuLabelview.animateView(enable: true)
       
      
//        contentView.layer.shadowColor = UIColor.black.cgColor
//        contentView.layer.shadowOpacity = 0.5
//        contentView.layer.shadowOffset = CGSize(width: 4, height: 4)
//        contentView.layer.shadowRadius = 3
//        contentView.layer.masksToBounds = false
        
        //MenuImgView.image = image
        GradientView.layer.cornerRadius = 10
        //applyGradient()
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        GradientView.animateView(enable: false)
//        MenuLabelview.animateView(enable: false)
        // Reset image and label to default values
        MenuImgView.image = nil // Or a placeholder image
        MenuLbl.text = "" // Or any default text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure the gradient layer is resized when the bounds of MenuImgView change
        if let gradientLayer = GradientView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            gradientLayer.frame = GradientView.bounds
        }
    }

//    func setImg(img : UIImage){
//        image = img
//        MenuImgView.image = img
//    }
    
    func applyGradient() {
        if let existingGradientLayer = GradientView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
              existingGradientLayer.removeFromSuperlayer()
          }

          // Create a new gradient layer
          let gradientLayer = CAGradientLayer()

          // Set the gradient layer's frame to the bounds of the UIImageView
          gradientLayer.frame = GradientView.bounds
          
          // Define the gradient colors (you can customize this)
        gradientLayer.colors = [UIColor.topBackgroundCLr.cgColor,UIColor.systemGreen.cgColor]
          
          // Optionally, define the gradient direction
        gradientLayer.startPoint = CGPoint(x: 0.8, y: 0.8)  // Top-left
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)    // Bottom-right

          // Insert the gradient layer behind the image
        GradientView.layer.insertSublayer(gradientLayer, at: 0)

          // Make sure the image is not hidden behind the gradient layer
        GradientView.layer.masksToBounds = true
    }


    

}
