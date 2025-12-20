//
//  QuestionTVC.swift
//  School Chimes
//
//  Created by Chandhru on 17/12/25.
//

import UIKit
import WebKit

class QuestionTVC: UITableViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var markLbl: UILabel!
    @IBOutlet weak var imgView: UIView!
    @IBOutlet weak var qstCountLbl: UILabel!
    @IBOutlet weak var qstLbl: UILabel!
    @IBOutlet weak var filePathCV: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    var attachment: [FilePath]?
    var parentController:UIViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        filePathCV.register(UINib(nibName: "ImageShowCVCell", bundle: nil), forCellWithReuseIdentifier: "ImageShowCVCell")
        filePathCV.register(UINib(nibName: "VideoPlayerCVC", bundle: nil), forCellWithReuseIdentifier: "VideoPlayerCVC")
        filePathCV.delegate = self
        filePathCV.dataSource = self
        pageController.currentPage = 0
    }
    func conficList(filePath: [FilePath]) {
        attachment = filePath
        pageController.numberOfPages = filePath.count
        pageController.currentPage = 0
        filePathCV.setContentOffset(.zero, animated: false)
        filePathCV.reloadData()
    }

}
extension QuestionTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachment?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let attachments = attachment,
              !attachments.isEmpty,
              indexPath.item < attachments.count else {
            return UICollectionViewCell()
        }

        let item = attachments[indexPath.item]
        let fileType = item.type?.lowercased() ?? ""

        switch fileType {

        // MARK: - Image
        case "image", "jpg", "jpeg", "png":
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.ImageShowCVCell,
                for: indexPath
            ) as! ImageShowCVCell

            cell.imageView.isHidden = false
            cell.WebView.isHidden = true

            if let urlStr = item.url, let imageURL = URL(string: urlStr) {
                cell.imageView.sd_setImage(
                    with: imageURL,
                    placeholderImage: UIImage(named: "placeholder")
                )
            } else {
                cell.imageView.image = UIImage(named: "placeholder")
            }

            return cell

        // MARK: - Video
        case "video", "mp4", "mov":
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.VideoPlayerCVC,
                for: indexPath
            ) as! VideoPlayerCVC

            if let urlStr = item.url, let videoURL = URL(string: urlStr) {
                cell.configure(
                    with: videoURL,
                    parentVC: parentController ?? UIViewController()
                )
            }

            return cell

        // MARK: - PDF / Docs / Other
        default:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.ImageShowCVCell,
                for: indexPath
            ) as! ImageShowCVCell

            cell.imageView.isHidden = true
            cell.WebView.isHidden = false

            if let urlStr = item.url, let url = URL(string: urlStr) {
                cell.WebView.load(URLRequest(url: url))
            }

            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: filePathCV.frame.width, height: filePathCV.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: filePathCV.contentOffset, size: filePathCV.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let count = attachment?.count ?? 0
        
        guard let indexPath = filePathCV.indexPathForItem(at: visiblePoint), indexPath.item < count else {
            print("❌ Invalid index during scroll")
            return
        }
        pageController.currentPage = indexPath.item
    }
}

extension QuestionTVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        print("❌ WebView failed: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        print("❌ Provisional navigation failed: \(error.localizedDescription)")
    }
}
