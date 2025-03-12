//
//  HolidayTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MacMini2 on 08/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class HolidayTVCell: UITableViewCell {
    @IBOutlet weak var HolidayDateLabel: UILabel!
    @IBOutlet weak var ReasonLabel: UILabel!
    @IBOutlet weak var FloatHolidayDateLabel: UILabel!
    @IBOutlet weak var FloatReasonLabel: UILabel!
    @IBOutlet weak var MainView: UIView!
    
    @IBOutlet weak var holidayNameLabel: UILabel!
    
    @IBOutlet weak var FloatHolidayNameLabel: UILabel!
    
    @IBOutlet weak var subViews: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        MainView.layer.cornerRadius = 5
        MainView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
