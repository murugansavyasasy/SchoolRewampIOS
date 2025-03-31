//
//  SideTvcell.swift
//  VsSchoolChimes
//
//  Created by admin on 23/11/24.
//

import UIKit

class SideTvcell: UITableViewCell {

    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var ExameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.backgroundColor = UIColor.white.cgColor
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        cellView.layer.cornerRadius = 10
        cellView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if isSelected == true {
           cellView.backgroundColor = .parentClr
        }else{
           cellView.backgroundColor = .white
        }
    }
    
}
