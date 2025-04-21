//
//  SchoolListTVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 22/03/25.
//

import UIKit

class SchoolListTVC: UITableViewCell {

    @IBOutlet weak var arrowWidth: NSLayoutConstraint!
    @IBOutlet weak var selectBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var schoolRelignLangLbl: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
