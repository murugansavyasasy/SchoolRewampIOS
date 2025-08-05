//
//  LeaveHistoryTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 01/08/25.
//

import UIKit

class LeaveHistoryTV: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var DaysCountLbl: UILabel!
    @IBOutlet weak var StatusBtn: UIButton!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TypeLbl: UILabel!
    @IBOutlet weak var ReasonLbl: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var DeleteBtn: UIButton!
    @IBOutlet weak var EditBtn: UIButton!
    @IBOutlet weak var OptionsBtn: UIButton!
    @IBOutlet weak var GetOutpassBtn: UIButton!
    
    var indexPath: IndexPath?
    weak var delegate: EditDeleteDelegate?
    var outpassAction: ((IndexPath) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 10
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor.systemGray4.cgColor
        
        StatusBtn.layer.cornerRadius = 5
        
        DaysCountLbl.setFont(style: .body, size: FontSize.BodySize)
        DateLbl.setFont(style: .title, size: FontSize.TitleSize)
        TypeLbl.setFont(style: .body, size: FontSize.BodySize)
        ReasonLbl.setFont(style: .body, size: FontSize.BodySize)
        StatusBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        OptionsBtn.transform = CGAffineTransform(rotationAngle: .pi/2)
        popupView.setShadow()
        popupView.isHidden = true
    }
    
    func hidePopup() {
        popupView.isHidden = true
    }
    
    @IBAction func iconBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
            if sender.isSelected {
                if let indexPath = indexPath {
                    delegate?.edit(edit: indexPath, delete: IndexPath(row: -999, section: indexPath.section))
                }
            } else {
                hidePopup()
            }
    }

    @IBAction func editAct(_ sender: UIButton) {
        if let indexPath = indexPath {
                delegate?.edit(edit: indexPath, delete: nil)
            }
    }

    @IBAction func deleteAct(_ sender: UIButton) {
        if let indexPath = indexPath {
                delegate?.edit(edit: nil, delete: indexPath)
            }
    }
    
    @IBAction func GetOutpassBtnTapped(_ sender: UIButton) {
        if let indexPath = indexPath {
            outpassAction?(indexPath)
        }
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
