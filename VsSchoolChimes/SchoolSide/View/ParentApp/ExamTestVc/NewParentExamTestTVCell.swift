//
//  NewParentExamTestTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 21/07/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class NewParentExamTestTVCell: UITableViewCell {

     @IBOutlet weak var SubjectLabel: UILabel!
     @IBOutlet weak var DateLabel: UILabel!
     @IBOutlet weak var MarkLabel: UILabel!
     @IBOutlet weak var SessionLabel: UILabel!
    @IBOutlet weak var FloatSubjectLabel: UILabel!
    @IBOutlet weak var FloatDateLabel: UILabel!
    @IBOutlet weak var FloatMarkLabel: UILabel!
    @IBOutlet weak var FloatSessionLabel: UILabel!
    
    @IBOutlet weak var SyllabusLabel: UILabel!
       @IBOutlet weak var FloatSyllabusLabel: UILabel!
    @IBOutlet weak var CellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
