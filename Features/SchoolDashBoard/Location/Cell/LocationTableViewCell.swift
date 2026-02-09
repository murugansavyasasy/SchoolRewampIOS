//
//  LocationTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by chandhru on 04/09/25.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var checkinLbl: UILabel!
    @IBOutlet weak var checkoutLbl: UILabel!
    @IBOutlet weak var hoursLbl: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var rollLable: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var namelbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        dateView.setShadow(cornerRadius: dateView.frame.width/2)
        statusBtn.layer.cornerRadius = 8
        statusBtn.clipsToBounds = true

    }


}
