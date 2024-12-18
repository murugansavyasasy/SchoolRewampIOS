//
//  NotificationTableViewCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 25/10/24.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var messageTypeLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var roundview: UIView!
    @IBOutlet weak var cellview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellview.layer.cornerRadius = Colornames.CORadius15
        roundview.layer.cornerRadius = roundview.frame.width/2
        NameLabel.setFont(style: .title, size: FontSize.TitleSize)
        messageTypeLabel.setFont(style: .title, size: FontSize.TitleSize)
        contentLabel.setFont(style: .body, size: FontSize.BodySize)
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        cellview.layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
