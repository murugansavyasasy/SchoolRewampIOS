//
//  MsgTvCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 02/09/25.
//

import UIKit
protocol viewAttachments {
    
    func viewAttachment(sender : UIButton)
}
class MsgTvCell: UITableViewCell {

    @IBOutlet weak var alphbetLbl: UILabel!
    @IBOutlet weak var readView: UIView!
    @IBOutlet weak var timeAndDateLbl: UILabel!
    
    @IBOutlet weak var descrptionLb: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var senderNamelbl: UILabel!
    @IBOutlet weak var rollBtn: UIButton!
    @IBOutlet weak var alphbetView: UIView!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var viewBtn: UIButton!
    var delegate : viewAttachments?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBtn.layer.cornerRadius = 5
        viewBtn.layer.borderWidth = 1
        viewBtn.layer.borderColor = UIColor.systemBlue
            .withAlphaComponent(0.6).cgColor
        alphbetView.layer.cornerRadius = alphbetView.frame.height/2
        fullview.layer.cornerRadius = 10
        rollBtn.layer.cornerRadius = 5
        readView.layer.cornerRadius = readView.frame.width/2
    }

    @IBAction func viewBtnAct(_ sender: UIButton) {
        
        delegate?.viewAttachment(sender: sender)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
