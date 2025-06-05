//
//  LeveHistoryTV.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
class LeveHistoryTV: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var approvedBy: UILabel!
    @IBOutlet weak var aproverNameLbl: UILabel!
    @IBOutlet weak var statusBtn: UIView!
    @IBOutlet weak var aproveLbl: UILabel!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var satusImg: UIImageView!
    @IBOutlet weak var botomSts: NSLayoutConstraint!
    @IBOutlet weak var ShowPopup: UIView!
    @IBOutlet weak var editHeight: NSLayoutConstraint!
    @IBOutlet weak var deltBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ShowPopup.isHidden = true
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        
        ShowPopup.layer.cornerRadius = 10
        ShowPopup.layer.shadowColor = UIColor.black.cgColor
        ShowPopup.layer.shadowOffset = CGSize(width: 0, height: 2)
        ShowPopup.layer.shadowRadius = 5
        ShowPopup.layer.shadowOpacity = 0.3
        statusBtn.layer.cornerRadius = 8
        statusBtn.layer.shadowColor = UIColor.black.cgColor
        statusBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        statusBtn.layer.shadowRadius = 5
        statusBtn.layer.shadowOpacity = 0.3
        
        styleLabel(toDateLbl)
        styleLabel(fromDateLbl)
     
        fromDateLbl.setFont(style:.body, size: FontSize.BodySize)
        toDateLbl.setFont(style:.body, size: FontSize.BodySize)
        aproveLbl.setFont(style:.body, size: FontSize.BodySize)
        approvedBy.setFont(style:.body, size: FontSize.BodySize)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentViewTapped))
        contentView.isUserInteractionEnabled = true // Ensure interaction is enabled
        contentView.addGestureRecognizer(tapGesture)
//        approvedBy.text = ""
    }
    func styleLabel(_ label: UILabel) {
        label.layer.cornerRadius = 8
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowRadius = 5
        label.layer.shadowOpacity = 0.3
        label.clipsToBounds = false // To ensure shadows are visible outside the label bounds
    }
    // Action to be triggered when the contentView is tapped
    @objc func contentViewTapped() {
        ShowPopup.isHidden = true
    }
    @IBAction func shoPopup(_ sender: UIButton) {
        sender.isSelected.toggle()
        ShowPopup.isHidden = !sender.isSelected
    }
    @IBAction func deleteRequest(_ sender: UIButton) {
//        guard let leaveRequest = leaverequest else {
//            print("Leave request is nil")
//            return
//        }
//       // delegate?.delete(index: sender.tag, UpdateDetails: leaveRequest, Updated: false)
//        ShowPopup.isHidden = true
    }
    @IBAction func edit(_ sender: UIButton) {
//        guard let leaveRequest = leaverequest else {
//            print("Leave request is nil")
//            return
//        }
//        delegate?.delete(index: sender.tag, UpdateDetails: leaveRequest, Updated: true)
//        ShowPopup.isHidden = true
    }
    
    
    
}
