//
//  ReportAttCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 29/10/25.
//

import UIKit

class ReportAttCell: UITableViewCell {

    @IBOutlet weak var AnBtnName: UIButton!
    @IBOutlet weak var FnBtnName: UIButton!
    @IBOutlet weak var rollNumberLbl: UILabel!
    @IBOutlet weak var StudentLbl: UILabel!
    
    @IBOutlet weak var admissionLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        FnBtnName.layer.cornerRadius = 10
        AnBtnName.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
