//
//  AssignmentTVC.swift
//  School Chimes
//
//  Created by Chandhru on 04/08/25.
//

import UIKit

// MARK: - Data Model
struct SubCategories {
    let name: String
    let icon: String
    let backgroundColor: UIColor
    let textColor: UIColor
    
    init(name: String, icon: String, backgroundColor: UIColor = .systemGray6, textColor: UIColor = .label) {
        self.name = name
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
}

class AssignmentTVC: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var createdDateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var assignmentProgressLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var submittedProgressStack: UIStackView!
    @IBOutlet weak var subCatogoriesStack: UIStackView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var mysubmitBtn: UIButton!
    @IBOutlet weak var completedBtn: UIButton!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var imgCount: UIButton!
    
    // MARK: - Variables
    var categories: [SubCategories]?
    var assignment: Report?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        completedBtn.layer.cornerRadius = 6
        submitBtn.layer.cornerRadius = 10
        mysubmitBtn.layer.cornerRadius = 10
        mysubmitBtn.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.5)
        submitBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
        mysubmitBtn.layer.cornerRadius = 10
        outerView.setShadow()
        outerView.backgroundColor = .systemBackground
        outerView.layer.cornerRadius = 12
        
        titleLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLbl.textColor = .label
        
        createdDateLbl.font = .systemFont(ofSize: 12, weight: .regular)
        createdDateLbl.textColor = .secondaryLabel
        
        descriptionLbl.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLbl.textColor = .secondaryLabel
        descriptionLbl.numberOfLines = 2
        
        assignmentProgressLbl.font = .systemFont(ofSize: 12, weight: .medium)
        assignmentProgressLbl.textColor = .label
    }
    
    // MARK: - Cell Configuration
    func configure(with assignment: Report) {
        self.assignment = assignment
        
        titleLbl.text = assignment.title
        descriptionLbl.text = assignment.description
        createdDateLbl.text = "Assigned : \(formatDate(assignment.created_date ?? ""))"
        
        // Clear old stack items
        subCatogoriesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create and add new category pills
        categories = createCategoriesArray(from: assignment)
        
        if let categories = categories {
            let generatedStack = createSubCategoriesStack(with: categories)
            subCatogoriesStack.addArrangedSubview(generatedStack)
        }
        
        configureProgress(Double(assignment.progress ?? 0.0))
        configureStudentImages()
    }
    
    // MARK: - Create Categories Array
    func createCategoriesArray(from assignment: Report) -> [SubCategories] {
        var cats: [SubCategories] = []
        
        if let endDate = assignment.end_date {
            cats.append(SubCategories(
                name: "Deadline \(formatDate(endDate))",
                icon: "calendar",
                backgroundColor: .systemOrange.withAlphaComponent(0.15),
                textColor: .systemOrange
            ))
        }
        
        if let subject = assignment.subject {
            cats.append(SubCategories(
                name: subject,
                icon: "book.closed",
                backgroundColor: .systemBlue.withAlphaComponent(0.15),
                textColor: .systemBlue
            ))
        }
        
        if let category = assignment.category {
            cats.append(SubCategories(
                name: category,
                icon: "square.grid.2x2"
            ))
        }
        
        return cats
    }
    
    // MARK: - Configure Progress
    func configureProgress(_ value: Double) {
        progressView.progress = Float(value / 100.0)
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .systemGreen
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        assignmentProgressLbl.text = "Assignment Progress"
    }
    
    // MARK: - Configure Student Images
    func configureStudentImages() {
        [img1, img2, img3].forEach { imageView in
            imageView?.layer.cornerRadius = 12
            imageView?.clipsToBounds = true
            imageView?.backgroundColor = .systemGray4
            imageView?.contentMode = .scaleAspectFill
        }
        
        imgCount.backgroundColor = .systemGray5
        imgCount.layer.cornerRadius = 12
        imgCount.setTitleColor(.label, for: .normal)
        imgCount.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        imgCount.setTitle("+34 Students", for: .normal)
    }
    
    // MARK: - Create Subcategory Stack with Wrapping
    func createSubCategoriesStack(with tags: [SubCategories]) -> UIStackView {
        let containerStack = UIStackView()
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.translatesAutoresizingMaskIntoConstraints = false

        var currentLineStack = createHorizontalStack()
        var currentLineWidth: CGFloat = 0
        let maxLineWidth = UIScreen.main.bounds.width - 64

        for tag in tags {
            if let pill = createPill(for: tag) {
                let estimatedPillWidth = estimateWidth(for: pill)

                if currentLineWidth + estimatedPillWidth > maxLineWidth && currentLineStack.arrangedSubviews.count > 0 {
                    currentLineStack.addArrangedSubview(createFlexibleSpacer()) // Add empty space to fill
                    containerStack.addArrangedSubview(currentLineStack)
                    currentLineStack = createHorizontalStack()
                    currentLineWidth = 0
                }

                currentLineStack.addArrangedSubview(pill)
                currentLineWidth += estimatedPillWidth + 8
            }
        }

        if currentLineStack.arrangedSubviews.count > 0 {
            currentLineStack.addArrangedSubview(createFlexibleSpacer()) // Fill remaining space
            containerStack.addArrangedSubview(currentLineStack)
        }

        return containerStack
    }

    // MARK: - Create Horizontal Stack
    func createHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }

    // MARK: - Create Pill View
    func createPill(for category: SubCategories) -> UIView? {
        guard !category.name.isEmpty else { return nil }

        let pillView = UIView()
        pillView.backgroundColor = category.backgroundColor
        pillView.layer.cornerRadius = 8
        pillView.layer.masksToBounds = true

        let iconView = UIImageView()
        configureIcon(iconView, with: category.icon)
        iconView.tintColor = category.textColor

        let label = UILabel()
        label.text = category.name.isEmpty ? " " : category.name
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = category.textColor
        label.numberOfLines = 1

        let hStack = UIStackView(arrangedSubviews: [iconView, label])
        hStack.axis = .horizontal
        hStack.spacing = 4
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        pillView.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: pillView.topAnchor, constant: 6),
            hStack.bottomAnchor.constraint(equalTo: pillView.bottomAnchor, constant: -6),
            hStack.leadingAnchor.constraint(equalTo: pillView.leadingAnchor, constant: 8),
            hStack.trailingAnchor.constraint(equalTo: pillView.trailingAnchor, constant: -8)
        ])

        return pillView
    }

    // MARK: - Configure Icon
    func configureIcon(_ iconView: UIImageView, with systemName: String) {
        let image = UIImage(systemName: systemName) ?? UIImage(systemName: "tag.fill")
        iconView.image = image
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 14),
            iconView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    // MARK: - Estimate Width of Pill
    func estimateWidth(for view: UIView) -> CGFloat {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let size = view.systemLayoutSizeFitting(
            CGSize(width: CGFloat.greatestFiniteMagnitude, height: 32),
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required
        )
        return size.width
    }

    // MARK: - Empty View to Fill Remaining Space
    func createFlexibleSpacer() -> UIView {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return spacer
    }

    // MARK: - Date Formatting (Placeholder)
    func formatDate(_ dateString: String) -> String {
        // TODO: Replace with actual date formatting
        return dateString
    }
}
