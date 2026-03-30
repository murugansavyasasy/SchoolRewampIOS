import UIKit

protocol StudentAttendanceCellDelegate: AnyObject {
    func didTapPresent(for index: Int)
    func didTapAbsent(for index: Int)
    func outPassApproval(for index : Int)
    func outPassReject(for index : Int)
}

class StudentAttendanceCell: UITableViewCell {
    @IBOutlet weak var approveAndRejectFullStack: UIStackView!
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
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    weak var delegate: StudentAttendanceCellDelegate?
    var studentIndex: Int = 0

    @IBAction func OutpassApproveBtnAct(_ sender: UIButton) {
        
        delegate?.outPassApproval(for: sender.tag)
    }
    
    @IBAction func outPassRejectBtnAct(_ sender: UIButton) {
        
        delegate?.outPassReject(for: sender.tag)
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
        outpassApproveBtnName.layer.cornerRadius = 10
        OutPassRejectBtnName.layer.cornerRadius = 10
        
        statusView.layer.cornerRadius = 12
        statusView.layer.borderWidth = 1
    }

    func configure(name: String, id: String, parentNum: String, state: String, index: Int,reason:String,out_pass_status:String,outDateInDate:String,outpass_id : String) {
        
        if outpass_id == ""{
            outPassRequestFullView.isHidden = true
           
        }else{
            outPassRequestFullView.isHidden  = false
            OutPassReasonLbl.text = reason
            OutPassTimmingLbl.text = outDateInDate
            if out_pass_status == "APPROVED"{
                approveAndRejectFullStack.isHidden = true
            }else if out_pass_status == "REJECTED"{
                approveAndRejectFullStack.isHidden = true
            }else if out_pass_status == "PENDING" || out_pass_status == "" {
                approveAndRejectFullStack.isHidden = false
            }
        }
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
    private func updateButtonStates(state: String) {
        if state == "2" {
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
        } else if state == "1" {
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

    @IBAction func presentTapped(_ sender: UIButton) {
        delegate?.didTapPresent(for: sender.tag)
    }

    @IBAction func absentTapped(_ sender: UIButton) {
        delegate?.didTapAbsent(for: sender.tag)
    }
}
