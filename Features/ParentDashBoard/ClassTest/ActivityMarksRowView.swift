//
//  ActivityMarksRowView.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import UIKit

class ActivityMarksRowView: UIView {
    
    @IBOutlet weak var minMarkLbl: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var sessionPillView: UIView!
    @IBOutlet weak var sessionPillImageView: UIImageView!
    @IBOutlet weak var sessionPillLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var syllabusLabel: UILabel!
    
    @IBOutlet weak var scoredMarkLabel: UILabel!
    @IBOutlet weak var maxMarkLabel: UILabel!
    @IBOutlet weak var markUnderlineView: UIView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }
    
    private func setupStyles() {
        sessionPillView.layer.cornerRadius = 10
        markUnderlineView.backgroundColor = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0) // Green #10B981
        checkmarkImageView.tintColor = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0)
    }
    
    func configure(with activity: MarksActivity, index: Int) {
        indexLabel.text = "\(index)"
        activityNameLabel.text = activity.activityName
        dateLabel.text = activity.examDate
        syllabusLabel.text = activity.syllabus
        minMarkLbl.text =  "Min : " + (activity.minMark ?? "")
        // Format max mark
        if let maxDouble = Double(activity.maxMark ?? "") {
            maxMarkLabel.text = String(format: "%.0f", maxDouble)
        } else {
            maxMarkLabel.text = activity.maxMark
        }
        
        // Attendance check
        let isPresent = activity.attendance?.uppercased() == "P"
        
        if isPresent {
            if let markStr = activity.mark, let markDouble = Double(markStr) {
                scoredMarkLabel.text = String(format: "%.0f", markDouble)
                scoredMarkLabel.textColor = UIColor(red: 20/255, green: 25/255, blue: 40/255, alpha: 1.0)
                
                // Compare mark and min_mark
                let minMarkDouble = Double(activity.minMark ?? "") ?? 0.0
                if markDouble >= minMarkDouble {
                    // Green tick
                    checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
                    checkmarkImageView.tintColor = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0)
                    markUnderlineView.backgroundColor = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0)
                } else {
                    // Red cross
                    checkmarkImageView.image = UIImage(systemName: "xmark.circle.fill")
                    checkmarkImageView.tintColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
                    markUnderlineView.backgroundColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
                }
            } else {
                scoredMarkLabel.text = "AB"
                scoredMarkLabel.textColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
                checkmarkImageView.image = UIImage(systemName: "xmark.circle.fill")
                checkmarkImageView.tintColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
                markUnderlineView.backgroundColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
            }
        } else {
            // Absent/Not present: show "--"
            scoredMarkLabel.text = "AB"
            scoredMarkLabel.textColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
            checkmarkImageView.image = UIImage(systemName: "xmark.circle.fill")
            checkmarkImageView.tintColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
            markUnderlineView.backgroundColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
        }
        
        // Session format
        let isFN = activity.session?.uppercased() == "FN"
        sessionPillLabel.text = isFN ? "Forenoon" : "Afternoon"
        
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
