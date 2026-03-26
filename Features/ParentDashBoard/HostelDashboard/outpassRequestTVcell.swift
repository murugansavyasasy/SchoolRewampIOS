//
//  outpassRequestTVcell.swift
//  School Chimes
//
//  Created by apple on 26/03/26.
//

import UIKit

class outpassRequestTVcell: UITableViewCell {

    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var RequestTimeLbl: UILabel!
    @IBOutlet weak var outPassTimeLbl: UILabel!
    @IBOutlet weak var reasonLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fullview.layer.cornerRadius = 10
        fullview.layer.borderWidth = 0.5
        fullview.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
