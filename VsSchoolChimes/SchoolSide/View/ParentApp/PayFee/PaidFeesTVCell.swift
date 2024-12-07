//
//  PaidFeesTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 09/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class PaidFeesTVCell: UITableViewCell {
    @IBOutlet weak var MainView: UIView!
    
    @IBOutlet weak var CreatedOnLbl: UILabel!
    @IBOutlet weak var TotalPaidLbl: UILabel!
    @IBOutlet weak var PaymentTypeLbl: UILabel!
    @IBOutlet weak var LateFeeLbl: UILabel!
    @IBOutlet weak var PaymentSuccessLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
          MainView.layer.borderWidth = 0.3
        MainView.layer.cornerRadius = 5
        MainView.clipsToBounds = true
        MainView.layer.borderColor = UIColor.lightGray.cgColor
        
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
