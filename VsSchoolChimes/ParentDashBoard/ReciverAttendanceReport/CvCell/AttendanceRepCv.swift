//
//  AttendanceRepCv.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 19/09/25.
//

import UIKit

class AttendanceRepCv: UICollectionViewCell {

    @IBOutlet weak var MnthLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var dateYrLbl: UILabel!
    @IBOutlet weak var AbsentBtnNm: UIButton!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var mnthView: UIView!
    @IBOutlet weak var pin2View: UIView!
    @IBOutlet weak var pin1View: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     
        fullview.layer.cornerRadius = 15
        fullview.layer.shadowColor = UIColor.black.cgColor
        fullview.layer.shadowOffset = CGSize(width: 0, height: 2)
        fullview.layer.shadowRadius = 5
        fullview.layer.shadowOpacity = 0.3
        
        AbsentBtnNm.layer.cornerRadius = 8
        
        pin2View.layer.cornerRadius = pin2View.frame.width / 2
        pin2View.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, // Top
                                        .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        pin1View.layer.cornerRadius = pin1View.frame.width / 2
        pin1View.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, // Top
                                        .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        mnthView.layer.cornerRadius = 8
    }

}
