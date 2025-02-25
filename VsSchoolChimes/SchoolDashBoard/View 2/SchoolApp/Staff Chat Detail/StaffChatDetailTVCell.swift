//
//  StaffChatDetailTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 12/06/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffChatDetailTVCell: UITableViewCell {
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var topView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
