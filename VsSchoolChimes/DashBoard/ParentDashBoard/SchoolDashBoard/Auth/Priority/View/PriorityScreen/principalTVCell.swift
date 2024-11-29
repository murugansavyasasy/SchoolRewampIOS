//
//  principalTVCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 30/10/24.
//

import UIKit

class principalTVCell: UITableViewCell {

    @IBOutlet weak var AddressLbl: UILabel!
    @IBOutlet weak var RoleLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var checkbox: CheckBox!
    @IBOutlet weak var SchoolNamelbl: UILabel!
    //    @IBOutlet weak var checkbox: UIImageView!
    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var imgview: UIImageView!
    
    private var gradientColors: [CGColor] = []
       
       override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
           cellview.layer.cornerRadius = Colornames.CORadius10
           //cellview.layer.masksToBounds = true
           cellview.layer.shadowColor = UIColor.white.cgColor
           cellview.layer.shadowOpacity = 0.5
           cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
           cellview.layer.shadowRadius = 3
           cellview.layer.masksToBounds = false
           
           imgview.layer.cornerRadius = Colornames.CORadius10
           
           checkbox.isChecked = false
           
           AddressLbl.setFont(style: .body, size: FontSize.BodySize)
           RoleLbl.setFont(style: .body, size: FontSize.BodySize)
           NameLbl.setFont(style: .body, size: FontSize.BodySize)
           SchoolNamelbl.setFont(style: .body, size: FontSize.BodySize)

           
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
       }
       
       // This method is called each time the cell is displayed or resized
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
           cellview.layer.sublayers?.removeAll { $0 is CAGradientLayer }
           
           // Create and configure the gradient layer
           let gradientLayer = CAGradientLayer()
           gradientLayer.colors = gradientColors
           gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.5)
           gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
           gradientLayer.frame = cellview.bounds
           gradientLayer.cornerRadius = cellview.layer.cornerRadius

           // Insert the gradient layer into the cell's view hierarchy
           cellview.layer.insertSublayer(gradientLayer, at: 0)
       }
    
   
}
