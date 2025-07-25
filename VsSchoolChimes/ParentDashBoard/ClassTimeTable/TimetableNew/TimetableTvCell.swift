//
//  TimetableTvCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 23/07/25.
//

import UIKit

class TimetableTvCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var VerticalLineView: UIView!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var StaffLbl: UILabel!
    @IBOutlet weak var startEndTimeLbl: UILabel!
    @IBOutlet weak var DurationLbl: UILabel!
    @IBOutlet weak var toTimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 10
        
        TimeLbl.setFont(style: .title, size: FontSize.BodySize)
        toTimeLbl.setFont(style: .title, size: FontSize.BodySize)
        SubjectLbl.setFont(style: .title, size: FontSize.TitleSize)
        StaffLbl.setFont(style: .body, size: FontSize.BodySize)
        startEndTimeLbl.setFont(style: .body, size: FontSize.BodySize)
        DurationLbl.setFont(style: .body, size: FontSize.BodySize)
        DurationLbl.cornerRadius(5)
        //DurationLbl.backgroundColor = .systemGreen.withAlphaComponent(0.2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
