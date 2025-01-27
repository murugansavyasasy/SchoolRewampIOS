//
//  SectionCollectionViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 26/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class SectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var sectionClick: UIViewX!
    @IBOutlet weak var absentcountLbl: UILabel!
    @IBOutlet weak var sectionNameLbl: UILabel!
    override var isSelected: Bool {
            didSet {
                if isSelected {
                    sectionClick.backgroundColor = .systemOrange
                    sectionNameLbl.textColor = .white
                    sectionNameLbl.textColor = .white
                } else {
                    sectionClick.backgroundColor = .gray
                    sectionNameLbl.textColor = .black
                    sectionNameLbl.textColor = .black
                }
            }
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
