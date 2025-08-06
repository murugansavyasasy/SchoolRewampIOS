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
    
    
    var indexPath: IndexPath?
    weak var delegate: EditDeleteDelegate?

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
        
        editClickBtn.layer.cornerRadius = 5
        editClickBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        aproveBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        rejectBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        aproveBtn.setShadow()
        rejectBtn.setShadow()
        
    }

    @IBAction func iconBtnTapped(_ sender: UIButton) {
    }

    @IBAction func aprove(_ sender: UIButton) {
        if let indexPath = indexPath {
                delegate?.edit(edit: indexPath, delete: IndexPath(row: 0, section: indexPath.section)) // use as needed
            }
    }
    @IBAction func rejectAct(_ sender: UIButton) {
        if let indexPath = indexPath {
                delegate?.edit(edit: indexPath, delete: IndexPath(row: 1, section: indexPath.section)) // use as needed
            }
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
