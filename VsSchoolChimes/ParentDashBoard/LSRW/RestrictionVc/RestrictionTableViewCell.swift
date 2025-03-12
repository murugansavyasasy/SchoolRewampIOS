//
//  RestrictionTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/27/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class RestrictionTableViewCell: UITableViewCell {

    
    @IBOutlet weak var contentLbl: UILabel!
    
    @IBOutlet weak var agreeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
