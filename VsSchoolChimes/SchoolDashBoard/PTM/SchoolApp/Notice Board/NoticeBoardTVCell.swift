//
//  NoticeBoardTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 16/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class NoticeBoardTVCell: UITableViewCell {
     @IBOutlet weak var SchoolNameLbl: UILabel!
     @IBOutlet weak var SelectionImage: UIImageView!
    
    @IBOutlet weak var schoolNameTop: NSLayoutConstraint!
    @IBOutlet weak var SchoolNameRegionalLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(selected)
        {
            SelectionImage.image = UIImage(named: "UnChechBoxImage")
        }else{
            SelectionImage.image = UIImage(named: "CheckBoximage")
        }
    }

}
