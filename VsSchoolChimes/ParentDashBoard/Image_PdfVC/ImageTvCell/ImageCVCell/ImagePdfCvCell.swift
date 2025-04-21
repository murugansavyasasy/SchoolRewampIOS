//
//  ImagePdfCvCell.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit
import WebKit

class ImagePdfCvCell: UICollectionViewCell {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var imageView: UIImageView!
   
    @IBOutlet weak var IndicaterImageView: UIImageView!
    @IBOutlet weak var fullView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        IndicaterImageView.isHidden = true
//        fullView.layer.cornerRadius = 15
        webView.isHidden = true
        
        fullView.layer.cornerRadius = Colornames.CORadius15
        imageView.layer.cornerRadius = Colornames.CORadius15
        fullView.backgroundColor = .white
        fullView.layer.shadowColor = UIColor.lightGray.cgColor
        fullView.layer.shadowOpacity = 0.3
        fullView.layer.shadowOffset = CGSize(width: 0, height: 8)
        fullView.layer.shadowRadius = 15
        fullView.layer.shadowPath = UIBezierPath(roundedRect: fullView.bounds, cornerRadius: 16).cgPath
        
        
    }

}
