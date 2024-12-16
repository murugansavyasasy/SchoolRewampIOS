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
        cellview.layer.cornerRadius = 7
        cellview.layer.masksToBounds = true
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        
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
}
