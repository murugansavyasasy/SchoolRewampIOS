//
//  SpecificStudentTvcell.swift
//  VsSchoolChimes
//
//  Created by Admin on 07/01/25.
//

import UIKit

class SpecificStudentTvcell: UITableViewCell {

    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var CheckBoxImgview: UIImageView!
    @IBOutlet weak var AdmisionNoLbl: UILabel!
    @IBOutlet weak var RollNoLbl: UILabel!
    @IBOutlet weak var DropdownImg: UIImageView!
    @IBOutlet weak var alphabetLbl: UILabel!
    @IBOutlet weak var AlphabetView: UIView!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        AlphabetView.layer.cornerRadius = AlphabetView.frame.width/2
//        AdmisionNoLbl.isHidden = true
//        RollNoLbl.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
