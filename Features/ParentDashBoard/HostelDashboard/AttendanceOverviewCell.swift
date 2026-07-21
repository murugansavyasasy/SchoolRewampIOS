import UIKit

class AttendanceOverviewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var donutChartView: DonutChartView!
    @IBOutlet weak var presentCountLabel: UILabel!
    @IBOutlet weak var absentCountLabel: UILabel!
    
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
    
    func configure(with model: AttendanceOverviewModel) {
        titleLabel.text = model.title
        presentCountLabel.text = "\(model.presentCount)"
        absentCountLabel.text = "\(model.absentCount)"
        
        donutChartView.presentValue = model.presentCount
        donutChartView.absentValue = model.absentCount
        donutChartView.setNeedsLayout()
    }
}
