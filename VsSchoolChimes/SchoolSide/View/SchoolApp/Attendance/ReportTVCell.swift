//
//  ReportTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 04/10/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class ReportTVCell: UITableViewCell {

    @IBOutlet weak var notTakeLbl: UILabel!
    @IBOutlet weak var presentImageView: UIImageView!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var admisionLbl: UILabel!
    
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
