import UIKit

protocol StudentAttendanceCellDelegate: AnyObject {
    func didTapPresent(for index: Int)
    func didTapAbsent(for index: Int)
}

class StudentAttendanceCell: UITableViewCell {
    @IBOutlet weak var OutPassTimmingLbl: UILabel!
    @IBOutlet weak var OutPassReasonLbl: UILabel!
    @IBOutlet weak var outPassFullStackView: UIStackView!
    @IBOutlet weak var outPassRequestFullView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var avatarContainer: UIView!
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var presentButton: UIButton!
    @IBOutlet weak var absentButton: UIButton!
    @IBOutlet weak var OutPassRejectBtnName: UIButton!
    @IBOutlet weak var outpassApproveBtnName: UIButton!
    weak var delegate: StudentAttendanceCellDelegate?
    var studentIndex: Int = 0

    @IBAction func OutpassApproveBtnAct(_ sender: UIButton) {
    }
    
    @IBAction func outPassRejectBtnAct(_ sender: UIButton) {
    }
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor

        avatarContainer.layer.cornerRadius = 20

        presentButton.layer.cornerRadius = 10
        absentButton.layer.cornerRadius = 10
        outPassRequestFullView.layer.cornerRadius = 10
    }

    func configure(name: String, id: String, parentNum: String, state: Int, index: Int) {
        self.studentIndex = index
        nameLabel.text = name
        detailsLabel.text = "Student ID: \(id) • \(parentNum)"

        if let first = name.first {
            avatarLabel.text = String(first).uppercased()
        }

        // Randomly set colors for avatar
        let colors: [UIColor] = [.systemPurple, .systemBlue, .systemIndigo, .systemOrange]
        avatarContainer.backgroundColor = colors[index % colors.count]

        updateButtonStates(state: state)
    }

    // state: 0 = unset, 1 = present, 2 = absent
    private func updateButtonStates(state: Int) {
        if state == 1 {
            // Present Selected
            presentButton.backgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.35, alpha: 1.0)
            presentButton.setTitleColor(.white, for: .normal)
            presentButton.tintColor = .white
            presentButton.layer.borderWidth = 0

            absentButton.backgroundColor = .white
            absentButton.setTitleColor(.darkGray, for: .normal)
            absentButton.tintColor = .darkGray
            absentButton.layer.borderWidth = 1
            absentButton.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        } else if state == 2 {
            // Absent Selected
            absentButton.backgroundColor = UIColor(red: 0.95, green: 0.3, blue: 0.3, alpha: 1.0)
            absentButton.setTitleColor(.white, for: .normal)
            absentButton.tintColor = .white
            absentButton.layer.borderWidth = 0

            presentButton.backgroundColor = .white
            presentButton.setTitleColor(.darkGray, for: .normal)
            presentButton.tintColor = .darkGray
            presentButton.layer.borderWidth = 1
            presentButton.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        } else {
            // Unset
            presentButton.backgroundColor = .white
            presentButton.setTitleColor(.darkGray, for: .normal)
            presentButton.tintColor = .darkGray
            presentButton.layer.borderWidth = 1
            presentButton.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor

            absentButton.backgroundColor = .white
            absentButton.setTitleColor(.darkGray, for: .normal)
            absentButton.tintColor = .darkGray
            absentButton.layer.borderWidth = 1
            absentButton.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        }
    }

    @IBAction func presentTapped(_ sender: Any) {
        delegate?.didTapPresent(for: studentIndex)
    }

    @IBAction func absentTapped(_ sender: Any) {
        delegate?.didTapAbsent(for: studentIndex)
    }
}
