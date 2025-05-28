//
//  SectionStregnthTVC.swift
//  School Chimes
//
//  Created by Chandhru on 27/05/25.
//

import UIKit

class SectionStregnthTVC: UITableViewCell {

    @IBOutlet weak var boysCountLbl: UILabel!
    @IBOutlet weak var girlsCountLbl: UILabel!
    @IBOutlet weak var otersCountLbl: UILabel!
    @IBOutlet weak var standardName: UILabel!
    @IBOutlet weak var studentCount: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
