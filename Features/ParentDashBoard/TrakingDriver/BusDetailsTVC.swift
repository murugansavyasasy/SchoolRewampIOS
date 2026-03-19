//
//  BusDetailsTVC.swift
//  BusTraking
//
//  Created by Chandhru on 13/02/26.
//

import UIKit
protocol RecentMoveDelegate{
    func recentMove(_ recent:Bool)
}

class BusDetailsTVC: UITableViewCell {
    @IBOutlet weak var busIconButton: UIButton!
    @IBOutlet weak var recentBtn: UIButton!
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet weak var busRouteLabel: UILabel!
    @IBOutlet weak var busStatusLabel: UILabel!

    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var nextStopLabel: UILabel!
    
    @IBOutlet weak var callDriverButton: UIButton!
    @IBOutlet weak var shareLocationButton: UIButton!
    var delegate:RecentMoveDelegate?
    var callDriverAction: (() -> Void)?
        var shareLocationAction: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        callDriverButton.layer.cornerRadius = 12
        shareLocationButton.layer.cornerRadius = 12
        shareLocationButton.layer.borderWidth = 2
        shareLocationButton.layer.borderColor = UIColor.systemGray5.cgColor
        recentBtn.layer.cornerRadius = recentBtn.frame.width/2
        busIconButton.layer.cornerRadius = 12
        busStatusLabel.layer.cornerRadius = 11
        busStatusLabel.layer.masksToBounds = true
    }
    func configure(busNumber: String,
                   route: String,
                   eta: String,
                   distance: String,
                   speed: String,
                   nextStop: String) {

        busNumberLabel.text = busNumber
        busRouteLabel.text = route
        etaLabel.text = eta
        distanceLabel.text = distance
        speedLabel.text = speed
        nextStopLabel.text = nextStop
    }
    @IBAction func callDriver(_ sender: UIButton) {
        callDriverAction?()
    }
    
    @IBAction func recentBtn(_ sender: UIButton) {
        delegate?.recentMove(true)
    }
    @IBAction func shareLocation(_ sender: UIButton) {
        shareLocationAction?()
    }

}
