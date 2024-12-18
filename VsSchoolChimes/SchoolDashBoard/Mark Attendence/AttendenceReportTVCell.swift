//
//  AttendenceReportTVCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 16/12/24.
//

import UIKit

class AttendenceReportTVCell: UITableViewCell {

    @IBOutlet weak var Imgview: UIImageView!
    @IBOutlet weak var AdmisionNOLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
