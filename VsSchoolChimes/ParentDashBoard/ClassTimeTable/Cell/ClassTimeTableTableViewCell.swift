//
//  ClassTimeTableTableViewCell.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/17/24.
//

import UIKit

class ClassTimeTableTableViewCell: UITableViewCell {
    @IBOutlet weak var subNameLbl: UILabel!
    
    
    @IBOutlet weak var durationNameLbl: UILabel!
    @IBOutlet weak var staffNameLbl: UILabel!
    
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var animateView: UIView!
    @IBOutlet weak var fromImg: UIImageView!
    @IBOutlet weak var fromLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        fromImg.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
