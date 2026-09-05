import UIKit

class StudentTableViewCell: UITableViewCell {
    @IBOutlet weak var adminNoLbl: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rollNoLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Card rounded corners and border
        cardView.layer.cornerRadius = 10
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor
        
        // Shadow for premium feel
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.03
        cardView.layer.masksToBounds = false
        
        // Avatar circle
        avatarView.layer.cornerRadius = 20
        avatarView.clipsToBounds = true
    }
    
    func configure(with student: StudentDetails, isSelected: Bool) {
        nameLabel.text = student.name
        
        if student.roll_no?.isEmpty == nil {
            rollNoLabel.text = "Roll No: --"
        } else {
            rollNoLabel.text = "Roll No: \(student.roll_no ?? "")"
        }
        
        if student.admission_no?.isEmpty == nil {
            adminNoLbl.text = "Admin No: --"
        } else {
            adminNoLbl.text = "Admin No: \(student.admission_no ?? "")"
        }
        
        // Set initials
        initialsLabel.text = getInitials(from: student.name ?? "")
        
        // Set avatar color based on name hash to match pastels
        avatarView.backgroundColor = getAvatarColor(from: student.name ?? "")
        
        // Selection state
        if isSelected {
            cardView.layer.borderColor = UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0).cgColor
            cardView.layer.borderWidth = 1.5
            checkmarkImageView.isHidden = false
            nameLabel.textColor = UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0)
        } else {
            cardView.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor
            cardView.layer.borderWidth = 1.0
            checkmarkImageView.isHidden = true
            nameLabel.textColor = UIColor(red: 0.05, green: 0.14, blue: 0.23, alpha: 1.0)
        }
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count > 1, let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        } else if let first = name.first {
            if name.count > 1 {
                let secondIndex = name.index(name.startIndex, offsetBy: 1)
                return "\(first)\(name[secondIndex])".uppercased()
            }
            return "\(first)".uppercased()
        }
        return "ST"
    }
    
    private func getAvatarColor(from name: String) -> UIColor {
        // High contrast pastel palettes matching screenshot colors
        let colors: [UIColor] = [
            UIColor(red: 0.62, green: 0.38, blue: 0.93, alpha: 1.0), // Purple (AV)
            UIColor(red: 0.0, green: 0.69, blue: 0.81, alpha: 1.0),  // Light Blue/Teal (PK)
            UIColor(red: 0.0, green: 0.74, blue: 0.83, alpha: 1.0),  // Turquoise (RS)
            UIColor(red: 0.18, green: 0.49, blue: 0.96, alpha: 1.0), // Blue (SM)
            UIColor(red: 0.0, green: 0.66, blue: 0.42, alpha: 1.0),  // Green (TD)
            UIColor(red: 0.92, green: 0.19, blue: 0.49, alpha: 1.0)  // Pink (VP)
        ]
        
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
}
