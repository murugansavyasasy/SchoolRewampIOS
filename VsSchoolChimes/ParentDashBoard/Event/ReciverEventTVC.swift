//
//  ReciverEventTVC.swift
//  School Chimes
//
//  Created by Chandhru on 22/07/25.
//

import UIKit

class ReciverEventTVC: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var imgCount: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setBorderAndCornerRadius(for: imgCount,cornerRadius: img1.frame.width/2)
        setBorderAndCornerRadius(for: img1,cornerRadius: img1.frame.width/2)
        setBorderAndCornerRadius(for: img2,cornerRadius: img1.frame.width/2)
        setBorderAndCornerRadius(for: img3,cornerRadius: img1.frame.width/2)
        setBorderAndCornerRadius(for: selectBtn,cornerRadius: 8)
    }
    func setBorderAndCornerRadius(for view: UIView, cornerRadius: CGFloat = 8.0, borderWidth: CGFloat = 1.0, borderColor: UIColor = .lightGray) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.clipsToBounds = true
    }
}
