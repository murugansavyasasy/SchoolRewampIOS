//
//  CalanderCvCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 21/07/25.
//

import UIKit

class CalanderCvCell: UICollectionViewCell {

    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
   
    @IBOutlet weak var monthLabel: UILabel!
       
    @IBOutlet weak var dayLabel: UILabel!
    

    override func awakeFromNib() {
            super.awakeFromNib()
            contentView.layer.cornerRadius = 10
            contentView.layer.masksToBounds = true
            dotView.layer.cornerRadius = dotView.frame.width/2
            dotView.clipsToBounds = true
        }

        func configure(with item: CalendarItem, isToday: Bool, isSelected: Bool, hasHomework: Bool, isFuture: Bool) {
            dayLabel.text = item.dayString
            dateLabel.text = item.dateString
            monthLabel.text = item.monthString

//            dotView.isHidden = !hasHomework
//            dotView.backgroundColor = hasHomework ? UIColor.homeWorkClr : .clear

            if isFuture {
                dayLabel.textColor = .lightGray
                dateLabel.textColor = .lightGray
                monthLabel.textColor = .lightGray
                contentView.backgroundColor = .clear
            } else if isSelected {
                dayLabel.textColor = .white
                dateLabel.textColor = .white
                monthLabel.textColor = .white
                contentView.backgroundColor = .systemBlue
            } else {
                dayLabel.textColor = .black
                dateLabel.textColor = .black
                monthLabel.textColor = .black
                contentView.backgroundColor = .clear
            }
        }
    }
