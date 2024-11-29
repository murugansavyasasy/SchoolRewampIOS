//
//  ImageCvCell.swift
//  VsSchoolChimes
//
//  Created by admin on 28/10/24.
//

import UIKit

class ImageCvCell: UICollectionViewCell {

    @IBOutlet weak var imageViews: UIImageView!
    
    @IBOutlet weak var TrashIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageViews.layer.cornerRadius = Colornames.CORadius10
        
    }

}
