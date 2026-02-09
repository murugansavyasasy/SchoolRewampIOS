//
//  TargetCvCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 10/10/25.
//

import UIKit

class TargetCvCell: UICollectionViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 15
                contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        nameLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nameLbl.textColor = .black
        // Initialization code
    }

}
