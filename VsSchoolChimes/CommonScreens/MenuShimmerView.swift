//
//  MenuShimmerView.swift
//  VsSchoolChimes
//
//  Created by Admin on 03/02/25.
//

import Foundation
import UIKit

class MenuShimmerView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private var isShimmering = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShimmer()
    }
    
    private func setupShimmer() {
        // Configure shimmer gradient
        gradientLayer.colors = [
            UIColor.systemGray4.withAlphaComponent(0.6).cgColor,
            UIColor.systemGray5.withAlphaComponent(0.8).cgColor,
            UIColor.systemGray4.withAlphaComponent(0.6).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        layer.addSublayer(gradientLayer)
    }
    
    /// Start shimmer effect
    func startShimmer() {
        guard !isShimmering else { return } // Prevent multiple shimmer layers
        isShimmering = true
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }
    
    /// Stop shimmer effect
    func stopShimmer() {
        isShimmering = false
        gradientLayer.removeAllAnimations() // Stop animation
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

