import UIKit

protocol AttendanceSessionHeaderDelegate: AnyObject {
    func didTapToggleStudents(in section: Int)
}

class AttendanceSessionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var rootStackView: UIStackView!
    
    // Room Header Items
    @IBOutlet weak var roomHeaderContainer: UIView!
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var roomPillView: UIView!
    @IBOutlet weak var roomPillLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    
    // Top Row
    @IBOutlet weak var roundBadgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var sessionTitleLabel: UILabel!
    @IBOutlet weak var studentsSubtitleLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    // Middle Stats
    @IBOutlet weak var totalStudentsView: UIView!
    @IBOutlet weak var totalStudentsLabel: UILabel!
    
    @IBOutlet weak var presentView: UIView!
    @IBOutlet weak var presentLabel: UILabel!
    
    @IBOutlet weak var absentView: UIView!
    @IBOutlet weak var absentLabel: UILabel!
    
    // Bottom Action
    @IBOutlet weak var toggleButton: UIButton!
    
    weak var delegate: AttendanceSessionHeaderDelegate?
    private var section: Int = 0
    private var isExpanded: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Room header pill styling
        roomPillView.layer.cornerRadius = 12
        roomPillView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        roomPillLabel.textColor = .systemBlue
        
        // Card styling
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.backgroundColor = .white
        
        roundBadgeView.layer.cornerRadius = 18 // Assuming 36x36 height
        roundBadgeView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        badgeLabel.textColor = .systemBlue
        
        totalStudentsView.layer.cornerRadius = 8
        totalStudentsView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        
        presentView.layer.cornerRadius = 8
        presentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.08)
        
        absentView.layer.cornerRadius = 8
        absentView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.08)
        
        toggleButton.layer.cornerRadius = 8
        toggleButton.setTitleColor(.darkGray, for: .normal)
        
        // Action
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
    }

    func configure(session: AttendanceHistorySession, section: Int, isExpanded: Bool, roomId: String?, roomNo: String?, totalSessionsInRoom: Int?,totalsessions : Int) {
        self.section = section
        self.isExpanded = isExpanded
        
        if let roomNo = roomNo, let total = totalSessionsInRoom {
            roomHeaderContainer.isHidden = false
            roomTitleLabel.text = "Room \(roomNo)"
            roomPillLabel.text = "\(total) Sessions"
        } else {
            roomHeaderContainer.isHidden = true
        }
        
        // We use `session.sessionTypeId + 1` or just `section + 1` for badge?
        // Let's use sessionTypeId + 1 to keep it accurate for the session.
//        let sessionTypeId = Int(session.sessionTypeId) ?? 0
        badgeLabel.text = "\(totalsessions )"
        if session.sectionName == ""{
            sessionTitleLabel.text = " "
        }else{
            sessionTitleLabel.text = "\(session.sectionName.capitalized)"
        }
     
        studentsSubtitleLabel.text = "\(session.students.count) students"
        
        // Calculate percentage natively
        let t = Double(session.students.count)
        let p = Double(session.presentStudent) ?? 0.0
        if t > 0 {
            let percentage = Int((p / t) * 100)
            percentageLabel.text = "\(percentage)%"
        } else {
            percentageLabel.text = "0%"
        }
        
        totalStudentsLabel.text = String(session.students.count)
        presentLabel.text = session.presentStudent
        absentLabel.text = session.absentStudent
        
        if isExpanded {
            toggleButton.setTitle("Hide Students", for: .normal)
            toggleButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            toggleButton.tintColor = .darkGray
            toggleButton.layer.borderColor = UIColor.darkGray.cgColor
            
            // Alter corner radius depending on expansion
            cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            toggleButton.setTitle("View Students", for: .normal)
            toggleButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            toggleButton.tintColor = .darkGray
            toggleButton.layer.borderColor = UIColor.darkGray.cgColor
            
            cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    @objc private func toggleTapped() {
        delegate?.didTapToggleStudents(in: section)
    }
}
