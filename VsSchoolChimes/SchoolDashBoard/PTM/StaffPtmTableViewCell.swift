//
//  StaffPtmTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 14/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
protocol ShowPopupDelegate{
    func showPopup(sender:UIButton)
}
class StaffPtmTableViewCell: UITableViewCell {

    @IBOutlet weak var statusview: UIViewX!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var cancelView: UIViewX!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var slotBtn: UIButton!
    @IBOutlet weak var MeetingModeBtn: UIButton!
    @IBOutlet weak var takeMeetingBtn: UIButton!
    @IBOutlet weak var cancelAndReponeView: UIViewX!
    @IBOutlet weak var classSectionLbl: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var backView: UIView!
    
    var showpopup:ShowPopupDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        takeMeetingBtn.layer.cornerRadius = 8
        takeMeetingBtn.layer.backgroundColor = UIColor.systemBlue.cgColor
        if let image = UIImage(systemName: "video") {
            let resizedImage = image.resizeTo(size: CGSize(width: 15, height: 12)) // Adjust size as needed
            MeetingModeBtn.setImage(resizedImage, for: .normal)
            MeetingModeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func showPopup(_ sender: UIButton) {
        showpopup?.showPopup(sender: sender)
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
class customView:UIView{
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.backgroundColor = .systemGray6
    }
}

extension UIImage {
    func resizeTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
