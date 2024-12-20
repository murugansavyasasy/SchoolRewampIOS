//
//  CertificateTableViewCell.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/20/24.
//

import UIKit

class CertificateTableViewCell: UITableViewCell {

    @IBOutlet weak var linkUrlLbl: UILabel!
    @IBOutlet weak var resonLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var cetificateNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
