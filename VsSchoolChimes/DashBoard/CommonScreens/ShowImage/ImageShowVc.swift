//
//  ImageShowVc.swift
//  VsSchoolChimes
//
//  Created by admin on 18/11/24.
//

import UIKit
import SDWebImage

class ImageShowVc: UIViewController {

    @IBOutlet weak var cv: UICollectionView!
    
    
    var imageIterms : [String] = []
    var imageURL : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        cv.delegate = self
        cv.dataSource = self
        
        cv.register(UINib(nibName: CellConfingName.ImageShowCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageShowCVCell)
        
       
    }


    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true)
    }
    

}

extension ImageShowVc : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageShowCVCell, for: indexPath) as! ImageShowCVCell
        
        cell.imageView.sd_setImage(with: URL(string: imageURL[indexPath.row]), placeholderImage: UIImage(named: "placeholder"))
//        cell.imageView.image = UIImage(named: imageIterms[indexPath.row])
        
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: 350, height: 600)
    
    }
    
    
}
