//
//  ClassTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 26/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var absentCountlbl: UILabel!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var sectionNameLbl: UILabel!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        countView.setShadow(cornerRadius: countView.frame.width/2)
        countView.backgroundColor = UIColor.blue.withAlphaComponent(0.6)
        countView.layer.borderColor = UIColor.black.cgColor
        countView.layer.borderWidth = 1
        fullView.setShadow(cornerRadius: 8)
    }
}
