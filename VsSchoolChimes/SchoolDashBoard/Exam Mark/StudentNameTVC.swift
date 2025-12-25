//
//  StudentNameTVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/12/25.
//

import UIKit

class StudentNameTVC: UITableViewCell {
        
        @IBOutlet weak var nameLabel: UILabel!
        @IBOutlet weak var rollNoLabel: UILabel!
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }
        
        private func setupUI() {
            nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            rollNoLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            rollNoLabel.textColor = .gray
            selectionStyle = .none
        }
        
        func configure(name: String, rollNo: String) {
            nameLabel.text = name
            rollNoLabel.text = rollNo
        }
    }
