//
//  LSRWProgressCVC.swift
//  School Chimes
//
//  Created by Chandhru on 13/08/25.
//

import UIKit

class LSRWProgressCVC: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        outerView.setShadow()
        iconBtn.isUserInteractionEnabled = false
        iconBtn.layer.cornerRadius = 8
    }
    
    func configure(with data: DashboardItem) {
        titleLbl.text = data.title
        valueLbl.text = data.value
        descriptionLbl.text = data.subtitle
        
        // Configure icon and colors based on dashboard item type
        let iconConfig = getIconConfiguration(for: data.title)
        iconBtn.setTitle(data.icon, for: .normal)
        iconBtn.backgroundColor = iconConfig.backgroundColor
        iconBtn.tintColor = iconConfig.tintColor
        
        // Configure label styles
        titleLbl.textColor = UIColor.black
        titleLbl.numberOfLines = 2
        valueLbl.textColor = UIColor.label
        
        descriptionLbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descriptionLbl.textColor = UIColor.gray
        descriptionLbl.numberOfLines = 2
        
        // Add subtle animation on configuration
        animateConfiguration()
    }
    
    private func getIconConfiguration(for title: String) -> (backgroundColor: UIColor, tintColor: UIColor) {
        switch title {
        case "Active Tasks":
            return (UIColor.systemBlue.withAlphaComponent(0.2), UIColor.systemBlue)
        case "Total Students":
            return (UIColor.systemGreen.withAlphaComponent(0.2), UIColor.systemGreen)
        case "Avg. Performance":
            return (UIColor.systemOrange.withAlphaComponent(0.2), UIColor.systemOrange)
        case "Completed Today":
            return (UIColor.systemPurple.withAlphaComponent(0.2), UIColor.systemPurple)
        default:
            return (UIColor.systemGray.withAlphaComponent(0.2), UIColor.systemGray)
        }
    }
    
    private func animateConfiguration() {
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLbl.text = nil
        valueLbl.text = nil
        descriptionLbl.text = nil
        iconBtn.setTitle(nil, for: .normal)
        iconBtn.backgroundColor = UIColor.clear
    }
}
