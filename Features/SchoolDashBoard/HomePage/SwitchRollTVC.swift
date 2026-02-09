//
//  SwitchRollTVC.swift
//  School Chimes
//
//  Created by Chandhru on 17/09/25.
//

import UIKit

class SwitchRollTVC: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var selectIconBtn: UIButton!
    @IBOutlet weak var schoolLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImg.layer.cornerRadius = profileImg.frame.width/2
        profileImg.layer.borderColor = UIColor.systemGray5.cgColor
        profileImg.layer.borderWidth = 1
        outerView.layer.cornerRadius = 10
        outerView.layer.borderColor = UIColor.systemGray5.cgColor
        outerView.layer.borderWidth = 1
    }

}
