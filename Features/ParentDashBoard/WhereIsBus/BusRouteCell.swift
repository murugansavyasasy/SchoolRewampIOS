import UIKit

protocol liveTrakingBtnDelegate : AnyObject {
    func livetrakingBtnAction(index: Int)
}
class BusRouteCell: UITableViewCell {

    @IBOutlet weak var mainContainerView: UIView!
    
    @IBOutlet weak var topIconContainer: UIView!
    @IBOutlet weak var topIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var routeNumberLabel: UILabel!
    @IBOutlet weak var rightBadgeContainer: UIView!
    @IBOutlet weak var rightBadgeLabel: UILabel!
    
    @IBOutlet weak var stopContainerView: UIView!
    @IBOutlet weak var stopIconContainer: UIView!
    @IBOutlet weak var stopIconImageView: UIImageView!
    @IBOutlet weak var stopTitleLabel: UILabel!
    @IBOutlet weak var stopValueLabel: UILabel!
    @IBOutlet weak var navigateButton: UIButton!
    
    @IBOutlet weak var pickupContainer: UIView!
    @IBOutlet weak var pickupTitleLabel: UILabel!
    @IBOutlet weak var pickupValueLabel: UILabel!
    @IBOutlet weak var pickupIconImageView: UIImageView!
    
    @IBOutlet weak var dropContainer: UIView!
    @IBOutlet weak var dropTitleLabel: UILabel!
    @IBOutlet weak var dropValueLabel: UILabel!
    @IBOutlet weak var dropIconImageView: UIImageView!
    
    @IBOutlet weak var bottomRouteContainer: UIView!
    @IBOutlet weak var bottomRouteTitleLabel: UILabel!
    @IBOutlet weak var bottomRouteValueLabel: UILabel!
    
    @IBOutlet weak var trackButton: UIButton!
    weak var delegte : liveTrakingBtnDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        mainContainerView.layer.cornerRadius = 24
        mainContainerView.backgroundColor = .white
        mainContainerView.layer.shadowColor = UIColor.black.cgColor
        mainContainerView.layer.shadowOpacity = 0.05
        mainContainerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        mainContainerView.layer.shadowRadius = 16
        
        topIconContainer.layer.cornerRadius = 16
        rightBadgeContainer.layer.cornerRadius = 10
        
        stopContainerView.layer.cornerRadius = 16
        stopIconContainer.layer.cornerRadius = 14
        
        pickupContainer.layer.cornerRadius = 14
        dropContainer.layer.cornerRadius = 14
        
        bottomRouteContainer.layer.cornerRadius = 16
        
        trackButton.layer.cornerRadius = 16
    }
    
    @IBAction func liveTrackBtn(_ sender: UIButton) {
        
        delegte?.livetrakingBtnAction(index: sender.tag)
    }
    
    func configure(with route: StudentRouteData) {
        titleLabel.text = route.route_name
        routeNumberLabel.text = route.route_id
        rightBadgeLabel.text = route.vehicle_no
        
        stopValueLabel.text = route.stop_name
        
        pickupValueLabel.text = route.tentative_pickup_time
        dropValueLabel.text = route.tentative_drop_time
        
        bottomRouteValueLabel.text =  route.vehicle_no
        
    
            topIconContainer.backgroundColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0)
            rightBadgeContainer.backgroundColor = UIColor(red: 235/255, green: 245/255, blue: 255/255, alpha: 1.0)
            rightBadgeLabel.textColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0)
            
            stopContainerView.backgroundColor = UIColor(red: 245/255, green: 248/255, blue: 255/255, alpha: 1.0)
            stopIconContainer.backgroundColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0)
            stopTitleLabel.textColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0)
            navigateButton.tintColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0)
            
            pickupContainer.backgroundColor = UIColor(red: 235/255, green: 245/255, blue: 255/255, alpha: 1.0)
            pickupTitleLabel.textColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0)
            pickupIconImageView.tintColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0)
            
            dropContainer.backgroundColor = UIColor(red: 245/255, green: 235/255, blue: 255/255, alpha: 1.0)
            dropTitleLabel.textColor = UIColor(red: 170/255, green: 60/255, blue: 255/255, alpha: 1.0)
            dropIconImageView.tintColor = UIColor(red: 170/255, green: 60/255, blue: 255/255, alpha: 1.0)
            
     
        
        bottomRouteContainer.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 1.0)
        trackButton.backgroundColor = UIColor(red: 45/255, green: 120/255, blue: 255/255, alpha: 1.0)
    }
}

