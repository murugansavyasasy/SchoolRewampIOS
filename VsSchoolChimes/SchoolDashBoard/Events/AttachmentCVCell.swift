//
//  AttachmentCVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 02/12/24.
//

import UIKit

class AttachmentCVCell: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 10
//        outerView.layer.backgroundColor = UIColor.color.cgColor
    }

}
