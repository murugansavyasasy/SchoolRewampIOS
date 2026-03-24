import UIKit

class SessionAnalysisCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barChartView: SimpleBarChartView!
    
    // Stack views for percent cards
    @IBOutlet weak var percentStackView: UIStackView!
    @IBOutlet weak var morningPercentLabel: UILabel!
    @IBOutlet weak var afternoonPercentLabel: UILabel!
    @IBOutlet weak var eveningPercentLabel: UILabel!
    
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
    
    func configure(with model: SessionAnalysisModel) {
        titleLabel.text = model.title
        
        // Pass data to bar chart
        barChartView.dataPoints = model.sessions.map { 
            (title: $0.title, presentCount: $0.presentCount, absentCount: $0.absentCount) 
        }
        barChartView.setNeedsLayout()
        
        // Update percentages
        if model.sessions.count >= 3 {
            morningPercentLabel.text = model.sessions[0].percentageString
            afternoonPercentLabel.text = model.sessions[1].percentageString
            eveningPercentLabel.text = model.sessions[2].percentageString
        }
    }
}
