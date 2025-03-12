//
//  HomeWorkTVCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 02/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class HomeWorkTVCell: UITableViewCell {
    
    @IBOutlet weak var VoiceView: UIView!
    @IBOutlet weak var TextView: UIView!
    @IBOutlet weak var VoiceButton: UIButton!
    @IBOutlet weak var TextButton: UIButton!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var DayLbl: UILabel!
    @IBOutlet weak var VoiceCountLbl: UILabel!
    @IBOutlet weak var TextCountLbl: UILabel!
    @IBOutlet weak var VocieMessageLabel: UILabel!
    
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var MainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        VoiceView.layer.cornerRadius = 5
        VoiceView.clipsToBounds = true
        VoiceView.layer.borderWidth = 1
        
        VoiceView.layer.borderColor = UIColor.black.cgColor
        TextView.layer.cornerRadius = 5
        TextView.clipsToBounds = true
        TextView.layer.borderWidth = 1
        
        TextView.layer.borderColor = UIColor.black.cgColor
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
