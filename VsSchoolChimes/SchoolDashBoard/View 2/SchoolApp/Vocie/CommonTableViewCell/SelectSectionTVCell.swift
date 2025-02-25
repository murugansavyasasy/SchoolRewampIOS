//
//  SelectSectionTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 25/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SelectSectionTVCell: UITableViewCell {

    @IBOutlet weak var SelectionImage: UIImageView!
    @IBOutlet weak var SectionNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected{
            SelectionImage.backgroundColor = UIColor.orange
        }else{
            SelectionImage.backgroundColor = UIColor.gray
        }
    }

}
