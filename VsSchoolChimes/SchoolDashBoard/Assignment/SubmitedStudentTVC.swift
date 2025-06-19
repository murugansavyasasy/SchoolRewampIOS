//
//  SubmitedStudentTVC.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//

import UIKit

class SubmitedStudentTVC: UITableViewCell {
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var standerdScection: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var submitedCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyShadowAndCornerRadius(to: outerView)
    }
}
