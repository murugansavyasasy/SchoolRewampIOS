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
    @IBOutlet weak var viewDetailsBtn: UIButton!
    
    var onViewDetails: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        fullview.layer.cornerRadius = 10
        fullview.layer.borderWidth = 1
        fullview.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        
        statusView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func viewDetailsAct(_ sender: Any) {
        onViewDetails?()
    }
    
}
