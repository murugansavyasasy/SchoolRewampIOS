//
//  StudentFeeDetailsCells.swift
//  School Chimes
//
//  Cells for the Student Fee Details screen. Layout lives in
//  StudentFeeSummaryCell.xib and StudentFeeRowCell.xib; these classes only bind data.
//

import UIKit

// MARK: - Summary  (StudentFeeSummaryCell.xib)

final class StudentFeeSummaryCell: UITableViewCell {
    static let id = "StudentFeeSummaryCell"

    @IBOutlet weak var totalCaptionLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var pendingCaptionLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var paidCaptionLabel: UILabel!
    @IBOutlet weak var paidLabel: UILabel!
    @IBOutlet weak var discountCaptionLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!

    func configure(_ s: StudentFeeSummary) {
        totalCaptionLabel.text = "Total fee".translated()
        pendingCaptionLabel.text = "Pending".translated()
        paidCaptionLabel.text = "Paid".translated()
        discountCaptionLabel.text = "Discount".translated()
        totalLabel.text = s.total
        pendingLabel.text = s.pending
        paidLabel.text = s.paid
        discountLabel.text = s.discount
        progressView.progress = s.paidFraction
        let percent = Int((s.paidFraction * 100).rounded())
        progressLabel.text = "\(s.paid) \("of".translated()) \(s.total) \("paid".translated()) (\(percent)%)"
    }
}

// MARK: - Fee line  (StudentFeeRowCell.xib)

final class StudentFeeRowCell: UITableViewCell {
    static let id = "StudentFeeRowCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: StudentFeePillLabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountsLabel: UILabel!
    @IBOutlet weak var pendingCaptionLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var expandImageView: UIImageView!
    @IBOutlet weak var breakdownView: UIView!
    @IBOutlet weak var breakdownLabel: UILabel!

    func configure(_ row: StudentFeeRow, expanded: Bool) {
        titleLabel.text = row.title
        statusLabel.text = row.status.title
        statusLabel.textColor = row.status.color
        statusLabel.backgroundColor = row.status.color.withAlphaComponent(0.14)
        subtitleLabel.text = row.subtitle
        subtitleLabel.isHidden = row.subtitle.isEmpty
        amountsLabel.text = row.amounts
        pendingCaptionLabel.text = row.pendingCaption
        pendingLabel.text = row.pending
        pendingLabel.textColor = FeeAmount.value(row.pending) > 0 ? StudentFeeColor.orange : StudentFeeColor.green

        let expandable = !row.breakdown.isEmpty
        selectionStyle = expandable ? .default : .none
        expandImageView.isHidden = !expandable
        expandImageView.image = UIImage(systemName: expanded ? "chevron.up" : "chevron.down")
        breakdownView.isHidden = !(expandable && expanded)
        breakdownLabel.attributedText = (expandable && expanded) ? studentFeeBreakdownText(row.breakdown) : nil
    }
}

/// Breakdown lines: item name on one line, its amounts on the next.
func studentFeeBreakdownText(_ items: [(String, String)]) -> NSAttributedString {
    let para = NSMutableParagraphStyle()
    para.paragraphSpacing = 8
    let out = NSMutableAttributedString()
    for (i, (title, value)) in items.enumerated() {
        out.append(NSAttributedString(string: title + "\n", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: StudentFeeColor.ink]))
        out.append(NSAttributedString(string: value + (i < items.count - 1 ? "\n" : ""), attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: StudentFeeColor.muted, .paragraphStyle: para]))
    }
    return out
}
