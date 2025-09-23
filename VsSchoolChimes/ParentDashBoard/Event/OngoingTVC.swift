//
//  OngoingTVC.swift
//  School Chimes
//
//  Created by Chandhru on 22/07/25.
//

import UIKit
import Kingfisher

class OngoingTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!

    var type = false
    var onGoing: [EventList]?
    var category: [EventCategory]?
    var delegate:FilterCatagories?
    var selectedIndex : Int?
    let transitionDelegate = TransitioningDelegate()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: "OngoingCVC", bundle: nil), forCellWithReuseIdentifier: "OngoingCVC")
        collectionView.register(UINib(nibName: "CatogoryCVC", bundle: nil), forCellWithReuseIdentifier: "CatogoryCVC")
    }

    func config(category: [EventCategory]?, onGoing: [EventList]?, type: Bool,index:Int) {
        self.category = category
        self.onGoing = onGoing
        self.selectedIndex = index
//        pageController.isHidden = type && onGoing?.count ?? 0<1
        self.type = type
        collectionView.isPagingEnabled = !type
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type ? (category?.count ?? 0) : (onGoing?.count ?? 0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if type {
            // Animate tap
            if let cell = collectionView.cellForItem(at: indexPath) {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }) { _ in
                    UIView.animate(withDuration: 0.1) {
                        cell.transform = .identity
                    }
                }
            }

            // Track selection and refresh visuals
//            selectedIndex = indexPath.item
//            collectionView.reloadData()

            // Delegate should be called after reload is applied
            DispatchQueue.main.async {
                self.delegate?.filterCatagories(name: self.category?[indexPath.item].name ?? "")
            }

        }else{
            guard let notice = onGoing?[indexPath.item],
                             let attributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }

                       let cellFrameInSuperview = collectionView.convert(attributes.frame, to: self.window)
                       let detailVC = PrivewVc()
                       detailVC.attachmetList = notice.file_path
                       detailVC.selectedDate = notice.date
                       detailVC.titleString = notice.title
                       detailVC.descriptionString = notice.description
                       detailVC.subject_name = "Event".translated()
                       detailVC.postedBy = notice.sent_by
                       detailVC.modalPresentationStyle = .custom
                       transitionDelegate.originFrame = cellFrameInSuperview
                       detailVC.transitioningDelegate = transitionDelegate
                       getCurrentViewController()?.present(detailVC, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if type {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatogoryCVC", for: indexPath) as? CatogoryCVC,
                  let categoryItem = category?[indexPath.item] else {
                return UICollectionViewCell()
            }
            let isSelected = indexPath.item == selectedIndex

            // Shadow and border for selected cell
            if isSelected {
                cell.outerView.setShadow(shadowColor: .blue, shadowOpacity: 0.6, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 8)
                cell.outerView.layer.borderColor = UIColor.systemBlue.cgColor
                cell.outerView.layer.borderWidth = 2
            } else {
                cell.outerView.setShadow(shadowOpacity: 0)
                cell.outerView.layer.borderColor = UIColor.clear.cgColor
                cell.outerView.layer.borderWidth = 0
            }
            cell.iconheight.constant = categoryItem.url == "" ? 0:50
            cell.titleLbl.text = categoryItem.name ?? ""
            cell.iconImg.kf.setImage(with: URL(string: categoryItem.url ?? ""))
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OngoingCVC", for: indexPath) as? OngoingCVC,
                  let event = onGoing?[indexPath.item] else {
                return UICollectionViewCell()
            }
            cell.dateLbl.text = "\(event.category)  \(event.time) - \(event.date.convertToTargetDateFormat() ?? "")"
            cell.placeLbl.text = event.venue
            cell.titleLbl.text = event.title
            cell.descriptionLbl.text = event.description
            loadFiles(into: cell, files: event.file_path)
            cell.attacmentView.isHidden = event.file_path.count ==  0
            return cell
        }
    }
    private func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }
    func loadFiles(into cell: OngoingCVC, files: [FilePath]) {
        [cell.img1, cell.img2, cell.img3].forEach { $0?.isHidden = true }
        cell.imgCount.isHidden = true
        
        for (index, item) in files.enumerated() {
            // Only process first 3 files for display
            guard index < 3 else { break }
            
            guard let urlString = item.url, let url = URL(string: urlString) else { continue }
            
            // Safe array access
            let imageViews = [cell.img1, cell.img2, cell.img3]
            guard index < imageViews.count, let imageView = imageViews[index] else { continue }
            
            imageView.isHidden = false
            
            if item.type?.lowercased() != "image" {
                let iconName = getFileIconName(for: url)
                imageView.image = UIImage(named: iconName)
            } else {
                imageView.kf.setImage(with: url)
            }
        }
        
        // Handle extra files count display
        if files.count > 3 {
            let extraCount = files.count - 3
            if let button = cell.imgCount as? UIButton {
                button.setTitle("+\(extraCount)", for: .normal)
                cell.imgCount.isHidden = false
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !type {
            let pageWidth = scrollView.frame.size.width
            let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
            pageController.currentPage = currentPage

            // Zoom animation on center cell
            let centerX = scrollView.contentOffset.x + (scrollView.frame.width / 2)
            for cell in collectionView.visibleCells {
                let basePosition = cell.convert(cell.bounds, to: self.contentView)
                let cellCenterX = basePosition.midX
                let distance = abs(centerX - cellCenterX)

                let maxScale: CGFloat = 1.0
                let minScale: CGFloat = 0.92
                let scale = max(minScale, maxScale - (distance / scrollView.frame.width * 0.2))

                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resetCellTransforms()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            resetCellTransforms()
        }
    }

    private func resetCellTransforms() {
        for cell in collectionView.visibleCells {
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform.identity
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if type {
            return CGSize(width: 100, height: 130)
        } else {
            return CGSize(width: collectionView.frame.width, height: 210)
        }
    }
}
