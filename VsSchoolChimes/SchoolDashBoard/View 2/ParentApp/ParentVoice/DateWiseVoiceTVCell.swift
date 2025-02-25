//
//  DateWiseVoiceTVCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 02/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class DateWiseVoiceTVCell: UITableViewCell {

    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var DayLbl: UILabel!
    @IBOutlet weak var UnreadCountLbl: UILabel!
    @IBOutlet weak var MainView: UIView!
    
    @IBOutlet weak var seemoreBtn: UIButton!
    let utilObj = UtilClass()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        MainView.layer.cornerRadius = 2
        MainView.clipsToBounds = true
        UnreadCountLbl.layer.cornerRadius = 5
        UnreadCountLbl.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
