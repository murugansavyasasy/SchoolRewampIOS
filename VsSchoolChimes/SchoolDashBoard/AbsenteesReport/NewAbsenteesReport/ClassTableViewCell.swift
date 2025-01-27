//
//  ClassTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 26/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {
    @IBOutlet weak var fullView: UIViewX!
    @IBOutlet weak var absentCountlbl: UILabel!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
