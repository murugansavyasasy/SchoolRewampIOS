//
//  TotalAssignmentTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 05/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class TotalAssignmentTVCell: UITableViewCell {
    @IBOutlet weak var viewButton: UIButton!
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var SectionLabel: UILabel!
    @IBOutlet weak var TypeLabel: UILabel!
    
    let util = Util()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonBorder(view: viewButton)
    }
    
    func buttonBorder(view : UIView){
        view.layer.borderWidth = 0.3
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.clear.cgColor
    }
    
}
