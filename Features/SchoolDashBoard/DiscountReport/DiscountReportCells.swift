//
//  DiscountReportCells.swift
//  School Chimes
//
//  Cell classes for the Discount report. Layout lives in the matching .xib files;
//  these classes only bind data.
//

import UIKit

// MARK: - Summary  (DiscountSummaryCell.xib)

final class DiscountSummaryCell: UITableViewCell {
    static let id = "DiscountSummaryCell"

    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var discountCaptionLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var subsidyCaptionLabel: UILabel!
    @IBOutlet weak var subsidyLabel: UILabel!

   
    func configure(
        _ report: DiscountReport,
        type: DiscountFilterType
    ) {
        
        // Hide individual Discount and Subsidy labels
        discountCaptionLabel.isHidden = true
        discountLabel.isHidden = true
        subsidyCaptionLabel.isHidden = true
        subsidyLabel.isHidden = true
        
        switch type {
        case .all:
            captionLabel.text = "Total Discount and Subsidy".translated()
            
            totalLabel.text = report.total_discount_and_subsidy

        case .discount:
            captionLabel.text = "Total Discount".translated()
            totalLabel.text = report.discountTotal

        case .subsidy:
            captionLabel.text = "Total Subsidy".translated()
            totalLabel.text = report.subsidyTotal
        }

        let records = "\(report.count) \("records".translated())"
        let categories = "\(report.categories.count) \("categories".translated())"
        countLabel.text = "\(records) · \(categories)"

        discountCaptionLabel.text = DiscountKind.discount.title
        discountLabel.text = report.discountTotal

        subsidyCaptionLabel.text = DiscountKind.subsidy.title
        subsidyLabel.text = report.subsidyTotal
    }

}

// MARK: - Category header row  (DiscountCategoryCell.xib)

final class DiscountCategoryCell: UITableViewCell {
    static let id = "DiscountCategoryCell"

    @IBOutlet weak var kindLabel: StudentFeePillLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var expandImageView: UIImageView!
    
    
//    func configure(_ category: DiscountCategory, collapsed: Bool) {
//
//        // Make sure the label is visible
//        kindLabel.isHidden = false
//
//        switch category.kind {
//        case .discount:
//            kindLabel.text = "Discount".translated()
//            kindLabel.textColor = .systemOrange
//            kindLabel.backgroundColor =
//                UIColor.systemOrange.withAlphaComponent(0.14)
//
//        case .subsidy:
//            kindLabel.text = "Subsidy".translated()
//            kindLabel.textColor = .systemBlue
//            kindLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.14)
//
//        case .other:
//            kindLabel.text = nil
//            kindLabel.backgroundColor = .clear
//            kindLabel.isHidden = true
//        }
//
//        nameLabel.text = category.name
//        countLabel.text = "\(category.count) \("students".translated())"
//        totalLabel.text = category.total
//
//        expandImageView.image = UIImage(
//            systemName: collapsed ? "chevron.down" : "chevron.up"
//        )
//    }
    
    
    
    func configure(_ category: DiscountCategory, collapsed: Bool) {

        switch category.kind {
        case .discount:
            kindLabel.text = DiscountKind.discount.title.uppercased()
            kindLabel.textColor = .systemOrange
            kindLabel.backgroundColor =
                UIColor.systemOrange.withAlphaComponent(0.14)

        case .subsidy:
            kindLabel.text = DiscountKind.subsidy.title.uppercased()
            kindLabel.textColor = .systemBlue
            kindLabel.backgroundColor =
                UIColor.systemBlue.withAlphaComponent(0.14)

        case .other:
            kindLabel.text = nil
            kindLabel.isHidden = true
            kindLabel.backgroundColor = .clear
        }

        // Make sure Discount/Subsidy labels are visible after cell reuse
        if category.kind != .other {
            kindLabel.isHidden = false
        }

        nameLabel.text = category.name
        countLabel.text = "\(category.count) \("students".translated())"
        totalLabel.text = category.total

        expandImageView.image = UIImage(
            systemName: collapsed ? "chevron.down" : "chevron.up"
        )
    }
    
    
//    func configure(_ category: DiscountCategory, collapsed: Bool) {
//        kindLabel.text = category.kind.title
//        kindLabel.textColor = category.kind.color
//        kindLabel.backgroundColor = category.kind.color.withAlphaComponent(0.14)
//        nameLabel.text = category.name
//        countLabel.text = "\(category.count) \("students".translated())"
//        totalLabel.text = category.total
//        expandImageView.image = UIImage(systemName: collapsed ? "chevron.down" : "chevron.up")
//    }
}

// MARK: - One discount given  (DiscountEntryCell.xib)

final class DiscountEntryCell: UITableViewCell {
    static let id = "DiscountEntryCell"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var givenLabel: UILabel!
    @IBOutlet weak var remarksLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    func configure(_ entry: DiscountEntry, kind: DiscountKind) {
        nameLabel.text = entry.name
        metaLabel.text = entry.meta
        metaLabel.isHidden = entry.meta.isEmpty
        feeLabel.text = entry.fee
        givenLabel.text = entry.given
        givenLabel.isHidden = entry.given.isEmpty
        remarksLabel.text = "\("Remarks".translated()): \(entry.remarks)"
        remarksLabel.isHidden = entry.remarks.isEmpty
        amountLabel.text = entry.amount
        amountLabel.textColor = kind.color
    }
}
