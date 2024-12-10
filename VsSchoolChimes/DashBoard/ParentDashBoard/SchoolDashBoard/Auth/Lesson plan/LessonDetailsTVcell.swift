//
//  LessonDetailsTVcell.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit

class LessonDetailsTVcell: UITableViewCell {

    @IBOutlet weak var barwidth: NSLayoutConstraint!
    @IBOutlet weak var progressview: UIView!
    @IBOutlet weak var Cellview: UIView!
    
    
    
    @IBOutlet weak var progressLine2WidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var progressBar: UIView!
    
    @IBOutlet weak var progressLine1WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressbar2: UIView!
   
       @IBOutlet weak var startIcon: UIImageView!
       @IBOutlet weak var progressIcon: UIImageView!
       @IBOutlet weak var completedIcon: UIImageView!
       @IBOutlet weak var startLabel: UILabel!
       @IBOutlet weak var progressLabel: UILabel!
       @IBOutlet weak var completedLabel: UILabel!
    
    var animated = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       // barwidth.constant = 0
        // Initialization code
        Cellview.layer.cornerRadius = 12.0
        Cellview.layer.masksToBounds = false
        
        // Shadow to make it look "popped up"
        Cellview.layer.shadowColor = UIColor.black.cgColor
        Cellview.layer.shadowOpacity = 0.2
        Cellview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Cellview.layer.shadowRadius = 6
        
        // Optional: Add a border for a polished look
        Cellview.layer.borderColor = UIColor.lightGray.cgColor
        Cellview.layer.borderWidth = 0.5

        
        // Background color for the card
        Cellview.backgroundColor = .white
        
        startIcon.tintColor = .lightGray
           progressIcon.tintColor = .lightGray
           completedIcon.tintColor = .lightGray
           
           // Initial setup for labels
//           startLabel.textColor = .lightGray
//           progressLabel.textColor = .lightGray
//           completedLabel.textColor = .lightGray
           
           // Reset progress line widths
           progressLine1WidthConstraint.constant = 0
           progressLine2WidthConstraint.constant = 0
           
           // Optional: Customize the appearance of progress lines
        progressBar.backgroundColor = .systemGreen
        progressbar2.backgroundColor = .systemGreen
           
           // Layout adjustments if needed
           self.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func prepareForReuse() {
           super.prepareForReuse()
//           progressLine1WidthConstraint.constant = 0
//           progressLine2WidthConstraint.constant = 0
//           resetIconsAndLabels()
           //animated = false
       }
       
    
    func startProgressAnimation() {
        
        if animated == false {
            
            animated = true
            // Step 1: Animate progressLine1 (startIcon to progressIcon)
            let startX = startIcon.frame.maxX
            let midX = progressIcon.frame.minX
            let firstLineWidth = midX - startX
            
            UIView.animate(withDuration: 1.0, animations: {
                self.progressLine1WidthConstraint.constant = firstLineWidth + 15
                self.startIcon.tintColor = .systemGreen // Highlight start icon
                self.startLabel.textColor = .black // Highlight start label
                self.layoutIfNeeded()
            }) { _ in
                // Step 2: Animate progressLine2 (progressIcon to completedIcon)
                let midX = self.progressIcon.frame.maxX
                let endX = self.completedIcon.frame.minX
                let secondLineWidth = endX - midX
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.progressLine2WidthConstraint.constant = secondLineWidth - 20
                    self.progressIcon.tintColor = .systemGreen // Highlight progress icon
                    self.progressLabel.textColor = .black // Highlight progress label
                    self.layoutIfNeeded()
                }) { _ in
                    // Step 3: Update "Completed" icon and label after progressLine2 finishes
                    self.completedIcon.tintColor = .systemGreen
                    self.completedLabel.textColor = .black
                }
            }
            
        }
    }

       
       // Reset icons and labels to default state
       private func resetIconsAndLabels() {
           startIcon.tintColor = .lightGray
           progressIcon.tintColor = .lightGray
           completedIcon.tintColor = .lightGray
//           startLabel.textColor = .lightGray
//           progressLabel.textColor = .lightGray
//           completedLabel.textColor = .lightGray
       }
    
   // func startProgressAnimation(duration: TimeInterval) {
   //            // Animate the width of the progressBar
   //       // barwidth.constant = self.contentView.frame.size.width/2 - 50
   //        self.barwidth.constant = 80
   //            UIView.animate(withDuration: duration) {
   //                self.contentView.layoutIfNeeded()
   //            }
   //        }

}
