import UIKit

class RequestItemCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconLabel: UILabel!

    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var studentLabel: UILabel!
    @IBOutlet weak var issueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var statusIconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1

        iconContainerView.layer.cornerRadius = 12
    }

    func configure(
        roomNum: String, studentName: String, issue: String, date: String, isResolved: Bool
    ) {
        let cleanRoom = roomNum.replacingOccurrences(of: "Room ", with: "")
        iconLabel.text = cleanRoom
        roomLabel.text = roomNum
        studentLabel.text = studentName
        dateLabel.text = date

        if isResolved {
            // Green "Resolved" Theme
            cardView.backgroundColor = UIColor(red: 0.96, green: 1.0, blue: 0.96, alpha: 1.0)
            cardView.layer.borderColor =
                UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1.0).cgColor

            iconContainerView.backgroundColor = UIColor(
                red: 0.35, green: 0.8, blue: 0.45, alpha: 1.0)
            iconLabel.textColor = .white

            // Strikethrough for issue label
            let attrString = NSAttributedString(
                string: issue,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.gray,
                ]
            )
            issueLabel.attributedText = attrString

            statusIconImageView.image = UIImage(systemName: "checkmark.circle")
            statusIconImageView.tintColor = UIColor(red: 0.35, green: 0.8, blue: 0.45, alpha: 1.0)
        } else {
            // Orange/Yellow "Pending" Theme
            cardView.backgroundColor = UIColor(red: 1.0, green: 0.98, blue: 0.91, alpha: 1.0)
            cardView.layer.borderColor =
                UIColor(red: 0.98, green: 0.9, blue: 0.7, alpha: 1.0).cgColor

            iconContainerView.backgroundColor = UIColor(
                red: 0.98, green: 0.6, blue: 0.0, alpha: 1.0)
            iconLabel.textColor = .white

            // Normal text for issue label
            let attrString = NSAttributedString(
                string: issue,
                attributes: [
                    .foregroundColor: UIColor.darkGray
                ]
            )
            issueLabel.attributedText = attrString

            statusIconImageView.image = UIImage(systemName: "exclamationmark.circle")
            statusIconImageView.tintColor = UIColor(red: 0.98, green: 0.6, blue: 0.0, alpha: 1.0)
        }
    }
}
