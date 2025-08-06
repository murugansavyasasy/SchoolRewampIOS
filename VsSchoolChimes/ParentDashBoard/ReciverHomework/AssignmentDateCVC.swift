//
//  AssignmentDateCVC.swift
//  School Chimes
//
//  Created by Chandhru on 06/08/25.
//

import UIKit

class AssignmentDateCVC: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var dateLabl: UILabel!
    @IBOutlet weak var statusView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        outerView.layer.cornerRadius = 25
        outerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        outerView.layer.masksToBounds = true
        statusView.layer.cornerRadius = statusView.frame.height / 2
    }

    func configure(with date: Date, isSelected: Bool, status: DotStatus?) {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date) - 1
        let weekday = calendar.shortWeekdaySymbols[weekdayIndex]
        let day = calendar.component(.day, from: date)
        dateLabl.text = "\(weekday)\n\(day)"
        // Weekend styling
        if weekdayIndex == 0 { // Sunday
            dateLabl.textColor = UIColor.systemPink
        } else if weekdayIndex == 6 { // Saturday
            dateLabl.textColor = UIColor.systemPink.withAlphaComponent(0.7)
        } else {
            dateLabl.textColor = UIColor.label
        }

        // Selected date styling
        if isSelected {
            outerView.backgroundColor = Colornames.primeryColor
            dateLabl.textColor = .white
        } else {
            outerView.backgroundColor = .clear
        }

        // Dot status
        if let status = status {
            statusView.backgroundColor = (status == .red) ? .red : .green
        }else{
            statusView.backgroundColor = .clear
        }
    }
}
