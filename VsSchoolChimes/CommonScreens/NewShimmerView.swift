//
//  NewShimmerView.swift
//  VsSchoolChimes
//
//  Created by Lakshmanan on 01/04/25.
//

import Foundation
import UIKit

//MARK: Shimmer effect for UIView
class ShimmerView2: UIView {
    // Reference to the shimmer gradient layer.
    private var gradientLayer: CAGradientLayer?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShimmer()
    }

    // MARK: - Shimmer Setup

    private func setupShimmer() {
        // Configure the gradient layer for the shimmer effect.
        let shimmerGradient = CAGradientLayer()
        shimmerGradient.colors = [
            UIColor.systemGray4.withAlphaComponent(0.7).cgColor,
            UIColor.systemGray5.withAlphaComponent(1).cgColor,
            UIColor.systemGray4.withAlphaComponent(0.7).cgColor
        ]
        shimmerGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        shimmerGradient.endPoint   = CGPoint(x: 1.0, y: 0.5)
        // Begin offscreen: converting array of doubles to NSNumber.
        shimmerGradient.locations = [-1.0, -0.5, 0.0].map { NSNumber(value: $0) }

        // Insert the gradient layer at the bottom.
        layer.insertSublayer(shimmerGradient, at: 0)
        gradientLayer = shimmerGradient

        // Ensure clipping to maintain any rounded shape.
        layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the gradient covers the entire view.
        gradientLayer?.frame = bounds
        applyCustomMask()
    }

    /// Applies a mask that matches the view's rounded corners.
    private func applyCustomMask() {
        guard let gradient = gradientLayer else { return }
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        gradient.mask = maskLayer
    }

    // MARK: - Shimmer Animation

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            startShimmerAnimation()
        } else {
            stopShimmerAnimation()
        }
    }

    /// Begins the shimmer animation.
    private func startShimmerAnimation() {
        guard let gradient = gradientLayer else { return }
        let shimmerAnimation = CABasicAnimation(keyPath: "locations")
        shimmerAnimation.fromValue = [-1.0, -0.5, 0.0].map { NSNumber(value: $0) }
        shimmerAnimation.toValue   = [1.0, 1.5, 2.0].map { NSNumber(value: $0) }
        shimmerAnimation.duration  = 1.5
        shimmerAnimation.repeatCount = .infinity
        gradient.add(shimmerAnimation, forKey: "shimmer")
    }

    /// Stops the shimmer animation.
    private func stopShimmerAnimation() {
        gradientLayer?.removeAnimation(forKey: "shimmer")
    }

    /// Removes the shimmer effect; typically called once your data loads.
    func removeShimmer() {
        stopShimmerAnimation()
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
        layer.masksToBounds = false
    }
}
//MARK: Shimmer effect for UILabel
@IBDesignable
class ShimmerLabel: UILabel {
    
    // MARK: - Horizontal Properties
    
    /// If greater than 0, the shimmer view will use this fixed width.
    @IBInspectable var constantShimmerWidth: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    /// Leading inset for the shimmer view when constantShimmerWidth is 0.
    @IBInspectable var shimmerLeadingInset: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    /// Trailing inset for the shimmer view when constantShimmerWidth is 0.
    @IBInspectable var shimmerTrailingInset: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    // MARK: - Vertical Properties
    
    /// The constant height for the shimmer effect.
    /// This value is used if top and bottom insets are not provided.
    @IBInspectable var ShimmerHeight: CGFloat = 20.0 {
        didSet { setNeedsLayout() }
    }
    
    /// Top inset for the shimmer view.
    @IBInspectable var shimmerTopInset: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    /// Bottom inset for the shimmer view.
    @IBInspectable var shimmerBottomInset: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    // MARK: - Common Properties
    
    /// The corner radius for the shimmer layer.
    @IBInspectable var shimmerCornerRadius: CGFloat = 10.0 {
        didSet {
            gradientLayer.cornerRadius = shimmerCornerRadius
        }
    }
    
