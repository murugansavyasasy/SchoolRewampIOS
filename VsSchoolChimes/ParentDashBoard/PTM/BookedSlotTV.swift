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
    @IBOutlet weak var cancelStackHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelStackTop: NSLayoutConstraint!
    @IBOutlet weak var DateDefLbl: UILabel!
    @IBOutlet weak var timeDefLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var JoinBtn: UIButton!
    
    
    var onCancel : (() -> Void)?
    var onCall : (() -> Void)?
    var onJoin : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 10
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor.systemGray4.cgColor
        
        subjectBGview.backgroundColor = .systemIndigo.withAlphaComponent(1)
        
        subjectBGview.layer.cornerRadius = 12
        statusBtn.layer.cornerRadius = 8
        cancelBtn.layer.cornerRadius = cancelBtn.frame.height / 2
        callBtn.layer.cornerRadius = callBtn.frame.height / 2
        
        DateDefLbl.text = PTMString.date
        timeDefLbl.text = PTMString.time
        
        callBtn.setTitle(PTMString.call, for: .normal)
        cancelBtn.setTitle(PTMString.cancel, for: .normal)
        
        MeetingNameLbl.setFont(style: .title, size: FontSize.TitleSize)
        staffNameLbl.setFont(style: .body, size: FontSize.BodySize)
        subjectLbl.setFont(style: .body, size: FontSize.BodySize)
        dateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        TimeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        ModeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        DurationBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        statusBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        cancelBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        callBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        callBtn.isHidden = true
        JoinBtn.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cellView.clipsToBounds = true
        cellView.applyVerticalGradient(
            topColor: UIColor(
                red: 184/255,
                green: 201/255,
                blue: 234/255,
                alpha: 1
            ),
            bottomColor: UIColor(
                red: 211/255,
                green: 224/255,
                blue: 245/255,
                alpha: 1
            ) // darker bottom
        )
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        
        onCancel?()
    }
    
    @IBAction func CallBtn(_ sender: Any) {
        
        onCall?()
    }
    
    @IBAction func JoinAct(_ sender: Any) {
        onJoin?()
    }
    
}
