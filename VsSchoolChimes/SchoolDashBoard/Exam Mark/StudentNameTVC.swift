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
        // Name label styling
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 0
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8
        
        // Roll number label styling
        rollNoLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        rollNoLabel.textColor = .secondaryLabel
        rollNoLabel.numberOfLines = 1
        
        // Cell styling
        selectionStyle = .none
        backgroundColor = .systemBackground
    }
    
    func configure(name: String, rollNo: String) {
        nameLabel.text = name
        rollNoLabel.text = "Roll No: \(rollNo)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        rollNoLabel.text = ""
    }
}
