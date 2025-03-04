//
//  TopCVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class TopCVCell: UICollectionViewCell {

    @IBOutlet weak var fullview: UIViewX!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let gradientLayer = CAGradientLayer()

        // Set the gradient layer's frame to the bounds of the UIImageView
        gradientLayer.frame = fullview.bounds
        
        // Define the gradient colors (you can customize this)
        gradientLayer.colors = [UIColor.white.cgColor,UIColor.priority.cgColor]
        
        // Optionally, define the gradient direction
      gradientLayer.startPoint = CGPoint(x: 0.4, y: 0.4)  // Top-left
      gradientLayer.endPoint = CGPoint(x: 0.9, y: 0.9)    // Bottom-right

        // Insert the gradient layer behind the image
        fullview.layer.insertSublayer(gradientLayer, at: 0)

        // Make sure the image is not hidden behind the gradient layer
        fullview.layer.masksToBounds = true
       
    }
}
