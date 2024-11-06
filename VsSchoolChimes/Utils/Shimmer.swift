//
//  Shimmer.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import Foundation
import UIKit
class ShimmerView: UIView {

    

    static let shimmerLayerIdentifier  = "ShimmerEffectLayer"



    var colorA : CGColor = Colornames.shim1!.cgColor

    var colorB : CGColor = Colornames.shim2!.cgColor

    

    func startAnimating() {

        

        let shimmerLayer = CAGradientLayer()

        

        shimmerLayer.frame = self.bounds

        shimmerLayer.startPoint = CGPoint(x: 0.0, y: 1.0)

        shimmerLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        shimmerLayer.colors = [colorA, colorB, colorA]

        shimmerLayer.locations = [0.0, 0.5, 1.0]

        shimmerLayer.name = ShimmerView.shimmerLayerIdentifier

        self.layer.addSublayer(shimmerLayer)

        

        let animation = CABasicAnimation(keyPath: "locations")

        animation.fromValue = [-1.0, -0.5, 0.0]

        animation.toValue = [1.0, 1.5, 2.0]

        animation.repeatCount = .infinity

        animation.duration = 0.9

       

        shimmerLayer.add(animation, forKey: animation.keyPath)

    }

    

    func stopAnimating() {

        self.layer.sublayers?.forEach({ layer in

            if layer.name == ShimmerView.shimmerLayerIdentifier {

                layer.removeFromSuperlayer()

            }

        })

    }

    

    func animateView(enable:Bool){

        if enable {

            self.startAnimating()

        }else {

            self.stopAnimating()

        }

    }



}
