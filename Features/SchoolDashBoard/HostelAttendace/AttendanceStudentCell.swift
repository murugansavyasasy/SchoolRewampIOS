import UIKit

class AttendanceStudentCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var avatarLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    
    @IBOutlet weak var statusPillView: UIView!
    @IBOutlet weak var statusPillLabel: UILabel!
    
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarView.layer.cornerRadius = 20 // Assuming 40x40
        statusPillView.layer.cornerRadius = 12
        statusPillView.layer.borderWidth = 1
    }

    func configure(student: AttendanceHistoryStudent) {
        // Defaults to Present if empty string for green styling as per JSON ("" -> Present)
        let isPresent = student.status.lowercased() == "present" || student.status.trimmingCharacters(in: .whitespaces).isEmpty
        
        nameLabel.text = student.studentName.capitalized
        detailsLabel.text = "\(student.admissionNo)  •  Class \(student.className)-\(student.sectionName)"
        mobileLabel.text = student.primaryMobile
        
        if let initial = student.studentName.first {
            avatarLabel.text = String(initial).uppercased()
        } else {
            avatarLabel.text = "?"
        }
        
        if isPresent {
            avatarView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            avatarLabel.textColor = UIColor.systemGreen
            
            statusPillLabel.text = "Present"
            statusPillLabel.textColor = UIColor.systemGreen
            statusPillView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            statusPillView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.3).cgColor
        } else {
            avatarView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            avatarLabel.textColor = UIColor.systemRed
            
            statusPillLabel.text = "Absent"
            statusPillLabel.textColor = UIColor.systemRed
            statusPillView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            statusPillView.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        }
    }
}
