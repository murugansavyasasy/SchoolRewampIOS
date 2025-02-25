//
//  AttendTvCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 29/11/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class AttendTvCell: UITableViewCell {

    @IBOutlet weak var DefaultrollColun: UILabel!
    @IBOutlet weak var defaultRollLbl: UILabel!
    @IBOutlet weak var SelectionImage: UIImageView!
    @IBOutlet weak var StudentNameLabel: UILabel!
    @IBOutlet weak var StudentIdLabel: UILabel!
    
    @IBOutlet weak var RollNumLbl: UILabel!
    
    var attendendanceType : Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected{
            SelectionImage.image = UIImage(named: "CheckBoximage")
            if attendendanceType == 1 {
                SelectionImage.image = UIImage(named: "AbsentImage")
                SelectionImage.tintColor = .red
            }
        }else{
            SelectionImage.image = UIImage(named: "UnChechBoxImage")
            if attendendanceType == 1 {
                SelectionImage.image = UIImage(named: "PresentImage")
                SelectionImage.tintColor = .green
            }
        }
    }
    
}
