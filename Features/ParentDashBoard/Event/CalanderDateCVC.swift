//
//  DateCVC.swift
//  School Chimes
//
//  Created by Chandhru on 07/07/25.
//

import UIKit

class CalanderDateCVC: UICollectionViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func reset() {
        dateLbl.text = ""
        dateLbl.textColor = .black
        dateLbl.backgroundColor = .clear
        dateLbl.font = .systemFont(ofSize: 12)
        outerView.backgroundColor = .white
        outerView.layer.borderWidth = 0
        outerView.layer.borderColor = UIColor.clear.cgColor
    }
    
}
