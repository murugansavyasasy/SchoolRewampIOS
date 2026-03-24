import UIKit

class TodayAttendanceCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var containerStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.backgroundColor = .white
    }

    func configure(with model: TodayAttendanceModel) {
        // Clear old dynamically added rows
        // Keep index 0 (Title View) and 1 (Separator), clear the rest
        while containerStackView.arrangedSubviews.count > 2 {
            let view = containerStackView.arrangedSubviews.last!
            view.removeFromSuperview()
        }
        
        for session in model.sessions {
            let row = createSessionRow(sessionName: session.sessionName, status: session.status.lowercased())
            containerStackView.addArrangedSubview(row)
        }
    }
    
    private func createSessionRow(sessionName: String, status: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Let's create an inner view with gray border like the UI
        let borderBox = UIView()
        borderBox.translatesAutoresizingMaskIntoConstraints = false
        borderBox.layer.borderWidth = 1
        borderBox.layer.borderColor = UIColor.systemGray5.cgColor
        borderBox.layer.cornerRadius = 6
        container.addSubview(borderBox)
        
        NSLayoutConstraint.activate([
            borderBox.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            borderBox.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            borderBox.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            borderBox.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            container.heightAnchor.constraint(equalToConstant: 62)
        ])
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        
        if status.contains("present") {
            iconImageView.image = UIImage(systemName: "checkmark.circle")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        } else if status.contains("absent") {
            iconImageView.image = UIImage(systemName: "xmark.circle")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        } else {
            iconImageView.image = UIImage(systemName: "exclamationmark.circle")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        }
        borderBox.addSubview(iconImageView)
        
        let sessionLabel = UILabel()
        sessionLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionLabel.text = sessionName
        sessionLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        borderBox.addSubview(sessionLabel)
        
        let pillView = UIView()
        pillView.translatesAutoresizingMaskIntoConstraints = false
        pillView.layer.cornerRadius = 14
        pillView.layer.borderWidth = 1
        
        let statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        
        if status.contains("present") {
            pillView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.5).cgColor
            pillView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            statusLabel.textColor = .systemGreen
            statusLabel.text = "Present"
        } else if status.contains("absent") {
            pillView.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5).cgColor
            pillView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            statusLabel.textColor = .systemRed
            statusLabel.text = "Absent"
        } else {
            pillView.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.5).cgColor
            pillView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
            statusLabel.textColor = .darkGray
            statusLabel.text = "Not Marked"
        }
        
        pillView.addSubview(statusLabel)
        borderBox.addSubview(pillView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: borderBox.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: borderBox.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            sessionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            sessionLabel.centerYAnchor.constraint(equalTo: borderBox.centerYAnchor),
            
            pillView.trailingAnchor.constraint(equalTo: borderBox.trailingAnchor, constant: -16),
            pillView.centerYAnchor.constraint(equalTo: borderBox.centerYAnchor),
            pillView.heightAnchor.constraint(equalToConstant: 28),
            
            statusLabel.leadingAnchor.constraint(equalTo: pillView.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: pillView.trailingAnchor, constant: -12),
            statusLabel.centerYAnchor.constraint(equalTo: pillView.centerYAnchor)
        ])
        
        return container
    }
}
