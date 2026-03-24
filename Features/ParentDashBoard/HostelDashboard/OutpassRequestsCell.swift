import UIKit
protocol newRequestScreen: AnyObject {
    func newOutpassVc ()
}
class OutpassRequestsCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var baseHeaderStackView: UIStackView!
    var newRequestdelegate : newRequestScreen?
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.backgroundColor = .white
    }

    func configure(with model: OutpassRequestsModel) {
        // Clear old dynamically added rows
        // Keep index 0 (Title View) and 1 (Separator), clear the rest
        while containerStackView.arrangedSubviews.count > 2 {
            let view = containerStackView.arrangedSubviews.last!
            view.removeFromSuperview()
        }
        
        for request in model.requests {
            let row = createRequestRow(data: request)
            containerStackView.addArrangedSubview(row)
        }
    }
    
    @IBAction func NewOutpassBtnName(_ sender: UIButton) {
        newRequestdelegate?.newOutpassVc()
    }
    private func createRequestRow(data: OutpassRequestData) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let borderBox = UIView()
        borderBox.translatesAutoresizingMaskIntoConstraints = false
        borderBox.layer.borderWidth = 1
        borderBox.layer.borderColor = UIColor.systemGray5.cgColor
        borderBox.layer.cornerRadius = 6
        container.addSubview(borderBox)
        
        NSLayoutConstraint.activate([
            borderBox.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            borderBox.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            borderBox.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            borderBox.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            container.heightAnchor.constraint(equalToConstant: 120) // approx height for 3 lines
        ])
        
        // Row 1: Reason + Status Pill
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .equalSpacing
        topStack.translatesAutoresizingMaskIntoConstraints = false
        borderBox.addSubview(topStack)
        
        let reasonLabel = UILabel()
        reasonLabel.text = data.reason.capitalized
        reasonLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        topStack.addArrangedSubview(reasonLabel)
        
        let pillView = UIView()
        pillView.layer.cornerRadius = 12
        pillView.layer.borderWidth = 1
        
        let statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.text = data.status
        pillView.addSubview(statusLabel)
        
        // Logical assign since JSON misses it
        let st = data.status.lowercased()
        if st.contains("accept") {
            pillView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.5).cgColor
            pillView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            statusLabel.textColor = .systemGreen
        } else if st.contains("declin") {
            pillView.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5).cgColor
            pillView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            statusLabel.textColor = .systemRed
        } else {
            pillView.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.5).cgColor
            pillView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
            statusLabel.textColor = .systemOrange
        }
        
        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: pillView.leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: pillView.trailingAnchor, constant: -10),
            statusLabel.centerYAnchor.constraint(equalTo: pillView.centerYAnchor),
            pillView.heightAnchor.constraint(equalToConstant: 24)
        ])
        topStack.addArrangedSubview(pillView)
        
        // Row 2: Date
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = data.fromToDate
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .darkGray
        borderBox.addSubview(dateLabel)
        
        // Separator
        let sep = UIView()
        sep.backgroundColor = .systemGray6
        sep.translatesAutoresizingMaskIntoConstraints = false
        borderBox.addSubview(sep)
        
        // Row 3: Requested At
        let reqLabel = UILabel()
        reqLabel.translatesAutoresizingMaskIntoConstraints = false
        reqLabel.text = "Requested: \(data.requestTime)"
        reqLabel.font = .systemFont(ofSize: 13)
        reqLabel.textColor = .gray
        borderBox.addSubview(reqLabel)
        
        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: borderBox.topAnchor, constant: 12),
            topStack.leadingAnchor.constraint(equalTo: borderBox.leadingAnchor, constant: 12),
            topStack.trailingAnchor.constraint(equalTo: borderBox.trailingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: borderBox.leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: borderBox.trailingAnchor, constant: -12),
            
            sep.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            sep.leadingAnchor.constraint(equalTo: borderBox.leadingAnchor, constant: 12),
            sep.trailingAnchor.constraint(equalTo: borderBox.trailingAnchor, constant: -12),
            sep.heightAnchor.constraint(equalToConstant: 1),
            
            reqLabel.topAnchor.constraint(equalTo: sep.bottomAnchor, constant: 12),
            reqLabel.leadingAnchor.constraint(equalTo: borderBox.leadingAnchor, constant: 12),
            reqLabel.trailingAnchor.constraint(equalTo: borderBox.trailingAnchor, constant: -12)
        ])
        
        return container
    }
}
