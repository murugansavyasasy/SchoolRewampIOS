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
    
    @IBOutlet weak var shimmersViewss: CustomShimmerView!
    
    
    @IBOutlet weak var MenuLbl: UILabel!
    @IBOutlet weak var MenuImgView: UIImageView!
    
    var image = UIImage()
    
    override func awakeFromNib() {
            super.awakeFromNib()
            hiddenui(true)
            animationview()
            GradientView.layer.cornerRadius = Colornames.CORadius10
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            MenuImgView.image = nil
            MenuLbl.text = ""
        }
        
        func hiddenui(_ hide: Bool) {
            GradientView.isHidden = hide
            MenuLabelview.isHidden = hide
        }
        
        func animationview() {
            shimmersViewss.parentview.isHidden = false
            shimmersViewss.CustomShimmerView(enable: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [self] in
                shimmersViewss.CustomShimmerView(enable: false)
                shimmersViewss.parentview.isHidden = true
                hiddenui(false)
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if let gradientLayer = GradientView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
                gradientLayer.frame = GradientView.bounds
            }
        }
        
        func applyGradient(colours: [CGColor], xstart: Double, ystart: Double) {
            if let existingGradientLayer = GradientView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
                existingGradientLayer.removeFromSuperlayer()
            }
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = GradientView.bounds
            gradientLayer.colors = colours
            gradientLayer.startPoint = CGPoint(x: xstart, y: ystart)
            gradientLayer.endPoint = CGPoint(x: 0.9, y: 0.9)
            GradientView.layer.insertSublayer(gradientLayer, at: 0)
            GradientView.layer.masksToBounds = true
        }
    }

