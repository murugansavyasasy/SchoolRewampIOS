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
        setBorderAndCornerRadius(for: imgCount,cornerRadius: img1.frame.width/2)
        setBorderAndCornerRadius(for: img1,cornerRadius: img1.frame.width/2)
        setBorderAndCornerRadius(for: img2,cornerRadius: img1.frame.width/2)
        setBorderAndCornerRadius(for: img3,cornerRadius: img1.frame.width/2)
        onGoingStsBtn.layer.cornerRadius = 15
        
    }
    func imageLoad(loadimg: [FilePath]) {
        // Hide all initially
        img1.isHidden = true
        img2.isHidden = true
        img3.isHidden = true
        imgCount.isHidden = true
//        attacmentView.setShadow(cornerRadius: attacmentView.frame.width/2)
        // Loop through available images
        for (index, item) in loadimg.enumerated() {
            if index == 0 {
                img1.isHidden = false
                img1.kf.setImage(with:URL(string: item.url ?? ""))
            } else if index == 1 {
                img2.isHidden = false
                img2.kf.setImage(with:URL(string: item.url ?? ""))
            } else if index == 2 {
                img3.isHidden = false
                img3.kf.setImage(with:URL(string: item.url ?? ""))
            } else {
                break
            }
        }

        // Show "+N" if more than 3 images
        if loadimg.count > 3 {
            let extraCount = loadimg.count - 3
            imgCount.isHidden = false
            imgCount.titleLabel?.text = "+\(extraCount)"
        }
    }
    func setBorderAndCornerRadius(for view: UIView, cornerRadius: CGFloat = 8.0, borderWidth: CGFloat = 1.0, borderColor: UIColor = .lightGray) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.clipsToBounds = true
    }
}
