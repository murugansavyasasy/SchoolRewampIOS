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
        
        // Date circle view (purple gradient or solid color with rounded edges)
        dateView.layer.cornerRadius = dateView.frame.height / 2
        dateView.clipsToBounds = true
        dateView.backgroundColor = UIColor.systemPurple
        
        dayLbl.textColor = .white
        dateLbl.textColor = .white
        
        // Name label
        namelbl.font = UIFont.boldSystemFont(ofSize: 16)
        namelbl.textColor = .black
        
        // Role label
        rollLable.font = UIFont.systemFont(ofSize: 14)
        rollLable.textColor = .darkGray
        
        // Status button (Absent → Red background)
        statusBtn.layer.cornerRadius = 8
        statusBtn.clipsToBounds = true
        statusBtn.setTitleColor(.systemRed, for: .normal)
        statusBtn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
        statusBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        
        // Check-in & Check-out labels
        checkinLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        checkoutLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        checkinLbl.textColor = UIColor.systemBlue
        checkoutLbl.textColor = UIColor.systemGreen
        
        // Hours label
        hoursLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        hoursLbl.textColor = UIColor.systemGreen
        
        // Card style
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 6
    }


}
