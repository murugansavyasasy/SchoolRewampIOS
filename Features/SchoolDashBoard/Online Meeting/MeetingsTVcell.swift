//
//  MeetingsTVcell.swift
//  VsSchoolChimes
//
//  Created by Admin on 05/12/24.
//

import UIKit

protocol ReminderCellDelegate: AnyObject {
    func didTapCreateReminder(at indexPath: IndexPath)
}

class MeetingsTVcell: UITableViewCell {
    
    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var DateTimeLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var DescriptLbl: UILabel!
    @IBOutlet weak var reminder: UIImageView!
    @IBOutlet weak var LinkLbl: UILabel!
    @IBOutlet weak var MeetingTypeLbl: UILabel!
    
    weak var delegate: ReminderCellDelegate?
    var indexPath: IndexPath!
    private var gradientLayer: CAGradientLayer?
    private var gradientColors: [CGColor] = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        cellview.layer.cornerRadius = 6
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOffset = CGSize(width: 0, height: 2)
        cellview.layer.shadowRadius = 5
        cellview.layer.shadowOpacity = 0.3
        contentview.layer.cornerRadius = 6 // Adjust as needed
        contentview.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] // Top-right and Bottom-right corners
        contentview.clipsToBounds = true // Ensures the corners are clipped
        
        DateTimeLbl.setFont(style: .body, size: FontSize.BodySize)
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DescriptLbl.setFont(style: .title, size: FontSize.TitleSize)
        MeetingTypeLbl.setFont(style: .body, size: FontSize.BodySize)
        LinkLbl.setFont(style: .body, size: FontSize.BodySize)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AlarmAct))
        reminder.addGestureRecognizer(tap)
        reminder.isUserInteractionEnabled = true
        
        // setupPopUpButton()
    }
    
    @IBAction func AlarmAct(_ sender: Any) {
        
        delegate?.didTapCreateReminder(at: indexPath)
    }
    @IBAction func JoinMeeting(_ sender: UIButton) {
        if let url = URL(string: "https://meet.google.com/dac-augr-itc") {
                   UIApplication.shared.open(url)
               }
    }
    
}
