//
//  LeveHistoryTV.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

protocol EditDeleteDelegate: AnyObject {
    func edit(edit: IndexPath?, delete: IndexPath?)
}

class LeveHistoryTV: UITableViewCell {

    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var aproveBtn: UIButton!
    @IBOutlet weak var resonLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var editClickBtn: UIButton!
    @IBOutlet weak var LeaveTypeLbl: UILabel!
    @IBOutlet weak var classLbl: UILabel!
    
    var onApprove: (() -> Void)?
    var onReject: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        outerView.layer.cornerRadius = 10
        outerView.layer.borderWidth = 1
        outerView.layer.borderColor = UIColor.systemGray4.cgColor

        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        dateLbl.setFont(style: .title, size: FontSize.TitleSize)
        durationLbl.setFont(style: .body, size: FontSize.BodySize)
        resonLbl.setFont(style: .body, size: FontSize.BodySize)
        LeaveTypeLbl.setFont(style: .body, size: FontSize.BodySize)
        classLbl.setFont(style: .body, size: FontSize.BodySize)
        
        editClickBtn.layer.cornerRadius = 5
        editClickBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        aproveBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        rejectBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        aproveBtn.layer.cornerRadius = 5
        rejectBtn.layer.cornerRadius = 5
        
    }

    @IBAction func iconBtnTapped(_ sender: UIButton) {
    }

    @IBAction func aprove(_ sender: UIButton) {
       onApprove?()
    }
    
    @IBAction func rejectAct(_ sender: UIButton) {
        onReject?()
    }
    
}

extension UIView {
    func setShadow(cornerRadius: CGFloat = 10, shadowColor: UIColor = .black, shadowOpacity: Float = 0.2, shadowOffset: CGSize = CGSize(width: 4, height: 4), shadowRadius: CGFloat = 4) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
    }
    func clearShadow() {
            self.layer.shadowColor = nil
            self.layer.shadowOpacity = 0
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = 0
            self.layer.shadowPath = nil
        }
}
