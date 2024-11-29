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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
