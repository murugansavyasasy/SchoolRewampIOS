//
//  CoupenDetailTVC.swift
//  rewardDesign
//
//  Created by admin on 19/02/25.
//

import UIKit

class CoupenDetailTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
   
    @IBOutlet weak var collectView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Register the collection view cell
        collectView.register(UINib(nibName: "CoupenDetailCVC", bundle: nil), forCellWithReuseIdentifier: "CoupenDetailCVC")
        
        // Set delegate & dataSource
        collectView.delegate = self
        collectView.dataSource = self
    }

    // Ensure proper reloading when the cell is reused
    override func prepareForReuse() {
        super.prepareForReuse()
        collectView.reloadData()
    }

    // MARK: - UICollectionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1  // If dynamic, replace with array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoupenDetailCVC", for: indexPath) as! CoupenDetailCVC
        return cell
    }

    // MARK: - UICollectionView DelegateFlowLayout Method
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
