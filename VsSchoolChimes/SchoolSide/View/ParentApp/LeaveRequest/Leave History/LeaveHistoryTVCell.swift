//
//  LeaveHistoryTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 14/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class LeaveHistoryTVCell: UITableViewCell {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var ClassLabel: UILabel!
    @IBOutlet weak var LeaveAppiledOnLabel: UILabel!
    @IBOutlet weak var LeaveFromLabel: UILabel!
    @IBOutlet weak var LeaveToLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    
    @IBOutlet weak var FloatNameLabel: UILabel!
    @IBOutlet weak var FloatClassLabel: UILabel!
    @IBOutlet weak var FloatLeaveAppiledOnLabel: UILabel!
    @IBOutlet weak var FloatLeaveFromLabel: UILabel!
    @IBOutlet weak var FloatLeaveToLabel: UILabel!
    @IBOutlet weak var FloatreasonLabel: UILabel!
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.cellView.layer.masksToBounds = true
        self.cellView.layer.borderColor = UIColor.lightGray.cgColor
        self.cellView.layer.borderWidth = 1
        self.cellView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
