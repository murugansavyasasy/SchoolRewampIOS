//
//  staffContactTvCell.swift
//  School Chimes
//
//  Created by apple on 16/02/26.
//

import UIKit

class staffContactTvCell: UITableViewCell {
    @IBOutlet weak var StatusView: UIView!
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var RejectBtnName: UIButton!
    @IBOutlet weak var locationBackView: UIView!
    @IBOutlet weak var mailBackView: UIView!
    @IBOutlet weak var phnBackView: UIView!
    @IBOutlet weak var BalanceView: UIView!
    @IBOutlet weak var informationFullView: UIView!
    @IBOutlet weak var dayTakenView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.uiUpdate()
        }
    }

    func uiUpdate(){
        BalanceView.layer.cornerRadius = 10
        BalanceView.layer.masksToBounds = true
        BalanceView.layer.borderWidth = 1
        BalanceView.layer.borderColor = UIColor.lightGray.cgColor
        
        dayTakenView.layer.cornerRadius = 10
        dayTakenView.layer.masksToBounds = true
        dayTakenView.layer.borderWidth = 1
        dayTakenView.layer.borderColor = UIColor.lightGray.cgColor
        
        informationFullView.layer.cornerRadius = 15
        informationFullView.layer.masksToBounds = true
        informationFullView.layer.borderWidth = 0.5
        informationFullView.layer.borderColor = UIColor.lightGray.cgColor
        
        locationBackView.layer.cornerRadius  = 15
        mailBackView.layer.cornerRadius  = 15
        phnBackView.layer.cornerRadius  = 15
        
        RejectBtnName.layer.borderWidth = 1
        RejectBtnName.layer.borderColor = UIColor.red1.cgColor
        
        profileContainerView.layer.cornerRadius = 24 // 48x48
        profileContainerView.clipsToBounds = true
        
        fullView.cornerRadius(10)
        fullView.layer.borderWidth = 0.5
        fullView.layer.borderColor = UIColor.lightGray.cgColor
        
        
    }
    
}
