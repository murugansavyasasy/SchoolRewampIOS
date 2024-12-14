//
//  PaymentListTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 08/05/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class PaymentListTableViewCell: UITableViewCell {

    @IBOutlet weak var fullview: UIViewX!
    
    @IBOutlet weak var paymentmodeLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
