//
//  StaffSectionTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 09/08/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffSectionTVCell: UITableViewCell {
    
    
    @IBOutlet weak var SelectAllButton: UIButton!
    
    
    @IBOutlet weak var EditButton: UIButton!
    @IBOutlet weak var SectionNameLabel: UILabel!
    
    @IBOutlet weak var SubjectNameLabel: UILabel!
    
    @IBOutlet weak var TotalStudentLabel: UILabel!
    
    @IBOutlet weak var StudentCountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let image = UIImage(named: "UnCheckBoxIcon") as UIImage?
        
        SelectAllButton.setImage(image, for: .normal)
        EditButton.layer.borderWidth = 1
        EditButton.layer.borderColor = UIColor.gray.cgColor
        EditButton.layer.cornerRadius = 5
        EditButton.layer.masksToBounds = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
