//
//  principalTVCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 30/10/24.
//

import UIKit

class principalTVCell: UITableViewCell {

    @IBOutlet weak var checkbox: CheckBox!
//    @IBOutlet weak var checkbox: UIImageView!
    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var imgview: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellview.layer.cornerRadius = 10
        //cellview.layer.masksToBounds = true
        cellview.layer.shadowColor = UIColor.white.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        cellview.layer.masksToBounds = false
        
        imgview.layer.cornerRadius = 10
        
        checkbox.isChecked = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
