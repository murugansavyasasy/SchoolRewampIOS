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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Remove existing gradient layer and reapply
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
        applyGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient layer frame to match Cellview's bounds
        gradientLayer?.frame = Cellview.bounds
        TopView.applyCustomCorners(topLeft: 0, topRight: 10, bottomLeft: 20, bottomRight: 0)
        BottomView.applyCustomCorners(topLeft: 0, topRight: 20, bottomLeft: 10, bottomRight: 0)
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
    
    private func applyGradient() {
        // Remove any existing gradient layer
        gradientLayer?.removeFromSuperlayer()
        
        // Create new gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hex: "#1E3A8A").cgColor, UIColor(hex: "#3B82F6").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = Cellview.bounds
        gradientLayer.cornerRadius = Cellview.layer.cornerRadius
        gradientLayer.masksToBounds = true
        
        // Insert gradient layer
        Cellview.layer.insertSublayer(gradientLayer, at: 0)
        
        // Store reference to the gradient layer
        self.gradientLayer = gradientLayer
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
