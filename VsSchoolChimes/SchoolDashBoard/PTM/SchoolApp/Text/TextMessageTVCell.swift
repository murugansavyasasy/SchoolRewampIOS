//
//  TextMessageTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 17/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class TextMessageTVCell: UITableViewCell {

    @IBOutlet weak var unreadCountLbl: UILabel!
    @IBOutlet weak var unreadCountView: UIView!
    @IBOutlet weak var schoolNameTop: NSLayoutConstraint!
    @IBOutlet weak var SchoolNameRegionalLbl: UILabel!
    
    @IBOutlet weak var SchoolNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
//        unreadCountView.isHidden  = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
