//
//  ActivityDetailCardView.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import UIKit

class ActivityDetailCardView: UIView {
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var sessionPillView: UIView!
    @IBOutlet weak var sessionPillImageView: UIImageView!
    @IBOutlet weak var sessionPillLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var syllabusLabel: UILabel!
    @IBOutlet weak var maxMarksLabel: UILabel!
    @IBOutlet weak var minMarksLabel: UILabel!
    
    @IBOutlet weak var maxMarksContainerView: UIView!
    @IBOutlet weak var minMarksContainerView: UIView!
    @IBOutlet weak var syllabusContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }
    
    private func setupStyles() {
        // Main container card styles
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.layer.borderWidth = 1.0
        cardContainerView.layer.borderColor = UIColor(red: 234/255, green: 240/255, blue: 246/255, alpha: 1.0).cgColor
        
        // Icon circle styles
        activityIconImageView.layer.cornerRadius = 8
        activityIconImageView.backgroundColor = UIColor(red: 238/255, green: 242/255, blue: 255/255, alpha: 1.0)
        activityIconImageView.tintColor = UIColor(red: 74/255, green: 85/255, blue: 246/255, alpha: 1.0)
        
        // Syllabus card background
        syllabusContainerView.layer.cornerRadius = 8
        syllabusContainerView.backgroundColor = UIColor(red: 241/255, green: 245/255, blue: 249/255, alpha: 1.0)
        
        // Marks blocks corners
        maxMarksContainerView.layer.cornerRadius = 12
        maxMarksContainerView.backgroundColor = UIColor(red: 232/255, green: 245/255, blue: 233/255, alpha: 1.0)
        
        minMarksContainerView.layer.cornerRadius = 12
        minMarksContainerView.backgroundColor = UIColor(red: 255/255, green: 235/255, blue: 238/255, alpha: 1.0)
    }
    
    func configure(with activity: TestsActivity) {
        activityNameLabel.text = activity.activityName ?? ""
        dateLabel.text = activity.examDate ?? ""
        syllabusLabel.text = activity.syllabus ?? ""
        
        // Format marks
        if let maxDouble = Double(activity.maxMark ?? "") {
            maxMarksLabel.text = String(format: "%.0f", maxDouble)
        } else {
            maxMarksLabel.text = activity.maxMark
        }
        
        if let minDouble = Double(activity.minMark ?? "") {
            minMarksLabel.text = String(format: "%.0f", minDouble)
        } else {
            minMarksLabel.text = activity.minMark
        }
        
        // Format session pill
        let isFN = activity.session?.uppercased() == "FN"
        sessionPillLabel.text = isFN ? "Forenoon".translated() : "Afternoon".translated()
        sessionPillView.layer.cornerRadius = 10
        
        if isFN {
            sessionPillView.backgroundColor = UIColor(red: 225/255, green: 245/255, blue: 254/255, alpha: 1.0)
            sessionPillLabel.textColor = UIColor(red: 2/255, green: 136/255, blue: 209/255, alpha: 1.0)
            sessionPillImageView.tintColor = UIColor(red: 2/255, green: 136/255, blue: 209/255, alpha: 1.0)
        } else {
            sessionPillView.backgroundColor = UIColor(red: 255/255, green: 243/255, blue: 224/255, alpha: 1.0)
            sessionPillLabel.textColor = UIColor(red: 230/255, green: 81/255, blue: 0/255, alpha: 1.0)
            sessionPillImageView.tintColor = UIColor(red: 230/255, green: 81/255, blue: 0/255, alpha: 1.0)
        }
    }
}
