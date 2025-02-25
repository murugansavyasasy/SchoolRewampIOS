//
//  parentPTMcell.swift
//  VsSchoolChimes
//
//  Created by MacBook on 20/02/25.
//

import UIKit

class parentPTMcell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TimeCollectionViewCell
        cell.timelbl.text = "07 : 00 AM"
//        if indexPath.row == 9{
//            cvHeight.constant = cv.collectionViewLayout.collectionViewContentSize.height
//        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cv.frame.width/3, height: 50)
    }

    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var AvailableslotLbl: UILabel!
    @IBOutlet weak var clockImgview: UIImageView!
    @IBOutlet weak var MeetingTypeBtn: UIButton!
    @IBOutlet weak var StaffNameLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var Stackview: UIStackView!
    @IBOutlet weak var Cellview: UIView!
    var identifier = "TimeCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Cellview.layer.cornerRadius = 10
        Cellview.layer.shadowColor = UIColor.black.cgColor
        Cellview.layer.shadowOpacity = 0.5
        Cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        Cellview.layer.shadowRadius = 3
        Cellview.layer.masksToBounds = false
        Cellview.layer.borderWidth = 0.7
        Cellview.layer.borderColor = UIColor.gray.cgColor
        
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        StaffNameLbl.setFont(style: .body, size: FontSize.BodySize)
        AvailableslotLbl.setFont(style: .body, size: FontSize.BodySize)
        MeetingTypeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        cv.layer.cornerRadius = 10
        cv.layer.borderWidth = 0.5
        cv.layer.borderColor = UIColor.gray.cgColor
        
        
        cv.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
                
        cv.delegate = self
        cv.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
