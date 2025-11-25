//
//  Exam_ClassListTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class Exam_ClassListTV: UITableViewCell {

    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var Classview: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseView.layer.cornerRadius = 10
        Classview.layer.cornerRadius = 10
        
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOpacity = 0.15
        baseView.layer.shadowRadius = 4
        baseView.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
