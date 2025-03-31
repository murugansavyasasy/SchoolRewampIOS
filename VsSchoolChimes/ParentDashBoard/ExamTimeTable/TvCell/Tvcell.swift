//
//  Tvcell.swift
//  VsSchoolChimes
//
//  Created by admin on 23/11/24.
//

import UIKit

class Tvcell: UITableViewCell {

    @IBOutlet weak var fullView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        fullView.layer.shadowColor = UIColor.black.cgColor
        fullView.layer.shadowOpacity = 0.5
        fullView.layer.shadowOffset = CGSize(width: 4, height: 4)
        fullView.layer.shadowRadius = 3
        fullView.layer.masksToBounds = false
        fullView.layer.cornerRadius = Colornames.CORadius10
        fullView.layer.borderWidth = 1
        fullView.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
