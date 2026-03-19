import UIKit

class AttendanceHistoryCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!

    @IBOutlet weak var pctLabel: UILabel!

    @IBOutlet weak var iconBgView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet weak var totalBgView: UIView!
    @IBOutlet weak var totalValueLabel: UILabel!

    @IBOutlet weak var presentBgView: UIView!
    @IBOutlet weak var presentValueLabel: UILabel!

    @IBOutlet weak var absentBgView: UIView!
    @IBOutlet weak var absentValueLabel: UILabel!

    @IBOutlet weak var roomsValueLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor

        totalBgView.layer.cornerRadius = 12
        presentBgView.layer.cornerRadius = 12
        absentBgView.layer.cornerRadius = 12
        iconBgView.layer.cornerRadius = 16
    }

    func configure(
        date: String, year: String, pct: String, isUp: Bool, total: String, present: String,
        absent: String, rooms: String, progress: Float
    ) {
        dateLabel.text = date
        yearLabel.text = year
        pctLabel.text = pct
        totalValueLabel.text = total
        presentValueLabel.text = present
        absentValueLabel.text = absent
        roomsValueLabel.text = rooms
        progressView.progress = progress

        if isUp {
            iconBgView.backgroundColor = UIColor(red: 0.88, green: 0.97, blue: 0.91, alpha: 1.0)
            iconImageView.image = UIImage(systemName: "arrow.up.right")
            iconImageView.tintColor = UIColor(red: 0.13, green: 0.77, blue: 0.36, alpha: 1.0)
        } else {
            iconBgView.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
            iconImageView.image = UIImage(systemName: "minus")
            iconImageView.tintColor = UIColor.gray
        }
    }
}
