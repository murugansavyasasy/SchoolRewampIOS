import UIKit

public final class ReviewTestDetailTableViewCell: UITableViewCell {
    
   
    // MARK: - IBOutlets
    @IBOutlet public weak var badgeContainer: UIView!
    @IBOutlet public weak var badgeLabel: UILabel!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var sessionPill: UIView!
    @IBOutlet public weak var sessionLabel: UILabel!
    @IBOutlet public weak var removeButton: UIButton!
    
    @IBOutlet public weak var dateBox: UIView!
    @IBOutlet public weak var dateValueLabel: UILabel!
    
    @IBOutlet public weak var maxBox: UIView!
    @IBOutlet public weak var maxMarksValueLabel: UILabel!
    
    @IBOutlet public weak var minBox: UIView!
    @IBOutlet public weak var minMarksValueLabel: UILabel!
    
    @IBOutlet public weak var syllabusBox: UIView!
    @IBOutlet public weak var syllabusValueLabel: UILabel!
    
    // MARK: - Callbacks
    public var onRemoveTapped: (() -> Void)?
    
    private let activeColor = UIColor.primery
    //UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0)
    private let boxBgColor = UIColor(red: 0.961, green: 0.969, blue: 0.984, alpha: 1.0)
    
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        badgeContainer.layer.cornerRadius = 10
        badgeContainer.layer.masksToBounds = true
        badgeContainer.backgroundColor = activeColor
        badgeLabel.textColor = .white
        
        sessionPill.layer.cornerRadius = 8
        sessionPill.layer.masksToBounds = true
        sessionPill.backgroundColor = UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 0.08)
        sessionLabel.textColor = activeColor
        
        removeButton.setTitle(NSLocalizedString("Remove", comment: ""), for: .normal)
        styleBox(dateBox)
        styleBox(maxBox)
        styleBox(minBox)
        styleBox(syllabusBox)
    }
    
    private func styleBox(_ box: UIView) {
        box.layer.cornerRadius = 8
        box.layer.masksToBounds = true
        box.backgroundColor = boxBgColor
    }
    
    // MARK: - Configuration
    public func configure(with test: TestDetails, index: Int) {
        badgeLabel.text = "\(index + 1)"
        titleLabel.text = test.activity_name.isEmpty ? "" : test.activity_name
        
        sessionLabel.text = test.session
        dateValueLabel.text = test.testDate.isEmpty ? "" : test.testDate
        maxMarksValueLabel.text = test.maxMarks
        minMarksValueLabel.text = test.minMarks
        syllabusValueLabel.text = test.syllabus.isEmpty ? "" : test.syllabus
    }
    
    @IBAction @objc public func removeButtonTapped(_ sender: UIButton) {
        onRemoveTapped?()
    }
}
