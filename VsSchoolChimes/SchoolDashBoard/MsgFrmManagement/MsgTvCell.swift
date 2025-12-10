//
//  MsgTvCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 02/09/25.
//

import UIKit
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
    @IBOutlet weak var schoolNameLbl: UILabel!
    var delegate : ViewAttachments?
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBtn.layer.cornerRadius = 5
        viewBtn.layer.borderWidth = 1
        viewBtn.layer.borderColor = UIColor.systemBlue
            .withAlphaComponent(0.6).cgColor
        alphbetView.layer.cornerRadius = alphbetView.frame.height/2
        fullview.setShadow()
        rollBtn.layer.cornerRadius = 5
    }
    @IBAction func viewBtnAct(_ sender: UIButton) {
        
        delegate?.viewAttachment(sender: sender)
    }
   
}
