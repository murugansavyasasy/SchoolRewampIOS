import UIKit

class SetTableViewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var radioButtonImageView: UIImageView!
    @IBOutlet weak var setNameLabel: UILabel!
    @IBOutlet weak var chipsStackView: UIStackView!
    @IBOutlet weak var selectedBadgeView: UIView!
    @IBOutlet weak var selectedBadgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor
        
        // Premium shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.02
        cardView.layer.masksToBounds = false
    }
    
    func configure(with set: analysisData, isSelected: Bool) {
        setNameLabel.text = set.setName
        
        if isSelected {
            radioButtonImageView.image = UIImage(systemName: "checkmark.square.fill")
            radioButtonImageView.tintColor = UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0)
            cardView.layer.borderColor = UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0).cgColor
            cardView.layer.borderWidth = 1.5
            cardView.layer.shadowOpacity = 0.05
            selectedBadgeView.isHidden = false
        } else {
            radioButtonImageView.image = UIImage(systemName: "square")
            radioButtonImageView.tintColor = UIColor(red: 0.68, green: 0.72, blue: 0.78, alpha: 1.0)
            cardView.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor
            cardView.layer.borderWidth = 1.0
            cardView.layer.shadowOpacity = 0.02
            selectedBadgeView.isHidden = true
        }
        
        if let classdata = set.class_tests{
            buildChips(for: classdata)
        }
       
    }
    
    private func buildChips(for tests: [analysisClass_tests]) {
        // Clear old chips
        chipsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let maxRowWidth: CGFloat = 343.0 - 56.0 // Card content area width limit
        var currentRowSubviews: [UIView] = []
        var currentRowWidth: CGFloat = 0.0
        
        let labelFont = UIFont.systemFont(ofSize: 11, weight: .bold)
        let labelAttributes: [NSAttributedString.Key: Any] = [.font: labelFont]
        
        for (index, test) in tests.enumerated() {
            let title = "\(index + 1). \(test.examName ?? "")"
            let textWidth = title.size(withAttributes: labelAttributes).width
            let chipWidth = textWidth + 24.0 // Add padding
            
            // Create Chip View container
            let chipView = UIView()
            chipView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0)
            chipView.layer.cornerRadius = 6
            chipView.layer.borderWidth = 1
            chipView.layer.borderColor = UIColor(red: 0.78, green: 0.80, blue: 0.83, alpha: 1.0).cgColor
            chipView.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = title
            label.font = labelFont
            label.textColor = UIColor(red: 0.05, green: 0.14, blue: 0.23, alpha: 1.0)
            label.translatesAutoresizingMaskIntoConstraints = false
            chipView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: chipView.leadingAnchor, constant: 12),
                label.trailingAnchor.constraint(equalTo: chipView.trailingAnchor, constant: -12),
                label.topAnchor.constraint(equalTo: chipView.topAnchor, constant: 6),
                label.bottomAnchor.constraint(equalTo: chipView.bottomAnchor, constant: -6),
                chipView.heightAnchor.constraint(equalToConstant: 26)
            ])
            
            let spacing: CGFloat = 8.0
            if currentRowWidth + chipWidth + (currentRowSubviews.isEmpty ? 0 : spacing) > maxRowWidth {
                // Add current row stack to main vertical stack
                let rowStack = createRowStackView(with: currentRowSubviews)
                chipsStackView.addArrangedSubview(rowStack)
                
                currentRowSubviews = [chipView]
                currentRowWidth = chipWidth
            } else {
                currentRowSubviews.append(chipView)
                currentRowWidth += chipWidth + (currentRowSubviews.count > 1 ? spacing : 0)
            }
        }
        
        // Add last row stack
        if !currentRowSubviews.isEmpty {
            let rowStack = createRowStackView(with: currentRowSubviews)
            chipsStackView.addArrangedSubview(rowStack)
        }
    }
    
    private func createRowStackView(with subviews: [UIView]) -> UIStackView {
        let rowStack = UIStackView(arrangedSubviews: subviews)
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.alignment = .center
        rowStack.distribution = .fill
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rowStack.addArrangedSubview(spacer)
        
        return rowStack
    }
}
