import UIKit

class OutpassRequestCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var avatarContainer: UIView!
    @IBOutlet weak var avatarLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!

    @IBOutlet weak var statusContainer: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var outDateLabel: UILabel!
    @IBOutlet weak var returnDateLabel: UILabel!

    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1

        avatarContainer.layer.cornerRadius = 24
        statusContainer.layer.cornerRadius = 12

        approveButton.layer.cornerRadius = 12
        rejectButton.layer.cornerRadius = 12
    }

    func configure(
        name: String, room: String, status: String, dest: String, desc: String?, outDate: String?,
        returnDate: String?
    ) {
        nameLabel.text = name
        roomLabel.text = room
        statusLabel.text = status.capitalized

        if let first = name.first {
            avatarLabel.text = String(first).uppercased()
        }

        // Destination label mapping
        destinationLabel.text = "Reason : \(dest)"
        if let descText = desc, !descText.isEmpty {
            descriptionLabel.text = descText
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }

        if status.lowercased() == "pending" {
            // Orange Theme
            cardView.backgroundColor = UIColor(red: 1.0, green: 0.98, blue: 0.91, alpha: 1.0)
            cardView.layer.borderColor =
                UIColor(red: 0.98, green: 0.9, blue: 0.7, alpha: 1.0).cgColor

            avatarContainer.backgroundColor = UIColor(red: 0.94, green: 0.51, blue: 0.0, alpha: 1.0)
            avatarLabel.textColor = .white

            statusContainer.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.75, alpha: 1.0)
            statusLabel.textColor = UIColor(red: 0.85, green: 0.45, blue: 0.0, alpha: 1.0)

            outDateLabel.text = "Out: \(outDate ?? "")"
            returnDateLabel.text = "Return: \(returnDate ?? "")"
            dateStackView.isHidden = false
            buttonsStackView.isHidden = false

        } else if status.lowercased() == "approved" {
            // Green Theme
            cardView.backgroundColor = UIColor(red: 0.92, green: 0.98, blue: 0.94, alpha: 1.0)
            cardView.layer.borderColor =
                UIColor(red: 0.8, green: 0.95, blue: 0.85, alpha: 1.0).cgColor

            avatarContainer.backgroundColor = UIColor(red: 0.0, green: 0.75, blue: 0.4, alpha: 1.0)
            avatarLabel.textColor = .white

            statusContainer.backgroundColor = UIColor(red: 0.85, green: 0.96, blue: 0.9, alpha: 1.0)
            statusLabel.textColor = UIColor(red: 0.0, green: 0.65, blue: 0.35, alpha: 1.0)

            dateStackView.isHidden = true
            buttonsStackView.isHidden = true

        } else if status.lowercased() == "rejected" {
            // Red Theme
            cardView.backgroundColor = UIColor(red: 1.0, green: 0.94, blue: 0.94, alpha: 1.0)
            cardView.layer.borderColor =
                UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0).cgColor

            avatarContainer.backgroundColor = UIColor(red: 0.98, green: 0.35, blue: 0.4, alpha: 1.0)
            avatarLabel.textColor = .white

            statusContainer.backgroundColor = UIColor(red: 1.0, green: 0.88, blue: 0.88, alpha: 1.0)
            statusLabel.textColor = UIColor(red: 0.9, green: 0.2, blue: 0.25, alpha: 1.0)

            dateStackView.isHidden = true
            buttonsStackView.isHidden = true
        }
    }
}
