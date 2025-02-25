//
//  AudioFileTableViewCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 12/06/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AudioFileTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var SenderNameLabel: UILabel!
    
    @IBOutlet weak var AudioDatelabel: UILabel!
    @IBOutlet weak var NewOrOldLabel: UILabel!
    
    @IBOutlet weak var TimeLabel: UILabel!
    
    @IBOutlet weak var PlayAudioButton: UIButton!
    
    @IBOutlet weak var AudioDownloadButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
