//
//  PendingFeeReportTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 22/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class PendingFeeReportTableViewCell: UITableViewCell {

    @IBOutlet weak var classLbl: UILabel!
    
    @IBOutlet weak var numberLbl: UILabel!
    
    @IBOutlet weak var amountLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
