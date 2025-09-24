//
//  FeedetailTVC.swift
//  School Chimes
//
//  Created by Chandhru on 24/05/25.
//

import UIKit
import WebKit

class FeedetailTVC: UITableViewCell {

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var document: GlowingImageView!
    @IBOutlet weak var invoceNo: UILabel!
    @IBOutlet weak var invoceDate: UILabel!
    @IBOutlet weak var invoceAmount: UILabel!
    @IBOutlet weak var dowloadBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()

        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3

    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
class GlowingImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 8
        layer.masksToBounds = false
    }
}
