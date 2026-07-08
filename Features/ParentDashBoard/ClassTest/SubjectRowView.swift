//
//  SubjectRowView.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import UIKit

class SubjectRowView: UIView {
    
    @IBOutlet weak var indicatorDotView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var headerTapView: UIView!
    
    private var subject: TestsSubject?
    private var isExpanded: Bool = false
    private var onToggle: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGesture()
        setupStyles()
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        headerTapView.addGestureRecognizer(tap)
        headerTapView.isUserInteractionEnabled = true
    }
    
    private func setupStyles() {
        indicatorDotView.layer.cornerRadius = 4
        indicatorDotView.backgroundColor = UIColor(red: 74/255, green: 85/255, blue: 246/255, alpha: 1.0)
    }
    
    @objc private func didTapHeader() {
        onToggle?()
    }
    
    func configure(with subject: TestsSubject, isExpanded: Bool, onToggle: @escaping () -> Void) {
        self.subject = subject
        self.isExpanded = isExpanded
        self.onToggle = onToggle
        
        let activityCount = subject.activities.count
        let activityText = activityCount == 1 ? "1 activity" : "\(activityCount) activities"
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1.0)
        ]
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1.0)
        ]
        
        let text = NSMutableAttributedString(string: "\(subject.subjectName ?? "")  ", attributes: boldAttributes)
        text.append(NSAttributedString(string: activityText, attributes: regularAttributes))
        titleLabel.attributedText = text
        
        let chevronName = isExpanded ? "chevron.up" : "chevron.down"
        chevronImageView.image = UIImage(systemName: chevronName)
        chevronImageView.tintColor = UIColor(red: 142/255, green: 154/255, blue: 168/255, alpha: 1.0)
        
        detailsStackView.isHidden = !isExpanded
        
        for subview in detailsStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        if isExpanded {
            for activity in subject.activities {
                let card = ActivityDetailCardView.loadFromNib()
                card.configure(with: activity)
                detailsStackView.addArrangedSubview(card)
            }
        }
    }
}
