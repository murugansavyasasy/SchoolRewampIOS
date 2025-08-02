//
//  CustomMenuCVC.swift
//  School Chimes
//
//  Created by Chandhru on 31/07/25.
//

import UIKit

class CustomMenuCVC: UICollectionViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var imenuName: UILabel!
    @IBOutlet weak var menuCondent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.setShadow(cornerRadius: 4)
    }

}
