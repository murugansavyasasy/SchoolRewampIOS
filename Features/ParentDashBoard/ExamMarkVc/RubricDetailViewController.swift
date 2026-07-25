import UIKit

public class RubricDetailViewController: UIViewController {

    @IBOutlet public weak var grabHandleView: UIView!
    @IBOutlet public weak var lblRubricTitle: UILabel!
    @IBOutlet public weak var btnClose: UIButton!
    @IBOutlet public weak var schedulingContainerStackView: UIStackView!
    
     var rubric: Rubric?

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
        
        guard let rubric = rubric else { return }
        lblRubricTitle.text = rubric.rubricName
        
        schedulingContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let details = rubric.schedulingDetails {
            var rows: [SchedulingType] = []
            if let dateStr = details.formattedDate { rows.append(.date(dateStr)) }
            if let timeStr = details.formattedTimeRange { rows.append(.time(timeStr)) }
            if let sessionStr = details.session, !sessionStr.isEmpty { rows.append(.session(sessionStr)) }
            if let venueStr = details.venue, !venueStr.isEmpty { rows.append(.venue(venueStr)) }
            if let syllabusStr = details.syllabus, !syllabusStr.isEmpty { rows.append(.syllabus(syllabusStr)) }
            
            if let syllabusStr = rubric.max_mark, !syllabusStr.isEmpty { rows.append(.TotalMarks(syllabusStr)) }
            
            if let syllabusStr = rubric.pass_mark, !syllabusStr.isEmpty { rows.append(.PassMark(syllabusStr)) }
            
            for (index, rowType) in rows.enumerated() {
                let rowView = SchedulingRowView()
                let isLast = index == rows.count - 1
                rowView.configure(type: rowType, showSeparator: !isLast)
                schedulingContainerStackView.addArrangedSubview(rowView)
            }
        }
    }
    
    @IBAction public func didTapClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
