//
//  LSWViewAttachmentTVC.swift
//  School Chimes
//
//  Created by Chandhru on 09/07/25.
//

import UIKit
import WebKit

class LSWViewAttachmentTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var pageViewController: UIPageControl!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imagesView: UIView!
    @IBOutlet weak var videoPlayer: WKWebView!
    @IBOutlet weak var imageCollection: UICollectionView!
    var filePath: [FilePath]?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let collection = UINib(nibName: CellConfingName.ImagePdfCvCell, bundle: nil)
        imageCollection.register(collection, forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        imageCollection.delegate = self
        imageCollection.dataSource = self
    }
    func loadFilePath(_ filePath:[FilePath]){
        self.filePath = filePath
        if filePath.first?.type?.uppercased() == "VIDEO"{
            if let url = URL(string: filePath.first?.url ?? "") {
             let request = URLRequest(url: url)
             videoPlayer.load(request)
             }
        }
        pageViewController.numberOfPages = filePath.count
        pageViewController.currentPage = 0
        imageCollection.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filePath?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        if let img = filePath?[indexPath.row] {
            let fileURL = URL(fileURLWithPath: img.url ?? "")
            let iconName = getFileIconName(for: fileURL)
            
            if iconName != "image"{
                if let pdfURL = URL(string: img.url ?? "") {
                    cell.hide = false
                      let request = URLRequest(url: pdfURL)
                    cell.webView.load(request)
                    cell.webView.isHidden = false
                    cell.imageView.isHidden = true
                  } else {
                      cell.webView.isHidden = true
                      cell.imageView.isHidden = false
                  }
            }else{
                cell.hide = false
                cell.webView.isHidden = true
                cell.imageView.isHidden = false
                cell.imageView.sd_setImage(with: URL(string: img.url ?? ""), placeholderImage: ImageName.placeholder)
                
              
            }
            let iconImage = UIImage(named: iconName)
            cell.IndicaterImageView.image = iconImage
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let maxVisibleIndex = collectionView.indexPathsForVisibleItems.map({ $0.item }).max() {
            pageViewController.currentPage = maxVisibleIndex
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
