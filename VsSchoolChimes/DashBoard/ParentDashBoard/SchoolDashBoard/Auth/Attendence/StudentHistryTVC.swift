//
//  StudentHistryTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 20/11/24.
//

import UIKit

class StudentHistryTVC: UITableViewCell {

    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var phnBtn: UIButton!
    @IBOutlet weak var rollNomber: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var stdImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
     
//        stdImage.translatesAutoresizingMaskIntoConstraints = false
//        stdImage.heightAnchor.constraint(equalToConstant: outerView.frame.height - 30).isActive = true
//        stdImage.layer.cornerRadius = stdImage.frame.width/2
//        outerView.addSubview(stdImage)
        // Configure stdImage
//         stdImage.layer.masksToBounds = true // To ensure the corner radius applies
//         stdImage.contentMode = .scaleAspectFill
    }
//    override func layoutSubviews() {
//         super.layoutSubviews()
//         stdImage.layer.cornerRadius = stdImage.frame.width / 2
//     }
    @IBAction func callAction(_ sender: UIButton) {
        let phoneNumber = "1234567890" // Replace with the phone number you want
        if let phoneURL = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            print("Phone app is not available on this device or invalid phone number.")
        }
    }
    
}
