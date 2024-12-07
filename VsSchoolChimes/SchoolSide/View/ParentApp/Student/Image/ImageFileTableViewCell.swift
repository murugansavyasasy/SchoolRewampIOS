//
//  ImageFileTableViewCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 12/06/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class ImageFileTableViewCell: UITableViewCell {
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var MyImageView: UIImageView!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var ViewFullImageButton: UIButton!
    
    @IBOutlet weak var NewLbl: UILabel!
    @IBOutlet weak var NewLblWidth: NSLayoutConstraint!
    
    @IBOutlet weak var seemoreBtn: UIButton!
    let utilObj = UtilClass()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       

        
        NewLbl.layer.cornerRadius = 5
        NewLbl.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
