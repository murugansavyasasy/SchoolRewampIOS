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
    
    @IBOutlet weak var shimmersViewss: AnimatView!
    
    
    @IBOutlet weak var MenuLbl: UILabel!
    @IBOutlet weak var MenuImgView: UIImageView!
    
    var image = UIImage()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        hiddenui(true)
        animationview()
        
        GradientView.layer.cornerRadius = 12
        GradientView.layer.cornerRadius = Colornames.CORadius10
        //applyGradient()
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
//        GradientView.animateView(enable: false)
//        MenuLabelview.animateView(enable: false)
        // Reset image and label to default values
        MenuImgView.image = nil // Or a placeholder image
        MenuLbl.text = "" // Or any default text
    }
    
    func hiddenui(_ hide:Bool){
        shimmersViewss.changeHeightAndAnimate(0, 50, 20, 0, top: 5)
        GradientView.isHidden = hide
        MenuLabelview.isHidden = hide
    }
    func animationview(){
        shimmersViewss.parentview.isHidden = false
        shimmersViewss.animateView(enable:true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [self] in
            // Code to execute after delay
            self.shimmersViewss.animateView(enable:false)
            shimmersViewss.parentview.isHidden = true
            hiddenui(false)
        }
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the gradient layer is resized when the bounds of MenuImgView change
//        hiddenui(true)
//        animationview()
        if let gradientLayer = GradientView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            gradientLayer.frame = GradientView.bounds
        }
    }

//    func setImg(img : UIImage){
//        image = img
//        MenuImgView.image = img
//    }
    
    func applyGradient(colours: [CGColor],xstart:Double,ystart:Double) {
        if let existingGradientLayer = GradientView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
              existingGradientLayer.removeFromSuperlayer()
          }

          // Create a new gradient layer
          let gradientLayer = CAGradientLayer()

          // Set the gradient layer's frame to the bounds of the UIImageView
          gradientLayer.frame = GradientView.bounds
          
          // Define the gradient colors (you can customize this)
        gradientLayer.colors = colours //[UIColor.parentClr.cgColor,UIColor.priority.cgColor]
          
          // Optionally, define the gradient direction
        gradientLayer.startPoint = CGPoint(x: xstart, y: ystart)  // Top-left
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 0.9)    // Bottom-right

          // Insert the gradient layer behind the image
        GradientView.layer.insertSublayer(gradientLayer, at: 0)

          // Make sure the image is not hidden behind the gradient layer
        GradientView.layer.masksToBounds = true
    }


    

}
