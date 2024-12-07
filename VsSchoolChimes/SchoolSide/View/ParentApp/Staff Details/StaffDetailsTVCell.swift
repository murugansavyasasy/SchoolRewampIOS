//
//  StaffDetailsTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 14/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffDetailsTVCell: UITableViewCell {

    @IBOutlet weak var unreadCountLbl: UILabel!
    @IBOutlet weak var unReadCountView: UIView!
    @IBOutlet weak var StaffNameLabel: UILabel!
    @IBOutlet weak var SubjectfNameLabel: UILabel!
    @IBOutlet weak var FloatStaffNameLabel: UILabel!
    @IBOutlet weak var FloatSubjectfNameLabel: UILabel!
    @IBOutlet weak var interactButton: UIButton!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cellView.layer.cornerRadius = 5
        self.cellView.layer.masksToBounds = true
        interactButton.layer.cornerRadius = 5
        interactButton.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
