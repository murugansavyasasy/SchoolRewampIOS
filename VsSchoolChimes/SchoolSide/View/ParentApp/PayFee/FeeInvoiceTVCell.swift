//
//  FeeInvoiceTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 19/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class FeeInvoiceTVCell: UITableViewCell {
     @IBOutlet weak var SNoLbl: UILabel!
     @IBOutlet weak var FeeNameLbl: UILabel!
     @IBOutlet weak var PaymentLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        SNoLbl.layer.borderWidth = 0.5
        SNoLbl.layer.cornerRadius = 2
        SNoLbl.layer.borderColor = UIColor.black.cgColor
        
        FeeNameLbl.layer.borderWidth = 0.5
        FeeNameLbl.layer.cornerRadius = 2
        FeeNameLbl.layer.borderColor = UIColor.black.cgColor
        
        PaymentLbl.layer.borderWidth = 0.5
        PaymentLbl.layer.cornerRadius = 2
        PaymentLbl.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
