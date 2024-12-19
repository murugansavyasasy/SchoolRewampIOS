//
//  NoticeBoardTvcellTableViewCell.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit
import SDWebImage

protocol SelectNotice: AnyObject {
    
    func didTapButton(title: String, content: String, items: [String])
}

@available(iOS 14.0, *)
class NoticeBoardTvcellTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var HomeworkTitleLbl: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    
    @IBOutlet weak var dicriptContent: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var CVHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var cellview: AnimatView!
    
    @IBOutlet weak var Pinview: UIView!
    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pagecontroller: UIPageControl!
    
    @IBOutlet weak var pagecontrollerheight: NSLayoutConstraint!
    
    
    @IBOutlet weak var SelectBtn: UIButton!
    var delegate : SelectNotice?
    var ishomework = false

    let imgs: [String] = ["https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/27-11-2024/File_vc_-5346401391795845263.png","https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/27-11-2024/File_vc_-5346401391795387749.png","https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/27-11-2024/File_vc_-5346401391797604035.png"]
    

    var countShimmer = 0
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        datelbl.setFont(style: .title, size: FontSize.TitleSize)
        dicriptContent.setFont(style: .body, size: FontSize.BodySize)
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        HomeworkTitleLbl.isHidden = true
        CVHeight.constant = 0  // set this to 120 when you need
        pagecontrollerheight.constant = 0  // set this to 26 when you need
        pagecontroller.isHidden = true
        hiddenui(true)
        animationview()
        
        cellview.layer.cornerRadius = 10
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        cellview.layer.masksToBounds = false
        
        Pinview.layer.cornerRadius = Pinview.frame.width/2
        
         dicriptContent.numberOfLines = 0
          dicriptContent.setNeedsLayout()
          dicriptContent.layoutIfNeeded()
        
       

        
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
        countShimmer = 1
    }
    
    @IBAction func Select(_ sender: UIButton) {
        delegate?.didTapButton(title: TitleLbl.text!, content: dicriptContent.text!, items: imgs)
        
        
    }
    
    
    
    func hiddenui(_ hide:Bool){
        
       // cellview.changeHeightAndAnimate(40, 110, 31, 80, top: 5)
        pinImage.isHidden = hide
        datelbl.isHidden = hide
        dicriptContent.isHidden = hide
        TitleLbl.isHidden = hide
        pinImage.isHidden = hide
        Pinview.isHidden = hide
        collectionview.isHidden = hide
        pagecontroller.isHidden = hide
        let color = hide == true ? UIColor.dashBoardClr : UIColor.white
        cellview.backgroundColor = .white
    }
    
    func animationview(){
        cellview.animateView(enable:true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [self] in
            // Code to execute after delay
            self.cellview.animateView(enable:false)
            cellview.parentview.isHidden = true
            pinImage.isHidden = false
            
            if ishomework == true{
                hideforHomework()
            }else{
                
                hiddenui(false)
            }
            
        }
        
    }
    
    func hideforHomework(){
        HomeworkTitleLbl.isHidden = false
        pinImage.isHidden = true
        datelbl.isHidden = true
        Pinview.isHidden = true
        dicriptContent.isHidden = false
        TitleLbl.isHidden = false
        collectionview.isHidden = false
       // pagecontroller.isHidden = false
        let color = true == true ? UIColor.dashBoardClr : UIColor.white
        cellview.backgroundColor = color
    }
    
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        if countShimmer == 1{
//            cellview.animateView(enable:true)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) { [self] in
//                // Code to execute after delay
//                cellview.animateView(enable:false)
//                countShimmer = 2
//                pinImage.isHidden = false
//            }
//        }
//    }
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
        
        cell.imageView.sd_setImage(with: URL(string: imgs[indexPath.row]), placeholderImage: ImageName.placeholder)
        
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
        vcc.type = 2
        vcc.modalPresentationStyle = .fullScreen

        vc?.present(vcc, animated: true)
        
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
//        return CGSize(width: width, height: width)
        
        return CGSize(width: 250, height: 135)
    }
    
    
}
