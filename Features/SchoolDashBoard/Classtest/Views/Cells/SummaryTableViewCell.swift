import UIKit

public final class SummaryTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet public weak var summaryContainerView: UIView!
    @IBOutlet public weak var summaryLabel: UILabel!
    
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        self.selectionStyle = .none
        
        summaryContainerView.layer.cornerRadius = 20
        summaryContainerView.layer.borderWidth = 1.0
        summaryContainerView.layer.borderColor = UIColor.msg.cgColor/*UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor*/ // #E2E8F0
       /* summaryContainerView.backgroundColor = UIColor(red: 0.957, green: 0.957, blue: 1.0, alpha: 1.0)*/ // #F4F4FF
        
        summaryLabel.adjustsFontForContentSizeCategory = true
    }
    
    // MARK: - Configuration
    public func configure(withCount count: Int) {
        let text = "\(count) section" + (count == 1 ? "" : "s") + " selected"
        summaryLabel.text = text
        summaryLabel.textColor = UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0) // #4C4DDC
        
        // Accessibility
        self.isAccessibilityElement = true
        self.accessibilityLabel = text
    }
}
