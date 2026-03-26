import UIKit

class HostelInfoCell: UITableViewCell {

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

    func configure(with data: HostelInfo) {
        // Clear old rows
        while containerStackView.arrangedSubviews.count > 2 {
            let view = containerStackView.arrangedSubviews.last!
            view.removeFromSuperview()
        }
        
        var blocks = [HostelInfoData]()
        if let institute = data.institute_name {
            blocks.append(HostelInfoData(title: "Institute", value: institute))
        }
        if let hostelName = data.hostel_name {
            blocks.append(HostelInfoData(title: "Hostel Name", value: hostelName))
        }
//        if let hType = data.hostel_type {
//            blocks.append(HostelInfoData(title: "Type", value: hType.capitalized))
//        }
//        if let capacity = data.max_capacity {
//            blocks.append(HostelInfoData(title: "Capacity", value: "\(capacity) Students"))
//        }
//        if let floors = data.no_of_floors, let rooms = data.no_of_rooms {
//            blocks.append(HostelInfoData(title: "Layout", value: "\(floors) Floors, \(rooms) Rooms"))
//        }
        if let wardens = data.warden_name {
            var uniqueWardens = [String]()
            for w in wardens where !uniqueWardens.contains(w) { uniqueWardens.append(w) }
            blocks.append(HostelInfoData(title: "Wardens", value: uniqueWardens.joined(separator: ", ")))
        }
        if let wType = data.warden_type {
            blocks.append(HostelInfoData(title: "Warden Type", value: wType))
        }
        if let address = data.institute_address {
            blocks.append(HostelInfoData(title: "Address", value: address.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        
        for (index, info) in blocks.enumerated() {
            let row = createInfoRow(title: info.title, value: info.value)
            containerStackView.addArrangedSubview(row)
            
            // Add separator if not last
            if index < blocks.count - 1 {
                let sepContainer = UIView()
                sepContainer.translatesAutoresizingMaskIntoConstraints = false
                sepContainer.heightAnchor.constraint(equalToConstant: 1).isActive = true
                
                let sep = UIView()
                sep.backgroundColor = UIColor.systemGray6
                sep.translatesAutoresizingMaskIntoConstraints = false
                sepContainer.addSubview(sep)
                
                NSLayoutConstraint.activate([
                    sep.topAnchor.constraint(equalTo: sepContainer.topAnchor),
                    sep.bottomAnchor.constraint(equalTo: sepContainer.bottomAnchor),
                    sep.leadingAnchor.constraint(equalTo: sepContainer.leadingAnchor, constant: 16),
                    sep.trailingAnchor.constraint(equalTo: sepContainer.trailingAnchor, constant: -16)
                ])
                containerStackView.addArrangedSubview(sepContainer)
            }
        }
    }
    
    private func createInfoRow(title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        // Allow the container to expand vertically if needed
        container.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .darkText
        
        // Ensure title label doesn't compress and stays intact
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        container.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 15, weight: .regular)
        valueLabel.textColor = .black
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0 // Allow multiple lines for long texts like address
        valueLabel.lineBreakMode = .byWordWrapping
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            // Title constraints
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12),
            
            // Value constraints
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16)
        ])
        
        return container
    }
}
