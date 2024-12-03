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
    @IBOutlet weak var deleteBtn: UIButton!
    var delegate:DeleteImge?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageViews.layer.cornerRadius = Colornames.CORadius10
        
    }
    
    @IBAction func deleteImg(_ sender: UIButton) {
        delegate?.deleteImage(index: sender.tag)
    }
    
}
