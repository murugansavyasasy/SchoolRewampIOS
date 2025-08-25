//
//  NewLSRWTVcell.swift
//  VsSchoolChimes
//
//  Created by MacBook on 24/02/25.
//

import UIKit

class NewLSRWTVcell: UITableViewCell {

    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var sendedByLbl: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var starticon: UIButton!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var iconBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Cell design
        cellView.layer.cornerRadius = 10
        cellView.backgroundColor = .white
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellView.layer.shadowRadius = 3
        cellView.layer.masksToBounds = false
        cellView.layer.borderWidth = 0.5
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        startBtn.setTitleFont(style: .primary, size: FontSize.BodySize)
        // Icon button
        iconBtn.tintColor = .white
        iconBtn.layer.cornerRadius = 8
    }
    
    func configure(with task: LSRWTask) {
        tittleLbl.text = task.title ?? "-"
        descriptionLbl.text = task.description ?? "-"
        subjectLbl.text = task.subject ?? "-"
        sendedByLbl.text = task.sent_by ?? "-"
        if let type = task.activity_type {
            typeLbl.text = type.displayName
            let iconConfig = getIconConfiguration(for: type)
            iconBtn.setTitle(type.icon, for: .normal)
            iconBtn.backgroundColor = iconConfig.backgroundColor
            iconBtn.setTitleColor(iconConfig.textColor, for: .normal)
        } else {
            typeLbl.text = "-"
            iconBtn.setTitle("❓", for: .normal)
            iconBtn.backgroundColor = .lightGray
            iconBtn.setTitleColor(.white, for: .normal)
        }
    }
    
    private func getIconConfiguration(for type: LSRWType) -> (backgroundColor: UIColor, textColor: UIColor) {
        switch type {
        case .listening:
            return (.systemBlue.withAlphaComponent(0.2), .systemBlue)
        case .speaking:
            return (.systemGreen.withAlphaComponent(0.2), .systemGreen)
        case .reading:
            return (.systemOrange.withAlphaComponent(0.2), .systemOrange)
        case .writing:
            return (.systemPurple.withAlphaComponent(0.2), .systemPurple)
        case .unknown(_):
            return (.systemPurple.withAlphaComponent(0.2), .systemPurple)
        }
    }
}
