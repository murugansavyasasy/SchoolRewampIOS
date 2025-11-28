//
//  PriorityStudentTVC.swift
//  School Chimes
//

import UIKit
import Kingfisher

class PriorityStudentTVC: UITableViewCell {
    
    @IBOutlet weak var Cellview: UIView!
    @IBOutlet weak var StudentImage: UIImageView!
    @IBOutlet weak var ClassLbl: UILabel!
    @IBOutlet weak var RollNo: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var bloodLbl: UILabel!
    @IBOutlet weak var SchoolNameLbl: UILabel!
    @IBOutlet weak var SchoolAdressLbl: UILabel!
    @IBOutlet weak var innerView: UIView!
    
    private var gradientLayer: CAGradientLayer?
    private var gradientColors: [CGColor] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Remove existing gradient layer and reapply
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = Cellview.bounds
        DispatchQueue.main.async {
//            self.applyGradient()
            self.applyGradientGlassEffect()
        }
    }
    
    private func setupUI() {
        Cellview.layer.cornerRadius = 12
        Cellview.clipsToBounds = true
        Cellview.setShadow()
        
        innerView.setShadow()
        StudentImage.layer.cornerRadius = StudentImage.frame.width / 2
        innerView.layer.cornerRadius = innerView.frame.width / 2
        innerView.layer.borderWidth = 1
        innerView.layer.borderColor = UIColor.systemIndigo.withAlphaComponent(0.5).cgColor
    }
    func setGradientColors(_ colors: [CGColor]) {
        gradientColors = colors
//        applyGradient()
        applyGradientGlassEffect()
    }
    func applyGradient() {
        guard gradientColors.isEmpty == false else { return }

        // Remove old gradients
        Cellview.layer.sublayers?.removeAll { $0 is CAGradientLayer }

        let gradientLayer = CAGradientLayer()

        gradientLayer.colors = gradientColors.compactMap {
            UIColor(cgColor: $0).withAlphaComponent(0.65).cgColor
        }

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = Cellview.bounds
        gradientLayer.cornerRadius = Cellview.layer.cornerRadius

        Cellview.layer.insertSublayer(gradientLayer, at: 0)

        Cellview.layer.masksToBounds = true
        Cellview.layer.borderWidth = 0.5
        Cellview.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        Cellview.layer.shadowColor = UIColor.black.cgColor
        Cellview.layer.shadowOpacity = 0.05
        Cellview.layer.shadowRadius = 4
        Cellview.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    func applyGradientGlassEffect() {
        Cellview.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        Cellview.subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = Cellview.bounds
        blurView.layer.cornerRadius = Cellview.layer.cornerRadius
        blurView.clipsToBounds = true
        Cellview.insertSubview(blurView, at: 0)
        guard gradientColors.isEmpty == false else { return }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map {
            UIColor(cgColor: $0).cgColor
        }

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = Cellview.bounds
        gradientLayer.cornerRadius = Cellview.layer.cornerRadius
        Cellview.layer.insertSublayer(gradientLayer, above: blurView.layer)
        Cellview.layer.borderWidth = 0.7
        Cellview.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        Cellview.layer.shadowColor = UIColor.black.cgColor
        Cellview.layer.shadowOpacity = 0.10
        Cellview.layer.shadowRadius = 6
        Cellview.layer.shadowOffset = CGSize(width: 0, height: 3)

        Cellview.layer.masksToBounds = false
    }
}

