//
//  SettingsTableViewCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 26/10/24.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var faceIdSwitch: UISwitch!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var arrowImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        faceIdSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        faceIdSwitch.isOn = BiometricAuthentication.shared.isBiometricEnabledInApp()

    }
    @IBAction func enablFaceId(_ sender: UISwitch) {
        BiometricAuthentication.shared.enableBiometric(sender.isOn)
    }
    
}
