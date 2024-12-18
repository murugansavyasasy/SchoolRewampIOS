//
//  DailyCollectionTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 16/03/23.
//  Copyright © Gayathri. All rights reserved.
//

import UIKit

class DailyCollectionTableViewCell: UITableViewCell {

    
    @IBOutlet weak var headingLbl: UILabel!
    
    
    @IBOutlet weak var amountLbl: UILabel!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
