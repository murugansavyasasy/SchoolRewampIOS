import UIKit

class OverallSummaryCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // Present Card
    @IBOutlet weak var presentBgView: UIView!
    @IBOutlet weak var presentCountLabel: UILabel!
    @IBOutlet weak var presentTitleLabel: UILabel!
    
    // Absent Card
    @IBOutlet weak var absentBgView: UIView!
    @IBOutlet weak var absentCountLabel: UILabel!
    @IBOutlet weak var absentTitleLabel: UILabel!
    
    // Not Marked Card
    @IBOutlet weak var notMarkedBgView: UIView!
    @IBOutlet weak var notMarkedCountLabel: UILabel!
    @IBOutlet weak var notMarkedTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        // Main Card Shadow & Radius
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 12
        
        // Present View
        presentBgView.layer.cornerRadius = 12
        presentBgView.backgroundColor = UIColor(red: 0.94, green: 0.98, blue: 0.94, alpha: 1.0)
        presentCountLabel.textColor = UIColor(red: 0.0, green: 0.65, blue: 0.25, alpha: 1.0)
        
        // Absent View
        absentBgView.layer.cornerRadius = 12
        absentBgView.backgroundColor = UIColor(red: 1.0, green: 0.94, blue: 0.94, alpha: 1.0)
        absentCountLabel.textColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0)
        
        // Not Marked View
        notMarkedBgView.layer.cornerRadius = 12
        notMarkedBgView.backgroundColor = UIColor(red: 1.0, green: 0.96, blue: 0.92, alpha: 1.0)
        notMarkedCountLabel.textColor = UIColor(red: 0.95, green: 0.4, blue: 0.0, alpha: 1.0)
        
        let subTitleColor = UIColor(red: 0.35, green: 0.4, blue: 0.45, alpha: 1.0)
        presentTitleLabel.textColor = subTitleColor
        absentTitleLabel.textColor = subTitleColor
        notMarkedTitleLabel.textColor = subTitleColor
        
        presentTitleLabel.text = "TOTAL PRESENT".translated()
        absentTitleLabel.text = "TOTAL ABSENT".translated()
        notMarkedTitleLabel.text = "NOT MARKED".translated()
        titleLabel.text = "Overall Summary".translated()
    }

    func configure(with stat: OverallStat) {
        presentCountLabel.text = "\(stat.present ?? 0)"
        absentCountLabel.text = "\(stat.absent ?? 0)"
        notMarkedCountLabel.text = "\(stat.not_marked ?? 0)"
    }
}
