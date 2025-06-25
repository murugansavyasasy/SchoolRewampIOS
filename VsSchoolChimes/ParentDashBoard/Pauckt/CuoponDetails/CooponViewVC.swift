//
//  CooponViewVC.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 20/02/25.
//  Copyright © 2025 Gayathri. All rights reserved.
//

import UIKit
import SDWebImage
class CooponViewVC: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var cv: UICollectionView!
    var currentIndex = 0
    var autoScrollTimer: Timer?
    var timer: Timer?
    var source_Link : String?
    var Category : String?
    var ThumbnailImg : String?
    var ActivatedStatus: String?
    var totalPoints: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        shareBtn.layer.cornerRadius = 15
        likeBtn.layer.cornerRadius = 15
        backBtn.layer.cornerRadius = 15
        likeBtn.isHidden = true
        shareBtn.isHidden = true
        cv.register(UINib(nibName: "CVCell", bundle: nil), forCellWithReuseIdentifier: "CVCell")
        cv.delegate = self
        cv.dataSource = self
//        startAutoScroll()
        view.bringSubviewToFront(backBtn)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
//            let detailViewController = BottomView()
//            detailViewController.category = Category
//            detailViewController.sourceLink = source_Link
//            detailViewController.CouponStatus = ActivatedStatus
//            detailViewController.totalPoints = totalPoints
//            
//            let nav = UINavigationController(rootViewController: detailViewController)
//            
//            // 1 - Set modal presentation style
//            nav.modalPresentationStyle = .pageSheet
//            
//            // 2 - Configure bottom sheet
//            if let sheet = nav.sheetPresentationController {
//                if #available(iOS 16.0, *) {
//                    sheet.detents = [.custom { _ in 470 }, .large()]
//                }
//                sheet.prefersGrabberVisible = false // Hide grabber
//                sheet.largestUndimmedDetentIdentifier = .large // REMOVE BACKGROUND DIMMING
//            }
//            
//            // 3 - Prevent dismiss on swipe down
//            nav.isModalInPresentation = true
//            // 4 - Present the bottom sheet
//            present(nav, animated: true)
//        }
        
    }
//    func startAutoScroll() {
//        autoScrollTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
//    }
//    
//    @objc func autoScroll() {
//        let nextIndex = (currentIndex + 1) % 3
//        let nextIndexPath = IndexPath(item: nextIndex, section: 0)
//        cv.scrollToItem(at: nextIndexPath, at: .right, animated: true)
//        currentIndex = nextIndex
//        
//    }
//    
//    @objc func stopAutoScroll() {
//        autoScrollTimer?.invalidate()
//        autoScrollTimer = nil
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVCell", for: indexPath) as! CVCell
        cell.BannerImg.sd_setImage(with: URL(string: ThumbnailImg ?? ""), placeholderImage: UIImage(named: ""), options: SDWebImageOptions.refreshCached)
        return cell
    }
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true){
            self.dismiss(animated: true)
        }
    }
    @IBAction func share(_ sender: UIButton) {
        let url = URL(string: "https://www.example.com")! // Replace with your actual URL
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // For iPad support
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(activityVC, animated: true)
    }
    
    @IBAction func addFav(_ sender: UIButton) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height:collectionView.frame.height)
    }
    
    
   
}
