import UIKit

public class ActivityCardView: UIView {

    @IBOutlet weak var dateInfoStack: UIStackView!
    @IBOutlet weak var sessionLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
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
   
    private var contentView: UIView?
    private var currentActivity: NewActivity?
       private var tapGesture: UITapGestureRecognizer?
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        contentView = view
        setupCardShadowAndCorner()
    }
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ActivityCardView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
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
         dateInfoStack.isHidden = false
         // Clean up previous tap gesture
         if let tap = tapGesture {
             cardBackgroundView.removeGestureRecognizer(tap)
             tapGesture = nil
         }
        // 1. Configure Scheduling Rows
        schedulingContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if activity.hasSchedulingDetails, let details = activity.schedulingDetails {
            schedulingContainerStackView.isHidden = false
            schedulingContainerStackView.isHidden = true
            var rows: [SchedulingType] = []

            if let dateStr = details.formattedDate { rows.append(.date(dateStr))
                dateLbl.text = "Date : \(dateStr)"
            }
            if let timeStr = details.formattedTimeRange { rows.append(.time(timeStr)) }
            if let sessionStr = details.session, !sessionStr.isEmpty { rows.append(.session(sessionStr))
                sessionLbl.text = "Session :  \(sessionStr)"
            }
          
            if let venueStr = details.venue, !venueStr.isEmpty { rows.append(.venue(venueStr)) }
            if let syllabusStr = details.syllabus, !syllabusStr.isEmpty { rows.append(.syllabus(syllabusStr)) }
            
            for (index, rowType) in rows.enumerated() {
                let rowView = SchedulingRowView()
                let isLast = index == rows.count - 1
                rowView.configure(type: rowType, showSeparator: !isLast)
                schedulingContainerStackView.addArrangedSubview(rowView)
            
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
                      cardBackgroundView.addGestureRecognizer(tap)
                      cardBackgroundView.isUserInteractionEnabled = true
                      tapGesture = tap
        } else {
            schedulingContainerStackView.isHidden = true
            dateInfoStack.isHidden = true
        }
        
        // 2. Configure Rubrics Section
        rubricsListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if activity.rubrics?.count == 0 {
            lblRubricsHeader.isHidden = true
            emptyRubricsContainerView.isHidden = true
            rubricsListStackView.isHidden = true
        } else {
            lblRubricsHeader.isHidden = true
//            lblRubricsHeader.text = "RUBRICS"
            
            emptyRubricsContainerView.isHidden = true
            rubricsListStackView.isHidden = false
            

            
            for rubric in activity.rubrics ?? [] {
                let item = RubricItemView()
                item.configure(rubricName: rubric.rubricName ?? "",rubricSession: rubric.schedulingDetails?.session ?? "",rubricDate: rubric.schedulingDetails?.date?.convertToTargetDateFormat() ?? "") { [weak self] in
                    self?.delegate?.didSelectRubric(rubric)
                }
                rubricsListStackView.addArrangedSubview(item)
            }
            cardBackgroundView.isUserInteractionEnabled = true
        }
    }
    
    @objc private func didTapCard() {
        guard let activity = currentActivity else { return }
        
        // Touch animation feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.cardBackgroundView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.cardBackgroundView.transform = .identity
            }
            self.delegate?.didSelectActivity(activity)
        }
    }
}
