//
//  CalendarCollectionViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 23/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var slotCountLbl: UILabel!
    
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var caleView: UIViewX!
    

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!

    override var isSelected: Bool {
        didSet {
            // Change the appearance of the cell when it's selected
            if isSelected {
            
                self.caleView.backgroundColor = .systemOrange
//
            } else {
                
                self.caleView.backgroundColor = UIColor(named: "NoDataColor")

            }
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.caleView.backgroundColor = UIColor(named: "NoDataColor")
    }
   

}
