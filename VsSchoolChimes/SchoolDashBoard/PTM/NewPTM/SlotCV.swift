//
//  SlotCV.swift
//  School Chimes
//
//  Created by Lakshmanan on 18/08/25.
//

import UIKit

class SlotCV: UICollectionViewCell {
    
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    
    
    var onRemove: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 10
        cellView.backgroundColor = .systemGray4
        cellView.layer.borderWidth = 0.5
        cellView.layer.borderColor = UIColor.systemGray4.cgColor
        label.setFont(style: .body, size: 12)
        statusLbl.setFont(style: .body, size: 10)
    }
    
    func configure(slot: StudentSlot) {
            label.text = "\(slot.slot_from ?? "") - \(slot.slot_to ?? "")"

            if slot.my_booking ?? false {
                cellView.backgroundColor = .systemGreen
                label.textColor = .white
                statusLbl.text = "Already Booked"
                isUserInteractionEnabled = false
            } else if slot.userSelected ?? false {
                cellView.backgroundColor = .systemBlue
                label.textColor = .white
                statusLbl.text = "Selected"
                isUserInteractionEnabled = true
            } else if slot.is_booked ?? false {
                cellView.backgroundColor = .darkGray
                label.textColor = .white
                statusLbl.text = "Not Available"
                isUserInteractionEnabled = false
            } else if slot.is_conflictDisabled ?? false {
                cellView.backgroundColor = .lightGray
                label.textColor = .black
                statusLbl.text = "Time Conflict"
                isUserInteractionEnabled = false
            } else {
                cellView.backgroundColor = .white
                label.textColor = .black
                statusLbl.text = "Available"
                isUserInteractionEnabled = true
            }
        }
    
    @IBAction func removeAct(_ sender: UIButton) {
        onRemove?()
    }
}
