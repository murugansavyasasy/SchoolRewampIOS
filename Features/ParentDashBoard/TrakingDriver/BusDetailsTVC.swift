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
    
    @IBOutlet weak var toStoplbl: UILabel!
    @IBOutlet weak var fromStopLbl: UILabel!
    @IBOutlet weak var busdetailsFullView: UIView!
    @IBOutlet weak var busspeedFullView: UIView!
    @IBOutlet weak var busIconButton: UIButton!
    @IBOutlet weak var recentBtn: UIButton!
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet weak var busRouteLabel: UILabel!
    @IBOutlet weak var busStatusLabel: UILabel!

    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var nextStopLabel: UILabel!
   
    var delegate:RecentMoveDelegate?
    var callDriverAction: (() -> Void)?
    var shareLocationAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
        recentBtn.layer.cornerRadius = recentBtn.frame.width/2
        busIconButton.layer.cornerRadius = 12
        busStatusLabel.layer.cornerRadius = 11
        busStatusLabel.layer.masksToBounds = true
        busdetailsFullView.layer.cornerRadius = 15
        busdetailsFullView.layer.borderWidth = 0.5
        busdetailsFullView.layer.borderColor = UIColor.systemGray5.cgColor
        busspeedFullView.layer.cornerRadius = 15
    }
    
    func configure(busNumber: String,
                   route: String,
                   eta: String,
                   distance: String,
                   speed: String,
                   nextStop: String,fromstop:String,tostop:String) {

        busNumberLabel.text = busNumber
        busRouteLabel.text = route
        etaLabel.text = eta
        distanceLabel.text = distance
        speedLabel.text = speed
        nextStopLabel.text = nextStop
        fromStopLbl.text = fromstop
        toStoplbl.text = tostop
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
