//
//  AttendenceReportTVCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 16/12/24.
//

import UIKit

class AttendenceReportTVCell: UITableViewCell {

    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var AdmisionNOLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.borderWidth = 1
        cellView.layer.cornerRadius = 10
        cellView.layer.masksToBounds = true
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.2
        cellView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cellView.layer.shadowRadius = 8
        
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        contentView.layer.shadowRadius = 2
        contentView.layer.cornerRadius = 10
        
        // Style the status view
        statusView.layer.cornerRadius = 15 // Adjust the radius as needed
        statusView.layer.maskedCorners = [.layerMinXMinYCorner]
        statusView.clipsToBounds = true
        
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        AdmisionNOLbl.setFont(style: .body, size: FontSize.BodySize)
        statusLbl.setFont(style: .body, size: FontSize.BodySize)
        
        showPopUpEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showPopUpEffect() {
        cellView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // Start smaller
        cellView.alpha = 0 // Start invisible

        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.cellView.transform = CGAffineTransform.identity // Restore to original size
            self.cellView.alpha = 1 // Make it visible
        })
    }

    
}
