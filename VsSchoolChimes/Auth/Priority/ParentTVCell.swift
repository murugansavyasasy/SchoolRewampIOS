//
//  DemoTVCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 30/10/24.
//

import UIKit

class ParentTVCell: UITableViewCell {
    
    @IBOutlet weak var SchoolnameRegeion: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var REgisterNoLbl: UILabel!
    @IBOutlet weak var AddressLbl: UILabel!
    @IBOutlet weak var SchoolnameLbl: UILabel!
    @IBOutlet weak var StdSecLbl: UILabel!
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var SchoolInfoView: UIView!
    private var gradientLayer: CAGradientLayer?
    private var gradientColors: [CGColor] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellview.layer.cornerRadius = Colornames.CORadius10
        cellview.layer.masksToBounds = true
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        
        
        imgview.contentMode = .scaleAspectFill
        imgview.layer.cornerRadius =  imgview.frame.width/2
        imgview.layer.masksToBounds = true
        
        namelabel.setFont(style: .title, size: FontSize.TitleSize)
        REgisterNoLbl.setFont(style: .title, size: FontSize.TitleSize)
        AddressLbl.setFont(style: .body, size: FontSize.BodySize)
        SchoolnameLbl.setFont(style: .title, size: FontSize.TitleSize)
        SchoolnameRegeion.setFont(style: .title, size: FontSize.TitleSize)
        StdSecLbl.setFont(style: .body, size: FontSize.BodySize)
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
