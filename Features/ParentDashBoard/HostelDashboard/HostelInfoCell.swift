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

    func configure(with model: HostelInformationModel) {
        // Clear old rows
        while containerStackView.arrangedSubviews.count > 2 {
            let view = containerStackView.arrangedSubviews.last!
            view.removeFromSuperview()
        }
        
        for (index, info) in model.infoBlocks.enumerated() {
            let row = createInfoRow(title: info.title, value: info.value)
            containerStackView.addArrangedSubview(row)
            
            // Add separator if not last
            if index < model.infoBlocks.count - 1 {
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
        container.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .darkText
        container.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 15, weight: .regular)
        valueLabel.textColor = .black
        valueLabel.textAlignment = .right
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            // Allow title to squeeze if value is long
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -16)
        ])
        
        return container
    }
}
