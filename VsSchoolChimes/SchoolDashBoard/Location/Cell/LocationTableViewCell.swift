//
//  LocationTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 29/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var presentStatus: UIStackView!
    @IBOutlet weak var opsentStus: UIStackView!
    @IBOutlet weak var prestType: UILabel!
    @IBOutlet weak var opsentType: UILabel!
    @IBOutlet weak var opsentLbl: UILabel!
    @IBOutlet weak var calanderView: UIView!
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var historyTimImage: UIImageView!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var statusView: UIViewX!
    @IBOutlet weak var StatusLbl: UILabel!
    @IBOutlet weak var workingHrsLbl: UILabel!
    @IBOutlet weak var attendanceTypeLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var mnthLbl: UILabel!
    @IBOutlet weak var firstInLbl: UILabel!
    @IBOutlet weak var namelbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        StatusLbl.layer.cornerRadius = 10
        StatusLbl.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner]
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
