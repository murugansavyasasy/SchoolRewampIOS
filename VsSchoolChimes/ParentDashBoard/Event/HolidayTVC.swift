//
//  HolidayTVC.swift
//  School Chimes
//
//  Created by Chandhru on 07/07/25.
//

import UIKit

class HolidayTVC: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var colorBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorBtn.layer.cornerRadius = colorBtn.frame.width/2
        nameLbl.setFont(style: .body, size: FontSize.BodySize)
    }

}
