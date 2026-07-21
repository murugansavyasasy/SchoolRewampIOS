//
//  SubjectBadgeCollectionViewCell.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import UIKit

class SubjectBadgeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var badgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }
    
    private func setupStyles() {
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = UIColor(red: 238/255, green: 242/255, blue: 255/255, alpha: 1.0)
        badgeLabel.textColor = UIColor(red: 74/255, green: 85/255, blue: 246/255, alpha: 1.0)
    }
    
    func configure(with text: String) {
        badgeLabel.text = text
    }
}
