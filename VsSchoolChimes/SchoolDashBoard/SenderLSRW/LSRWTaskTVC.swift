//
//  LSRWTaskTVC.swift
//  School Chimes
//
//  Created by Chandhru on 13/08/25.
//

import UIKit

class LSRWTaskTVC: UITableViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var submitedCountLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
//        selectionStyle = .none
//        backgroundColor = .clear
//        outerView.backgroundColor = .systemBackground
        
        // Rounded corners for the card style
        outerView.layer.cornerRadius = 12
        outerView.layer.masksToBounds = true
        
        // Soft shadow
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.05
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 4
        outerView.layer.masksToBounds = false
        
        setupButtons()
        setupLabels()
    }
    
    private func setupButtons() {
        iconBtn.layer.cornerRadius = 8
        iconBtn.isUserInteractionEnabled = false
    }
    
    private func setupLabels() {
        
        typeLbl.font = .systemFont(ofSize: 13, weight: .medium)
        typeLbl.textColor = .systemBlue
        
        
        dateLbl.font = .systemFont(ofSize: 12, weight: .medium)
        dateLbl.textColor = .systemGray
        
        submitedCountLbl.font = .systemFont(ofSize: 12, weight: .medium)
    }

    func configure(with task: LSRWTask) {
        titleLbl.text = task.title
        typeLbl.text = task.activity_type?.displayName
        subjectLbl.text = task.subject
        // Format date
        let dateText: String
        if let date = task.created_on {
            dateText = formattedDateStatus(from: date)
        } else {
            dateText = "--/--/----"
        }
        
        // --- Date label with SF Symbol ---
        let calendarAttachment = NSTextAttachment()
        calendarAttachment.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysTemplate)
        calendarAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
        
        let dateAttrString = NSMutableAttributedString(attachment: calendarAttachment)
        dateAttrString.append(NSAttributedString(string: " \(dateText)"))
        dateLbl.attributedText = dateAttrString
        dateLbl.textColor = .secondaryLabel
        
        // --- Submitted count label with SF Symbol ---
        let personAttachment = NSTextAttachment()
        personAttachment.image = UIImage(systemName: "person.2")?.withRenderingMode(.alwaysTemplate)
        personAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
        
        let submittedAttrString = NSMutableAttributedString(attachment: personAttachment)
        submittedAttrString.append(NSAttributedString(string: " \(task.submitted_average ?? "") submitted"))
        submitedCountLbl.attributedText = submittedAttrString
        submitedCountLbl.textColor = .secondaryLabel
        if let type = task.activity_type{
            // Icon button setup
            let iconConfig = getIconConfiguration(for: type)
            iconBtn.setTitle(type.icon, for: .normal)
            iconBtn.backgroundColor = iconConfig.backgroundColor
            iconBtn.setTitleColor(iconConfig.textColor, for: .normal)
        }
        // Description
        descriptionLbl.text = task.description
        
        // Animate
        animateConfiguration()
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
    
    private func getProgressConfiguration(for percentage: Float) -> (backgroundColor: UIColor, textColor: UIColor) {
        switch percentage {
        case 0.0..<0.5:
            return (.systemRed.withAlphaComponent(0.2), .systemRed)
        case 0.5..<0.8:
            return (.systemYellow.withAlphaComponent(0.2), .systemYellow)
        case 0.8...1.0:
            return (.systemGreen.withAlphaComponent(0.2), .systemGreen)
        default:
            return (.systemGray.withAlphaComponent(0.2), .systemGray)
        }
    }
    
    private func animateConfiguration() {
        transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
            self.transform = .identity
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLbl.text = nil
        typeLbl.text = nil
        descriptionLbl.text = nil
        dateLbl.text = nil
        submitedCountLbl.text = nil
        iconBtn.setTitle(nil, for: .normal)
        iconBtn.backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.alpha = highlighted ? 0.8 : 1.0
            }
        }
    }
}
