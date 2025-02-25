//
//  VocieMessageTVCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 02/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class VocieMessageTVCell: UITableViewCell {

    @IBOutlet weak var NewLbl: UILabel!   
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var DiscriptionTextLbl: UILabel!
   
    @IBOutlet weak var VocieMessageLabel: UILabel!
    @IBOutlet weak var playAudioButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NewLbl.layer.cornerRadius = 5
        NewLbl.clipsToBounds = true
        playAudioButton.layer.cornerRadius = 5
        playAudioButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
