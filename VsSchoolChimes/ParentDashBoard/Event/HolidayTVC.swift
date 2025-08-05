//
//  HolidayTVC.swift
//  School Chimes
//
//  Created by Chandhru on 07/07/25.
//

import UIKit

class HolidayTVC: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var DateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = 10
//        cellView.layer.borderWidth = 0.3
//        cellView.layer.borderColor = UIColor.systemGray4.cgColor
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.2
        cellView.layer.shadowRadius = 0.2
        cellView.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        cellView.layer.masksToBounds = false
        colorBtn.layer.cornerRadius = colorBtn.frame.width/2
        nameLbl.setFont(style: .body, size: FontSize.TitleSize)
        DateLbl.setFont(style: .body, size: FontSize.BodySize)
        DateLbl.textColor = .black.withAlphaComponent(0.8)
    }

}
