//
//  CustomShimmerView.swift
//  VsSchoolChimes
//
//  Created by Admin on 04/02/25.
//

import UIKit

class CustomShimmerView: UIView {
    
    
    @IBOutlet weak var view1: UIView!
        @IBOutlet weak var view2: UIView!
        @IBOutlet weak var OuterView: UIView!
        @IBOutlet weak var parentview: UIView!
        
        // MARK: - Shimmer Properties
        static let shimmerLayerIdentifier = "ShimmerEffectLayer"
        var colorA: CGColor = Colornames.shim1!.cgColor
        var colorB: CGColor = Colornames.shim2!.cgColor
        
        // MARK: - Initialization
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        private func commonInit() {
            guard let contentView = loadViewFromNib() else { return }
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(contentView)
        }
        
        private func loadViewFromNib() -> UIView? {
            let nib = UINib(nibName: "CustomShimmerView", bundle: nil)
            return nib.instantiate(withOwner: self, options: nil).first as? UIView
        }
        
        // MARK: - Shimmer Animation
        private func startShimmer(for view: UIView) {
            view.layer.sublayers?.forEach { layer in
                if layer.name == VsSchoolChimes.CustomShimmerView.shimmerLayerIdentifier {
                    layer.removeFromSuperlayer()
                }
            }
            
            let shimmerLayer = CAGradientLayer()
            shimmerLayer.frame = view.bounds
            shimmerLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            shimmerLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            shimmerLayer.colors = [colorA, colorB, colorA]
            shimmerLayer.locations = [0.0, 0.5, 1.0]
            shimmerLayer.name = VsSchoolChimes.CustomShimmerView.shimmerLayerIdentifier
            
            view.layer.addSublayer(shimmerLayer)
            
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-1.0, -0.5, 0.0]
            animation.toValue = [1.0, 1.5, 2.0]
            animation.repeatCount = .infinity
            animation.duration = 0.9
            
            shimmerLayer.add(animation, forKey: animation.keyPath)
        }
        
        private func stopShimmer(for view: UIView) {
            view.layer.sublayers?.forEach { layer in
                if layer.name == VsSchoolChimes.CustomShimmerView.shimmerLayerIdentifier {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        func CustomShimmerView(enable: Bool) {
            if enable {
                [view1, view2].forEach { startShimmer(for: $0) }
            } else {
                [view1, view2].forEach { stopShimmer(for: $0) }
            }
        }
        
        // MARK: - Lifecycle
        override func awakeFromNib() {
            super.awakeFromNib()
        }
    }
