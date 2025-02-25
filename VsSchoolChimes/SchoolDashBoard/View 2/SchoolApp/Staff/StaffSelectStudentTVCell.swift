//
//  StaffSelectStudentTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 14/08/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffSelectStudentTVCell: UITableViewCell {
    
    @IBOutlet weak var StudentIdLabel: UILabel!
    
    @IBOutlet weak var SelectImage: UIImageView!
    
    @IBOutlet weak var StudentNameLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected
        {
            SelectImage.image = UIImage(named: "CheckBoximage")
        }
        else{
            SelectImage.image = UIImage(named: "UnChechBoxImage")
        }
        
    }
    
}
