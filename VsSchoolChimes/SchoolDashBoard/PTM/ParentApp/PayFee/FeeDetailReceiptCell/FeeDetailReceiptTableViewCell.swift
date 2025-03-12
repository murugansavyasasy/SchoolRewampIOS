//
//  FeeDetailReceiptTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by APPLE on 27/01/23.
//  Copyright © 2023 Shenll-Mac-04. All rights reserved.
//

import UIKit

class FeeDetailReceiptTableViewCell: UITableViewCell {

    @IBOutlet weak var InvoiceNumberLbl: UILabel!
    
    @IBOutlet weak var InvoiceDateLbl: UILabel!
    
    @IBOutlet weak var viewInvoice: UIView!
    @IBOutlet weak var InvoiceAmountLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
