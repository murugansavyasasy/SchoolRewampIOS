import UIKit

public final class ReviewSubjectTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet public weak var cardContainerView: UIView!
    @IBOutlet public weak var headerView: UIView!
    @IBOutlet public weak var avatarView: UIView!
    @IBOutlet public weak var avatarLabel: UILabel!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var subtitleLabel: UILabel!
    @IBOutlet public weak var testCountLabel: UILabel!
    @IBOutlet public weak var testsTableView: UITableView!
    @IBOutlet public weak var testsTableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Callbacks
    public var onRemoveTestTapped: ((Int) -> Void)?
    
    private var config: SubjectExamConfig?
    private let activeColor = UIColor.primery
    
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.layer.borderWidth = 1.0
        cardContainerView.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor // #E2E8F0
        cardContainerView.layer.masksToBounds = true
        
        avatarView.layer.cornerRadius = 18
        avatarView.layer.masksToBounds = true
        avatarView.backgroundColor = UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 0.1)
        avatarLabel.textColor = activeColor
    }
    
    private func setupTableView() {
        testsTableView.delegate = self
        testsTableView.dataSource = self
        testsTableView.backgroundColor = .clear
        testsTableView.isScrollEnabled = false
        testsTableView.estimatedRowHeight = 185
        testsTableView.rowHeight = 185.0 // Set explicit row height for perfect height sizing
        
        testsTableView.register(
            UINib(nibName: "ReviewTestDetailTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ReviewTestDetailTableViewCell"
        )
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        testsTableView.layoutIfNeeded()
        testsTableViewHeightConstraint.constant = testsTableView.contentSize.height
    }
    
    // MARK: - Configuration
    public func configure(with config: SubjectExamConfig) {
        self.config = config
        
        titleLabel.text = config.subjectName
        subtitleLabel.text = "Section \(config.sectionName.uppercased())"
        
        let initial = String(config.subjectName.prefix(1)).uppercased()
        avatarLabel.text = initial
        
        let count = config.tests.count
        testCountLabel.text = count == 1 ? "1 Activity" : "\(count) Activities"
        
        // Compute height constraint synchronously so parent table view sizes correctly during reloadData
        testsTableViewHeightConstraint.constant = CGFloat(count) * 185.0
        
        testsTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ReviewSubjectTableViewCell: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return config?.tests.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReviewTestDetailTableViewCell",
            for: indexPath
        ) as? ReviewTestDetailTableViewCell,
              let test = config?.tests[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: test, index: indexPath.row)
        cell.onRemoveTapped = { [weak self] in
            self?.onRemoveTestTapped?(indexPath.row)
        }
        
        return cell
    }
}
