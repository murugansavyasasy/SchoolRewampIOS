//
//  ImageShowCVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 18/11/24.
//

import UIKit
import WebKit

class ImageShowCVCell: UICollectionViewCell {

    @IBOutlet weak var WebView: WKWebView!
    @IBOutlet weak var FulView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var type = "Document"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        FulView.layer.borderWidth = 0.5
        FulView.layer.borderColor = UIColor.black.cgColor
//        if type == "Document" {
//            
//            if let pdfURL = URL(string: pdfUrl ?? "") {
//                let request = URLRequest(url: pdfURL)
//                pdfView.load(request)
//                
//            } else {
//                print("Invalid URL")
//            }
//        }
    }

}
