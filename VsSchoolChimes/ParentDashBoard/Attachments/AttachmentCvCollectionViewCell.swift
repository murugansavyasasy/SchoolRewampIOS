//
//  AttachmentCvCollectionViewCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 05/05/25.
//

import UIKit

class AttachmentCvCollectionViewCell: UICollectionViewCell {
    enum Constants {
        static let padding: CGFloat = 8
        static let font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    }
   
    @IBOutlet weak var discreptionLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var lblcon: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        
//        lblcon.constant = Constants.padding
    }
}
