//
//  AttendanceTVCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 02/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class UploadTVCell: UITableViewCell {

    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var pathLbl: UILabel!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var submitView: UIView!

    @IBOutlet weak var submitViewHeight: NSLayoutConstraint!
    @IBOutlet weak var uploadViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLblHeight: NSLayoutConstraint!


    let utilObj = UtilClass()

    @IBOutlet weak var MainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        MainView.backgroundColor = .clear
        
        uploadBtn.layer.cornerRadius = 5
        uploadBtn.layer.borderWidth = 1
        uploadBtn.layer.borderColor = UIColor.lightGray.cgColor
       // uploadBtn.setTitle(SEE_MORE_TITLE, for: .normal)
        uploadBtn.backgroundColor = .white
       // uploadBtn.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        uploadBtn.titleLabel?.font = .systemFont(ofSize: 12)
        
//        submitBtn.backgroundColor = .clear
//        submitBtn.layer.cornerRadius = 5
//        submitBtn.layer.borderWidth = 1
//        submitBtn.layer.borderColor = UIColor.lightGray.cgColor
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
