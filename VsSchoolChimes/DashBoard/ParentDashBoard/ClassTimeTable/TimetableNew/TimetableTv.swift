//
//  TimetableTv.swift
//  TimetableDesignPractice
//
//  Created by Admin on 10/01/25.
//

import UIKit

class TimetableTv: UITableViewCell {

    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var DetailsView: UIView!
    @IBOutlet weak var ProgressView: UIView!
    @IBOutlet weak var ProgrssviewHeight: NSLayoutConstraint!
    @IBOutlet weak var CheckImgview: UIImageView!
    
    @IBOutlet weak var SubjectLbl: UILabel!
    
    @IBOutlet weak var StaffNameLbl: UILabel!
    
    @IBOutlet weak var DurationLbl: UILabel!
    var animated = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        DetailsView.layer.cornerRadius = 10
        DetailsView.layer.borderWidth = 0.5
        DetailsView.layer.borderColor = UIColor.gray.cgColor
        ProgrssviewHeight.constant = 0
        ProgressView.backgroundColor = .systemGreen
        
        TimeLbl.setFont(style: .title, size: FontSize.TitleSize)
        SubjectLbl.setFont(style: .title, size: FontSize.TitleSize)
        StaffNameLbl.setFont(style: .body, size: FontSize.BodySize)
        DurationLbl.setFont(style: .body, size: FontSize.BodySize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func animateProgressVertically() {
        
        if animated == false {
            
            animated = true
            // Ensure the progress view height starts at 0
            self.ProgrssviewHeight.constant = 0
            self.layoutIfNeeded() // Apply the initial state immediately
            
            // Calculate the target height for the animation
            let startY = CheckImgview.frame.maxY
            let targetHeight = cellview.frame.maxY - startY + 15
            
            // Animate the height change
            UIView.animate(withDuration: 3.0, animations: {
                self.ProgrssviewHeight.constant = targetHeight
                self.layoutIfNeeded() // Trigger the animation
            })
        }
    }

}
