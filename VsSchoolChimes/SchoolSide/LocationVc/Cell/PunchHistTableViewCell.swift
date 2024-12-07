//
//  PunchHistTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 24/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class PunchHistTableViewCell: UITableViewCell {

    @IBOutlet weak var punchType: UILabel!
    @IBOutlet weak var phoneModel: UILabel!
    @IBOutlet weak var timing: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
