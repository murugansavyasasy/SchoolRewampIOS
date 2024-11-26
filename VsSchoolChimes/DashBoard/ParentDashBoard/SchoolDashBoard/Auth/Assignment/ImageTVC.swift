//
//  ImageTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 22/11/24.
//

import UIKit

class ImageTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var imageCollecctView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageCollecctView.delegate = self
        imageCollecctView.dataSource = self
        register()
        
    }

    func register(){

        let nib = UINib(nibName: "ImageCViewCell", bundle: nil)
        imageCollecctView.register(nib, forCellWithReuseIdentifier: "ImageCViewCell")

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollecctView.dequeueReusableCell(withReuseIdentifier: "ImageCViewCell", for: indexPath) as! ImageCViewCell
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

