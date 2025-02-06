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

       override init(frame: CGRect) {
           super.init(frame: frame)
           setupShimmer()
       }

       required init?(coder: NSCoder) {
           super.init(coder: coder)
           setupShimmer()
       }

       private func setupShimmer() {
           // Set gradient colors to create shimmer effect
           gradientLayer.colors = [
               UIColor(white: 0.85, alpha: 1.0).cgColor,
               UIColor(white: 0.95, alpha: 1.0).cgColor,
               UIColor(white: 0.85, alpha: 1.0).cgColor
           ]
           gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
           gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
           gradientLayer.locations = [0.0, 0.5, 1.0]

           layer.addSublayer(gradientLayer)
       }

       override func layoutSubviews() {
           super.layoutSubviews()
           gradientLayer.frame = bounds
           startShimmering()
       }

       func startShimmering() {
           let animation = CABasicAnimation(keyPath: "locations")
           animation.fromValue = [-1.0, -0.5, 0.0]
           animation.toValue = [1.0, 1.5, 2.0]
           animation.duration = 1.5
           animation.repeatCount = .infinity
           gradientLayer.add(animation, forKey: "shimmerAnimation")
       }

       func stopShimmering() {
           gradientLayer.removeAnimation(forKey: "shimmerAnimation")
           self.isHidden = true
       }
   }

