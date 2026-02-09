//
//  ExamsListTVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 17/12/24.
//

import UIKit

class ExamsListTVCell: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 6
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
    }

}
