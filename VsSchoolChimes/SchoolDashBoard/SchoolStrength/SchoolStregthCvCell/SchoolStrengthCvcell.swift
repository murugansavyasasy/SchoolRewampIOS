//
//  SchoolStrengthCvcell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 14/10/25.
//

import UIKit

class SchoolStrengthCvcell: UICollectionViewCell {

    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var girlCount: UILabel!
    @IBOutlet weak var lastYearLbl: UILabel!
    @IBOutlet weak var roles: UILabel!
    @IBOutlet weak var Icons: UIImageView!
    @IBOutlet weak var OverAllcountLbl: UILabel!
    @IBOutlet weak var fullview: UIView!
    private var gradientLayer: CAGradientLayer?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fullview.layer.cornerRadius = 12
        fullview.clipsToBounds = true
        fullview.setShadow()
//        fullview.layer.cornerRadius = 5
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Remove existing gradient layer and reapply
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = fullview.bounds
    }
    func applyGradient(with colors: [CGColor]) {
        // Remove any existing gradient layer
        gradientLayer?.removeFromSuperlayer()
        
        // Create new gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = fullview.bounds
        gradientLayer.cornerRadius = fullview.layer.cornerRadius
        gradientLayer.masksToBounds = true
        fullview.layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
        fullview.setNeedsLayout()
        fullview.layoutIfNeeded()
    }

    func updateProgress(absentees: String, total: String) {
        // String → Float convert
        let absentCount = Float(absentees) ?? 0
        let totalCount = Float(total) ?? 1  // avoid divide by zero
        
        let progressValue = absentCount / totalCount
        
        progressbar.setProgress(progressValue, animated: true)   // 0.0 to 1.0 range
        
        
        // Optional: progress color change
//        progress.progressTintColor =
//        progress.trackTintColor = .systemGreen
    }
}
