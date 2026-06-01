//
//  BusStopTableViewCell.swift
//  BusTraking
//
//  Created by Chandhru on 23/02/26.
//

import UIKit

class BusStopTableViewCell: UITableViewCell {

    static let identifier = "BusStopTableViewCell"

    // MARK: - IBOutlets (Connected in XIB)
    @IBOutlet weak var statusIndicatorView: UIView!
    @IBOutlet weak var statusIconLabel: UILabel!
    @IBOutlet weak var connectingLineView: UIView!
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var stopTimeLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        // ✅ cornerRadius here, not in setupUI
        statusIndicatorView.layer.cornerRadius = 16
        statusIndicatorView.clipsToBounds = true
    }

    // MARK: - Configure

    func configure(with stop: BusStop, isLast: Bool) {
        stopNameLabel.text = stop.name
        stopTimeLabel.text = stop.time
        connectingLineView.isHidden = isLast

        if stop.isCompleted {
            statusIndicatorView.backgroundColor = .systemGreen
            statusIconLabel.text = "✓"
            statusIconLabel.textColor = .white
            stopNameLabel.textColor = .systemGray
            stopTimeLabel.textColor = .systemGray
            connectingLineView.backgroundColor = .systemGreen

        } else if stop.isCurrent {
            statusIndicatorView.backgroundColor = .systemOrange
            statusIconLabel.text = "●"
            statusIconLabel.textColor = .white
            stopNameLabel.textColor = .systemOrange
            stopTimeLabel.textColor = .systemOrange
            connectingLineView.backgroundColor = .systemGray5

        } else {
            statusIndicatorView.backgroundColor = .systemGray5
            statusIconLabel.text = "○"
            statusIconLabel.textColor = .systemGray
            stopNameLabel.textColor = .label
            stopTimeLabel.textColor = .systemGray
            connectingLineView.backgroundColor = .systemGray5
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        stopNameLabel.textColor = .label
        stopTimeLabel.textColor = .systemGray
        connectingLineView.isHidden = false
        connectingLineView.backgroundColor = .systemGray5
        statusIndicatorView.backgroundColor = .systemGray5
        statusIconLabel.text = "○"
        statusIconLabel.textColor = .systemGray
    }
}
