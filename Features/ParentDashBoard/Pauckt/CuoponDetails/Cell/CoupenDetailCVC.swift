//
//  CoupenDetailCVC.swift
//  rewardDesign
//
//  Created by admin on 19/02/25.
//

import UIKit

class CoupenDetailCVC: UICollectionViewCell {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var valid_tillLbl : UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var DiscountLbl: UILabel!
    @IBOutlet weak var productNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 20
    }

}
