//
//  AttachmentCvCollectionViewCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 05/05/25.
//

import UIKit
import WebKit

class AttachmentCvCollectionViewCell: UICollectionViewCell {
    enum Constants {
        static let padding: CGFloat = 8
        static let font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    }
   
    @IBOutlet weak var webview: WKWebView!

    @IBOutlet weak var sentBy: UILabel!
    @IBOutlet weak var timeAndDate: UILabel!
    @IBOutlet weak var discreptionLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        
//        lblcon.constant = Constants.padding
    }
    
    
    
    
    func loadVimeoVideo(iframe: String) {
        let htmlString = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>body, html { margin: 0; padding: 0; }</style>
        </head>
        <body>
        \(iframe)
        </body>
        </html>
        """
        webview.loadHTMLString(htmlString, baseURL: nil)
    }

}
