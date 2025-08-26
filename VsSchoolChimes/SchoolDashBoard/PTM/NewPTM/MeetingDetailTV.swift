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
    @IBOutlet weak var optionsBtn: UIButton!
    @IBOutlet weak var modeLbl: UILabel!
    @IBOutlet weak var datebaseView: UIView!
    @IBOutlet weak var timebaseView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 15
        datebaseView.layer.cornerRadius = 15
        timebaseView.layer.cornerRadius = 15
        joinBtn.layer.cornerRadius = 15
        optionsBtn.layer.cornerRadius = optionsBtn.frame.width / 2
        
        optionsBtn.backgroundColor = .white
        datebaseView.backgroundColor = .white.withAlphaComponent(1)
        timebaseView.backgroundColor = .white.withAlphaComponent(1)
        
        dateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        timeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        joinBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        countBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        MeetingNameLbl.setFont(style: .title, size: 17)
        modeLbl.setFont(style: .body, size: FontSize.BodySize)
        
        img1.layer.cornerRadius = img1.frame.width / 2
        img2.layer.cornerRadius = img1.frame.width / 2
        img3.layer.cornerRadius = img1.frame.width / 2
        countBtn.layer.cornerRadius = img1.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
