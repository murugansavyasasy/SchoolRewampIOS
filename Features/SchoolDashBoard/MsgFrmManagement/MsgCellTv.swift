//
//  MsgCellTv.swift
//  School Chimes
//
//  Created by apple on 08/12/25.
//

import UIKit

class MsgCellTv: UITableViewCell {
    
    @IBOutlet weak var readView: UIView!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var emergencyBannerView: UIView!
    @IBOutlet weak var emergencyIconImageView: UIImageView!
    @IBOutlet weak var emergencyTitleLabel: UILabel!
    @IBOutlet weak var emergencyBannerHeightConstraint: NSLayoutConstraint! // To
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var profileInitialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleContainerView: UIView!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeIconImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewButton: UIButton!
    
    // MARK: - Lifecycle
    var delegate : ViewAttachments?
    var viewBtnTitle : String?
    var viewBtnImageName : String?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBAction func viewBtn(_ sender: UIButton) {
        delegate?.viewAttachment(sender: sender)
    }
    
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //        // Update gradients if needed on layout changes
    //        applyGradients()
    //    }
    //    
    // MARK: - Setup
    private func setupUI() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1.0) // Light gray background for the cell
        
        // Container View (Shadow Layer)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = CGSize(width: 4, height: 4)
        containerView.layer.shadowRadius = 8
        
        // Card View (Content & Clipping Layer)
        // Note: cardView background should be white.
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        
        // Emergency Banner
        emergencyTitleLabel.text = "EMERGENCY MESSAGE"
        emergencyTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        emergencyTitleLabel.textColor = .red
        emergencyIconImageView.image = UIImage(systemName: "light.beacon.max.fill")
        emergencyIconImageView.tintColor = .red
        
        
        // Profile
        profileContainerView.layer.cornerRadius = 24 // 48x48
        profileContainerView.clipsToBounds = true
        profileInitialsLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        profileInitialsLabel.textColor = .white
        
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .black
        
        roleContainerView.backgroundColor = UIColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 1.0) // Light Blue
        roleContainerView.layer.cornerRadius = 10
        roleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        roleLabel.textColor = .parentClr
        
        // Content
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.1, alpha: 1.0) // Almost black
        titleLabel.numberOfLines = 2
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 2
        
        // Bottom
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        timeLabel.textColor = .gray
        timeIconImageView.image = UIImage(systemName: "clock")
        timeIconImageView.tintColor = .gray
        
        // View Button
        viewButton.backgroundColor = .systemBlue
        viewButton.setTitle("View", for: .normal)
        viewButton.setTitleColor(.white, for: .normal)
        viewButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        viewButton.layer.cornerRadius = 22 // Height 44
        viewButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        viewButton.tintColor = .white
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .backGroundClr
            config.baseForegroundColor = .white
            config.cornerStyle = .capsule
            config.image = UIImage(systemName: "eye.fill")
            config.imagePadding = 8
            config.title = "View"
            viewButton.configuration = config
        } else {
            viewButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        }
        
    }

}
