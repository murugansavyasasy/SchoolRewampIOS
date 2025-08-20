//
//  NotificationsTvCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 13/08/25.
//

import UIKit

class NotificationsTvCell: UITableViewCell {

    @IBOutlet weak var sentbyLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
