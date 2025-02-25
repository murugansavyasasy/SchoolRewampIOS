//
//  holidayCelsTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 05/07/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class holidayCelsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var HolidayDateLabel: UILabel!
 
    @IBOutlet weak var FloatHolidayDateLabel: UILabel!
  
  
    
   
    
    @IBOutlet weak var subViews: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
