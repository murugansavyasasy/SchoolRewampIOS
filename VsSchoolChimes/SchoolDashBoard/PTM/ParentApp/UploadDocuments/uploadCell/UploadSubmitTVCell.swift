//
//  AttendanceTVCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 02/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class UploadSubmitTVCell: UITableViewCell {

    
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
        

        
        submitBtn.backgroundColor = .clear
        submitBtn.layer.cornerRadius = 5
        submitBtn.layer.borderWidth = 1
        submitBtn.layer.borderColor = UIColor.lightGray.cgColor
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
