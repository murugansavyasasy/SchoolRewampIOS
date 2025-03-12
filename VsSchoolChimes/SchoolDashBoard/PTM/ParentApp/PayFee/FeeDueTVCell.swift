//
//  FeeDueTVCell.swift
//  Sample RazorPay
//
//  Created by Preethi on 18/09/20.
//  Copyright © 2020 shenll. All rights reserved.
//

import UIKit

class FeeDueTVCell: UITableViewCell {
    
    // MARK:- UIView Deceleration
    @IBOutlet weak var cellView: UIView!
    // MARK:- UIButton Deceleration
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var radioButton: UIButton!
    
    // MARK:- UILabel Deceleration
    @IBOutlet weak var feeNameLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var anountLabel: UILabel!
    @IBOutlet weak var discountTitleLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    
    // MARK:- UIButton Deceleration
    @IBOutlet weak var radioButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        cellView.layer.borderWidth = 1
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
