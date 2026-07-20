import UIKit

public final class StandardCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet public weak var cardContainerView: UIView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var subtitleLabel: UILabel!
    @IBOutlet public weak var badgeImageView: UIImageView!
    
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.layer.masksToBounds = true
        cardContainerView.layer.borderWidth = 1.5
        
        // Dynamic type support setup
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        
        // Inactive unselected colors initially
        updateBorderColor()
    }
    
    // MARK: - Configuration
    public func configure(with standard: TestStandard, isSelected: Bool) {
        titleLabel.text = standard.name
        
        let count = standard.sections.count
        let sectionText = (count == 1 ? "SECTION" : "SECTIONS").translated()
        subtitleLabel.text = "\(count) \(sectionText)"
        
//        badgeImageView.isHidden = !isSelected
        badgeImageView.image = isSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        
        // Colors from design spec
        if isSelected {
            cardContainerView.backgroundColor = UIColor.primery/*UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0)*/ // #4C4DDC
            titleLabel.textColor = .white
            subtitleLabel.textColor = .white.withAlphaComponent(0.8)
            cardContainerView.layer.borderColor =  UIColor.primery.cgColor /* UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0).cgColor*/
        } else {
            cardContainerView.backgroundColor = .white
            titleLabel.textColor = UIColor(red: 0.102, green: 0.110, blue: 0.161, alpha: 1.0) // #1A1C29
            subtitleLabel.textColor = UIColor(red: 0.392, green: 0.455, blue: 0.545, alpha: 1.0) // #64748B
            cardContainerView.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor // #E2E8F0
        }
        
        // Accessibility
        self.isAccessibilityElement = true
        self.accessibilityLabel = "Class \(standard.name), \(count) section" + (count == 1 ? "" : "s")
        self.accessibilityHint = isSelected ? "Currently selected." : "Double tap to select."
        self.accessibilityTraits = isSelected ? [.button, .selected] : [.button]
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBorderColor()
    }
    
    private func updateBorderColor() {
        // Safe check for system trait variations
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            // Unselected dark mode border
            if badgeImageView.isHidden {
                cardContainerView.layer.borderColor = UIColor.systemGray.cgColor
            }
        }
    }
}
