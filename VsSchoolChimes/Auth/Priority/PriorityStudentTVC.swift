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
            self.applyGradient()
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
        applyGradient()
    }
    func applyGradient() {
        guard gradientColors.isEmpty == false else { return }
        Cellview.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        // Create new gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = Cellview.bounds
        gradientLayer.cornerRadius = Cellview.layer.cornerRadius
        gradientLayer.masksToBounds = true
        Cellview.layer.insertSublayer(gradientLayer, at: 0)
    }
}

