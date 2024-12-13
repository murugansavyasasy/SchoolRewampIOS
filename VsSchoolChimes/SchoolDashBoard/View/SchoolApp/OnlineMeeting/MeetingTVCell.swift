//
//  ChooseCountryTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 28/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class MeetingTVCell: UITableViewCell {
    @IBOutlet weak var meetingDateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var createOnLabel: UILabel!
    @IBOutlet weak var targetTypeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var NewLbl: UILabel!
    
    
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }
    
}
