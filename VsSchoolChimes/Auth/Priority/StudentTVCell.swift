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
    @IBOutlet weak var SchoolNameLbl: UILabel!
    @IBOutlet weak var SchoolAdressLbl: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var RegionalSchoolName: UILabel!
    @IBOutlet weak var AcademicYearLbl: UILabel!
    
    private var gradientColors: [CGColor] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Cellview.layer.cornerRadius = Colornames.CORadius10
        Cellview.layer.shadowColor = UIColor.black.cgColor
        Cellview.layer.shadowOpacity = 0.3
        Cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        Cellview.layer.shadowRadius = 2
        Cellview.layer.borderWidth = 0.5
        Cellview.layer.borderColor = UIColor.systemGray.cgColor
        Cellview.layer.masksToBounds = false
        
        TopView.layer.cornerRadius = 10
        TopView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        BottomView.layer.cornerRadius = 10
        BottomView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        
        
        SchoolLogo.layer.cornerRadius = SchoolLogo.frame.width / 2
        StudentImage.layer.cornerRadius = 5
        
        TopView.backgroundColor = .systemIndigo.withAlphaComponent(0.4)
        BottomView.backgroundColor = .systemIndigo.withAlphaComponent(0.4)
        
        SchoolLogo.layer.borderWidth = 1
        SchoolLogo.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        RollNo.setFont(style: .body, size: FontSize.BodySize)
        ClassLbl.setFont(style: .body, size: FontSize.BodySize)
        SchoolNameLbl.setFont(style: .title, size: FontSize.TitleSize)
        SchoolAdressLbl.setFont(style: .body, size: FontSize.BodySize)
        RegionalSchoolName.setFont(style: .body, size: FontSize.BodySize)
        AcademicYearLbl.setFont(style: .body, size: FontSize.BodySize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.applyGradientIfNeeded()
        }
        
    }
    
    func setGradientColors(_ colors: [CGColor]) {
        // Store the colors so we can use them in layoutSubviews
        gradientColors = colors
        applyGradientIfNeeded() // Ensure the gradient is applied immediately as well
    }
    
    private func applyGradientIfNeeded() {
        // Check if we already have the same gradient applied
        guard gradientColors.isEmpty == false else { return }
        
        // Remove existing gradient layers if any
        TopView.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        // Create and configure the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = TopView.bounds
        gradientLayer.cornerRadius = TopView.layer.cornerRadius
        
        // Insert the gradient layer into the cell's view hierarchy
        TopView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
