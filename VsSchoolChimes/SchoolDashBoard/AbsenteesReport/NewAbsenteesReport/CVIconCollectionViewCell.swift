//
//  CVIconCollectionViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 24/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class CVIconCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateFulView: UIViewX!
    @IBOutlet weak var MnthLbl: UILabel!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                dateFulView.backgroundColor = .systemOrange
                dayLbl.textColor = .white
                dateLbl.textColor = .white
            } else {
                self.dateFulView.backgroundColor = .white
                dayLbl.textColor = .black
                dateLbl.textColor = .black
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
