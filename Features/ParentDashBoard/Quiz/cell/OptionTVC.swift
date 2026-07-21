//
//  OptionTVC.swift
//  School Chimes
//
//  Created by Chandhru on 17/12/25.
//

import UIKit

class OptionTVC: UITableViewCell {

    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var ansImg: UIImageView!
    @IBOutlet weak var ansLbl: UILabel!
    @IBOutlet weak var optionBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        optionView.setShadow()
        optionBtn.layer.cornerRadius = optionBtn.frame.height/2
    }
    func configure(option: OptionsDeatil,
                   chooseOption: String,
                   studentAnswer: String?,
                   correctAnswer: String?) {

        ansLbl.text = option.option

        // Image
        if let imgStr = option.image, let imgURL = URL(string: imgStr), !imgStr.isEmpty {
            ansImg.isHidden = false
            ansImg.kf.setImage(with: imgURL, placeholder: UIImage(named: "ImagePdf"))
        } else {
            ansImg.isHidden = true
        }

        // Default gray
        optionView.layer.borderColor = UIColor.systemGray4.cgColor
        optionView.layer.borderWidth = 1
        optionView.backgroundColor = .clear
        optionBtn.setTitle(chooseOption, for: .normal)
        optionBtn.setImage(nil, for: .normal)

        // Correct & Student answer logic
        let optionText = option.option ?? ""

        if let student = studentAnswer, let correct = correctAnswer {

            if student == correct && optionText == student {
                // Student correct → GREEN
                optionBtn.setTitle("", for: .normal)
                optionBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                optionView.layer.borderColor = UIColor.systemGreen.cgColor
                optionView.layer.borderWidth = 2
                optionView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            }
            else if student != correct && optionText == correct {
                // Correct answer → GREEN
                optionBtn.setTitle("", for: .normal)
                optionBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                optionView.layer.borderColor = UIColor.systemGreen.cgColor
                optionView.layer.borderWidth = 2
                optionView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            }
            else if student != correct && optionText == student {
                // Student wrong → RED
                optionView.layer.borderColor = UIColor.systemRed.cgColor
                optionView.layer.borderWidth = 2
                optionView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            }
        }
    }
}
