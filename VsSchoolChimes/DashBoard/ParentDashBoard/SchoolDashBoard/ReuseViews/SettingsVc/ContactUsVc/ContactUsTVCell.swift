//
//  ContactUsTVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class ContactUsTVCell: UITableViewCell {

    @IBOutlet weak var cellview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellview.layer.cornerRadius = 15
        cellview.layer.borderWidth = 0.35
        cellview.layer.borderColor = UIColor.systemGray6.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
