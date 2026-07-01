//
//  ClassTestsHeaderView.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import UIKit

class ClassTestsHeaderView: UIView {
    
    @IBOutlet weak var examsCountLabel: UILabel!
    @IBOutlet weak var subjectsCountLabel: UILabel!
    @IBOutlet weak var activitiesCountLabel: UILabel!
    @IBOutlet weak var headerStatsContainerView: UIView!
    @IBOutlet weak var headerTitleBadgeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }
    
    private func setupStyles() {
        headerTitleBadgeView.layer.cornerRadius = 20
        headerTitleBadgeView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        headerStatsContainerView.layer.cornerRadius = 16
        headerStatsContainerView.layer.borderWidth = 0.5
        headerStatsContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        headerStatsContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
    }
    
    func configure(exams: Int, subjects: Int, activities: Int) {
        examsCountLabel.text = "\(exams)"
        subjectsCountLabel.text = "\(subjects)"
        activitiesCountLabel.text = "\(activities)"
    }
}
