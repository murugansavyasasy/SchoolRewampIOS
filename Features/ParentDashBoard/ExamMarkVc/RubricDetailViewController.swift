import UIKit

public class RubricDetailViewController: UIViewController {

    @IBOutlet public weak var grabHandleView: UIView!
    @IBOutlet public weak var lblRubricTitle: UILabel!
    @IBOutlet public weak var btnClose: UIButton!
    @IBOutlet public weak var schedulingContainerStackView: UIStackView!
    
     var rubric: Rubric?
    var activity :NewActivity?
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureSheetPresentation()
        setupUI()
    }
    
    private func configureSheetPresentation() {
        if #available(iOS 15.0, *), let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
    }
    
    private func setupUI() {
        grabHandleView?.layer.cornerRadius = 2.5
        view.backgroundColor = .systemBackground
        
        schedulingContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let rubric = rubric {
            lblRubricTitle.text = rubric.rubricName
            if let details = rubric.schedulingDetails {
                populateDetails(details)
            }
        } else if let activity = activity {
            lblRubricTitle.text = activity.activityName
            if let details = activity.schedulingDetails {
                populateDetails(details)
            }
        }
    }
    
    private func populateDetails(_ details: SchedulingDetails) {
        var rows: [SchedulingType] = []
        if let dateStr = details.formattedDate { rows.append(.date(dateStr)) }
        if let timeStr = details.formattedTimeRange { rows.append(.time(timeStr)) }
        if let sessionStr = details.session, !sessionStr.isEmpty { rows.append(.session(sessionStr)) }
        if let venueStr = details.venue, !venueStr.isEmpty { rows.append(.venue(venueStr)) }
        if let syllabusStr = details.syllabus, !syllabusStr.isEmpty { rows.append(.syllabus(syllabusStr)) }
        
        // Total Marks
        if let maxMarks = rubric?.max_mark, !maxMarks.isEmpty {
            rows.append(.TotalMarks(maxMarks))
        } else if let maxMarks = activity?.max_mark, !maxMarks.isEmpty {
            rows.append(.TotalMarks(maxMarks))
        }

        // Pass Marks
        if let passMark = rubric?.pass_mark, !passMark.isEmpty {
            rows.append(.PassMark(passMark))
        } else if let passMark = activity?.pass_mark, !passMark.isEmpty {
            rows.append(.PassMark(passMark))
        }
        
        for (index, rowType) in rows.enumerated() {
            let rowView = SchedulingRowView()
            let isLast = index == rows.count - 1
            rowView.configure(type: rowType, showSeparator: !isLast)
            schedulingContainerStackView.addArrangedSubview(rowView)
        }
    }
    @IBAction public func didTapClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
