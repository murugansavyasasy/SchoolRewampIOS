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
        iconBtn.clipsToBounds = true
    }
    
    func configure(with data: Overview) {
        titleLbl.text = data.title
        valueLbl.text = data.value
        descriptionLbl.text = data.subtitle
        
        // Configure icon + colors
        let iconConfig = getIconConfiguration(for: data.title ?? "")
        iconBtn.setTitle(iconConfig.icon, for: .normal)
        iconBtn.backgroundColor = iconConfig.backgroundColor
        iconBtn.setTitleColor(iconConfig.tintColor, for: .normal)
        
        // Label styles
        titleLbl.textColor = .black
        titleLbl.numberOfLines = 2
        valueLbl.textColor = .label
        
        descriptionLbl.font = .systemFont(ofSize: 12, weight: .regular)
        descriptionLbl.textColor = .gray
        descriptionLbl.numberOfLines = 2
        
        // Subtle bounce animation
        animateConfiguration()
    }
    
    private func getIconConfiguration(for title: String) -> DashboardIconConfig {
        switch title {
        case "Active Tasks":
            return DashboardIconConfig(
                icon: "📋",
                backgroundColor: UIColor.systemBlue.withAlphaComponent(0.2),
                tintColor: UIColor.systemBlue
            )
        case "Total Students":
            return DashboardIconConfig(
                icon: "👥",
                backgroundColor: UIColor.systemGreen.withAlphaComponent(0.2),
                tintColor: UIColor.systemGreen
            )
        case "Avg. Performance":
            return DashboardIconConfig(
                icon: "📈",
                backgroundColor: UIColor.systemOrange.withAlphaComponent(0.2),
                tintColor: UIColor.systemOrange
            )
        case "Listening":
            return DashboardIconConfig(
                icon: "🎧",
                backgroundColor: UIColor.systemPurple.withAlphaComponent(0.2),
                tintColor: UIColor.systemPurple
            )
        case "Speaking":
            return DashboardIconConfig(
                icon: "🎤",
                backgroundColor: UIColor.systemOrange.withAlphaComponent(0.2),
                tintColor: UIColor.systemOrange
            )
        case "Reading":
            return DashboardIconConfig(
                icon: "📖",
                backgroundColor: UIColor.systemGreen.withAlphaComponent(0.2),
                tintColor: UIColor.systemGreen
            )
        case "Writing":
            return DashboardIconConfig(
                icon: "✏️",
                backgroundColor: UIColor.systemBlue.withAlphaComponent(0.2),
                tintColor: UIColor.systemBlue
            )
        case "Today Submitted":
            return DashboardIconConfig(
                icon: "✅",
                backgroundColor: UIColor.systemPurple.withAlphaComponent(0.2),
                tintColor: UIColor.systemPurple
            )
        case "Completed Tasks":
            return DashboardIconConfig(
                icon: "✅",
                backgroundColor: UIColor.systemPurple.withAlphaComponent(0.2),
                tintColor: UIColor.systemPurple
            )
        default:
            return DashboardIconConfig(
                icon: "❔",
                backgroundColor: UIColor.systemGray.withAlphaComponent(0.2),
                tintColor: UIColor.systemGray
            )
        }
    }
    
    private func animateConfiguration() {
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.transform = .identity
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLbl.text = nil
        valueLbl.text = nil
        descriptionLbl.text = nil
        iconBtn.setTitle(nil, for: .normal)
        iconBtn.backgroundColor = .clear
        iconBtn.setTitleColor(.clear, for: .normal)
    }
}

struct DashboardIconConfig {
    let icon: String
    let backgroundColor: UIColor
    let tintColor: UIColor
}
