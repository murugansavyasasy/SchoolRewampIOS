//
//  StudentMarkTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 15/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StudentMarkTVCell:  UITableViewCell {
    @IBOutlet weak var ExamTitleLbl: UILabel!
    @IBOutlet weak var ExamMarkLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
