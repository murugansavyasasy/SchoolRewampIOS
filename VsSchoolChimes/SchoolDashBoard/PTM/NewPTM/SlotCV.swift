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
        let from = slot.slot_from ?? ""
        let to = slot.slot_to ?? ""
        label.text = "\(from) - \(to)"
        
        if slot.my_booking ?? false {
            cellView.backgroundColor = .systemGreen   // API confirmed booking
            isUserInteractionEnabled = false
            label.textColor = .white
            statusLbl.textColor = .white
            statusLbl.text = "Already Booked"
        } else if slot.userSelected ?? false {
            cellView.backgroundColor = .systemBlue    // User temporary selection
            isUserInteractionEnabled = true
            label.textColor = .white
            statusLbl.textColor = .white
        } else if slot.is_booked ?? false {
            cellView.backgroundColor = .lightGray     // Disabled due to conflict
            isUserInteractionEnabled = false
            label.textColor = .black
            statusLbl.textColor = .red
            statusLbl.text = "Not Available"
        } else if slot.is_conflictDisabled ?? false{
            cellView.backgroundColor = .lightGray
            isUserInteractionEnabled = false
        }else {
            cellView.backgroundColor = .white
            label.textColor = .black
            statusLbl.textColor = .systemGreen// Available
            isUserInteractionEnabled = true
        }
    }
    
    @IBAction func removeAct(_ sender: UIButton) {
        onRemove?()
    }
}
