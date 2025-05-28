//
//  SectionTvTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 29/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//
protocol sectionCellDelegate: AnyObject {
    
    func didTapPhoneNo(phoneNo:String)
}

import UIKit

class SectionTvTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var AddmisionLbl: UILabel!
    @IBOutlet weak var SectionLbl: UILabel!
    @IBOutlet weak var RollNoLbl: UILabel!
    @IBOutlet weak var MobileNoBtn: UIButton!
    
    weak var delegate: sectionCellDelegate?
    var phonenumber: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        SectionLbl.setFont(style: .body, size: FontSize.BodySize)
        RollNoLbl.setFont(style: .body, size: FontSize.BodySize)
        AddmisionLbl.setFont(style: .body, size: FontSize.BodySize)
        MobileNoBtn.setTitleFont(style: .body, size: FontSize.BodySize)
       
    }
    
    @IBAction func PhoneNoClicked(){
        
        if let number = phonenumber{
            delegate?.didTapPhoneNo(phoneNo: number)
        }
    }
    
}
