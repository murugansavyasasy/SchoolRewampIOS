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
        applyShadowAndCornerRadius(to: fullView)
        imageView.layer.cornerRadius = Colornames.CORadius15
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

}
