//
//  LsrwListShowTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/20/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class LsrwListShowTableViewCell: UITableViewCell {

    @IBOutlet weak var newLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    
    @IBOutlet weak var takingSkillHeight: NSLayoutConstraint!
    @IBOutlet weak var submittedHeadingLbl: UILabel!
    @IBOutlet weak var takingSkillView: UIView!
    @IBOutlet weak var takingSkillBtn: UIButton!
    @IBOutlet weak var sentByLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var submittedOnLbl: UILabel!
    @IBOutlet weak var subLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
