//
//  WeeklyReportTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 30/07/25.
//

import UIKit

class WeeklyReportTV: UITableViewCell {

    @IBOutlet weak var Cellview: UIView!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var DayAndMonthLbl: UILabel!
    @IBOutlet weak var WeekStatusDefLbl: UILabel!
    @IBOutlet weak var Stackview: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Cellview.layer.cornerRadius = 10
        DateLbl.setFont(style: .header, size: 25)
        WeekStatusDefLbl.setFont(style: .body, size: FontSize.BodySize)
        
        let fulltext = "Wednesday July 2025"
        
        let attributedString = NSMutableAttributedString(string: fulltext)
        
        attributedString.addAttributes([.font: UIFont(name: "Poppins-Bold", size: 14) ], range: (fulltext as NSString).range(of: "Wednesday"))
        
        attributedString.addAttributes([.font: UIFont(name: "Poppins-Medium", size: 13) ], range: (fulltext as NSString).range(of: "July 2025"))
        
        DayAndMonthLbl.attributedText = attributedString
        
        setupDayButtons()
        
    }
    
    func setupDayButtons() {
        
        Stackview.arrangedSubviews.forEach { view in
            Stackview.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        let dayInitials = ["M", "T", "W", "T", "F", "S"] // You can include Sunday if needed
        
        for initial in dayInitials {
            // Create a vertical stack: [Label, Button]
            let verticalStack = UIStackView()
            verticalStack.axis = .vertical
            verticalStack.alignment = .center
            verticalStack.spacing = 4

            // Create the day label
            let label = UILabel()
            label.text = initial
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)

            // Create the checkbox button
            let button = UIButton(type: .system)
            button.setTitle("⬜", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 24)

            // Add label and button to the vertical stack
            verticalStack.addArrangedSubview(label)
            verticalStack.addArrangedSubview(button)

            // Add vertical stack to the horizontal stack
            Stackview.addArrangedSubview(verticalStack)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
