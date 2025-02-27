//
//  SettingsTableViewCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 26/10/24.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var arrowImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        // Initialization code
    }
}
