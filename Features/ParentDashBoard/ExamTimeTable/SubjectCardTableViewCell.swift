import UIKit

public class SubjectCardTableViewCell: UITableViewCell {

    @IBOutlet public weak var subjectCardContainerView: UIView!
    @IBOutlet public weak var lblSubjectName: UILabel!
    @IBOutlet public weak var lblTotalMarks: UILabel!
    @IBOutlet public weak var activitiesStackView: UIStackView!
    
    private var currentSubject: NewSubject?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupCardStyle()
    }
    
    private func setupCardStyle() {
        subjectCardContainerView.layer.cornerRadius = 16
        subjectCardContainerView.layer.masksToBounds = false
        subjectCardContainerView.backgroundColor = UIColor(red: 240/255, green: 247/255, blue: 255/255, alpha: 1.0) // Light Blue
        subjectCardContainerView.layer.borderWidth = 1
        subjectCardContainerView.layer.borderColor = UIColor(red: 210/255, green: 227/255, blue: 249/255, alpha: 1.0).cgColor
    }
    
     func configure(with subject: NewSubject, delegate: NewActivityCellDelegate?) {
        self.currentSubject = subject
        
        lblSubjectName.text = subject.subjectName?.uppercased()
        lblTotalMarks.text = "Total marks : 100" // Hardcoded matching the design spec
        
        // Clear old nested activity cards
        activitiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new activity cards
        for activity in subject.activities ?? [] {
            let activityView = ActivityCardView()
            activityView.configure(with: activity, delegate: delegate)
            activitiesStackView.addArrangedSubview(activityView)
        }
    }
}
