import UIKit

class ExamTagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor
    }
    
    func configure(with exam: Exam, isSelected: Bool, index: Int) {
        tagLabel.text = exam.label
        
        if isSelected {
            // Mapped comparison colors matching screenshot colors (DRT-2: Dark Navy/Orange, DRT-3: Green, DRT-4: Red)
            let colors: [UIColor] = [
                UIColor(red: 0.05, green: 0.14, blue: 0.23, alpha: 1.0), // Dark Navy (Default)
                UIColor(red: 0.92, green: 0.59, blue: 0.0, alpha: 1.0),  // Orange
                UIColor(red: 0.08, green: 0.70, blue: 0.44, alpha: 1.0),  // Green
                UIColor(red: 0.90, green: 0.26, blue: 0.22, alpha: 1.0)   // Red
            ]
            let selectedColor = colors[index % colors.count]
            
            containerView.backgroundColor = selectedColor
            containerView.layer.borderColor = selectedColor.cgColor
            tagLabel.textColor = .white
        } else {
            containerView.backgroundColor = .white
            containerView.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor
            tagLabel.textColor = UIColor(red: 0.05, green: 0.14, blue: 0.23, alpha: 1.0)
        }
    }
}
