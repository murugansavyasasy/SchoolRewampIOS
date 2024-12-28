//
//  ReciverAttendReportTV.swift
//  VsSchoolChimes
//
//  Created by Admin on 19/12/24.
//

import UIKit

class ReciverAttendReportTV: UITableViewCell {

    @IBOutlet weak var TakenLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var MonthView: UIView!
    @IBOutlet weak var DateView: UIView!
    @IBOutlet weak var Cellview: UIView!
    
    @IBOutlet weak var StatusView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        Cellview.layer.backgroundColor = UIColor.white.cgColor
        Cellview.layer.cornerRadius = 10
        DateView.layer.cornerRadius = 10
        MonthView.layer.cornerRadius = 10
        Cellview.layer.masksToBounds = true
        
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 4, height: 4)
        contentView.layer.shadowRadius = 5
        contentView.layer.cornerRadius = 10
        
        // Style the status view
        StatusView.layer.cornerRadius = 15 // Adjust the radius as needed
        StatusView.layer.maskedCorners = [.layerMinXMinYCorner]
        StatusView.clipsToBounds = true
        
        monthLbl.setFont(style: .title, size: FontSize.TitleSize)
        DateLbl.setFont(style: .header, size: FontSize.HeaderSize)
        dayLbl.setFont(style: .title, size: 11)
        statusLbl.setFont(style: .title, size: FontSize.TitleSize)
        TakenLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        showPopUpEffect()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showPopUpEffect() {
        Cellview.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // Start smaller
        Cellview.alpha = 0 // Start invisible

        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.Cellview.transform = CGAffineTransform.identity // Restore to original size
            self.Cellview.alpha = 1 // Make it visible
        })
    }

    
}
