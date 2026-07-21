//
//  MarkTvCell.swift
//  VsSchoolChimes
//
//  Created by admin on 09/12/24.
//

import UIKit

class MarkTvCell: UITableViewCell {

    @IBOutlet weak var markLbl: UILabel!
    
    @IBOutlet weak var defaultSubLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
