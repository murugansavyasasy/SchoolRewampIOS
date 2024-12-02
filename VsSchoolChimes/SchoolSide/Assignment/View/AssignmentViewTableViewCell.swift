//
//  AssignmentViewTableViewCell.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/29/24.
//

import UIKit

class AssignmentViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var submissionLbl: UILabel!
    @IBOutlet weak var deleteLbl: UILabel!
    @IBOutlet weak var forwardLbl: UILabel!
    @IBOutlet weak var viewLbl: UILabel!
    @IBOutlet weak var view: UIViewX!
    @IBOutlet weak var totalView: UIViewX!
    @IBOutlet weak var submissionView: UIViewX!
    @IBOutlet weak var deleteView: UIViewX!
    @IBOutlet weak var forwardView: UIViewX!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
