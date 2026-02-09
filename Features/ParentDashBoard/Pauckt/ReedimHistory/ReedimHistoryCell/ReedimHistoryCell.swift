//
//  ReedimHistoryCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 24/02/25.
//  Copyright © 2025 Gayathri. All rights reserved.
//

import UIKit

class ReedimHistoryCell: UICollectionViewCell {
    @IBOutlet weak var BackgroundImage: UIImageView!
    @IBOutlet weak var ticketViews: UIView!
    @IBOutlet weak var BrandLogoImage: UIImageView!
    @IBOutlet weak var CouponStatusView: UIView!
    @IBOutlet weak var CouponStatusLbl: UILabel!
    @IBOutlet weak var BrandNameLbl: UILabel!
    @IBOutlet weak var OfferLbl: UILabel!
    @IBOutlet weak var ExpireyDateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        addScallopedEdge(to: ticketViews)
        CouponStatusView.isHidden = true
        CouponStatusLbl.setFont(style: .body, size: 15)
        BrandNameLbl.setFont(style: .body, size: 17)
        OfferLbl.setFont(style: .title, size: 20)
        ExpireyDateLbl.setFont(style: .body, size: 14)
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        addScallopedEdge(to: ticketViews)
        
        ticketViews.layer.cornerRadius = 12
        ticketViews.layer.shadowColor = UIColor.black.cgColor
        ticketViews.layer.shadowOpacity = 0.1
        ticketViews.layer.shadowOffset = CGSize(width: 0, height: 2)
        ticketViews.layer.shadowRadius = 4
    }
    
    // Function to create the ticket shape
    private func addScallopedEdge(to view: UIView) {
        let path = UIBezierPath()
        let scallopRadius: CGFloat = 10
        let scallopCount = 10
        let rect = view.bounds
        let scallopWidth = rect.width / CGFloat(scallopCount)
        
        // Start from the top left
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Top edge with scallops
        for i in 0..<scallopCount {
            let x = CGFloat(i) * scallopWidth + (scallopWidth / 2)
            path.addArc(withCenter: CGPoint(x: x, y: 0),
                        radius: scallopRadius,
                        startAngle: .pi,
                        endAngle: 0,
                        clockwise: true)
        }
        
        // Move to top-right corner
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        
        // Bottom edge (flat)
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        
        // Close the path
        path.close()
        
        // Apply shape
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.systemYellow.cgColor
        view.layer.mask = shapeLayer
    }
}



   

