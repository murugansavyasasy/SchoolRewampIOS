//
//  LeveHistoryTV.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

protocol editDelete: AnyObject {
    func edit(edit: Int?, delete: Int?)
}

class LeveHistoryTV: UITableViewCell {

    @IBOutlet weak var showPopup: UIView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var aproveBtn: UIButton!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var resonLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var editClickBtn: UIButton!
    
    weak var delegate: editDelete?

    override func awakeFromNib() {
        super.awakeFromNib()
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3

        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        dateLbl.setFont(style: .body, size: FontSize.BodySize)
        durationLbl.setFont(style: .body, size: FontSize.BodySize)
        resonLbl.setFont(style: .body, size: FontSize.BodySize)
        
        aproveBtn.setShadow()
        rejectBtn.setShadow()
        showPopup.setShadow()
        iconBtn.setShadow(cornerRadius: iconBtn.frame.width / 2)
        showPopup.isHidden = true
    }

    func hidePopup() {
        showPopup.isHidden = true
        iconBtn.isSelected = false
        aproveBtn.isHidden = false
    }

    @IBAction func iconBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected{
            delegate?.edit(edit: sender.tag, delete: -999)
        }else{
            hidePopup()
        }
    }

    @IBAction func editAct(_ sender: UIButton) {
            delegate?.edit(edit: sender.tag, delete: nil)
        
    }

    @IBAction func deleteAct(_ sender: UIButton) {
            delegate?.edit(edit: nil, delete: sender.tag)
        
    }
    @IBAction func aprove(_ sender: UIButton) {
        delegate?.edit(edit: sender.tag, delete:0)
    }
    @IBAction func rejectAct(_ sender: UIButton) {
        delegate?.edit(edit: sender.tag, delete: 1)
    }
    
}

extension UIView {
    func setShadow(cornerRadius: CGFloat = 15, shadowColor: UIColor = .black, shadowOpacity: Float = 0.2, shadowOffset: CGSize = CGSize(width: 0, height: 2), shadowRadius: CGFloat = 4) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
    }
}
