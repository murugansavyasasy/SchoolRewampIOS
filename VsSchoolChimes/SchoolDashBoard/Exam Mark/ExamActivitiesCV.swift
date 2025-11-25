//
//  ExamActivitiesCV.swift
//  School Chimes
//
//  Created by Lakshmanan on 25/11/25.
//

import UIKit

class ExamActivitiesCV: UICollectionViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 12
        
    }

}
