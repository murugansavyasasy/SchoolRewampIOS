//
//  AttachmentViewerCollectionViewCell.swift
//  School Chimes
//
//  Created by Chandhru on 13/05/25.
//

import UIKit

class AttachmentViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.zoomScale = 1.0
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
        setZoomToFit()
    }
    
    //    private func setZoomToFit() {
    //        guard let image = imageView.image else { return }
    //
    //        let scrollViewSize = scrollView.bounds.size
    //        let imageSize = image.size
    //
    //        let widthScale = scrollViewSize.width / imageSize.width
    //        let heightScale = scrollViewSize.height / imageSize.height
    //        let minScale = min(widthScale, heightScale)
    //
    //        scrollView.minimumZoomScale = minScale
    //        scrollView.zoomScale = minScale
    //
    //        centerImage()
    //    }
    private func setZoomToFit() {
        guard let image = imageView.image else { return }

        scrollView.frame = self.bounds
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size
        
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        // Set appropriate zoom scales
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = min(minScale * 5, 3.0) // Limit max zoom to avoid zooming out of cell bounds
        scrollView.zoomScale = minScale
        
        // Resize the imageView to fit inside scrollView based on scale
        let imageViewWidth = imageSize.width * minScale
        let imageViewHeight = imageSize.height * minScale
        imageView.frame = CGRect(x: 0, y: 0, width: imageViewWidth, height: imageViewHeight)
        
        scrollView.contentSize = imageView.frame.size
        
        centerImage()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
    
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        
        let horizontalInset = max(0, (scrollViewSize.width - imageSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - imageSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

