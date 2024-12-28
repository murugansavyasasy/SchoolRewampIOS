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
    @IBOutlet weak var AdmisNomber: UILabel!
    @IBOutlet weak var clsLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiConfic()
    }
    func uiConfic(){
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        nameLbl.setFont(style: .body, size: FontSize.BodySize)
        AdmisNomber.setFont(style: .body, size: FontSize.BodySize)
        rollNomber.setFont(style: .body, size: FontSize.BodySize)
    }

    @IBAction func callAction(_ sender: UIButton) {
        let phoneNumber = sender.titleLabel?.text ?? "1234567890" // Replace with the phone number you want
        if let phoneURL = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            print("Phone app is not available on this device or invalid phone number.")
        }
    }
    
}
