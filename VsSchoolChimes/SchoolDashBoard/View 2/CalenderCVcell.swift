//
//  CalenderCVcell.swift
//  VsSchoolChimes
//
//  Created by MacBook on 21/02/25.
//

import UIKit

class CalenderCVcell: UICollectionViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var MonthLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        cellView.layer.cornerRadius = 10
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellView.layer.shadowRadius = 3
        cellView.layer.masksToBounds = false
        cellView.layer.borderWidth = 0.7
        cellView.layer.borderColor = UIColor.gray.cgColor
        
        MonthLbl.setFont(style: .title, size: FontSize.TitleSize)
        DateLbl.setFont(style: .header, size: FontSize.HeaderSize)
    }
    
    
    override var isSelected: Bool {
        didSet {
            // Change the appearance of the cell when it's selected
            if isSelected {
            
                self.cellView.backgroundColor = .attendence
//
            } else {
                
                self.cellView.backgroundColor = .white

            }
        }
    }
    
}
