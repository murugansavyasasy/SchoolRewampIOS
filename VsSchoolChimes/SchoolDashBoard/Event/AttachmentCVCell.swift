import UIKit

class AttachmentCVCell: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 10
        outerView.clipsToBounds = true // Ensures the content respects the corner radius

        // Create a dashed border
        let dashBorder = CAShapeLayer()
        dashBorder.strokeColor = UIColor.black.cgColor // Set border color
        dashBorder.lineDashPattern = [6, 3] // Pattern: 6pt line, 3pt gap
        dashBorder.frame = outerView.bounds
        dashBorder.fillColor = nil // No fill, only border
        dashBorder.lineWidth = 2 // Border thickness
        dashBorder.path = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 10).cgPath

        // Remove any existing border to avoid duplicates
        outerView.layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }
        
        // Add the dashed border layer
        outerView.layer.addSublayer(dashBorder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let dashLayer = outerView.layer.sublayers?.first(where: { $0 is CAShapeLayer }) as? CAShapeLayer {
            dashLayer.frame = outerView.bounds
            dashLayer.path = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 10).cgPath
        }
    }
}
