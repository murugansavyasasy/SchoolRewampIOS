//
//  TimeCollectionViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 13/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class TimeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timelbl: UILabel!
    @IBOutlet weak var timeHoleView: UIViewX!
    override var isSelected: Bool {
        didSet {
            // Change the appearance of the cell when it's selected
            if isSelected {
                
                self.timeHoleView.backgroundColor = .systemOrange
                //
            } else {
                
                self.timeHoleView.backgroundColor = UIColor(named: "NoDataColor")
                
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.timeHoleView.backgroundColor = UIColor(named: "NoDataColor")
    }
}
