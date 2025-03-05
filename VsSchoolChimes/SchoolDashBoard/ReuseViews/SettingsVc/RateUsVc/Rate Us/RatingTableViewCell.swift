
//  RatingTableViewCell.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 05/11/24.
//

import UIKit

class RatingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var HowSatisfiedLbl: UILabel!
    @IBOutlet var groupButtons: [UIButton]!
    @IBOutlet weak var RatingValue: UIButton!
    var RatingDelegate: RatingDelegate?
    var selectcount:Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        HowSatisfiedLbl.setFont(style: .title, size: FontSize.TitleSize)
        RatingValue.setTitleFont(style: .body, size: 18)
        RatingValue.layer.borderWidth = 1
        RatingValue.layer.borderColor = UIColor.red.cgColor
        RatingValue.layer.cornerRadius = 20
        
    }
    @IBAction func rating(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        RatingValue.layer.borderColor = UIColor.clear.cgColor
        
        let filledStars = sender.tag + 1
        var ratingText: String = ""
        var ratingTextColour : UIColor
        
        // Only proceed if tag is not 0 or `isSelected` is true
        if filledStars != 0 || sender.isSelected {
            switch filledStars {
            case 1:
                ratingText = RatingCellStringFile.Bad
                ratingTextColour = .systemRed
            case 2:
                ratingText = RatingCellStringFile.Not_bad
                ratingTextColour = .systemRed
            case 3:
                ratingText = RatingCellStringFile.Good
                ratingTextColour = .systemOrange
            case 4:
                ratingText = RatingCellStringFile.Well_done
                ratingTextColour = .systemGreen
            case 5:
                ratingText = RatingCellStringFile.Excellent
                ratingTextColour = .systemGreen
            default:
                RatingValue.layer.borderColor = UIColor.red.cgColor
                return // Exit if out of expected range
            }
            
            // Update the label text
            RatingValue.setTitle(ratingText, for: .normal)
            RatingValue.tintColor = ratingTextColour
            
            // Set star images based on the rating
            for (index, button) in groupButtons.enumerated() {
//                let imageName = index < filledStars ? ImageName.unnamed : ImageName.unnamed2
//                button.setImage(imageName, for: .normal)
                var imageName = ImageName.unnamed2
                if index < filledStars {
                    imageName = ImageName.unnamed
                    button.tintColor = .systemYellow
                }else{
                    imageName = ImageName.unnamed2
                    button.tintColor = .systemGray4
                }
                button.setImage(imageName, for: .normal)
            }
            
            // Notify delegate with the rating
            RatingDelegate?.rating(filledStars)
        }
        
    }
}
