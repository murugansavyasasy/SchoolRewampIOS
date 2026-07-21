//
//  SettingsTableViewCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 26/10/24.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var faceIdSwitch: UISwitch!
    @IBOutlet weak var nameLbl: LocalizationLabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        faceIdSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        nameLbl.setFont(style: .body, size: 13)
        faceIdSwitch.isOn = BiometricAuthentication.shared.isBiometricEnabledInApp()

    }
    @IBAction func enablFaceId(_ sender: UISwitch) {
        BiometricAuthentication.shared.enableBiometric(sender.isOn)
    }
    
}
