import UIKit

class ExamTableViewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var examLabel: UILabel!
    @IBOutlet weak var seriesLabel: UILabel!
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
        
        cardView.layer.cornerRadius = 10
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor
        
        // Shadow offset for selected state
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.03
        cardView.layer.masksToBounds = false
        
        selectedBadgeView.layer.cornerRadius = 10
        selectedBadgeView.clipsToBounds = true
    }
    
    func configure(with exam: Exam, isSelected: Bool, index: Int) {
        examLabel.text = exam.label
        seriesLabel.text = "Series \(index + 1) · Max 100 marks"
        
        if isSelected {
            cardView.layer.borderColor = UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0).cgColor
            cardView.layer.borderWidth = 1.5
            cardView.layer.shadowOpacity = 0.05
            
            checkboxImageView.image = UIImage(systemName: "checkmark.square.fill")
            checkboxImageView.tintColor = UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0)
            
            selectedBadgeView.isHidden = false
            selectedBadgeView.backgroundColor = UIColor(red: 0.90, green: 0.94, blue: 1.0, alpha: 1.0)
            selectedBadgeLabel.textColor = UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0)
        } else {
            cardView.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor
            cardView.layer.borderWidth = 1.0
            cardView.layer.shadowOpacity = 0.0
            
            checkboxImageView.image = UIImage(systemName: "square")
            checkboxImageView.tintColor = UIColor(red: 0.68, green: 0.72, blue: 0.78, alpha: 1.0)
            
            selectedBadgeView.isHidden = true
        }
    }
}
