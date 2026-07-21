//
//  EmergencyInfoPopoverVCViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 17/04/25.
//

import UIKit

class EmergencyInfoPopoverVCViewController: UIViewController {

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "On enabling , this call will be dialed on priority . You can record upto 30 secs only".translated()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        preferredContentSize = CGSize(width: 250, height: 100)

        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6

        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            descriptionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }
}
