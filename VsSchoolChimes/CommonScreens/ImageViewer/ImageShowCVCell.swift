//
//  ImageShowCVCell.swift
//  VsSchoolChimes
//
//  Created by chandhru on 18/11/24.
//

import UIKit
import WebKit

class ImageShowCVCell: UICollectionViewCell, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var WebView: WKWebView!
    @IBOutlet weak var FulView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var type = "Document"
    
    override func awakeFromNib() {
        super.awakeFromNib()

        FulView.layer.borderWidth = 0.5
        FulView.layer.borderColor = UIColor.black.cgColor

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        // Double tap gesture
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1.0 {
            scrollView.setZoomScale(2.5, animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
}

