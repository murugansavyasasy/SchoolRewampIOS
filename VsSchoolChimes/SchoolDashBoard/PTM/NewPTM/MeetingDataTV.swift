//
//  MeetingDataTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 19/08/25.
//

import UIKit

class MeetingDataTV: UITableViewCell {

    @IBOutlet weak var meetingNameLbl: UILabel!
    @IBOutlet weak var dateDefBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var TimeDefBtn: UIButton!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var durationDefBtn: UIButton!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var modeDefBtn: UIButton!
    @IBOutlet weak var modeLbl: UILabel!
    @IBOutlet weak var JoinBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        meetingNameLbl.setFont(style: .title, size: FontSize.TitleSize)
        dateLbl.setFont(style: .body, size: FontSize.BodySize)
        TimeLbl.setFont(style: .body, size: FontSize.BodySize)
        durationLbl.setFont(style: .body, size: FontSize.BodySize)
        modeLbl.setFont(style: .body, size: FontSize.BodySize)
        
        dateDefBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        TimeDefBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        durationDefBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        modeDefBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        JoinBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        JoinBtn.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
