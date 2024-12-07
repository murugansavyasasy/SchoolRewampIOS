//
//  AttendanceTVCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 02/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SeeMoreTVCell: UITableViewCell {

    
    @IBOutlet weak var AbsentLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var DayLbl: UILabel!
    @IBOutlet weak var SeeMoreBtn: UIButton!
    let utilObj = UtilClass()

    @IBOutlet weak var MainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        MainView.backgroundColor = .clear
        
        SeeMoreBtn.layer.cornerRadius = 5
        SeeMoreBtn.layer.borderWidth = 2
        SeeMoreBtn.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        SeeMoreBtn.setTitle(SEE_MORE_TITLE, for: .normal)
        SeeMoreBtn.backgroundColor = .white
        SeeMoreBtn.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        SeeMoreBtn.titleLabel?.font = .systemFont(ofSize: 12)
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
