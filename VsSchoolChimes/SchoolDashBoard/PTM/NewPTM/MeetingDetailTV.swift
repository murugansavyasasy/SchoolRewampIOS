//
//  MeetingDetailTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 12/08/25.
//

import UIKit

class MeetingDetailTV: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var MeetingNameLbl: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var countBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 10
        dateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        timeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        joinBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        countBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        MeetingNameLbl.setFont(style: .title, size: FontSize.TitleSize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
