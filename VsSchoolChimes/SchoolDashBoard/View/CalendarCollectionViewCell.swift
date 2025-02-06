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
            
                self.caleView.backgroundColor = .attendence
//
            } else {
                
                self.caleView.backgroundColor = .white

            }
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.caleView.backgroundColor = .attendence
        caleView.layer.borderWidth = 0.5
        caleView.layer.borderColor = UIColor.gray.cgColor
    }
   

}
