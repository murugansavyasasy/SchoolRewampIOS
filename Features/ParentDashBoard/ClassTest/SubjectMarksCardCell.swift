//
//  SubjectMarksCardCell.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import UIKit

class SubjectMarksCardCell: UITableViewCell {
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var subjectDotView: UIView!
    @IBOutlet weak var subjectNameLabel: UILabel!
    @IBOutlet weak var trendLabel: UILabel!
    
    @IBOutlet weak var activitiesStackView: UIStackView!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalScoredLabel: UILabel!
    @IBOutlet weak var totalMaxLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }
    
    private func setupStyles() {
        selectionStyle = .none
        
        cardContainerView.layer.cornerRadius = 24
        cardContainerView.layer.borderWidth = 1.0
        cardContainerView.layer.borderColor = UIColor(red: 234/255, green: 240/255, blue: 246/255, alpha: 1.0).cgColor
        
        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowOpacity = 0.05
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainerView.layer.shadowRadius = 12
        cardContainerView.layer.masksToBounds = false
        
        subjectDotView.layer.cornerRadius = 4
        subjectDotView.backgroundColor = UIColor(red: 74/255, green: 85/255, blue: 246/255, alpha: 1.0)
    }
    
    func configure(with subject: TestsSubject) {
        subjectNameLabel.text = subject.subjectName.uppercased()
        
        // Calculate totals
        var totalScored: Double = 0
        var totalMax: Double = 0
        
        for activity in subject.activities {
            if activity.attendance?.uppercased() == "P" {
                if let markStr = activity.mark, let mark = Double(markStr) {
                    totalScored += mark
                }
            }
            if let max = Double(activity.maxMark) {
                totalMax += max
            }
        }
        
        // Trend calculation
        let percentage: Double = totalMax > 0 ? (totalScored / totalMax) * 100 : 0
        trendLabel.text = String(format: "%.0f%%", percentage)
        
        // Footer labels
        totalScoredLabel.text = String(format: "%.0f", totalScored)
        totalMaxLabel.text = String(format: "/ %.0f", totalMax)
        
        // Populate stack view
        for subview in activitiesStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        for (i, activity) in subject.activities.enumerated() {
            let row = ActivityMarksRowView.loadFromNib()
            row.configure(with: activity, index: i + 1)
            activitiesStackView.addArrangedSubview(row)
            
            // Add custom separator if not the last row
            if i < subject.activities.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor(red: 241/255, green: 243/255, blue: 246/255, alpha: 1.0)
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
                activitiesStackView.addArrangedSubview(separator)
            }
        }
    }
}
