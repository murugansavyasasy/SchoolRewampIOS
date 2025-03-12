//
//  LibraryTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 12/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class LibraryTVCell: UITableViewCell {

    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var BookIdLbl: UILabel!
    @IBOutlet weak var BookNameLbl: UILabel!
    @IBOutlet weak var IssueDateLbl: UILabel!
    @IBOutlet weak var DueDateLbl: UILabel!
    
    @IBOutlet weak var FloatBookIdLbl: UILabel!
    @IBOutlet weak var FloatBookNameLbl: UILabel!
    @IBOutlet weak var FloatIssueDateLbl: UILabel!
    @IBOutlet weak var FloatDueDateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        MainView.layer.borderWidth = 0.3
        MainView.layer.cornerRadius = 5
        MainView.clipsToBounds = true
        MainView.layer.borderColor = UIColor.lightGray.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
