//
//  ExamCardTableViewCell.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import UIKit

class ExamCardTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var examIconImageView: UIImageView!
    @IBOutlet weak var examTitleLabel: UILabel!
    @IBOutlet weak var examSubtitleLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    @IBOutlet weak var viewMarksButton: UIButton!
    @IBOutlet weak var dividerLine: UIView!
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var infoHeaderStack: UIStackView!
    
    private var exam: ClassTest?
    private var stateTracker: ClassTestsStateTracker?
    private var subjectNames: [String] = []
    
    var onToggle: (() -> Void)?
    var onSubjectToggle: (() -> Void)?
    var onViewMarks: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
        setupCollectionView()
        setupHeaderTapGesture()
    }
    
    private func setupHeaderTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        infoHeaderStack.addGestureRecognizer(tap)
        infoHeaderStack.isUserInteractionEnabled = true
    }
    
    @objc private func didTapHeader() {
        onToggle?()
    }
    
    private func setupStyles() {
        selectionStyle = .none
        
        cardContainerView.layer.cornerRadius = 24
        cardContainerView.layer.borderColor = UIColor(red: 234/255, green: 240/255, blue: 246/255, alpha: 1.0).cgColor
        cardContainerView.layer.borderWidth = 1.0
        
        // Shadow configuration
        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowOpacity = 0.06
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainerView.layer.shadowRadius = 12
        cardContainerView.layer.masksToBounds = false
        
        // Exam icon circle background
        examIconImageView.layer.cornerRadius = 20
        examIconImageView.backgroundColor = UIColor(red: 232/255, green: 235/255, blue: 253/255, alpha: 1.0)
        examIconImageView.tintColor = UIColor(red: 74/255, green: 85/255, blue: 246/255, alpha: 1.0)
        
        // Action Button styles
        viewMarksButton.layer.cornerRadius = 16
        viewMarksButton.layer.borderWidth = 1.0
        viewMarksButton.layer.borderColor = UIColor(red: 220/255, green: 225/255, blue: 253/255, alpha: 1.0).cgColor
        viewMarksButton.backgroundColor = UIColor(red: 240/255, green: 242/255, blue: 254/255, alpha: 1.0)
        viewMarksButton.tintColor = UIColor(red: 74/255, green: 85/255, blue: 246/255, alpha: 1.0)
        viewMarksButton.addTarget(self, action: #selector(didTapViewMarks), for: .touchUpInside)
        viewMarksButton.setTitle(NSLocalizedString("View Marks", comment: ""), for: .normal)
        // Chevron button styles
        chevronButton.layer.cornerRadius = 16
    }
    
    @objc private func didTapViewMarks() {
        onViewMarks?()
    }
    private func setupCollectionView() {
        subjectsCollectionView.dataSource = self
        subjectsCollectionView.delegate = self
        
        let nib = UINib(nibName: "SubjectBadgeCollectionViewCell", bundle: nil)
        subjectsCollectionView.register(nib, forCellWithReuseIdentifier: "SubjectBadgeCollectionViewCell")
        
        // Horizontal scroll flow settings
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        subjectsCollectionView.collectionViewLayout = layout
        subjectsCollectionView.showsHorizontalScrollIndicator = false
    }
    
    @IBAction func didTapChevron(_ sender: UIButton) {
        onToggle?()
    }
    
    func configure(with exam: ClassTest, isExpanded: Bool, stateTracker: ClassTestsStateTracker, onToggle: @escaping () -> Void, onSubjectToggle: @escaping () -> Void) {
        self.exam = exam
        self.stateTracker = stateTracker
        self.onToggle = onToggle
        self.onSubjectToggle = onSubjectToggle
        
        // 1. Text configurations
        examTitleLabel.text = exam.examName
        
        let subjectCount = exam.subjects.count
        let totalTests = exam.subjects.reduce(0) { $0 + $1.activities.count }
        let subjectKey = subjectCount == 1 ? "%d Subject" : "%d Subjects"
        let testKey = totalTests == 1 ? "%d Test" : "%d Tests"

        let subjectStr = String(
            format: NSLocalizedString(subjectKey, comment: ""),
            subjectCount
        )

        let testStr = String(
            format: NSLocalizedString(testKey, comment: ""),
            totalTests
        )

        examSubtitleLabel.text = "\(subjectStr)  ·  \(testStr)"
        
        // 2. Refresh Subject Badges collection view
        self.subjectNames = exam.subjects.map { $0.subjectName ?? "" }
        subjectsCollectionView.reloadData()
        
        // 3. Configure collapsed states
        detailsStackView.isHidden = !isExpanded
        dividerLine.isHidden = !isExpanded
        
        let chevronName = isExpanded ? "chevron.up" : "chevron.down"
        chevronButton.setImage(UIImage(systemName: chevronName), for: .normal)
        chevronButton.backgroundColor = isExpanded ? UIColor(red: 230/255, green: 232/255, blue: 255/255, alpha: 1.0) : UIColor(red: 238/255, green: 242/255, blue: 246/255, alpha: 1.0)
        chevronButton.tintColor = isExpanded ? UIColor(red: 74/255, green: 85/255, blue: 246/255, alpha: 1.0) : UIColor(red: 142/255, green: 154/255, blue: 168/255, alpha: 1.0)
        
        // 4. Populate dynamic subviews inside stack
        for subview in detailsStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        if isExpanded {
            for subject in exam.subjects {
                let subjectView = SubjectRowView.loadFromNib()
                let subjectExpanded = stateTracker.isSubjectExpanded(examId: exam.classTestId ?? "", subjectId: subject.subjectId ?? "")
                
                subjectView.configure(with: subject, isExpanded: subjectExpanded) { [weak self] in
                    guard let self = self else { return }
                    stateTracker.toggleSubject(examId: exam.classTestId ?? "", subjectId: subject.subjectId ?? "")
                    self.onSubjectToggle?()
                }
                detailsStackView.addArrangedSubview(subjectView)
            }
        }
    }
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subjectNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubjectBadgeCollectionViewCell", for: indexPath) as? SubjectBadgeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: subjectNames[indexPath.item])
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let name = subjectNames[indexPath.item]
        let font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        let width = name.size(withAttributes: [.font: font]).width + 16
        return CGSize(width: max(50, width), height: 28)
    }
}
