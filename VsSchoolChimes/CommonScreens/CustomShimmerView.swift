//
//  CustomShimmerView.swift
//  VsSchoolChimes
//
//  Created by Admin on 04/02/25.
//

import UIKit

class CustomShimmerView: UIView {

    @IBOutlet weak var MenuIconView: UIView!
    
    @IBOutlet weak var MenuLabelView: UIView!
    
    private var gradientLayers: [CAGradientLayer] = []

        override func awakeFromNib() {
            super.awakeFromNib()
            setupShimmer(for: MenuIconView)
            setupShimmer(for: MenuLabelView)
        }

        private func setupShimmer(for view: UIView) {
            let gradientLayer = CAGradientLayer()
            
            // Define gradient colors for shimmer effect
            gradientLayer.colors = [
                UIColor.systemGray4.withAlphaComponent(0.6).cgColor,
                UIColor.systemGray5.withAlphaComponent(0.8).cgColor,
                UIColor.systemGray4.withAlphaComponent(0.6).cgColor
            ]
            
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.locations = [0.0, 0.5, 1.0]
            
            // Apply frame and mask it to the view's bounds
            gradientLayer.frame = view.bounds
            gradientLayer.cornerRadius = view.layer.cornerRadius
            view.layer.addSublayer(gradientLayer)
            
            gradientLayers.append(gradientLayer)
            startShimmerAnimation(for: gradientLayer)
        }

        private func startShimmerAnimation(for gradientLayer: CAGradientLayer) {
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-1.0, -0.5, 0.0]
            animation.toValue = [1.0, 1.5, 2.0]
            animation.duration = 1.5
            animation.repeatCount = .infinity
            gradientLayer.add(animation, forKey: "shimmerAnimation")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            for (index, layer) in gradientLayers.enumerated() {
                if let subview = [MenuIconView, MenuLabelView][index] {
                    layer.frame = subview.bounds
                }
            }
        }
    
}
