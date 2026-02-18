//
//  StaffLeaveReqTvCell.swift
//  School Chimes
//
//  Created by apple on 16/02/26.
//

import UIKit

class StaffLeaveReqTvCell: UITableViewCell {

    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var StatusView: UIView!
    @IBOutlet weak var NameAroundView: UIView!
    @IBOutlet weak var RejectBtnName: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async{
            self.UiUpdate()
        }
    }

    func UiUpdate(){
        RejectBtnName.layer.borderWidth = 1
        RejectBtnName.layer.borderColor = UIColor.red1.cgColor
        profileContainerView.layer.cornerRadius = 24 // 48x48
        profileContainerView.clipsToBounds = true
        fullView.cornerRadius(10)
        fullView.layer.borderWidth = 0.5
        fullView.layer.borderColor = UIColor.lightGray.cgColor
        StatusView.backgroundColor = UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0) // Light Blue
        StatusView.layer.cornerRadius = 10
    }
    
    @IBAction func ApproveBtnAct(_ sender: UIButton) {
    }
    
    @IBAction func RejectBtnAct(_ sender: UIButton) {
    }
}
