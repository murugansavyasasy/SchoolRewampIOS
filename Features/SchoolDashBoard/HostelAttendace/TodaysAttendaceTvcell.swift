//
//  TodaysAttendaceTvcell.swift
//  School Chimes
//
//  Created by apple on 04/03/26.
//

import UIKit
protocol AttendanceSummaryCellDelegate: AnyObject {
    func didTapViewHistory()
}
class TodaysAttendaceTvcell: UITableViewCell {
    @IBOutlet weak var historyStackView: UIStackView!
    weak var delegate: AttendanceSummaryCellDelegate?
    @IBOutlet weak var pendingAttendanceView: UIView!
    @IBOutlet weak var todayFullview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        SetupUi()
    }

    func SetupUi(){
        
        
        if let card = todayFullview {
            card.layer.cornerRadius = 16
            card.layer.borderWidth = 1
            card.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        }
        if let card = pendingAttendanceView {
            card.layer.cornerRadius = 16
            card.layer.borderWidth = 1
            card.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        }
        
        if let stack = historyStackView {
            let tap = UITapGestureRecognizer(target: self, action: #selector(historyTapped))
            stack.addGestureRecognizer(tap)
            stack.isUserInteractionEnabled = true
        }
    }
    
    @objc private func historyTapped() {
        delegate?.didTapViewHistory()
    }

}
