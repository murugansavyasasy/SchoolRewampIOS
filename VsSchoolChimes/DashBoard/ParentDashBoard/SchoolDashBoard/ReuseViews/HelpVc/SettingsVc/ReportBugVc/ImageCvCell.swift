//
//  ImageCvCell.swift
//  VsSchoolChimes
//
//  Created by admin on 28/10/24.
//

import UIKit

class ImageCvCell: UICollectionViewCell {

    @IBOutlet weak var imageViews: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageViews.layer.cornerRadius = 10
        
    }

}
