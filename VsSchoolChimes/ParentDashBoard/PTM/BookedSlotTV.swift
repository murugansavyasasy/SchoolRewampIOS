//
//  BookedSlotTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 02/09/25.
//

import UIKit

class BookedSlotTV: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var MeetingNameLbl: UILabel!
    @IBOutlet weak var staffNameLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var TimeBtn: UIButton!
    @IBOutlet weak var ModeBtn: UIButton!
    @IBOutlet weak var DurationBtn: UIButton!
   // @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var subjectBGview: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    
    var onCancel : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 10
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor.systemGray4.cgColor
        
        subjectBGview.backgroundColor = .systemIndigo.withAlphaComponent(1)
        
        subjectBGview.layer.cornerRadius = 12
        statusBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
        callBtn.layer.cornerRadius = 10
        
        MeetingNameLbl.setFont(style: .title, size: FontSize.TitleSize)
        staffNameLbl.setFont(style: .body, size: FontSize.BodySize)
        subjectLbl.setFont(style: .body, size: FontSize.BodySize)
        dateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        TimeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        ModeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        DurationBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        statusBtn.setTitleFont(style: .body, size: FontSize.BodySize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        
        onCancel?()
    }
    
}
