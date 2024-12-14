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
    
    @IBOutlet weak var TopicLabel: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    
    @IBOutlet weak var RemarksLbl: UILabel!
    @IBOutlet weak var UnitLbl: UILabel!
    
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
    let Img = ImageName()
    var animated = false
    private let fireworkController = ClassicFireworkController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
       // setupBookAppearance()
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
      //  Cellview.backgroundColor = .white
        
        TopicLabel.setFont(style: .title, size: FontSize.TitleSize)
        DateLbl.setFont(style: .body, size: FontSize.BodySize)
        UnitLbl.setFont(style: .body, size: FontSize.BodySize)
        RemarksLbl.setFont(style: .body, size: FontSize.BodySize)
        startLabel.setFont(style: .body, size:10)
        progressLabel.setFont(style: .body, size: 10)
        completedLabel.setFont(style: .body, size: 10)
        
        if let originalImage = Img.completed {
                   let newSize = CGSize(width: 20, height: 20)
                   
                   // Call the resizing function
                   if let resizedImage = originalImage.resizedimg(to: newSize) {
                       // Set the resized image to the UIImageView
                       completedIcon.image = resizedImage
                       print("Image successfully resized")
                   } else {
                       print("Failed to resize the image.")
                   }
               } else {
                   print("Image named 'completed' not found in assets.")
               }
        
        completedIcon.contentMode = .scaleAspectFit
    
        startIcon.layer.cornerRadius = startIcon.frame.width/2
        progressIcon.layer.cornerRadius = progressIcon.frame.width/2
        completedIcon.layer.cornerRadius = completedIcon.frame.width/2
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
    private func checkSolution(selection: Int, correct: Int, imageView: UIImageView) {
        guard selection == correct else { return }

        // Assuming fireworkController is set up to work with UIImageView as well.
        self.fireworkController.addFireworks(count: 5, sparks: 8, around: imageView)
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
                }) { [self] _ in
                    // Step 3: Update "Completed" icon and label after progressLine2 finishes
                    self.completedIcon.tintColor = .systemGreen
                    self.completedLabel.textColor = .black
                    self.checkSolution(selection: 0, correct: 0, imageView: completedIcon)

                    // The print statement and animation code remain unchanged.
                    print("imgTapped")
                    UIView.animate(withDuration: 0.5, animations: {
                        imageView!.transform = CGAffineTransform.identity
                        }, completion: nil)

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
    
    private func setupBookAppearance() {
           // Add rounded corners
           self.layer.cornerRadius = 10
           self.layer.masksToBounds = true
           
           // Add a border to mimic book edges
           self.layer.borderColor = UIColor.lightGray.cgColor
           self.layer.borderWidth = 1
           
           // Add a shadow for depth
           self.layer.shadowColor = UIColor.black.cgColor
           self.layer.shadowOffset = CGSize(width: 2, height: 2)
           self.layer.shadowOpacity = 0.3
           self.layer.shadowRadius = 4
       }

}

// UIImage extension for resizing
extension UIImage {
    func resizedimg(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

