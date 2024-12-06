//
//  ExamMarkTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 15/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class ExamMarkTVCell: UITableViewCell {
@IBOutlet weak var ExamNameLbl: UILabel!
    @IBOutlet weak var ExamView: UIView!
    @IBOutlet weak var ExamButtonView: UIView!
    @IBOutlet weak var ViewExamBtn : UIButton!
    @IBOutlet weak var ViewProgressBtn : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ExamView.layer.borderWidth = 0.3
        ExamView.layer.borderColor = UIColor.lightGray.cgColor
        ExamView.layer.cornerRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
