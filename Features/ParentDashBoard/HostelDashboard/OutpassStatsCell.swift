import UIKit

class OutpassStatsCell: UITableViewCell {

    @IBOutlet weak var leftCardView: UIView!
    @IBOutlet weak var rightCardView: UIView!
    @IBOutlet weak var pieChartView: SolidPieChartView!
    
    // Quick Stats labels
    @IBOutlet weak var totalRequestsLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var acceptedLabel: UILabel!
    @IBOutlet weak var declinedLabel: UILabel!
    
    // Rows
    @IBOutlet weak var declinedRowView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI(for: leftCardView)
        setupUI(for: rightCardView)
    }

    private func setupUI(for card: UIView) {
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 8
        card.backgroundColor = .white
    }
    
    func configure(with model: OutpassStatsModel) {
        totalRequestsLabel.text = model.totalRequests
        pendingLabel.text = model.pending
        acceptedLabel.text = model.accepted
        
        if let acceptedVal = Int(model.accepted),
           let pendingVal = Int(model.pending),
           let totalVal = Int(model.totalRequests) {
            
            // Derive declined logically if not explicitly passed
            let declinedVal = max(0, totalVal - (acceptedVal + pendingVal))
            declinedLabel.text = "\(declinedVal)"
            
            pieChartView.accepted = CGFloat(acceptedVal)
            pieChartView.pending = CGFloat(pendingVal)
            pieChartView.declined = CGFloat(declinedVal)
            
            // Hide declined row if 0 logically based strictly on screenshot
            // Or show it anyway since it might be useful
            declinedRowView.isHidden = false
        }
        
        pieChartView.setNeedsLayout()
    }
}
