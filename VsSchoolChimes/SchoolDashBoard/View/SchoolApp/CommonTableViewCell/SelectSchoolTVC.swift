//
//  SelectSchoolTVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 06/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SelectSchoolTVC: UITableViewCell {
    
    @IBOutlet weak var SchoolNameLabel: UILabel!
    @IBOutlet weak var SelectImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
       super.setSelected(selected, animated: animated)

        if selected{
           SelectImage.image = UIImage(named: "CheckBoximage")
        }else{
           SelectImage.image = UIImage(named: "UnChechBoxImage")
        }
    }
}
