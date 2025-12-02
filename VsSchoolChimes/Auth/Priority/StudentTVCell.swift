//
//  StudentTVCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 28/04/25.
//

import UIKit

class StudentTVCell: UITableViewCell {
    
    @IBOutlet weak var Cellview: UIView!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var SchoolLogo: UIImageView!
    @IBOutlet weak var StudentImage: UIImageView!
    @IBOutlet weak var ClassLbl: UILabel!
    @IBOutlet weak var RollNo: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var bloodLbl: UILabel!
    @IBOutlet weak var SchoolNameLbl: UILabel!
    @IBOutlet weak var SchoolAdressLbl: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var AcademicYearLbl: UILabel!
    
    @IBOutlet weak var innerView: UIView!
    
    private var gradientLayer: CAGradientLayer?
    private var blurView: UIVisualEffectView?
    private var gradientColors: [CGColor] = []
    private var TopbotomgradientColors: [CGColor] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = Cellview.bounds
        DispatchQueue.main.async {
            self.applyGradientWithGlassEffect()
            self.TopView.applyCustomCorners(topLeft: 0, topRight: 10, bottomLeft: 20, bottomRight: 0)
            self.BottomView.applyCustomCorners(topLeft: 0, topRight: 20, bottomLeft: 10, bottomRight: 0)
            self.applyViewGradient(
                view: self.TopView,
                colors: self.TopbotomgradientColors
                )
            self.applyViewGradient(
                view: self.BottomView,
                colors: self.TopbotomgradientColors
                )
        }
    }
    
    private func setupUI() {
        innerView.layer.cornerRadius = 20
        innerView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        innerView.layer.masksToBounds = true
        Cellview.setShadow()
        
        SchoolLogo.layer.cornerRadius = SchoolLogo.frame.width / 2
        SchoolLogo.layer.borderWidth = 1
        SchoolLogo.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        
        StudentImage.layer.cornerRadius = 10
        StudentImage.layer.borderWidth = 1
        StudentImage.layer.borderColor = UIColor.systemIndigo.withAlphaComponent(0.5).cgColor
    }
    
    func applyViewGradient(view: UIView, colors: [CGColor]) {

        // Remove old gradients
        view.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        // Remove old blur
        view.subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = view.layer.cornerRadius

        // Light blur
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.clipsToBounds = true
        blurView.alpha = 0.25

        view.insertSubview(blurView, at: 0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    func setGradientColors(_ colors: [CGColor], topColors: [CGColor]) {
        gradientColors = colors
        TopbotomgradientColors = topColors
        applyGradientWithGlassEffect()
    }

    private func applyGradientWithGlassEffect() {
        // Remove previous layers
        gradientLayer?.removeFromSuperlayer()
        blurView?.removeFromSuperview()

        guard !gradientColors.isEmpty else { return }
        let newGradientLayer = CAGradientLayer()
        let finalColors: [CGColor]
        if !TopbotomgradientColors.isEmpty {
            finalColors = TopbotomgradientColors
        } else {
            finalColors = gradientColors
        }

        newGradientLayer.colors = finalColors.map {
            UIColor(cgColor: $0).withAlphaComponent(0.85).cgColor
        }
        newGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        newGradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)

        newGradientLayer.frame = Cellview.bounds
        newGradientLayer.cornerRadius = Cellview.layer.cornerRadius
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let newBlurView = UIVisualEffectView(effect: blurEffect)
        newBlurView.frame = Cellview.bounds
        newBlurView.layer.cornerRadius = Cellview.layer.cornerRadius
        newBlurView.clipsToBounds = true
        newBlurView.alpha = 0.3
        Cellview.insertSubview(newBlurView, at: 0)
        Cellview.layer.insertSublayer(newGradientLayer, at: 0)

        gradientLayer = newGradientLayer
        blurView = newBlurView
        Cellview.layer.borderWidth = 1
        Cellview.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    }

}

// Extension for custom corner radius and shadow
extension UIView {
    func applyCustomCorners(topLeft: CGFloat,
                           topRight: CGFloat,
                           bottomLeft: CGFloat,
                           bottomRight: CGFloat) {
        let path = UIBezierPath()
        let bounds = self.bounds
        
        path.move(to: CGPoint(x: bounds.minX + topLeft, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX - topRight, y: bounds.minY))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - topRight, y: bounds.minY + topRight),
                    radius: topRight,
                    startAngle: CGFloat(3 * Double.pi / 2),
                    endAngle: 0,
                    clockwise: true)
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - bottomRight))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - bottomRight, y: bounds.maxY - bottomRight),
                    radius: bottomRight,
                    startAngle: 0,
                    endAngle: CGFloat(Double.pi / 2),
                    clockwise: true)
        path.addLine(to: CGPoint(x: bounds.minX + bottomLeft, y: bounds.maxY))
        if bottomLeft > 0 {
            path.addArc(withCenter: CGPoint(x: bounds.minX + bottomLeft, y: bounds.maxY - bottomLeft),
                        radius: bottomLeft,
                        startAngle: CGFloat(Double.pi / 2),
                        endAngle: CGFloat(Double.pi),
                        clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        }
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + topLeft))
        if topLeft > 0 {
            path.addArc(withCenter: CGPoint(x: bounds.minX + topLeft, y: bounds.minY + topLeft),
                        radius: topLeft,
                        startAngle: CGFloat(Double.pi),
                        endAngle: CGFloat(3 * Double.pi / 2),
                        clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
        }
        
        path.close()
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
