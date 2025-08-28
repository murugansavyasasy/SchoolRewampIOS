import UIKit

class AttachmentCVCell: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 10
        outerView.clipsToBounds = true // Ensures the content respects the corner radius
        outerView.backgroundColor = .blue.withAlphaComponent(0.2)
    }

 }

 extension UIView {
     func addDashedBorder(color: UIColor = .lightGray,
                          lineWidth: CGFloat = 1,
                          dashPattern: [NSNumber] = [6, 3],
                          cornerRadius: CGFloat = 8) {
         
         // Remove old dashed layers
         layer.sublayers?.filter { $0.name == "DashedBorder" }.forEach { $0.removeFromSuperlayer() }
         
         let dashLayer = CAShapeLayer()
         dashLayer.name = "DashedBorder"
         dashLayer.strokeColor = color.cgColor
         dashLayer.fillColor = UIColor.clear.cgColor
         dashLayer.lineWidth = lineWidth
         dashLayer.lineDashPattern = dashPattern
         
         let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
         dashLayer.path = path.cgPath
         dashLayer.frame = bounds
         
         layer.addSublayer(dashLayer)
     }
 }
