//
//  OngoingCVC.swift
//  School Chimes
//
//  Created by Chandhru on 22/07/25.
//

import UIKit

class OngoingCVC: UICollectionViewCell {

    @IBOutlet weak var attacmentView: UIView!
    @IBOutlet weak var onGoingStsBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var imgCount: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.setShadow()
        img1.isHidden = true
        img2.isHidden = true
        img3.isHidden = true
        imgCount.isHidden = true
        [img1, img2, img3,imgCount].forEach {
            setBorderAndCornerRadius(for: $0!, cornerRadius:($0?.frame.width ?? 0)/2)
        }
        attacmentView.setShadow(cornerRadius: 20)
        onGoingStsBtn.layer.cornerRadius = 15
        
    }
    func setBorderAndCornerRadius(for view: UIView, cornerRadius: CGFloat = 8.0, borderWidth: CGFloat = 1.0, borderColor: UIColor = .lightGray) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.clipsToBounds = true
    }
}
