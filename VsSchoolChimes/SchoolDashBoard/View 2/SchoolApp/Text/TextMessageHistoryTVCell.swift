//
//  TextMessageHistoryTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 17/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class TextMessageHistoryTVCell: UITableViewCell {
    
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var TextMessageLabel: UILabel!
    @IBOutlet weak var audioCheckBoxButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
