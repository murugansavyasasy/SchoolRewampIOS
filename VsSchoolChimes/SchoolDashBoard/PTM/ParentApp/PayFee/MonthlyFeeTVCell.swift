//
//  MonthlyFeeTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 19/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class MonthlyFeeTVCell: UITableViewCell {
     @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var FeeNameLbl: UILabel!
    @IBOutlet weak var MonthlyFeeLbl: UILabel!
    @IBOutlet weak var TotalLbl: UILabel!
     @IBOutlet weak var PendingAmountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
          MainView.layer.borderWidth = 0.3
        MainView.layer.cornerRadius = 5
        MainView.clipsToBounds = true
        MainView.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
