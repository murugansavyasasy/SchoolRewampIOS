import UIKit

public final class SectionTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet public weak var cardContainerView: UIView!
    @IBOutlet public weak var avatarView: UIView!
    @IBOutlet public weak var avatarLabel: UILabel!
    @IBOutlet public weak var sectionTitleLabel: UILabel!
    @IBOutlet public weak var sectionSubtitleLabel: UILabel!
    @IBOutlet public weak var checkmarkImageView: UIImageView!
    
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        self.selectionStyle = .none
        
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.layer.masksToBounds = true
        cardContainerView.layer.borderWidth = 1.5
        
        avatarView.layer.cornerRadius = 20
        avatarView.layer.masksToBounds = true
        
        // Dynamic type
        avatarLabel.adjustsFontForContentSizeCategory = true
        sectionTitleLabel.adjustsFontForContentSizeCategory = true
        sectionSubtitleLabel.adjustsFontForContentSizeCategory = true
    }
    
    // MARK: - Configuration
    public func configure(with section: TestSection, standardName: String, isSelected: Bool) {
        avatarLabel.text = section.name
        sectionTitleLabel.text = "Section \(section.name)"
        sectionSubtitleLabel.text = "Standard \(standardName) — \(section.name)"
        
        checkmarkImageView.isHidden = !isSelected
        
        if isSelected {
            // Purple selected border and styling
            cardContainerView.layer.borderColor =  UIColor.primery.cgColor /*UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0).cgColor // #4C4DDC*/
            avatarView.backgroundColor =  UIColor.primery /* UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0)*/
            avatarLabel.textColor = .white
            
            // Add subtle shadow for selected cards
            cardContainerView.layer.shadowColor = UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 0.15).cgColor
            cardContainerView.layer.shadowOpacity = 1.0
            cardContainerView.layer.shadowRadius = 8
            cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
            cardContainerView.layer.masksToBounds = false
        } else {
            // Gray unselected borders
            cardContainerView.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor // #E2E8F0
            avatarView.backgroundColor = UIColor(red: 0.957, green: 0.957, blue: 1.0, alpha: 1.0) // #F4F4FF
            avatarLabel.textColor = UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0)
            
            cardContainerView.layer.shadowOpacity = 0.0
            cardContainerView.layer.masksToBounds = true
        }
        
        // Accessibility
        self.isAccessibilityElement = true
        self.accessibilityLabel = "Section \(section.name), class Standard \(standardName)."
        self.accessibilityValue = isSelected ? "Selected" : "Not selected"
        self.accessibilityHint = "Double tap to toggle selection."
    }
}
