//
//  StaffPtmTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 14/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class StaffPtmTableViewCell: UITableViewCell {

    @IBOutlet weak var statusview: UIViewX!
    @IBOutlet weak var cancelHeight: NSLayoutConstraint!
    @IBOutlet weak var zoomLbl: UILabel!
    @IBOutlet weak var yourMeetingLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var cancelView: UIViewX!
    @IBOutlet weak var eventLink: UILabel!
    
    @IBOutlet weak var cancelReopenHeight: NSLayoutConstraint!
  
    @IBOutlet weak var cancelAndReponeView: UIViewX!
    @IBOutlet weak var dateAndTimeLbl: UILabel!
    @IBOutlet weak var classSectionLbl: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var backView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        

              
              // Add circular cutouts
//              addCircularCutout(position: .left, to: backView)
//              addCircularCutout(position: .right, to: backView)
    }
    
    enum CutoutPosition {
        case left
        case right
    }
    
    private func addCircularCutout(position: CutoutPosition, to view: UIView) {
        let cutoutView = UIView()
        cutoutView.backgroundColor = .clear
        cutoutView.translatesAutoresizingMaskIntoConstraints = false
        
        let cutoutLayer = CALayer()
        cutoutLayer.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        cutoutLayer.cornerRadius = 15
        cutoutLayer.backgroundColor = UIColor.white.cgColor
        cutoutView.layer.addSublayer(cutoutLayer)
        
        view.addSubview(cutoutView)
        
        let horizontalConstraint: NSLayoutConstraint
        switch position {
        case .left:
            horizontalConstraint = cutoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -15)
        case .right:
            horizontalConstraint = cutoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 15)
        }
        
        NSLayoutConstraint.activate([
            horizontalConstraint,
            cutoutView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cutoutView.widthAnchor.constraint(equalToConstant: 30),
            cutoutView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
}
extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
