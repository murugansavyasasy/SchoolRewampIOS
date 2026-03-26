//
//  HostelRoomTvCell.swift
//  School Chimes
//
//  Created by apple on 03/03/26.
//

import UIKit

class HostelRoomTvCell: UITableViewCell {

    @IBOutlet weak var studentCapicatyLbl: UILabel!
    @IBOutlet weak var totalBedLbl: UILabel!
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alertIcon: UIImageView!
    @IBOutlet weak var occupancyStackView: UIStackView!
    @IBOutlet weak var occupancyLabel: UILabel!
    @IBOutlet weak var occupancyProgressView: UIProgressView!
    @IBOutlet weak var studentsStackView: UIStackView!
    @IBOutlet weak var emptyStateView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        if let card = cardContainerView {
            card.layer.cornerRadius = 16
            card.layer.borderWidth = 1
            card.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        }
        if let empty = emptyStateView {
            empty.layer.cornerRadius = 12
            empty.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        }
    }

    func configure(with room: HostelDashBoardRooms) {
        let current = room.current_occupancy ?? 0
        let max = room.max_occupancy ?? 0
        if let label = titleLabel { label.text = room.number }
        if let label = studentCapicatyLbl { label.text = " \(current)/\(max)" }
        
        if let label = totalBedLbl { label.text = String(room.total_beds ?? 0) }
        
        
        let occupancyPercent =
        room.max_occupancy ?? 0 > 0 ? Float(room.current_occupancy ?? 0) / Float(room.max_occupancy ?? 0) : 0
        if let occLabel = occupancyLabel { occLabel.text = "\(Int(occupancyPercent * 100))%" }
        if let prog = occupancyProgressView {
            prog.progress = occupancyPercent
            prog.progressTintColor = occupancyPercent >= 1.0 ? .systemRed : .systemBlue
        }

        if let stack = studentsStackView {
            stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

            if room.students?.count == 0 {
                occupancyStackView?.isHidden = true
                stack.isHidden = true
                emptyStateView?.isHidden = false
            } else {
                occupancyStackView?.isHidden = false
                stack.isHidden = false
                emptyStateView?.isHidden = true

                for studentName in room.students ?? [] {
                    let dotLabel = UILabel()
                    dotLabel.text = "•  \(studentName)"
                    dotLabel.font = .systemFont(ofSize: 14, weight: .regular)
                    dotLabel.textColor = .darkGray
                    stack.addArrangedSubview(dotLabel)
                }
            }
        }
    }
}
