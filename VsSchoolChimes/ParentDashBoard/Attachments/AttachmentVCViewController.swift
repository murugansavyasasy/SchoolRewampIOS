//
//  AttachmentVCViewController.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 05/05/25.
//

import UIKit

class AttachmentVCViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    
//    private func setupViews() {
//        collectionView.contentInsetAdjustmentBehavior = .never
//        collectionView.contentInset = UIEdgeInsets(top: 115, left: 6, bottom: 0, right: 6)
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        
//        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: Constants.imageCellID)
//        collectionView.register(BannerView.self, forSupplementaryViewOfKind: PinterestLayout.elementKindBanner, withReuseIdentifier: Constants.bannerID)
//        
//        pinterestLayout.delegate = self
//        pinterestLayout.numberOfColumns = 2
//        pinterestLayout.cellPadding = 6
//        
//    }
//}
//
//
//extension AttachmentVCViewController: PinterestLayoutDelegate {
//    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
//        let image = houseImages[indexPath.item]
//        let text = houseLabels[indexPath.item]
//        
//        let width = image?.size.width ?? 0
//        let height = image?.size.height ?? 0
//        let scaledImageHeight = (height * layout.cellWidth) / width
//        
//        let padding = ImageCell.Constants.padding
//        
//        let labelHeight = text.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
//        
//        return scaledImageHeight + padding + labelHeight
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout, heightForBannerAtIndexPath indexPath: IndexPath) -> CGFloat {
//        return 300
//    }
//    
//    func numberOfItemsBeforeAds(in collectionView: UICollectionView) -> Int {
//        return 10
//    }
//    
//
//}
//
//extension AttachmentVCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return numberOfCells
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCellID, for: indexPath)
//        let cell = dequeuedCell as? ImageCell ?? ImageCell()
//        cell.imageView.image = houseImages[indexPath.item]
//        cell.TitleLbl.text = houseLabels[indexPath.item]
//        cell.discreptionLbl.text = "saran"
//        return cell
//    }
//    
//     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        switch kind {
//        case PinterestLayout.elementKindBanner:
//            let dequeuedBanner = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.bannerID, for: indexPath) as? BannerView
//            let cell = dequeuedBanner ?? BannerView()
//            cell.imageView.image = UIImage(named: "testAd")
//            return cell
//        default:
//            fatalError()
//        }
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
//        
//        let dy = offsetY > 0 ? -offsetY : 0
//        titleLabel.transform = CGAffineTransform(translationX: 0, y: dy)
//    }
//    
//}
//
//extension String {
//    func heightFitting(width: CGFloat, font: UIFont) -> CGFloat {
//        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
//        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
//        return boundingBox.height
//    }
}
