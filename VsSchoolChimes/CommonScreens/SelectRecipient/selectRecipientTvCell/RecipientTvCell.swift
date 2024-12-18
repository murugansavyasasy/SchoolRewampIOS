//
//  RecipientTvCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 21/11/24.
//

import UIKit

class RecipientTvCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var checkboxImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
