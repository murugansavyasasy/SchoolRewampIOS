//
//  SideTvcell.swift
//  VsSchoolChimes
//
//  Created by admin on 23/11/24.
//

import UIKit

class SideTvcell: UITableViewCell {
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var ExameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 10
    }
    
}
