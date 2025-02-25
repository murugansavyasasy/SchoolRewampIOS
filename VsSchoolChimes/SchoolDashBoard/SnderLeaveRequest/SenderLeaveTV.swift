//
//  SenderLeaveTV.swift
//  VsSchoolChimes
//
//  Created by admin on 24/12/24.
//

import UIKit

class SenderLeaveTV: UITableViewCell {

    @IBOutlet weak var studentClass: UILabel!
    @IBOutlet weak var classLbl: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var aproveBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var reject: UIStackView!
    @IBOutlet weak var aproved: UIStackView!
    @IBOutlet weak var resonLbl: UILabel!
    @IBOutlet weak var toDate: UILabel!
    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var applyedTimeLbl: UILabel!
    var delegate:ConfirmDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        reject.layer.cornerRadius = 10
        reject.layer.shadowColor = UIColor.black.cgColor
        reject.layer.shadowOffset = CGSize(width: 0, height: 2)
        reject.layer.shadowRadius = 5
        reject.layer.shadowOpacity = 0.3
        
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        
        aproved.layer.cornerRadius = 10
        aproved.layer.shadowColor = UIColor.black.cgColor
        aproved.layer.shadowOffset = CGSize(width: 0, height: 2)
        aproved.layer.shadowRadius = 5
        aproved.layer.shadowOpacity = 0.3
        
        toDate.setFont(style:.header, size: FontSize.TitleSize)
        applyedTimeLbl.setFont(style:.body, size: FontSize.BodySize)
        resonLbl.setFont(style:.body, size: FontSize.BodySize)
        studentClass.setFont(style:.body, size: FontSize.BodySize)
        classLbl.setFont(style:.body, size: FontSize.BodySize)
        nameLbl.setFont(style:.body, size: FontSize.BodySize)
        studentName.setFont(style:.body, size: FontSize.BodySize)
        fromDate.setFont(style:.header, size: FontSize.TitleSize)
        statusLbl.setFont(style:.header, size: FontSize.TitleSize)
        rejectBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        aproveBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        
    }
    @IBAction func aprovedBtn(_ sender: UIButton) {
        delegate?.confirm(index: sender.tag, status: "Approved", AlertMsg: "Approve")
        
    }
    @IBAction func rejectBtn(_ sender: UIButton) {
        print("Rejected")
        delegate?.confirm(index: sender.tag, status: "Rejected", AlertMsg: "Reject")
    }
}
