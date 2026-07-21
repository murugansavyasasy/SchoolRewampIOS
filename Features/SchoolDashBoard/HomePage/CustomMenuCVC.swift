//
//  CustomMenuCVC.swift
//  School Chimes
//
//  Created by Chandhru on 31/07/25.
//

import UIKit

class CustomMenuCVC: UICollectionViewCell {
    @IBOutlet weak var readVieaw: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var imenuName: UILabel!
    @IBOutlet weak var menuCondent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 10
        outerView.layer.masksToBounds = false
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.04
        outerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        outerView.layer.shadowRadius = 4
        outerView.layer.borderWidth = 0.3
        outerView.layer.borderColor = UIColor.systemGray5.cgColor
        readVieaw.layer.cornerRadius = readVieaw.frame.width/2
    }
    
}
