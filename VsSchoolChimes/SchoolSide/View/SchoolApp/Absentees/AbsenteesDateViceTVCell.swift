//
//  AbsenteesDateViceTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 13/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AbsenteesDateViceTVCell: UITableViewCell {
    @IBOutlet weak var CountLabel: UILabel!
    @IBOutlet weak var Datelabel: UILabel!
    @IBOutlet weak var DayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        CountLabel.layer.cornerRadius = 5
        CountLabel.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }
    
}
