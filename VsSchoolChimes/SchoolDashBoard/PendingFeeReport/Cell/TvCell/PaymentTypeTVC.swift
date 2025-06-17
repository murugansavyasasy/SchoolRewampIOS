//
//  PaymentTypeTVC.swift
//  School Chimes
//
//  Created by Chandhru on 14/06/25.
//

import UIKit

class PaymentTypeTVC: UITableViewCell {

    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var inerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 4
        inerView.layer.cornerRadius = 4
        outerView.layer.masksToBounds = false
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.1
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 8
    }

}
