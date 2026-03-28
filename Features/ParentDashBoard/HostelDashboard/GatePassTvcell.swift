//
//  GatePassTvcell.swift
//  School Chimes
//
//  Created by apple on 23/03/26.
//

import UIKit

class GatePassTvcell: UITableViewCell {

    @IBOutlet weak var studentRollNumberLbl: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var AutjorizedByLbl: UILabel!
    @IBOutlet weak var validUntilLbl: UILabel!
    @IBOutlet weak var validFromLbl: UILabel!
    @IBOutlet weak var floorLbl: UILabel!
    @IBOutlet weak var roomNumberLbl: UILabel!
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var exitingTimeLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var purposeContainer: UIView!
    @IBOutlet weak var statusContainer: UIView!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var firstLetterLbl: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    
    private let dashedLineLayer = CAShapeLayer()
    let studentDetails = UserDefaultFileManager.get_child_Details()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyling()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyTicketMask()
        updateDashedLine()
    }

    // MARK: - Styling
    private func setupStyling() {
        self.backgroundColor = .clear
        
        // Shadow
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowOffset = CGSize(width: 0, height: 10)
        contentView.layer.shadowRadius = 20
        contentView.layer.masksToBounds = false

        // Card
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white

        // Avatar
        avatarView.layer.cornerRadius = 30
        avatarView.clipsToBounds = true
        
        // Purpose Container
        purposeContainer.layer.borderColor = UIColor(
            red: 250/255, green: 190/255, blue: 40/255, alpha: 1.0
        ).cgColor
        purposeContainer.layer.borderWidth = 1
        purposeContainer.layer.cornerRadius = 8
        
        // Status Container
        statusContainer.layer.borderColor = UIColor(
            red: 100/255, green: 220/255, blue: 140/255, alpha: 1.0
        ).cgColor
        statusContainer.layer.borderWidth = 1
        statusContainer.layer.cornerRadius = 8
        
        // Dashed separator
        dashedLineLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        dashedLineLayer.lineWidth = 1
        dashedLineLayer.lineDashPattern = [4, 4]
        dashedLineLayer.fillColor = nil
        separatorView.layer.addSublayer(dashedLineLayer)
    }

    // MARK: - Ticket Cutout Mask
    private func applyTicketMask() {
        let bounds = cardView.bounds
        guard bounds.width > 0 else { return }

        let path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 16
        )

        let cutoutRadius: CGFloat = 16

        // ✅ Convert separatorView center to cardView coordinate
        let separatorCenterInCard = separatorView.superview?.convert(
            separatorView.center,
            to: cardView
        ) ?? CGPoint(x: 0, y: bounds.midY)

        let cutoutY = separatorCenterInCard.y

        // Left hole
        let leftCircle = UIBezierPath(
            ovalIn: CGRect(
                x: -cutoutRadius,
                y: cutoutY - cutoutRadius,
                width: cutoutRadius * 2,
                height: cutoutRadius * 2
            )
        )

        // Right hole
        let rightCircle = UIBezierPath(
            ovalIn: CGRect(
                x: bounds.width - cutoutRadius,
                y: cutoutY - cutoutRadius,
                width: cutoutRadius * 2,
                height: cutoutRadius * 2
            )
        )

        path.append(leftCircle)
        path.append(rightCircle)

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd

        cardView.layer.mask = maskLayer
    }

    // MARK: - Dashed Line
    private func updateDashedLine() {
        dashedLineLayer.frame = separatorView.bounds

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: separatorView.bounds.midY))
        path.addLine(to: CGPoint(x: separatorView.bounds.width, y: separatorView.bounds.midY))

        dashedLineLayer.path = path.cgPath
    }

    // MARK: - Configure
    func configure(with data: GatePass?) {
        studentNameLbl.text = studentDetails?.name
        
        firstLetterLbl.text = studentDetails?.name?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .first
            .map { String($0).uppercased() } ?? ""

        studentRollNumberLbl.text = data?.admission_no
        reasonLbl.text = data?.reason
        floorLbl.text = data?.floor_no
        roomNumberLbl.text = data?.room_no
        setDateInfo(data?.fromdate_todate ?? "")
        AutjorizedByLbl.text = data?.action_by
        statusLbl.text = data?.status
        updateStatusUI(data?.status ?? "")
    }

    // MARK: - Date Formatting
    func setDateInfo(_ range: String) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let fullFormatter = DateFormatter()
        fullFormatter.dateFormat = "dd MMM yyyy hh:mm a"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"

        let parts = range.components(separatedBy: " - ")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        guard parts.count == 2,
              let fromDate = inputFormatter.date(from: parts[0]),
              let toDate = inputFormatter.date(from: parts[1]) else {
            validFromLbl.text = "-"
            validUntilLbl.text = "-"
            exitingTimeLbl.text = "-"
            return
        }

        validFromLbl.text = fullFormatter.string(from: fromDate)
        validUntilLbl.text = fullFormatter.string(from: toDate)

        let timeString = timeFormatter.string(from: fromDate)
        let attributed = NSMutableAttributedString(string: timeString)

        if let range = timeString.range(of: "AM") ?? timeString.range(of: "PM") {
            let nsRange = NSRange(range, in: timeString)
            attributed.addAttribute(
                .font,
                value: UIFont.systemFont(ofSize: 13, weight: .bold),
                range: nsRange
            )
        }

        exitingTimeLbl.attributedText = attributed
    }

    // MARK: - Status UI
    func updateStatusUI(_ statusString: String?) {
        let status = statusString?.lowercased() ?? ""

        if status.contains("pending") {
            statusContainer.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            statusIcon.image = UIImage(systemName: "clock.fill")
            statusLbl.textColor = .systemOrange
            statusIcon.tintColor = .systemOrange
            statusContainer.layer.borderColor = UIColor.systemOrange.cgColor

        } else if status.contains("approved") {
            statusContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = .systemGreen
            statusLbl.textColor = .systemGreen
            statusContainer.layer.borderColor = UIColor.systemGreen.cgColor
            statusLbl.text = "APPROVED & ACTIVE"

        } else if status.contains("rejected") {
            statusContainer.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            statusIcon.image = UIImage(systemName: "xmark.circle.fill")
            statusLbl.textColor = .systemRed
            statusIcon.tintColor = .systemRed
            statusContainer.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
}
