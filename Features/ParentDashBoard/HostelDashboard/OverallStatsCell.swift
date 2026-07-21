import UIKit

class OverallStatsCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var presentCountLabel: UILabel!
    @IBOutlet weak var absentCountLabel: UILabel!
    
    @IBOutlet var infoCards: [UIView]!

    override func awakeFromNib() {
        super.awakeFromNib()
        for v in infoCards {
            v.layer.cornerRadius = 12
            v.layer.borderWidth = 1
            v.layer.borderColor = UIColor.systemGray5.cgColor
            v.layer.shadowColor = UIColor.black.cgColor
            v.layer.shadowOpacity = 0.05
            v.layer.shadowOffset = CGSize(width: 0, height: 4)
            v.layer.shadowRadius = 8
            v.backgroundColor = .white
        }
    }

    func configure(with model: OverallStatsModel) {
        percentageLabel.text = model.percentage
        presentCountLabel.text = model.presentCount
        absentCountLabel.text = model.absentCount
    }
}
