//
//  SectionTvTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 29/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class SectionTvTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mobileNumHeight: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var mobileNumberLbl: UILabel!
    
    @IBOutlet weak var AddmisionLbl: UILabel!
    @IBOutlet weak var SectionLbl: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mobileNumHeight.constant = 0
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        
    }
    
}
