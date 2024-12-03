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
        fullView.backgroundColor = .white // Ensure it's white if not set in the storyboard
               
               // Apply shadow properties
        fullView.layer.shadowColor = UIColor.lightGray.cgColor // Softer shadow color
        fullView.layer.shadowOpacity = 0.3 // Slightly transparent
        fullView.layer.shadowOffset = CGSize(width: 0, height: 8) // Subtle drop shadow
        fullView.layer.shadowRadius = 15 // Soft and diffused shadow
               
               // Optional: Use shadowPath for better performance
        fullView.layer.shadowPath = UIBezierPath(roundedRect: fullView.bounds, cornerRadius: 16).cgPath
        
        
    }

}
