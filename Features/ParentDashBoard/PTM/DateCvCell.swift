//
//  DateCvCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 31/08/25.
//

import UIKit

class DateCvCell: UICollectionViewCell {

    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var dateBaseView: UIView!
    @IBOutlet weak var countBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 25
        dateBaseView.layer.cornerRadius = dateBaseView.frame.width / 2
        countBtn.layer.cornerRadius = countBtn.frame.width / 2
        
        monthLbl.setFont(style: .body, size: FontSize.BodySize)
        dateLbl.setFont(style: .body, size: FontSize.BodySize)
        countBtn.setTitleFont(style: .body, size: 10)
    }

}
