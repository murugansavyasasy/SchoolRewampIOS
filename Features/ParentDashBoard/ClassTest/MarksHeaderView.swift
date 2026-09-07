//
//  MarksHeaderView.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import UIKit

class MarksHeaderView: UIView {
    
    @IBOutlet weak var blueHeaderCardView: UIView!
    @IBOutlet weak var examTitleLabel: UILabel!
    @IBOutlet weak var examCountsLabel: UILabel!
    @IBOutlet weak var overallPercentagePillView: UIView!
    @IBOutlet weak var overallPercentagePillLabel: UILabel!
    
    @IBOutlet weak var statsCardView: UIView!
    @IBOutlet weak var scoredValueLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var percentageValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }
    
    private func setupStyles() {
        // Top card rounding
        blueHeaderCardView.layer.cornerRadius = 24
        
        // Circular overall badge
        overallPercentagePillView.layer.cornerRadius = 16
        overallPercentagePillView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        // Stats container rounding and borders
        statsCardView.layer.cornerRadius = 20
        statsCardView.layer.borderWidth = 1.0
        statsCardView.layer.borderColor = UIColor(red: 234/255, green: 240/255, blue: 246/255, alpha: 1.0).cgColor
    }
    
    func configure(with exam: ClassTestMarks) {
        examTitleLabel.text = exam.examName
        
        // Calculate counts
        let subjectsCount = exam.subjects.count
        let assessedCount = exam.subjects.reduce(0) { $0 + $1.activities.count }
        let subjectStr = subjectsCount == 1 ? "1 subject" : "\(subjectsCount) subjects"
        
        let assessedStr = assessedCount == 1 ? "1 assessed" : "\(assessedCount) assessed"
        examCountsLabel.text = "\(subjectStr)  ·  \(assessedStr)"
        
        // Dynamic calculations
        var totalScored: Double = 0
        var totalMax: Double = 0
        
        for subject in exam.subjects {
            for activity in subject.activities {
                if activity.attendance?.uppercased() == "P" {
                    if let markStr = activity.mark, let mark = Double(markStr) {
                        totalScored += mark
                    }
                }
                if let max = Double(activity.maxMark ?? "") {
                    totalMax += max
                }
            }
        }
        
        // Scored formatting
        scoredValueLabel.text = String(format: "%.0f", totalScored)
        // Total max formatting
        totalValueLabel.text = String(format: "%.0f", totalMax)
        
        // Percentage calculation
        let percentage: Double = totalMax > 0 ? (totalScored / totalMax) * 100 : 0
        let percentageStr = String(format: "%.0f%%", percentage)
        percentageValueLabel.text = percentageStr
        
        // Display in right top badge
        overallPercentagePillLabel.text = percentageStr
    }
}
