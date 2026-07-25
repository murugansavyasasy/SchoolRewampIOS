import UIKit

 protocol NewActivityCellDelegate: AnyObject {
    func didSelectRubric(_ rubric: Rubric)
}

public class ActivityTableViewCell: UITableViewCell {

    @IBOutlet public weak var cardBackgroundView: UIView!
    @IBOutlet public weak var lblActivityTitle: UILabel!
    
    // Scheduling Details Stack
    @IBOutlet public weak var schedulingContainerStackView: UIStackView!
    
    // Rubrics Details
    @IBOutlet public weak var lblRubricsHeader: UILabel!
    @IBOutlet public weak var emptyRubricsContainerView: UIView!
    @IBOutlet public weak var emptyRubricsIconView: UIImageView!
    @IBOutlet public weak var lblEmptyRubricsText: UILabel!
    @IBOutlet public weak var rubricsListStackView: UIStackView!
    
     weak var delegate: NewActivityCellDelegate?
    private var currentActivity: NewActivity?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupCardShadowAndCorner()
    }
    
    private func setupCardShadowAndCorner() {
        cardBackgroundView.layer.cornerRadius = 16
        cardBackgroundView.layer.masksToBounds = false
        cardBackgroundView.backgroundColor = .systemBackground
        
        // Subtle drop shadow
        cardBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cardBackgroundView.layer.shadowOpacity = 0.05
        cardBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardBackgroundView.layer.shadowRadius = 8
        
        // Border
        cardBackgroundView.layer.borderWidth = 1
        cardBackgroundView.layer.borderColor = UIColor(red: 235/255, green: 240/255, blue: 245/255, alpha: 1.0).cgColor
        
        // Setup empty rubrics container styling
        emptyRubricsContainerView.layer.cornerRadius = 12
        emptyRubricsContainerView.layer.borderWidth = 1
        emptyRubricsContainerView.layer.borderColor = UIColor(red: 220/255, green: 225/255, blue: 230/255, alpha: 1.0).cgColor
        emptyRubricsContainerView.backgroundColor = .clear
    }
    
     func configure(with activity: NewActivity, delegate: NewActivityCellDelegate?) {
        self.currentActivity = activity
        self.delegate = delegate
        
        lblActivityTitle.text = activity.activityName
        
        // 1. Configure Scheduling Rows
        schedulingContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if activity.hasSchedulingDetails, let details = activity.schedulingDetails {
            schedulingContainerStackView.isHidden = false
            
            var rows: [SchedulingType] = []
            if let dateStr = details.formattedDate { rows.append(.date(dateStr)) }
            if let timeStr = details.formattedTimeRange { rows.append(.time(timeStr)) }
            if let sessionStr = details.session, !sessionStr.isEmpty { rows.append(.session(sessionStr)) }
            if let venueStr = details.venue, !venueStr.isEmpty { rows.append(.venue(venueStr)) }
            if let syllabusStr = details.syllabus, !syllabusStr.isEmpty { rows.append(.syllabus(syllabusStr)) }
            if let syllabusStr = activity.max_mark, !syllabusStr.isEmpty { rows.append(.TotalMarks(syllabusStr)) }
            if let syllabusStr = activity.pass_mark, !syllabusStr.isEmpty { rows.append(.PassMark(syllabusStr)) }
            
            for (index, rowType) in rows.enumerated() {
                let rowView = SchedulingRowView()
                let isLast = index == rows.count - 1
                rowView.configure(type: rowType, showSeparator: !isLast)
                schedulingContainerStackView.addArrangedSubview(rowView)
            }
        } else {
            schedulingContainerStackView.isHidden = true
        }
        
        // 2. Configure Rubrics Section
        rubricsListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
         if ((activity.rubrics?.isEmpty) == nil) {
            lblRubricsHeader.text = "RUBRICS"
            emptyRubricsContainerView.isHidden = false
            rubricsListStackView.isHidden = true
        } else {
            lblRubricsHeader.text = "RUBRICS (\(activity.rubrics?.count ?? 0))"
            emptyRubricsContainerView.isHidden = true
            rubricsListStackView.isHidden = false
            
            for rubric in activity.rubrics ?? [] {
                let item = RubricItemView()
                item.configure(rubricName: rubric.rubricName ?? "") { [weak self] in
                    self?.delegate?.didSelectRubric(rubric)
                }
                rubricsListStackView.addArrangedSubview(item)
            }
        }
    }
}
