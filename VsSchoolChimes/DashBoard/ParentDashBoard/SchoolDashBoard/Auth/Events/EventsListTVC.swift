//
//  EventsListTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 02/12/24.
//

import UIKit

class EventsListTVC: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
                outerView.layer.cornerRadius = 10
                outerView.layer.shadowColor = UIColor.black.cgColor
                outerView.layer.shadowOffset = CGSize(width: 4, height: 4)
                outerView.layer.shadowOpacity = 0.5
                outerView.layer.shadowRadius = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
