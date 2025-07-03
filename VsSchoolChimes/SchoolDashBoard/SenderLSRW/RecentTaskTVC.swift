//
//  RecentTaskTVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/06/25.
//

import UIKit

class RecentTaskTVC: UITableViewCell {

    @IBOutlet weak var outerview: UIView!
    @IBOutlet weak var taskTitleLbl: UILabel!
    @IBOutlet weak var completedStatus: UILabel!
    @IBOutlet weak var taskicon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        outerview.layer.cornerRadius = 12
        outerview.layer.masksToBounds = true
        taskicon.tintColor = .label
    }

    func configure(with model: ActivityModel) {
        taskTitleLbl.text = model.title
        completedStatus.text = model.subtitle
        taskicon.image = model.icon
        taskicon.tintColor = model.iconColor
    }
}
