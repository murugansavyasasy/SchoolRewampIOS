//
//  NoticeBoardTvcellTableViewCell.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit
import SDWebImage

@available(iOS 14.0, *)
class NoticeBoardTvcellTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var CVHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var cellview: UIView!
    
    @IBOutlet weak var Pinview: UIView!
    
    @IBOutlet weak var pagecontroller: UIPageControl!
    
//    let imgs: [String] = [ "ImagePdf", "Circulars", "Homework","ImagePdf"]
    let imgs: [String] = [ "https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/20-11-2024/File_vc_-7402800388508860765.png", "https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/20-11-2024/File_vc_-7402800388492478013.png", "https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/20-11-2024/File_vc_-7402800388509938245.png","https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/20-11-2024/File_vc_-7402800388496770445.png"]

    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellview.layer.cornerRadius = 10
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        cellview.layer.masksToBounds = false
        
        Pinview.layer.cornerRadius = Pinview.frame.width/2
        
//        let collection = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
//        collectionview.register(collection, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        let collection = UINib(nibName:CellConfingName.ImagePdfCvCell, bundle: nil)
        collectionview.register(collection, forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        
       
        collectionview.delegate = self
        collectionview.dataSource = self
        
        pagecontroller.numberOfPages = imgs.count
        
        if let flowLayout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.scrollDirection = .horizontal  // Set the scroll direction to horizontal
                    flowLayout.minimumLineSpacing = 10        // Set the space between cells
                }
        collectionview.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if imgs.count == 0{
            CVHeight.constant = 0
        }
       else {
            
            CVHeight.constant = 150
        }
        

        return imgs.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"ImagePdfCvCell" , for: indexPath) as! ImagePdfCvCell
//
//        cell.imageView.image = UIImage(named: imgs[indexPath.row])
        cell.imageView.sd_setImage(with: URL(string: imgs[indexPath.row]), placeholderImage: UIImage(named: "placeholder"))
        //cell.imageView.image =
      //  cell.TrashIcon.isHidden = true
        
        return cell
    }
    
    func getCurrentViewController() -> UIViewController? {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
        let vc = getCurrentViewController()

        let vcc = ImageShowVc(nibName: nil, bundle: nil)
       // vcc.imageIterms = imgs
        vcc.imageURL = imgs
        vcc.modalPresentationStyle = .fullScreen

        vc?.present(vcc, animated: true)
        
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
//        return CGSize(width: width, height: width)
        
        return CGSize(width: 250, height: 135)
    }
    
}
