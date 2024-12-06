//
//  StudentChatTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 12/06/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StudentChatTVCell: UITableViewCell {
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var unreadImg: UIImageView!
    @IBOutlet weak var mainView: UIView!
        @IBOutlet weak var menuButton: UIButton!
        @IBOutlet weak var viewleftHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//    unreadImg.isHidden = true
        mainView.layer.masksToBounds = true
        mainView.layer.cornerRadius = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
