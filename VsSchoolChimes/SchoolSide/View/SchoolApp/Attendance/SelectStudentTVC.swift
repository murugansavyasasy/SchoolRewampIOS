//
//  SelectStudentTVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 06/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SelectStudentTVC: UITableViewCell {
    
    @IBOutlet weak var SelectionImage: UIImageView!
    @IBOutlet weak var StudentNameLabel: UILabel!
    @IBOutlet weak var StudentIdLabel: UILabel!
    
    
    var attendendanceType : Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        
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


