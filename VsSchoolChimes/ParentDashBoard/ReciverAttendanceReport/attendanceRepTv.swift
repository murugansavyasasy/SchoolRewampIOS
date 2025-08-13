//
//  attendanceRepTv.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 08/07/25.
//

import UIKit

class attendanceRepTv: UITableViewCell {

    @IBOutlet weak var cellFullview: UIView!
    @IBOutlet weak var absntBtn: UIButton!
    @IBOutlet weak var datefullView: UIView!
    @IBOutlet weak var dateYrLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datefullView.layer.cornerRadius = 32.5
        absntBtn.layer.cornerRadius = 15
        absntBtn.setTitle(AttendanceString.absent, for: .normal)
        absntBtn.setTitleFont(style: .secondary, size: FontSize.TitleSize)
        applyShadowAndCornerRadius(to:cellFullview)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
