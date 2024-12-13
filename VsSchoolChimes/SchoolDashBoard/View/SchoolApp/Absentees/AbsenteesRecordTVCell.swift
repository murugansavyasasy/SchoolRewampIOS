//
//  AbsenteesRecordTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 13/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AbsenteesRecordTVCell: UITableViewCell {
    @IBOutlet var SecNameLbl: UILabel!
    @IBOutlet var TotalStudentLbl: UILabel!
    @IBOutlet var PresentLbl: UILabel!
    @IBOutlet var PresentLblView: UIView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        TotalStudentLbl.layer.cornerRadius = 5
        TotalStudentLbl.layer.masksToBounds = true
        PresentLblView.layer.cornerRadius = 5
        PresentLblView.layer.masksToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
    }

}
