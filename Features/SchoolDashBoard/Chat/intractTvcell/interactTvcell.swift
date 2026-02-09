//
//  interactTvcell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 01/07/25.
//

import UIKit

class interactTvcell: UITableViewCell {

    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userBtn: UIButton!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var unReadCountBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var lastUpdateTimeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        unReadCountBtn.layer.cornerRadius = unReadCountBtn.frame.width/2
        innerView.layer.cornerRadius = 12
        userImg.layer.cornerRadius = userImg.frame.size.width/2
        userImg.layer.borderWidth = 2
        userImg.layer.borderColor = UIColor.blue.cgColor
        userImg.clipsToBounds = true
        innerView.layer.masksToBounds = true
        userBtn.backgroundColor = UIColor.blue.withAlphaComponent(0.6)
        userBtn.setShadow(cornerRadius: userBtn.frame.width/2)
    }
}
