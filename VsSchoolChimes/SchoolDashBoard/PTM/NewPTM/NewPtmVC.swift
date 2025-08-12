//
//  NewPtmVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 11/08/25.
//

import UIKit

class NewPtmVC: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var selectDateBtn: UIButton!
    @IBOutlet weak var MeetingCountLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topView.layer.cornerRadius = 20
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        backBtn.configureAsBackButton(firstLine: "PTM", secondLine: "savyasasy School", colour: .white)
        
        selectDateBtn.layer.cornerRadius = 10
        selectDateBtn.layer.borderWidth = 1
        selectDateBtn.layer.borderColor = UIColor.white.cgColor
        selectDateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        MeetingCountLbl.setFont(style: .header, size: FontSize.HeaderSize)
    }

}
