//
//  cell1Tv.swift
//  VsSchoolChimes
//
//  Created by admin on 26/03/25.
//

import UIKit

class cell1Tv: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
