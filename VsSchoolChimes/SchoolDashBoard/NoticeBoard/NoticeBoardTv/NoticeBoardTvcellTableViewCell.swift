//
//  NoticeBoardTvcellTableViewCell.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit
import SDWebImage

protocol SelectNotice: AnyObject {
    
    func didTapButton(title: String, content: String, items: [FilePath])
}

@available(iOS 14.0, *)
class NoticeBoardTvcellTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var HomeworkTitleTop: NSLayoutConstraint!
    @IBOutlet weak var SelectBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var HomeworkSubjectLbl: UILabel!
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
    @IBOutlet weak var newView: UIView!
    @IBOutlet weak var SelectBtn: UIButton!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    var delegate : SelectNotice?
    var ishomework = false
    var isreciver = false
    var issenderEvent = false
    var homeworkDocs:[FilePath]?
    var countShimmer = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        datelbl.setFont(style: .body, size: FontSize.BodySize)
        dicriptContent.setFont(style: .body, size: FontSize.BodySize)
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        SelectBtn.layer.cornerRadius = 10
        SelectBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        HomeworkSubjectLbl.isHidden = true
        HomeworkTitleTop.constant = 0
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
//        
//        dicriptContent.numberOfLines = 0
//        dicriptContent.setNeedsLayout()
//        dicriptContent.layoutIfNeeded()
        
        let collection = UINib(nibName:CellConfingName.ImagePdfCvCell, bundle: nil)
        collectionview.register(collection, forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        
        collectionview.delegate = self
        collectionview.dataSource = self
        
        pagecontroller.numberOfPages = homeworkDocs?.count ?? 0
        
        if let flowLayout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal  // Set the scroll direction to horizontal
            flowLayout.minimumLineSpacing = 10        // Set the space between cells
        }
        collectionview.reloadData()
        countShimmer = 1
        print("printing in awaken from nib")
    }
    func loadImage(urls:[FilePath]){
        homeworkDocs = urls
        collectionview.reloadData()
    }
    override func layoutSubviews() {
            super.layoutSubviews()
            dicriptContent.preferredMaxLayoutWidth = dicriptContent.frame.width
        }
    @IBAction func Select(_ sender: UIButton) {
                delegate?.didTapButton(title: TitleLbl.text!, content: dicriptContent.text!, items: homeworkDocs ?? [])
        
        
    }
    
    
    
    func hiddenui(_ hide:Bool){
        
        cellview.changeHeightAndAnimate(40, 110, 31, 80, top: 5)
        //fullView.changeHeightAndAnimate(40, 150, 21, 30, top: 5)
        pinImage.isHidden = hide
        SelectBtn.isHidden = hide
        datelbl.isHidden = hide
        dicriptContent.isHidden = hide
        TitleLbl.isHidden = hide
        Pinview.isHidden = hide
        SelectBtnHeight.constant = 25
        collectionview.isHidden = hide
        pagecontroller.isHidden = hide
        cellview.backgroundColor = .white
    }
    
    func animationview(){
        cellview.animateView(enable:true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [self] in
            // Code to execute after delay
            self.cellview.animateView(enable:false)
            cellview.parentview.isHidden = true
            //            pinImage.isHidden = false
            
            if ishomework == true{
                hideforHomework()
                print("ENTERED HOMEWORK")
            }else if isreciver == true{
                hideforReciverNotice()
            }else if issenderEvent == true{
                print("ENTERED event")
                hideforsenderEvent()
            }else{
                hiddenui(false)
                print("ENTERED Elsepart")
            }
            
        }
        
    }
    
    func hideforHomework(){
        HomeworkSubjectLbl.isHidden = false
        HomeworkTitleTop.constant = 15
        pinImage.isHidden = false
        datelbl.isHidden = false
        SelectBtnHeight.constant = 25
        Pinview.isHidden = false
        dicriptContent.isHidden = false
        TitleLbl.isHidden = false
        collectionview.isHidden = false
        SelectBtn.isHidden = false
        // pagecontroller.isHidden = false
        //        let color = true == true ? UIColor.dashBoardClr : UIColor.white
        cellview.backgroundColor = .white
    }
    func hideforReciverNotice(){
        HomeworkSubjectLbl.isHidden = true
        pinImage.isHidden = false
        datelbl.isHidden = false
        SelectBtnHeight.constant=0
        Pinview.isHidden = false
        dicriptContent.isHidden = false
        TitleLbl.isHidden = false
        collectionview.isHidden = false
        // pagecontroller.isHidden = false
        let color = true == true ? UIColor.dashBoardClr : UIColor.white
        cellview.backgroundColor = .white/*color*/
    }
    func hideforsenderEvent(){
        HomeworkSubjectLbl.isHidden = false
        pinImage.isHidden = true
        datelbl.isHidden = false
        SelectBtnHeight.constant=0
        Pinview.isHidden = true
        dicriptContent.isHidden = false
        TitleLbl.isHidden = false
        collectionview.isHidden = false
        pagecontroller.isHidden = false
        let color = true == true ? UIColor.dashBoardClr : UIColor.white
        cellview.backgroundColor = .white/*color*/
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
        
        if homeworkDocs?.count == 0{
            CVHeight.constant = 0
        }else {
            CVHeight.constant = 130
        }
        return homeworkDocs?.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        if let img = homeworkDocs?[indexPath.row]{
            cell.imageView
                .sd_setImage(
                    with: URL(string: img.url ?? ""),
                    placeholderImage: ImageName.placeholder
                )
        }
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
        vcc.imageURL = homeworkDocs ?? []
        vcc.subjectName = HomeworkSubjectLbl.text
        vcc.type = 2
        vcc.modalPresentationStyle = .fullScreen
        vc?.present(vcc, animated: true)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 135)
    }
    
    
}
