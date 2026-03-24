import UIKit

class SessionStatusCell: UICollectionViewCell {
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel! // Used if not present/absent
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func configure(status: String) {
        statusImageView.isHidden = false
        statusLabel.isHidden = true
        
        if status.lowercased().contains("present") {
            statusImageView.image = UIImage(systemName: "checkmark.arrow.trianglehead.clockwise")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        } else if status.lowercased().contains("absent") {
            statusImageView.image = UIImage(systemName: "xmark.circle")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        } else {
            statusImageView.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "-"
            statusLabel.textColor = .systemGray
        }
    }
    
    func configureHeader(sessionName: String) {
        statusImageView.isHidden = true
        statusLabel.isHidden = false
        statusLabel.text = sessionName.capitalized
        statusLabel.textColor = .darkGray
        statusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    }
}