    /// The gradient layer that creates the shimmer effect.
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShimmer()
    }
    
    // MARK: - Setup
    
    private func setupShimmer() {
        // Optionally clear the text or set a background to denote loading.
        // If you want to hide text while loading, it is enough to stop its rendering.
       // backgroundColor = UIColor.lightGray.withAlphaComponent(0.9)
        
        // Configure the gradient layer with the shimmer appearance.
        gradientLayer.colors = [
            UIColor.systemGray4.withAlphaComponent(0.9).cgColor,
            UIColor.systemGray5.withAlphaComponent(1).cgColor,
            UIColor.systemGray4.withAlphaComponent(0.9).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        // Start with the gradient offscreen.
        gradientLayer.locations = [-1.0, -0.5, 0.0]
        gradientLayer.cornerRadius = shimmerCornerRadius
        
        // Ensure the gradient is drawn above the label’s background.
        gradientLayer.zPosition = 1
        
        // Add the gradient layer to the label.
        layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let totalWidth = bounds.width
        guard totalWidth > 0 else { return }
        
        // Determine horizontal frame.
        let shimmerWidth: CGFloat
        let xOrigin: CGFloat
        
        if constantShimmerWidth > 0 && constantShimmerWidth <= totalWidth {
            shimmerWidth = constantShimmerWidth
            xOrigin = (totalWidth - constantShimmerWidth) / 2
        } else {
            shimmerWidth = totalWidth - shimmerLeadingInset - shimmerTrailingInset
            guard shimmerWidth > 0 else { return }
            xOrigin = shimmerLeadingInset
        }
        
        // Determine vertical frame.
        let totalHeight = bounds.height
        let gradientHeight: CGFloat
        let yOrigin: CGFloat
        
        // If top/bottom insets are set, use them. Otherwise, center using ShimmerHeight.
        if shimmerTopInset + shimmerBottomInset > 0 {
            gradientHeight = totalHeight - shimmerTopInset - shimmerBottomInset
            guard gradientHeight > 0 else { return }
            yOrigin = shimmerTopInset
        } else {
            gradientHeight = ShimmerHeight
            yOrigin = (totalHeight - ShimmerHeight) / 2
        }
        
        gradientLayer.frame = CGRect(x: xOrigin, y: yOrigin, width: shimmerWidth, height: gradientHeight)
        gradientLayer.cornerRadius = shimmerCornerRadius
    }
    
    // MARK: - Shimmer Animation Management
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            startShimmerAnimation()
        } else {
            gradientLayer.removeAnimation(forKey: "shimmer")
        }
    }
    
    private func startShimmerAnimation() {
        // Prevent duplicate animations.
        if gradientLayer.animation(forKey: "shimmer") != nil { return }
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue   = [1.0, 1.5, 2.0]
        animation.duration  = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    /// Call this method once data has loaded, stopping the shimmer and restoring the default appearance.
    public func removeShimmer() {
        gradientLayer.removeAnimation(forKey: "shimmer")
        gradientLayer.removeFromSuperlayer()
        backgroundColor = .clear
        // Trigger a refresh so the text is shown.
        setNeedsDisplay()
    }
    
    // MARK: - Override Text Drawing
    
    /// Overriding drawText: prevents the label from drawing its text while the shimmer animation is active.
    override func drawText(in rect: CGRect) {
        // If shimmer animation is active, do not draw the actual text.
        if gradientLayer.animation(forKey: "shimmer") != nil {
            return
        }
        super.drawText(in: rect)
    }
}

//MARK: Shimmer effect for UIButton
class ShimmerButton: UIButton {
    // Reference to the shimmer gradient layer.
    private var gradientLayer: CAGradientLayer?
    // Store the original title so it can be restored later.
    private var storedTitle: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShimmer()
    }

    private func setupShimmer() {
        // Store the current title (if any) and hide it.
        storedTitle = title(for: .normal)
        titleLabel?.isHidden = true

        // Configure the gradient layer for the shimmer effect.
        let shimmerGradient = CAGradientLayer()
        shimmerGradient.colors = [
            UIColor.lightGray.withAlphaComponent(0.9).cgColor,
            UIColor.white.withAlphaComponent(0.6).cgColor,
            UIColor.lightGray.withAlphaComponent(0.9).cgColor
        ]
        shimmerGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        shimmerGradient.endPoint   = CGPoint(x: 1.0, y: 0.5)
        // Begin offscreen
        shimmerGradient.locations = [-1.0, -0.5, 0.0]

        // Insert the shimmer gradient below any button content.
        layer.insertSublayer(shimmerGradient, at: 0)
        gradientLayer = shimmerGradient

        // Clip sublayers to match the button’s shape.
        layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Make the gradient cover the entire button.
        gradientLayer?.frame = bounds
        
        // If you want the button itself to be circular (assuming square dimensions):
        layer.cornerRadius = bounds.width / 2.0
        applyCustomMask()
    }
    
    /// Applies a custom circular mask so that the gradient follows the button's round shape.
    private func applyCustomMask() {
        guard let gradient = gradientLayer else { return }
        let maskLayer = CAShapeLayer()
        // Creating a circular mask using an oval path in the button's bounds.
        maskLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        gradient.mask = maskLayer
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            startShimmerAnimation()
        } else {
            stopShimmerAnimation()
        }
    }

    /// Begins the shimmer animation.
    private func startShimmerAnimation() {
        guard let gradient = gradientLayer else { return }
        let shimmerAnimation = CABasicAnimation(keyPath: "locations")
        shimmerAnimation.fromValue = [-1.0, -0.5, 0.0]
        shimmerAnimation.toValue   = [1.0, 1.5, 2.0]
        shimmerAnimation.duration  = 1.5
        shimmerAnimation.repeatCount = .infinity
        gradient.add(shimmerAnimation, forKey: "shimmer")
    }

    /// Stops the shimmer animation.
    private func stopShimmerAnimation() {
        gradientLayer?.removeAnimation(forKey: "shimmer")
    }

    /// Call this method once your data loads to remove the shimmer overlay.
    /// The button then shows its original title and background.
    func removeShimmer() {
        // Stop any shimmer animation first...
        stopShimmerAnimation()
        // Completely remove the gradient layer.
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil

        // Unhide the title label and restore the original title.
        titleLabel?.isHidden = false
        setTitle(storedTitle, for: .normal)
    }
}
