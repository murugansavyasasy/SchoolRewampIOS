//
//  ExamReportsTVC.swift
//  School Chimes
//
//  Created by Chandhru on 01/07/26.
//

import UIKit

class ExamReportsTVC: UITableViewCell {

    @IBOutlet weak var classSectionStack: UIStackView!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var sendbyLbl: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var arrowBtn: UIButton!
    private let classChip = PaddingLabel()
    private let sectionChip = PaddingLabel()
    private let dateChip = PaddingLabel()
    private let timeChip = PaddingLabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(with item: ExamListItem) {
        tittleLbl.text = item.title
        sendbyLbl.text = "Sent by \(item.sentBy)"

        classChip.text = "📖 \(item.classText)"
        sectionChip.text = "Sec \(item.sectionText)"
        dateChip.text = "🕐 \(item.dateText)"
        timeChip.text = item.timeText

        iconBtn.backgroundColor = item.iconTint
        arrowBtn.backgroundColor = item.iconTint
        iconBtn.setImage(UIImage(systemName: "doc.text.fill"), for: .normal)
        iconBtn.tintColor = .white
        arrowBtn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        arrowBtn.tintColor = .white

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            [self.classChip, self.sectionChip, self.dateChip, self.timeChip].forEach {
                $0.layer.cornerRadius = $0.bounds.height / 2
            }
        }
    }
}
class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}
struct ExamReportResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [ExamReportItem]?
}

struct ExamReportItem: Codable {
    let classTestId: String?
    let examName: String?
    let standardName: String?
    let sectionName: String?
    let sentBy: String?
    let sentOn: String?     // "24-06-2026 05:46 PM"

    enum CodingKeys: String, CodingKey {
        case classTestId = "class_test_id"
        case examName = "exam_name"
        case standardName = "standard_name"
        case sectionName = "section_name"
        case sentBy = "sent_by"
        case sentOn = "sent_on"
    }
}
struct ExamListItem {
    let id: String
    let title: String
    let classText: String
    let sectionText: String
    let dateText: String     // "24 Jun"
    let timeText: String     // "05:46 PM"
    let sentBy: String
    let iconTint: UIColor
}
