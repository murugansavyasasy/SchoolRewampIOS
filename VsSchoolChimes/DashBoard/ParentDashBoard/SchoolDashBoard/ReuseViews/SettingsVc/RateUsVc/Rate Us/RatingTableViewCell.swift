//
//  RatingTableViewCell.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 05/11/24.
//

import UIKit

class RatingTableViewCell: UITableViewCell {

    @IBOutlet var groupButtons: [UIButton]!
    @IBOutlet weak var RatingValue: UIButton!
    var RatingDelegate: RatingDelegate?
    var selectcount:Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        RatingValue.layer.borderWidth = 1
        RatingValue.layer.borderColor = UIColor.red.cgColor
        RatingValue.layer.cornerRadius = 20
//        RatingValue.backgroundColor = .blue
        // Initialization code
    }
    @IBAction func rating(_ sender: UIButton) {

        sender.isSelected.toggle()
        RatingValue.layer.borderColor = UIColor.clear.cgColor
        
        let filledStars = sender.tag + 1
        var ratingText: String = ""

        // Only proceed if tag is not 0 or `isSelected` is true
        if filledStars != 0 || sender.isSelected {
            switch filledStars {
            case 1:
                ratingText = "Nice"
            case 2:
                ratingText = "Nice"
            case 3:
                ratingText = "Better"
            case 4:
                ratingText = "Well done"
            case 5:
                ratingText = "Not bad"
            default:
                RatingValue.layer.borderColor = UIColor.red.cgColor
                return // Exit if out of expected range
            }
            
            // Update the label text
            RatingValue.setTitle(ratingText, for: .normal)

            // Set star images based on the rating
            for (index, button) in groupButtons.enumerated() {
                let imageName = index < filledStars ? "unnamed" : "unnamed-2"
                button.setImage(UIImage(named: imageName), for: .normal)
            }

            // Notify delegate with the rating
            RatingDelegate?.rating(filledStars)
        }

    }
}
