//
//  Exam_ExamListTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class Exam_ExamListTV: UITableViewCell {
    
    @IBOutlet weak var ArrowBtn: UIButton!
    @IBOutlet weak var activitiesLbl: UILabel!
    @IBOutlet weak var subjectNameLbl: UILabel!
    @IBOutlet weak var separatorview: UIView!
    @IBOutlet weak var subjectView: UIView!
    @IBOutlet weak var activitiesStack: UIStackView!
    
    var onExpand: (() -> Void)?
    var Activities : [ActivityData] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        subjectNameLbl.setFont(style: .body, size: 17)
        activitiesLbl.setFont(style: .body, size: FontSize.TitleSize)
        activitiesLbl.text = ExamMarkUploadString.Activities.translated()
        
        subjectView.backgroundColor = .systemGray6.withAlphaComponent(0.3)
        
        activitiesStack.axis = .vertical
        activitiesStack.spacing = 8
        activitiesStack.alignment = .fill
        activitiesStack.distribution = .fill
        
        activitiesStack.isHidden = true
        activitiesLbl.isHidden = true
    }
    
    override func prepareForReuse() {
            super.prepareForReuse()
            activitiesStack.arrangedSubviews.forEach {
                activitiesStack.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            activitiesStack.isHidden = true
            activitiesLbl.isHidden = true
            onExpand = nil
        }
    
    private func configureActivities() {
        activitiesStack.arrangedSubviews.forEach {
            activitiesStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for activity in Activities {
            let label = UILabel()
            label.numberOfLines = 0

            let activityName = "• \(activity.activity_name ?? "")"

            let attributedText = NSMutableAttributedString(
                string: activityName,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                    .foregroundColor: UIColor.label
                ]
            )

            let rubricNames = activity.rubrics?
                .compactMap { $0.rubric_name }
                .joined(separator: ", ") ?? ""

            if !rubricNames.isEmpty {
                let rubricText = " (\(rubricNames))"
                attributedText.append(
                    NSAttributedString(
                        string: rubricText,
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 14),
                            .foregroundColor: UIColor.black.withAlphaComponent(0.8)
                        ]
                    )
                )
            }

            label.attributedText = attributedText
            activitiesStack.addArrangedSubview(label)
        }
    }
    
    func configureExpansionState(_ expanded: Bool) {
        ArrowBtn.setImage(UIImage(systemName: expanded ? "chevron.down" : "chevron.forward"), for: .normal)
        activitiesLbl.isHidden = !expanded
        activitiesStack.isHidden = !expanded

        if expanded {
            configureActivities()
        } else {
            clearActivities()
        }
        
        setNeedsLayout()
           layoutIfNeeded()
    }

    private func clearActivities() {
        activitiesStack.arrangedSubviews.forEach {
            activitiesStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    
    @IBAction func expandAct(_ sender: UIButton) {
        onExpand?()
    }
}
