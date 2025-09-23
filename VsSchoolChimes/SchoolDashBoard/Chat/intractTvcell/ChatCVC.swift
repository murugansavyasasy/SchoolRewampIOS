//
//  ChatCVC.swift
//  School Chimes
//
//  Created by Chandhru on 23/09/25.
//

import UIKit

class ChatCVC: UICollectionViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var ounterView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var unReadCountBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var lastUpdateTimeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        unReadCountBtn.layer.cornerRadius = unReadCountBtn.frame.width/2
        ounterView.layer.cornerRadius = 12
        innerView.layer.cornerRadius = 12
        userImg.layer.cornerRadius = 12
        userImg.clipsToBounds = true
        innerView.layer.masksToBounds = true
//        innerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

}
