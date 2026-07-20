import UIKit

class StopTimelineCell: UITableViewCell {
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var stepperCircle: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var infoCardView: UIView!
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var badgeContainer: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    @IBOutlet weak var timeIconImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var landmarkIconImageView: UIImageView!
    @IBOutlet weak var landmarkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        stepperCircle.layer.cornerRadius = 18
        stepperCircle.layer.shadowOffset = CGSize(width: 0, height: 4)
        stepperCircle.layer.shadowOpacity = 0.3
        stepperCircle.layer.shadowRadius = 6
        
        infoCardView.layer.cornerRadius = 16
        badgeContainer.layer.cornerRadius = 6
    }
    
    func configure(
        number: String,
        stopName: String,
        time: String,
        landmark: String,
        isYourStop: Bool,
        isFirst: Bool,
        isLast: Bool,
        journeyType: String
    ) {
        numberLabel.text = number
        stopNameLabel.text = stopName
        timeLabel.text = time
        landmarkLabel.text = landmark
        
        // Handle timeline line visibility
        topLineView.isHidden = isFirst
        bottomLineView.isHidden = isLast
        
        // Define color scheme based on journey type
        let isPicking = (journeyType == "PICKING")
        let accentColor = isPicking ? UIColor(red: 46/255, green: 175/255, blue: 99/255, alpha: 1.0) : UIColor(red: 160/255, green: 75/255, blue: 230/255, alpha: 1.0)
        let trackColor = isPicking ? UIColor(red: 170/255, green: 210/255, blue: 255/255, alpha: 1.0) : UIColor(red: 220/255, green: 190/255, blue: 255/255, alpha: 1.0)
        let blueColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0)
        
        topLineView.backgroundColor = trackColor
        bottomLineView.backgroundColor = trackColor
        
        if isYourStop {
            // "Your Stop" specific styling
            stepperCircle.backgroundColor = accentColor
            stepperCircle.layer.shadowColor = accentColor.cgColor
            
            infoCardView.layer.borderWidth = 1.5
            infoCardView.layer.borderColor = accentColor.cgColor
            
            badgeContainer.isHidden = false
            badgeContainer.backgroundColor = accentColor
            badgeLabel.text = "Your Stop".translated()
            
            timeIconImageView.tintColor = accentColor
        } else {
            // Regular Stop styling
            stepperCircle.backgroundColor = blueColor
            stepperCircle.layer.shadowColor = blueColor.cgColor
            
            infoCardView.layer.borderWidth = 1.0
            infoCardView.layer.borderColor = UIColor(red: 235/255, green: 240/255, blue: 245/255, alpha: 1.0).cgColor
            
            badgeContainer.isHidden = true
            
            timeIconImageView.tintColor = blueColor
        }
    }
}
