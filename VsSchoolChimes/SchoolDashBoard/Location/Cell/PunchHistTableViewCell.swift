//
//  PunchHistTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by chandhru on 08/09/25.
//

import UIKit

class PunchHistTableViewCell: UITableViewCell {

    @IBOutlet weak var punchTypeBtn: UIButton!
    @IBOutlet weak var clockBtn: UIButton!
    @IBOutlet weak var deviceBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var verifyView: UIView!
    @IBOutlet weak var punchType: UILabel!
    @IBOutlet weak var phoneModel: UILabel!
    @IBOutlet weak var timing: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(with record: puchHistoryList) {
            
            // Set text values safely
        punchType.text = record.punch_type?.value ?? ""
            timing.text = record.time ?? ""
            phoneModel.text = record.device_model ?? ""
            
            // Styling for outerView
            outerView.layer.cornerRadius = 8
        outerView.layer.borderWidth = 0.5
        outerView.layer.borderColor = UIColor.systemGray5.cgColor
            
            // Styling for verifyView
            verifyView.layer.cornerRadius = 4
        deviceBtn.layer.cornerRadius = 4
        clockBtn.layer.cornerRadius = 4
        punchTypeBtn.layer.cornerRadius = 4
            // Set image based on punch type
//            if let punchValue = record.punch_type?.value?.lowercased() {
//                if punchValue == "punch" {
//                    punchTypeBtn.setImage(UIImage(named: "touchid"), for: .normal)
//                } else if punchValue == "face" {
//                    punchTypeBtn.setImage(UIImage(named: "faceid"), for: .normal)
//                } else {
//                    punchTypeBtn.setImage(nil, for: .normal)
//                }
//            } else {
//                punchTypeBtn.setImage(nil, for: .normal)
//            }
        }
}
