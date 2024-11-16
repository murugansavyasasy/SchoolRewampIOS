//
//  DemoTVCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 30/10/24.
//

import UIKit

class DemoTVCell: UITableViewCell {
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var cellview: UIView!
    
    @IBOutlet weak var SchoolInfoView: UIView!
    
    private var gradientLayer: CAGradientLayer?
    private var gradientColors: [CGColor] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellview.layer.cornerRadius = 10
        cellview.layer.masksToBounds = true
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        //cellview.layer.masksToBounds = false
        
        imgview.contentMode = .scaleAspectFill
        imgview.layer.cornerRadius =  imgview.frame.width/2
        imgview.layer.masksToBounds = true
        
        //namelabel.text?.append("Saranraj Shanmugammmmmmmmmm")

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
       // applyGradientIfNeeded()
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
