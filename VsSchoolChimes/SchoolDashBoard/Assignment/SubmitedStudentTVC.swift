//
//  SubmitedStudentTVC.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//

import UIKit

class SubmitedStudentTVC: UITableViewCell {
    @IBOutlet weak var initialBtn: UIButton!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var standerdScection: UILabel!
    @IBOutlet weak var submitDate: UILabel!
    @IBOutlet weak var submitedStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialBtn.setShadow(cornerRadius: initialBtn.frame.width/2)
        applyShadowAndCornerRadius(to: outerView)
    }
}
