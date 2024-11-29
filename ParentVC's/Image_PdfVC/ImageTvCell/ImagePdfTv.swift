//
//  ImagePdfTv.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit

class ImagePdfTv: UITableViewCell {

    @IBOutlet weak var GifImage: UIImageView!
    @IBOutlet weak var fullView: ShimmerView!
    @IBOutlet weak var DescriptionLbl: UILabel!
  
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    
    var imageIterms = ["DemoImage","maths","RealHomeWorkimage","RealImage"]
    let imgs: [String] = ["https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/27-11-2024/File_vc_-5346401391795845263.png","https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/27-11-2024/File_vc_-5346401391795387749.png","https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/27-11-2024/File_vc_-5346401391797604035.png","https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/27-11-2024/File_vc_-5346401391799793266.png","https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/27-11-2024/File_vc_-5346401391801142838.png"]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let gifImage = UIImage.gifImageWithName("New")
                //
        GifImage.image = gifImage
        fullView.layer.shadowColor = UIColor.black.cgColor
        fullView.layer.shadowOpacity = 0.5
        fullView.layer.shadowOffset = CGSize(width: 4, height: 4)
        fullView.layer.shadowRadius = 3
        fullView.layer.masksToBounds = false
        fullView.layer.cornerRadius  = Colornames.CORadius10
        cv.delegate = self
        cv.dataSource = self
        
        cv.register(UINib(nibName: CellConfingName.ImagePdfCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
     
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
    }
    
    
    
    
    
}


extension ImagePdfTv : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
//    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return imageIterms.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        
       // cell.imageView.image = UIImage(named: imageIterms[indexPath.row])
        
        cell.imageView.sd_setImage(with: URL(string: imgs[indexPath.row]), placeholderImage: UIImage(named: "placeholder"))
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
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//       
//        let vc = getCurrentViewController()
//
//        let vcc = ImageShowVc(nibName: nil, bundle: nil)
//        vcc.imageIterms = imageIterms
//        vcc.modalPresentationStyle = .fullScreen
//
//        vc?.present(vcc, animated: true)
//        
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
        let vc = getCurrentViewController()

        let vcc = ImageShowVc(nibName: nil, bundle: nil)
       // vcc.imageIterms = imgs
        vcc.imageURL = imgs
        vcc.type = 2
        vcc.modalPresentationStyle = .fullScreen

        vc?.present(vcc, animated: true)
        
    }

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
  
        return CGSize(width: 250, height: 110)
   
}
    
//    
//    
//    
}
