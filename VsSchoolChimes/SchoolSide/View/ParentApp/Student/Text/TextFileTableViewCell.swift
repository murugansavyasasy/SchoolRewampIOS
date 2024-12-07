//
//  TextFileTableViewCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 12/06/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class TextFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var NewLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var TextDetailLbl: UILabel!
    
     @IBOutlet weak var NoticeTextView: UITextView!
     @IBOutlet weak var ExtendArrow: UIImageView!
     @IBOutlet weak var NoticeButton: UIButton!
     @IBOutlet weak var TitleView: UIView!
     @IBOutlet weak var TitleText: UILabel!
    
     @IBOutlet weak var TextTitleTextView: UITextView!
    
     @IBOutlet weak var TextDetailTextView: UITextView!

  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NewLbl.layer.cornerRadius = 5
        NewLbl.clipsToBounds = true
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
