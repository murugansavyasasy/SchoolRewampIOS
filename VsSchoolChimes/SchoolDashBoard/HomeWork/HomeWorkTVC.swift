//
//  HomeWorkTVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 16/04/25.
//

import UIKit

class HomeWorkTVC: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{

    

    @IBOutlet weak var newView: UIImageView!
    @IBOutlet weak var forwordBtn: UIButton!
    @IBOutlet weak var dateLble: ShimmerLabel!
    @IBOutlet weak var descriptionLbl: ShimmerLabel!
    @IBOutlet weak var topics: ShimmerLabel!
    @IBOutlet weak var pageViewController: UIPageControl!
    @IBOutlet weak var ImageCollectionView: UICollectionView!
    @IBOutlet weak var subjectName: ShimmerLabel!
    @IBOutlet weak var Pinview: UIView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var SelectBtnHeight: NSLayoutConstraint!
    var delegate : SelectNotice?
    var ishomework = false
    var isreciver = false
    var issenderEvent = false
    var homeworkDocs:[FilePath]?
    var countShimmer = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateLble.setFont(style: .body, size: FontSize.BodySize)
        descriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        topics.setFont(style: .title, size: FontSize.TitleSize)
        forwordBtn.layer.cornerRadius = 10
        forwordBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        cellview.layer.cornerRadius = 10
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        cellview.layer.masksToBounds = false
        
        Pinview.layer.cornerRadius = Pinview.frame.width/2
        let collection = UINib(nibName:CellConfingName.ImagePdfCvCell, bundle: nil)
        ImageCollectionView.register(collection, forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        
        ImageCollectionView.delegate = self
        ImageCollectionView.dataSource = self
        
        pageViewController.numberOfPages = homeworkDocs?.count ?? 0
        
        if let flowLayout = ImageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 10        // Set the space between cells
        }
        ImageCollectionView.reloadData()
        countShimmer = 1
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        configureShimmer()
    }
    func loadImage(urls:[FilePath]){
        ImageCollectionView.isHidden = false
        homeworkDocs = urls
        ImageCollectionView.reloadData()
    }
    @IBAction func forword(_ sender: UIButton) {
        delegate?.didTapButton(title: topics.text!, content: descriptionLbl.text!, items: homeworkDocs ?? [])
    }

    func configureShimmer() {
        
        dateLble.removeShimmer()
        descriptionLbl.removeShimmer()
        topics.removeShimmer()
        subjectName.removeShimmer()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeworkDocs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        if let img = homeworkDocs?[indexPath.row]{
            cell.imageView.sd_setImage(with: URL(string: img.path ?? ""), placeholderImage: ImageName.placeholder)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height:ImageCollectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = getCurrentViewController()
        let vcc = ImageShowVc(nibName: nil, bundle: nil)
        vcc.imageURL = homeworkDocs ?? []
        vcc.subjectName = subjectName.text
        vcc.type = 2
        vcc.modalPresentationStyle = .fullScreen
        vc?.present(vcc, animated: true)
        
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
}
