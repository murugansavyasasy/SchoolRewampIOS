import UIKit

public final class SectionSubjectsTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet public weak var cardContainerView: UIView!
    @IBOutlet public weak var headerView: UIView!
    @IBOutlet public weak var avatarView: UIView!
    @IBOutlet public weak var avatarLabel: UILabel!
    @IBOutlet public weak var sectionTitleLabel: UILabel!
    @IBOutlet public weak var selectedCountLabel: UILabel!
    @IBOutlet public weak var selectAllButton: UIButton!
    @IBOutlet public weak var subjectsStackView: UIStackView!
    
    // MARK: - Callbacks
    public var onSelectAllTapped: (() -> Void)?
    public var onSubjectToggled: ((String,String) -> Void)?
    
    private let activeColor = UIColor.primery /*UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0)*/ // #4C4DDC
    
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.layer.borderWidth = 1.0
        cardContainerView.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor
        cardContainerView.layer.masksToBounds = true
        
        avatarView.layer.cornerRadius = 18
        avatarView.layer.masksToBounds = true
        
        // Style Select All text button
        selectAllButton.setTitleColor(activeColor, for: .normal)
        selectAllButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        
        // Accessibility
        self.isAccessibilityElement = false
    }
    
    // MARK: - Configuration
    public func configure(with sectionSubjects: TestSectionSubjects, viewModel: CreateTestViewModel) {
        let sectionName = sectionSubjects.sectionName.uppercased()
        avatarLabel.text = sectionName
        sectionTitleLabel.text = "Section \(sectionName)"
        
        let totalCount = sectionSubjects.subjects.count
        let selectedCount = viewModel.selectedSubjectsCount(in: sectionSubjects.sectionId)
        
        selectedCountLabel.text = "\(selectedCount)/\(totalCount) selected"
        
        // Toggle header action text (Select All vs Deselect All)
        let allSelected = (selectedCount == totalCount)
        let buttonTitle = allSelected ? "Deselect All" : "Select All"
        selectAllButton.setTitle(buttonTitle, for: .normal)
        
        // Clean old stacked views
        subjectsStackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        
        // Add new subject rows dynamically
        for subject in sectionSubjects.subjects {
            let isSelected = viewModel.isSubjectSelected(sectionId: sectionSubjects.sectionId, subjectId: subject.id)
            
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.alignment = .center
            rowStack.distribution = .fill
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            
            // Checkbox Icon (Empty circle or Checked blue circle)
            let checkboxImageView = UIImageView()
            checkboxImageView.translatesAutoresizingMaskIntoConstraints = false
            let checkboxImageName = isSelected ? "checkmark.circle.fill" : "circle"
            checkboxImageView.image = UIImage(systemName: checkboxImageName)
            checkboxImageView.tintColor = isSelected ? activeColor : UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0)
            checkboxImageView.contentMode = .scaleAspectFit
            NSLayoutConstraint.activate([
                checkboxImageView.widthAnchor.constraint(equalToConstant: 20),
                checkboxImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
            
            // Book Icon circular container view
            let bookIconCircle = UIView()
            bookIconCircle.translatesAutoresizingMaskIntoConstraints = false
            bookIconCircle.layer.cornerRadius = 16
            bookIconCircle.layer.masksToBounds = true
            bookIconCircle.backgroundColor = UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 0.08) // 8% alpha tint
            
            let bookImageView = UIImageView()
            bookImageView.translatesAutoresizingMaskIntoConstraints = false
            bookImageView.image = UIImage(systemName: "book")
            bookImageView.tintColor = activeColor
            bookImageView.contentMode = .scaleAspectFit
            
            bookIconCircle.addSubview(bookImageView)
            NSLayoutConstraint.activate([
                bookIconCircle.widthAnchor.constraint(equalToConstant: 32),
                bookIconCircle.heightAnchor.constraint(equalToConstant: 32),
                bookImageView.centerXAnchor.constraint(equalTo: bookIconCircle.centerXAnchor),
                bookImageView.centerYAnchor.constraint(equalTo: bookIconCircle.centerYAnchor),
                bookImageView.widthAnchor.constraint(equalToConstant: 16),
                bookImageView.heightAnchor.constraint(equalToConstant: 16)
            ])
            
            // Subject title label
            let nameLabel = UILabel()
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.text = subject.name
            nameLabel.font = .systemFont(ofSize: 14, weight: .bold)
            nameLabel.textColor = UIColor(red: 0.102, green: 0.110, blue: 0.161, alpha: 1.0) // #1A1C29
            nameLabel.adjustsFontForContentSizeCategory = true
            
            rowStack.addArrangedSubview(checkboxImageView)
            rowStack.addArrangedSubview(bookIconCircle)
            rowStack.addArrangedSubview(nameLabel)
            
            // Add flexible spacer so Selected badge aligns on the absolute right side
            let spacer = UIView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            rowStack.addArrangedSubview(spacer)
            
            // Selected Pill Badge
            let selectedPill = UIView()
            selectedPill.translatesAutoresizingMaskIntoConstraints = false
            selectedPill.layer.cornerRadius = 10
            selectedPill.layer.masksToBounds = true
            selectedPill.backgroundColor = UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 0.1) // 10% tint
            selectedPill.isHidden = !isSelected
            
            let selectedLabel = UILabel()
            selectedLabel.translatesAutoresizingMaskIntoConstraints = false
            selectedLabel.text = "Selected"
            selectedLabel.textColor = activeColor
            selectedLabel.font = .systemFont(ofSize: 10, weight: .bold)
            
            selectedPill.addSubview(selectedLabel)
            NSLayoutConstraint.activate([
                selectedLabel.leadingAnchor.constraint(equalTo: selectedPill.leadingAnchor, constant: 10),
                selectedLabel.trailingAnchor.constraint(equalTo: selectedPill.trailingAnchor, constant: -10),
                selectedLabel.topAnchor.constraint(equalTo: selectedPill.topAnchor, constant: 4),
                selectedLabel.bottomAnchor.constraint(equalTo: selectedPill.bottomAnchor, constant: -4)
            ])
            
            rowStack.addArrangedSubview(selectedPill)
            
            // Wrap in an outer container to capture taps and add horizontal margins
            let rowContainer = UIView()
            rowContainer.translatesAutoresizingMaskIntoConstraints = false
            rowContainer.addSubview(rowStack)
            
            NSLayoutConstraint.activate([
                rowStack.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor),
                rowStack.trailingAnchor.constraint(equalTo: rowContainer.trailingAnchor),
                rowStack.topAnchor.constraint(equalTo: rowContainer.topAnchor, constant: 6),
                rowStack.bottomAnchor.constraint(equalTo: rowContainer.bottomAnchor, constant: -6)
            ])
            
            // Add Separator Line below row (except for the last item)
            if let lastSub = sectionSubjects.subjects.last, lastSub.id != subject.id {
                let sepLine = UIView()
                sepLine.translatesAutoresizingMaskIntoConstraints = false
                sepLine.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
                rowContainer.addSubview(sepLine)
                NSLayoutConstraint.activate([
                    sepLine.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor),
                    sepLine.trailingAnchor.constraint(equalTo: rowContainer.trailingAnchor),
                    sepLine.bottomAnchor.constraint(equalTo: rowContainer.bottomAnchor),
                    sepLine.heightAnchor.constraint(equalToConstant: 1.0)
                ])
            }
            
            // Add tap guesture
            let rowTap = SubjectTapGesture(target: self, action: #selector(subjectRowTapped(_:)))
            rowTap.sectionId = sectionSubjects.sectionId
            rowTap.subjectId = subject.id
            rowContainer.addGestureRecognizer(rowTap)
            rowContainer.isUserInteractionEnabled = true
            
            subjectsStackView.addArrangedSubview(rowContainer)
        }
    }
    
    @objc private func subjectRowTapped(_ gesture: SubjectTapGesture) {
        if let secId = gesture.sectionId, let subId = gesture.subjectId {
                   onSubjectToggled?(secId, subId)
               }
    }
    
    // MARK: - IBActions
    @IBAction @objc public func selectAllTapped(_ sender: UIButton) {
        onSelectAllTapped?()
    }
}

// MARK: - Helper Tap Gesture
fileprivate final class SubjectTapGesture: UITapGestureRecognizer {
    var sectionId: String?
    var subjectId: String?
}
