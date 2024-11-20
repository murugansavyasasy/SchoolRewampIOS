//
//  ImageShowCVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 18/11/24.
//

import UIKit

class ImageShowCVCell: UICollectionViewCell {

    @IBOutlet weak var FulView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        FulView.layer.borderWidth = 0.5
        FulView.layer.borderColor = UIColor.black.cgColor
        
    }

}
