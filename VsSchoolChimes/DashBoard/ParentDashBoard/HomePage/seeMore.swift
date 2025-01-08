//
//  seeMore.swift
//  VsSchoolChimes
//
//  Created by admin on 30/12/24.
//

import UIKit

class seeMore: UICollectionViewCell,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    
    @IBOutlet weak var pageContorler: UIPageControl!
    @IBOutlet weak var adCollectionView: UICollectionView! // Embedded collection view
    @IBOutlet weak var seeAllButton: UIButton!
    var advertisements: [String] = []
    var currentIndex = 0
    var autoScrollTimer: Timer?
    var timer: Timer?
    var imageItems = ["Download2","sale-banner-templates","Download3"]
    override func awakeFromNib() {
        super.awakeFromNib()

        
//        adCollectionView.layer.cornerRadius = 10
        adCollectionView.delegate = self
        adCollectionView.dataSource = self
        
        
        adCollectionView.register(UINib(nibName: CellConfingName.addCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.addCvCell)
        
        startAutoScroll()
        NotificationCenter.default.addObserver(self, selector: #selector(stopAutoScroll), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAutoScroll), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
      
//    adCollectionView.layer.cornerRadius = 10
        
    }
    func startAutoScroll() {
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
    }
    
    @objc func autoScroll() {
        let nextIndex = (currentIndex + 1) % 3
        let nextIndexPath = IndexPath(item: nextIndex, section: 0)
        adCollectionView.scrollToItem(at: nextIndexPath, at: .right, animated: true)
        currentIndex = nextIndex
        pageContorler.currentPage = currentIndex
        
    }
    
    @objc func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    // MARK: - CollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.addCvCell, for: indexPath) as! addCvCell
        cell.imageView.image = UIImage(named: imageItems[indexPath.row])
        cell.imageView.layer.cornerRadius = 5
        return cell
    }
    
    // MARK: - CollectionView Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: adCollectionView.frame.width, height: adCollectionView.frame.height+50)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
            currentIndex = indexPath.row
            self.pageContorler.currentPage = indexPath.row
        
    }
    

}
