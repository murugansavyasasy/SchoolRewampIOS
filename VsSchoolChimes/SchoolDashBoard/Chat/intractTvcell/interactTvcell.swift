//
//  interactTvcell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 01/07/25.
//

import UIKit

class interactTvcell: UITableViewCell {

    @IBOutlet weak var ClasTeacherLbl: UILabel!
    @IBOutlet weak var subjectNameLbl: UILabel!
    @IBOutlet weak var teacherNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
