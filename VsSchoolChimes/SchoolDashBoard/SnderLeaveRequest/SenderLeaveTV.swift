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
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var aproveBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var resonLbl: UILabel!
    @IBOutlet weak var toDate: UILabel!
    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var applyedTimeLbl: UILabel!
    @IBOutlet weak var StatusBtn: UIButton!
    @IBOutlet weak var AppliedOnDefLbl: UILabel!
    @IBOutlet weak var NoOfDaysDefLbl: UILabel!
    @IBOutlet weak var NoOfDaysLbl: UILabel!
    @IBOutlet weak var UpdatedOnBtn: UIButton!
    @IBOutlet weak var ApproveRejectStack: UIStackView!
    @IBOutlet weak var reasonDefLbl: UILabel!
    var delegate:ConfirmDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        
        aproveBtn.layer.cornerRadius = 10
        rejectBtn.layer.cornerRadius = 10
        StatusBtn.layer.cornerRadius = 10
        UpdatedOnBtn.layer.cornerRadius = 10
        
        toDate.setFont(style:.header, size: FontSize.TitleSize)
        applyedTimeLbl.setFont(style:.body, size: FontSize.BodySize)
        resonLbl.setFont(style:.body, size: FontSize.BodySize)
        studentClass.setFont(style:.body, size: FontSize.BodySize)
        classLbl.setFont(style:.title, size: FontSize.TitleSize)
        nameLbl.setFont(style:.title, size: FontSize.TitleSize)
        studentName.setFont(style:.body, size: FontSize.BodySize)
        AppliedOnDefLbl.setFont(style:.title, size: FontSize.TitleSize)
        NoOfDaysDefLbl.setFont(style:.title, size: FontSize.TitleSize)
        reasonDefLbl.setFont(style:.title, size: FontSize.TitleSize)
        NoOfDaysLbl.setFont(style:.body, size: FontSize.BodySize)
        fromDate.setFont(style:.header, size: FontSize.TitleSize)
       
        rejectBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        aproveBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        StatusBtn.setTitleFont(style:.primary, size: FontSize.TitleSize)
        UpdatedOnBtn.setTitleFont(style:.secondary, size: FontSize.TitleSize)
        
        StatusBtn.backgroundColor = .pending.withAlphaComponent(0.8)
        
        UpdatedOnBtn.isHidden = true
    }
    
    @IBAction func aprovedBtn(_ sender: UIButton) {
        delegate?.confirm(index: sender.tag, status: true)
    }
    @IBAction func rejectBtn(_ sender: UIButton) {
        delegate?.confirm(index: sender.tag, status: false)
    }
}
