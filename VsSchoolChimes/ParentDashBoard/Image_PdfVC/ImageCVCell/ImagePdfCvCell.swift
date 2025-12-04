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
    var hide = false{
        didSet{
            if !hide{
                applyShadowAndCornerRadius(to: fullView)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
       
        imageView.layer.cornerRadius = Colornames.CORadius10
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

}
