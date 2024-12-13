//
//  AttendanceTVCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 02/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AttendanceTVCell: UITableViewCell {

    
    @IBOutlet weak var AbsentLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var DayLbl: UILabel!
    
    @IBOutlet weak var MainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        AbsentLbl.layer.cornerRadius = 5
        AbsentLbl.clipsToBounds = true
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
