//
//  seeMore.swift
//  VsSchoolChimes
//
//  Created by admin on 30/12/24.
//

import UIKit

class seeMore: UICollectionViewCell,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    
    
    @IBOutlet weak var adCollectionView: UICollectionView! // Embedded collection view
    @IBOutlet weak var seeAllButton: UIButton! // Button to toggle "See All" or "Show Less"
    
    var advertisements: [String] = [] // Array to store advertisement data
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        adCollectionView.delegate = self
        adCollectionView.dataSource = self
        
        adCollectionView.register(UINib(nibName: "addCvCell", bundle: nil), forCellWithReuseIdentifier: "addCvCell")
    }
    
    // MARK: - CollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return advertisements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCvCell", for: indexPath) as! addCvCell
      
        return cell
    }
    
    // MARK: - CollectionView Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: adCollectionView.frame.width, height: adCollectionView.frame.height+50)
    }
}
