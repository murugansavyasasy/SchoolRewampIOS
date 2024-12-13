//
//  StudentDetailTableSubVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 10/06/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StudentDetailTableSubVC: UITableViewCell {
    
    @IBOutlet  var CalenderImage: UIImageView!
    @IBOutlet  var DateMonthLabel: UILabel!
    @IBOutlet  var DayLabel: UILabel!
    @IBOutlet  var MessageReadUnreadLabel: UILabel!
    @IBOutlet  var MessageAlertImage: UIImageView!
    @IBOutlet  var VoiceAlertImage: UIImageView!
    @IBOutlet  var TextAlertImage: UIImageView!
    @IBOutlet  var ImageAlertImage: UIImageView!
    @IBOutlet  var PdfAlertImage: UIImageView!
    @IBOutlet  var VoiceMsgCountLabel: UILabel!
    @IBOutlet  var TextMsgCountLabel: UILabel!
    @IBOutlet  var ImageMsgCountLabel: UILabel!
    @IBOutlet  var PdfMsgCountLabel: UILabel!
    @IBOutlet  var VoiceUnreadCountLabel: UILabel!
    @IBOutlet  var TextUnreadCountLabel: UILabel!
    @IBOutlet  var ImageUnreadCountLabel: UILabel!
    @IBOutlet  var PdfUnreadCountLabel: UILabel!
    
    
    @IBOutlet var VoiceDetailMessageButton: UIButton!
    
    @IBOutlet var TextDetailMessageButton: UIButton!
    
    @IBOutlet  var ImageDetailMessageButton: UIButton!
    
    @IBOutlet  var PdfDetailMessageButton: UIButton!
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
