//
//  WhatsNewVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 22/09/25.
//

import UIKit

class WhatsNewVc: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var skipNowBtn: UIButton!
    @IBOutlet weak var tryItnowBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        headerView.layer.cornerRadius = 20

        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.15   // softness level
        headerView.layer.shadowOffset = CGSize(width: 0, height: 4) // shadow direction
        headerView.layer.shadowRadius = 8      // blur effect
        headerView.layer.masksToBounds = false

        tryItnowBtn.layer.cornerRadius = tryItnowBtn.layer.frame.height/2
        skipNowBtn.layer.cornerRadius = 5
        skipNowBtn.layer.masksToBounds = true
        skipNowBtn.layer.borderColor = UIColor.primery.cgColor
        skipNowBtn.layer.borderWidth = 0.5
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        tryItnowBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        skipNowBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        imageView.kf.setImage(with: URL(string: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//F5CB9561-8D48-492A-BEED-445BD479F5C6.jpg"))
        imageView.layer.cornerRadius = 10
    }

    @IBAction func backBtn(_ sender: UIButton) {
        
        dismiss(animated: true)
        
    }
}
