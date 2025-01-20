//
//  QuizTVcell.swift
//  VsSchoolChimes
//
//  Created by Admin on 17/01/25.
//

import UIKit

class QuizTVcell: UITableViewCell {

    @IBOutlet weak var StartBtn: UIButton!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 10
        StartBtn.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
