//
//  LSRWPerformenceTVC.swift
//  School Chimes
//
//  Created by Chandhru on 22/08/25.
//

import UIKit

class LSRWPerformenceTVC: UITableViewCell {
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var persantageLbl: UILabel!
    @IBOutlet weak var pesantageProgress: UIProgressView!
    @IBOutlet weak var classLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var initialBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialBtn.layer.cornerRadius = initialBtn.frame.width/2
    }

    
}

