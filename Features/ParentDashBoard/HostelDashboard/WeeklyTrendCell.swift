import UIKit

class WeeklyTrendCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineChartView: SimpleLineChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.backgroundColor = .white
    }
    
    func configure(with model: WeeklyTrendModel) {
        titleLabel.text = model.title
        
        // Pass data to Line Chart
        lineChartView.dataPoints = model.points.map { 
            (label: $0.dateLabel, percentage: $0.percentage) 
        }
        lineChartView.setNeedsLayout()
    }
}
