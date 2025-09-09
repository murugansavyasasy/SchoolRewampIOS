//
//  PunchUserDetailsTVC.swift
//  School Chimes
//
//  Created by Chandhru on 05/09/25.
//

import UIKit

class PunchUserDetailsTVC: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var institutionIcon: UIButton!
    @IBOutlet weak var institutionLabel: UILabel!
    @IBOutlet weak var institutionValueLabel: UILabel!
    
    @IBOutlet weak var staffNameIcon: UIButton!
    @IBOutlet weak var staffNameLabel: UILabel!
    @IBOutlet weak var staffNameValueLabel: UILabel!
    
    @IBOutlet weak var designationIcon: UIButton!
    @IBOutlet weak var designationLabel: UILabel!
    @IBOutlet weak var designationValueLabel: UILabel!
    
    @IBOutlet weak var dateIcon: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateValueLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    
    // MARK: - Properties
    var staffdetails = UserDefaultFileManager.get_staff_Details()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Configure container view
        headerView.layer.cornerRadius = 10
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor.systemGray5.cgColor
//        containerView.layer.masksToBounds = true
        setupIcons()
        
        // Configure labels
//        setupLabels()
        
        // Configure selection style
        selectionStyle = .none
    }
    
    private func setupIcons() {
        let icons = [institutionIcon, staffNameIcon, designationIcon, dateIcon]
        icons.forEach { icon in
            icon?.layer.cornerRadius = 15
            icon?.layer.masksToBounds = true
            icon?.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.7)
            icon?.tintColor = UIColor.systemGray
            icon?.isUserInteractionEnabled = false
        }
    }
    
//    private func setupLabels() {
//        // Title and subtitle
//        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
//        titleLabel.textColor = .label
//        
//        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
//        subtitleLabel.textColor = .secondaryLabel
//        
//        // Field labels
//        let fieldLabels = [institutionLabel, staffNameLabel, designationLabel, dateLabel]
//        fieldLabels.forEach { label in
//            label?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
//            label?.textColor = .label
//            label?.numberOfLines = 0
//        }
//        
//        // Value labels
//        let valueLabels = [institutionValueLabel, staffNameValueLabel, designationValueLabel, dateValueLabel]
//        valueLabels.forEach { label in
//            label?.font = UIFont.boldSystemFont(ofSize: 13)
//            label?.numberOfLines = 0
//            label?.textAlignment = .right
//        }
//        
//        // Special coloring for certain value labels
//        institutionValueLabel.textColor = UIColor(named: "PrimeryColor") ?? .systemBlue
//        staffNameValueLabel.textColor = .label
//        designationValueLabel.textColor = UIColor(named: "PrimeryColor") ?? .systemBlue
//        dateValueLabel.textColor = UIColor(named: "PrimeryColor") ?? .systemBlue
//    }
    
    func configureWithDetails(
        institutionName: String,
        staffName: String,
        designation: String,
        date: String
    ) {
        
        DispatchQueue.main.async { [weak self] in
            self?.institutionValueLabel.text = institutionName
            self?.staffNameValueLabel.text = staffName
            self?.designationValueLabel.text = designation.uppercased()
            self?.dateValueLabel.text = date
        }
    }
}

