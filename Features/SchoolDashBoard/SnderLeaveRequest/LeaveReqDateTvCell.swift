//
//  LeaveReqDateTvCell.swift
//  School Chimes
//
//  Created by apple on 13/03/26.
//

import UIKit

class LeaveReqDateTvCell: UITableViewCell {
    @IBOutlet weak var fromdateAndTodateLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var leaveTypeLbl: UILabel!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
