//
//  bubbleview.swift
//  VsSchoolChimes
//
//  Created by admin on 17/04/25.
//

import Foundation
import UIKit

class EmergencyInfoBubbleView: UIView {
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "📢 Description for emergency call: On enabling, this call will be sent."
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup Method
    
    private func setupView() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    // Optional: Setter if you want to customize text
    func setText(_ text: String) {
        descriptionLabel.text = text
    }
}
