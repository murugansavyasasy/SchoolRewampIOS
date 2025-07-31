//
//  PreviewCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 22/07/25.
//

import UIKit
import WebKit

class PreviewCell: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var webview: WKWebView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

