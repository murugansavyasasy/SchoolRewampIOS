////
////  AnimatView.swift
////  VsSchoolChimes
////
////  Created by admin on 28/11/24.
////
//

import Foundation
import UIKit

class AnimatView: UIView {
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var OuterView: UIView!
    
    @IBOutlet weak var parentview: UIView!
    
    @IBOutlet weak var view3top: NSLayoutConstraint!
    @IBOutlet weak var view4top: NSLayoutConstraint!
    @IBOutlet weak var Vheight1: NSLayoutConstraint!
    @IBOutlet weak var Vheight2: NSLayoutConstraint!
    @IBOutlet weak var Vheight3: NSLayoutConstraint!
    @IBOutlet weak var Vheight4: NSLayoutConstraint!
    
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
        let nib = UINib(nibName: "AnimatView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    // MARK: - Shimmer Animation for Individual Views
    private func startShimmer(for view: UIView) {
        // Remove existing shimmer layer if any
        view.layer.sublayers?.forEach { layer in
            if layer.name == AnimatView.shimmerLayerIdentifier {
                layer.removeFromSuperlayer()
            }
        }
        
        // Create shimmer layer
        let shimmerLayer = CAGradientLayer()
        shimmerLayer.frame = view.bounds  // Make sure the shimmer layer matches the view's bounds
        shimmerLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        shimmerLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        shimmerLayer.colors = [colorA, colorB, colorA]
        shimmerLayer.locations = [0.0, 0.5, 1.0]
        shimmerLayer.name = AnimatView.shimmerLayerIdentifier
        
        view.layer.addSublayer(shimmerLayer)
        
        // Animate shimmer effect based on the current view height
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        
        shimmerLayer.add(animation, forKey: animation.keyPath)
    }
    
    private func stopShimmer(for view: UIView) {
        view.layer.sublayers?.forEach { layer in
            if layer.name == AnimatView.shimmerLayerIdentifier {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    func animateView(enable: Bool) {
        if enable {
            [view1, view2, view3, view4].forEach { startShimmer(for: $0) }
        } else {
            [view1, view2, view3, view4].forEach { stopShimmer(for: $0) }
        }
    }
    
    func changeHeightAndAnimate(_ vHeight1: CGFloat, _ vHeight2: CGFloat, _ vHeight3: CGFloat, _ vHeight4: CGFloat, top: CGFloat) {
        // Update the height constraints dynamically
        self.Vheight1.constant = vHeight1
        self.Vheight2.constant = vHeight2
        self.Vheight3.constant = vHeight3
        self.Vheight4.constant = vHeight4
        self.view3top.constant = top
        
        // Apply the changes immediately
        self.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            // Start shimmer effect on the views
            self.startShimmer(for: self.view1)
            self.startShimmer(for: self.view2)
            self.startShimmer(for: self.view3)
            self.startShimmer(for: self.view4)
        }
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
