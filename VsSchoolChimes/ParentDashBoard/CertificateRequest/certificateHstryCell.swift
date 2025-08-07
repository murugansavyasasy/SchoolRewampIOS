//
//  certificateHstryCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 07/08/25.
//

import UIKit

class certificateHstryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "certificateHstryCvCell",
            for: indexPath
        ) as? certificateHstryCvCell else{
            return UICollectionViewCell()
        }
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        let vc  = CertificatePreviewVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        let currentController = getCurrentViewController()
        currentController?.present(vc, animated: true)
        
        
    }
    func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.width)/2
        return CGSize(width: size , height:130 )
    }

    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    @IBOutlet weak var cv: UICollectionView!
    let transitionDelegate = TransitioningDelegate()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cv
            .register(
                UINib(nibName: "certificateHstryCvCell", bundle: nil),
                forCellWithReuseIdentifier: "certificateHstryCvCell"
            )
        cv.delegate = self
        cv.dataSource = self
    }

    
    func configure() {
        cv.isScrollEnabled = false
           cv.reloadData()
           updateCollectionViewHeight()
       }

       func updateCollectionViewHeight() {
           let height = cv.collectionViewLayout.collectionViewContentSize.height
           cvHeight.constant = height
       }
    
   

       func collectionContentHeight() -> CGFloat {
           return cv.collectionViewLayout.collectionViewContentSize.height
       }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
