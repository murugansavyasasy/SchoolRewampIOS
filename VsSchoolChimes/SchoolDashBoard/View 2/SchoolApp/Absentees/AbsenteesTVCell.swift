//
//  AbsenteesTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 13/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AbsenteesTVCell: UITableViewCell {

    
    
    @IBOutlet weak var schoolCountLbl: UILabel!
    
    @IBOutlet weak var schoolCountView: UIView!
    
    
    
    @IBOutlet weak var schoolNameTop: NSLayoutConstraint!
    @IBOutlet weak var SchoolNameRegionalLbl: UILabel!
    
    @IBOutlet weak var SchoolNameLbl: UILabel!
    @IBOutlet weak var BaseView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        BaseView.layer.shadowOpacity = 0.7
        BaseView.layer.shadowOffset = CGSize.zero
        BaseView.layer.shadowRadius = 4
        BaseView.layer.shadowColor = UIColor.black.cgColor
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)       
    }

}
