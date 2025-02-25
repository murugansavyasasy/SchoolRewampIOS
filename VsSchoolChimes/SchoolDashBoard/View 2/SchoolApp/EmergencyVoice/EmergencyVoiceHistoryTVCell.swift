//
//  EmergencyVoiceHistoryTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 17/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class EmergencyVoiceHistoryTVCell: UITableViewCell {
    
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var PressThePlayButtonLabel: UILabel!
    
    @IBOutlet weak var playAudioButton: UIButton!
    @IBOutlet weak var audioCheckBoxButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playAudioButton.layer.cornerRadius = 5
        playAudioButton.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
