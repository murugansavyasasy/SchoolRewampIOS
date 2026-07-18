import UIKit

class PendingFeeCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var feeNameLabel: UILabel!
    @IBOutlet weak var feeGroupLabel: UILabel!
    
    @IBOutlet weak var statusContainer: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var hostelNameLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var bedLabel: UILabel!
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var paidAmountLabel: UILabel!
    @IBOutlet weak var pendingAmountLabel: UILabel!
    
    @IBOutlet weak var payButtonView: UIView!
    @IBOutlet weak var payButtonLabel: UILabel!
    
    var onPayButtonTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        // Ensure no selection color
        self.selectionStyle = .none
        
        // Card styling
        cardView.layer.borderColor = UIColor.systemGray5.cgColor
        cardView.layer.borderWidth = 1
        cardView.layer.cornerRadius = 8
        cardView.clipsToBounds = true
        
        // Status Badge styling
        statusContainer.layer.cornerRadius = 13 // Making it perfectly pill-round 
        statusContainer.layer.borderWidth = 1
        statusContainer.clipsToBounds = true
        statusContainer.translatesAutoresizingMaskIntoConstraints = false
        statusContainer.heightAnchor.constraint(equalToConstant: 26).isActive = true
        statusContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        
        // Label wrapping & resizing configuration
        feeNameLabel.numberOfLines = 0
        feeNameLabel.lineBreakMode = .byWordWrapping
        
        hostelNameLabel.adjustsFontSizeToFitWidth = true
        hostelNameLabel.minimumScaleFactor = 0.5
        
        roomLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        bedLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        
        // Pay Button styling
        payButtonView.layer.cornerRadius = 8
        payButtonView.backgroundColor = UIColor(red: 41/255, green: 98/255, blue: 255/255, alpha: 1.0)
        payButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PayButtonTapped)))
        payButtonView.isUserInteractionEnabled = true
    }

    // MARK: - Configuration
    
    /// Call this from `cellForRowAt` to map the API json data straight to this UI design
    func configure(with data: HostelFeeDetails) {
        
        // --- 1. Top Section ---
//        feeNameLabel.text =  "Hostel fee"
        // --- 2. Hostel Details Bar ---
        
        if let hDetails = data.hostel_details {
            let hName = hDetails.hostel_name ?? "-"
            setupAttributedText(
                for: hostelNameLabel,
                title: NSLocalizedString("Hostel", comment: "") + ": ",
                value: hName
            )

            let rNum = hDetails.room_no ?? "-"
            setupAttributedText(
                for: roomLabel,
                title: NSLocalizedString("Room", comment: "") + ": ",
                value: rNum
            )

            let bNum = hDetails.bed_no ?? "-"
            setupAttributedText(
                for: bedLabel,
                title: NSLocalizedString("Bed", comment: "") + ": ",
                value: bNum
            )
        }
        
        // --- 3. Summary Block ---
        if let summary = data.summary {
            let total = summary.total_amount ?? 0
            let paid = summary.paid_amount ?? 0
            let pending =  summary.pending_amount ?? 0
            let sts = summary.status ?? "PENDING"
            
            totalAmountLabel.text = formatCurrency(Double(total))
            paidAmountLabel.text = formatCurrency(Double(paid))
            pendingAmountLabel.text = formatCurrency(Double(pending))
            payButtonLabel.text = "Pay Now \(formatCurrency(Double(pending)))"
            
            // --- 4. Payment PENDING Badge Styling ---
            statusLabel.text = sts.uppercased()
            
            payButtonView.isHidden = sts.uppercased() == "PAID"
            
            if sts.uppercased() == "PENDING" {
                statusContainer.backgroundColor = UIColor(red: 255/255, green: 243/255, blue: 224/255, alpha: 1.0) // Light orange
                statusContainer.layer.borderColor = UIColor(red: 255/255, green: 204/255, blue: 128/255, alpha: 1.0).cgColor
                statusLabel.textColor = UIColor(red: 230/255, green: 81/255, blue: 0/255, alpha: 1.0) // Deep orange
            } else if sts.uppercased() == "PAID" {
                statusContainer.backgroundColor = UIColor(red: 232/255, green: 245/255, blue: 233/255, alpha: 1.0) // Light green
                statusContainer.layer.borderColor = UIColor(red: 165/255, green: 214/255, blue: 167/255, alpha: 1.0).cgColor
                statusLabel.textColor = UIColor(red: 46/255, green: 125/255, blue: 50/255, alpha: 1.0) // Deep Green
            } else {
                statusContainer.backgroundColor = UIColor(red: 236/255, green: 239/255, blue: 241/255, alpha: 1.0) // Light gray
                statusContainer.layer.borderColor = UIColor.lightGray.cgColor
                statusLabel.textColor = .darkGray
            }
        }
    }
    
    // MARK: - Helpers
    
    // Combines gray title with bold value
    private func setupAttributedText(for label: UILabel, title: String, value: String) {
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        let valAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 30/255, green: 40/255, blue: 50/255, alpha: 1.0),
            .font: UIFont.boldSystemFont(ofSize: 14)
        ]
        
        let attrStr = NSMutableAttributedString(string: title, attributes: titleAttrs)
        attrStr.append(NSAttributedString(string: value, attributes: valAttrs))
        label.attributedText = attrStr
    }
    
    // Formats integer amount into Indian Rupees format e.g 8500 -> ₹8,500
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        if let formattedValue = formatter.string(from: NSNumber(value: amount)) {
            return formattedValue
        }
        return "₹\(amount)"
    }
    
    @IBAction func PayButtonTapped(_ sender: Any) {
        onPayButtonTapped?()
    }
}
