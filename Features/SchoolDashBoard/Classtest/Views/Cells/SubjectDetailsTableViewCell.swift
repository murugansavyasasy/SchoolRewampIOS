//
//  SubjectDetailsTableViewCell.swift
//  School Chimes
//
//  Created by apple on 25/06/26.
//

import UIKit

class SubjectDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var countLable: UILabel!
    @IBOutlet weak var countContainerView: UIView!
    @IBOutlet public weak var cardContainerView: UIView!
    @IBOutlet public weak var headerView: UIView!
    @IBOutlet public weak var iconCircleView: UIView!
    @IBOutlet public weak var iconImageView: UIImageView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var subtitleLabel: UILabel!
    @IBOutlet public weak var checkmarkImageView: UIImageView!
    @IBOutlet public weak var chevronImageView: UIImageView!
    
    @IBOutlet public weak var detailsContainerView: UIView!
    @IBOutlet public weak var testsStackView: UIStackView!
    @IBOutlet public weak var addTestButton: UIButton!

    @IBOutlet public weak var mergeBannerView: UIView!
    @IBOutlet public weak var mergeBannerIconImageView: UIImageView!
    @IBOutlet public weak var mergeBannerTitleLabel: UILabel!
    @IBOutlet public weak var mergeBannerSubtitleLabel: UILabel!
    @IBOutlet public weak var mergeBannerButton: UIButton!
    public var onToggleExpand: (() -> Void)?
    public var onAddTest : ((String,String) -> Void)?
    public var onRemoveTest:((Int,String,String) -> Void)?
    public var onMergeTapped: ((String, String, String) -> Void)?
    public var onUpdateTest : ((TestDetails,Int) -> Void)?
    public var onHeightChanged: (() -> Void)?
    public var onInvalidMarksEnter: ((String) -> Void)?
    private var isCellExpanded: Bool = false
    private var dashedBorderLayer : CAShapeLayer?
    private var currentSubjectId: String?
    private var currentSectionId: String?
    
    private var currentConfig: SubjectExamConfig?
    private var currentViewModel: CreateTestViewModel?
    private var currentReport: StaffSubject?
    private var isReport = false
    
    private var bannerView: UIView?
    private var bannerIconView: UIImageView?
    private var bannerTitleLabel: UILabel?
    private var bannerSubtitleLabel: UILabel?
    private var bannerMergeButton: UIButton?
    private var bannerSeparatorView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }

    private func setupUi(){
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
    // Card corner radius
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.layer.borderWidth = 1.0
        cardContainerView.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor // #E2E8F0
        cardContainerView.layer.masksToBounds = true
        
        // Circular icon background
        iconCircleView.layer.cornerRadius = 20
        iconCircleView.layer.masksToBounds = true
        iconCircleView.backgroundColor = UIColor.primery/*UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 0.1)*/ // 10% tint
        iconImageView.tintColor =  UIColor.white/*UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0)*/
        
        // Action buttons
        addTestButton.layer.cornerRadius = 12
        addTestButton.layer.masksToBounds = true
        countContainerView.isHidden = true
        countContainerView.layer.cornerRadius = 10
        
        mergeBannerButton.layer.cornerRadius = 15
        mergeBannerButton.layer.masksToBounds = true
        
        // Add gesture reconizer for header
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        headerView.addGestureRecognizer(tap)
        
        // Accessibility
        self.isAccessibilityElement = false // Child components are elements
        headerView.isAccessibilityElement = true
        headerView.accessibilityHint = "Double tap to expand or collapse details."
        
    }
    //MARK: Configure
    
    public func Configure(with configu : SubjectExamConfig, viewModel: CreateTestViewModel,isExpanded : Bool,isConfigured : Bool ){
        
        isReport = false
        currentReport = nil
        self.isCellExpanded = isExpanded
        self.currentConfig = configu
        self.currentViewModel = viewModel
        titleLabel.text = configu.subjectName
        subtitleLabel.text = "Section \(configu.sectionName.uppercased())"
        // Show green checkmark if all test are populate
        checkmarkImageView.isHidden = !isConfigured
        
        // toggle chevor direction
        let chevronName = isExpanded ? "chevron.down" : "chevron.forward"
        chevronImageView.image = UIImage(systemName: chevronName)
        
        detailsContainerView.isHidden = !isExpanded
        
        // Rebuild the test from stack view
        testsStackView.arrangedSubviews.forEach{
            view in
            view.removeFromSuperview()
        }
        
//        let showRemov = configu.tests.count > 1
        
        self.currentSubjectId = configu.subjectId
         self.currentSectionId = configu.sectionId
         
         let showRemove = true
        
        for (idx, test) in configu.tests.enumerated() {
            guard let form = Bundle.main.loadNibNamed("TestFormView", owner: nil, options: nil)?.first as? TestFormView else {
                continue
            }
            
            // Configure single test form
            form.configure(with: test, index: idx, showRemoveButton: showRemove)
            
            // Assign callbacks
            form.onRemoveTapped = { [weak self] in
                self?.onRemoveTest?(idx, configu.subjectId, configu.sectionId)
            }
            form.onDataChanged = { [weak self] updatedDetails in
                self?.onUpdateTest?(updatedDetails, idx)
            }
            
            form.onHeightChanged = { [weak self] in
                self?.onHeightChanged?()
            }
            
//            form.onHeightChanged = { [weak self] in
//                          self?.onHeightChanged?()
//                      }
            
        form.onInvalidMarksEnter = { [weak self] errorMsg in
                     self?.onInvalidMarksEnter?(errorMsg)
            }
            testsStackView.addArrangedSubview(form)
        }
        
        // Dynamic title based on test forms list count
        if configu.tests.isEmpty {
            addTestButton.setTitle("+ Add Activity", for: .normal)
        } else {
            addTestButton.setTitle("+ Add Another Activity", for: .normal)
        }
        
        // Manage Counterpart Subject Merge Banner
        if let mergeable = viewModel.getMergeableConfig(for: configu.subjectName, currentSectionId: configu.sectionId) {
            mergeBannerView.isHidden = false
            
            if isExpanded {
                mergeBannerIconImageView.isHidden = true
                mergeBannerSubtitleLabel.isHidden = false
                mergeBannerTitleLabel.text = "Copy data from \(configu.subjectName) · Sec \(mergeable.sectionName)?"
                mergeBannerSubtitleLabel.text = "Fills all tests from that subject into this section"
            } else {
                mergeBannerIconImageView.isHidden = false
                mergeBannerSubtitleLabel.isHidden = true
                mergeBannerTitleLabel.text = "\(configu.subjectName) (Sec \(mergeable.sectionName)) is filled"
            }
        } else {
            mergeBannerView.isHidden = true
        }
        
        countContainerView.isHidden = true
        if configu.tests.count >= 2{
            countContainerView.isHidden = false
            countLable.text = "\(configu.tests.count) Activity"
        }
        
        // Accessibility
        headerView.accessibilityLabel = "Subject \(configu.subjectName), Section \(configu.sectionName)."
        headerView.accessibilityValue = isExpanded ? "Expanded" : "Collapsed"
       
         
    }
    
    //MARK: this is for reports page
    func configureReport(with report: StaffSubject, isExpanded: Bool) {

        self.isReport = true
        self.currentReport = report

        titleLabel.text = report.subject_name
       // subtitleLabel.text = "Section \((report.subject_id ?? "").uppercased())"
        subtitleLabel.isHidden = true

        checkmarkImageView.isHidden = true

        chevronImageView.image = UIImage(
            systemName: isExpanded ? "chevron.down" : "chevron.forward"
        )

        detailsContainerView.isHidden = !isExpanded

        testsStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        let activities = report.activities ?? []

        for (index, activity) in activities.enumerated() {

            guard let form = Bundle.main.loadNibNamed(
                "TestFormView",
                owner: nil,
                options: nil
            )?.first as? TestFormView else {
                continue
            }

            form.configureReport(with: activity, index: index)
            
            form.onRemoveTapped = { [weak self] in
                self?.onRemoveTest?(index,(activity.class_test_subject_id ?? ""), "")
            }

            testsStackView.addArrangedSubview(form)
        }
        
        

        addTestButton.isHidden = true
        mergeBannerView.isHidden = true

        countContainerView.isHidden = activities.count < 2
        countLable.text = "\(activities.count) Activities"
    }
    
    @objc private func headerTapped() {
        onToggleExpand?()
    }
    public override func layoutSubviews(){
        super.layoutSubviews()
        
        updateDashedBorder()
    }
    
    private func updateDashedBorder() {
        dashedBorderLayer?.removeFromSuperlayer()
        
        let border = CAShapeLayer()
        border.strokeColor = UIColor.primery.cgColor /*UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0).cgColor*/
        border.fillColor = nil
        border.lineDashPattern = [4, 4]
        border.lineWidth = 1.5
        border.frame = addTestButton.bounds
        border.path = UIBezierPath(roundedRect: addTestButton.bounds, cornerRadius: 12).cgPath
        
        addTestButton.layer.addSublayer(border)
        dashedBorderLayer = border
    }
    
    @IBAction @objc public func mergeTapped(_ sender: UIButton) {
        guard let currentSec = currentSectionId,
              let viewModel = currentViewModel,
              let config = currentConfig else { return }
        
        if let mergeable = viewModel.getMergeableConfig(for: config.subjectName, currentSectionId: currentSec) {
            onMergeTapped?(mergeable.sectionId, currentSec, config.subjectName)
        }
    }
    
    
    @IBAction func addTestTappedActBtn(_ sender: UIButton) {
        if let subId = currentSubjectId, let secId = currentSectionId {
                  onAddTest?(subId, secId)
              }
    }
}
