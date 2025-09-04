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

class AssignmentTVC: UITableViewCell, SelectedId, UIPopoverPresentationControllerDelegate {
    func selectId(id: String?, edit: Bool?) {
        delegate?.selectId(id:id, edit: edit)
    }
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
//    @IBOutlet weak var createdDateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var assignmentProgressLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var submittedProgressStack: UIStackView!
    @IBOutlet weak var subCatogoriesStack: UIStackView!
    @IBOutlet weak var submitBtnStack: UIStackView!
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
    var id :String?
    var subject :String?
    var edit:Bool?
    var delete:Bool?
    var delegate:SelectedId?
    var selectedId:String?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBAction func submitBtn(_ sender: UIButton) {
        if let currentVC = getCurrentViewController() {
            if #available(iOS 14.0, *) {
                let vcc = SubmitVC(nibName: nil, bundle: nil)
                vcc.titleName = titleLbl.text
                vcc.id = id
                vcc.modalPresentationStyle = .fullScreen
                currentVC.present(vcc, animated: true, completion: nil)
            }
        }
    }
    @IBAction func mySubmission(_ sender: UIButton) {
        if #available(iOS 14.0, *) {
            if let currentVC = getCurrentViewController() {
                let vcc = AssignmentSummitionVC(nibName: nil, bundle: nil)
                vcc.titleName = titleLbl.text
                vcc.subject = subject
                vcc.id = id
                vcc.modalPresentationStyle = .fullScreen
                currentVC.present(vcc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func viewAttachment(_ sender: UIButton) {
        if let topVC = getCurrentViewController() {
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.fileURL = assignment?.file_path ?? []
            imageVC.subjectName = assignment?.subject
            imageVC.index = 0
            imageVC.modalPresentationStyle = .fullScreen
            topVC.present(imageVC, animated: true)
        }
    }
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
    // MARK: - UI Setup
    func setupUI() {
        [img1, img2, img3, imgCount].forEach { $0?.isHidden = true }
        [img1, img2, img3, imgCount].forEach {
            if let view = $0 {
                setBorderAndCornerRadius(for: view, cornerRadius: view.frame.width / 2)
            }
        }
        imgCount.layer.cornerRadius = imgCount.frame.width / 2
        completedBtn.layer.cornerRadius = 6
        submitBtn.layer.cornerRadius = 6
        mysubmitBtn.layer.cornerRadius = 6
//        mysubmitBtn.backgroundColor = UIColor.systemOrange
//        submitBtn.backgroundColor = UIColor.systemGreen
        mysubmitBtn.layer.cornerRadius = 10
        outerView.setShadow()
        outerView.backgroundColor = .systemBackground
        outerView.layer.cornerRadius = 12
        
        titleLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLbl.textColor = .label
        
//        createdDateLbl.font = .systemFont(ofSize: 12, weight: .medium) // Slightly bolder
//        createdDateLbl.textColor = .secondaryLabel
//        createdDateLbl.backgroundColor = .systemBackground
//        createdDateLbl.layer.cornerRadius = 15
//        createdDateLbl.layer.borderWidth = 1
//        createdDateLbl.layer.borderColor = UIColor.separator.cgColor // Subtle border
//        createdDateLbl.textAlignment = .center
//        createdDateLbl.layer.masksToBounds = true
        
        descriptionLbl.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLbl.textColor = .secondaryLabel
        
        assignmentProgressLbl.font = .systemFont(ofSize: 12, weight: .medium)
        assignmentProgressLbl.textColor = .label
    }
    func edit(edit:Bool,delete:Bool,selectedId:String){
        self.selectedId = selectedId
        self.delete = delete
        self.edit = edit
        editBtn.isHidden = !(edit || delete)
    }
    // MARK: - Cell Configuration
    func configure(with assignment: Report) {
        self.assignment = assignment
        
        titleLbl.text = assignment.title
        descriptionLbl.text = assignment.description
        // Clear old stack items
        subCatogoriesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create and add new category pills
        categories = createCategoriesArray(from: assignment)
        
        if let categories = categories {
            let generatedStack = createSubCategoriesStack(with: categories)
            subCatogoriesStack.addArrangedSubview(generatedStack)
        }
        assignmentProgressLbl.text = "Submitted Progress (\(assignment.submitted_count ?? 0)/\(assignment.total_count ?? 0))"
        let progress = calculateProgressPercentage(submitted: assignment.submitted_count, total: assignment.total_count)
        configureProgress(progress)
    }
    func loadFiles(into cell: AssignmentTVC, files: [FilePath]) {
        [cell.img1, cell.img2, cell.img3].forEach { $0?.isHidden = true }
        cell.imgCount.isHidden = true

        for (index, file) in files.enumerated() where index < 3 {
            guard let urlString = file.url, let url = URL(string: urlString) else { continue }

            let imageViews = [cell.img1, cell.img2, cell.img3]
            guard index < imageViews.count, let imageView = imageViews[index] else { continue }

            imageView.isHidden = false

            if file.type?.lowercased() != "image" {
                let iconName = getFileIconName(for: url) // Ensure this function exists
                imageView.image = UIImage(named: iconName) ?? UIImage(systemName: "doc.fill")
            } else {
                imageView.kf.setImage(with: url)
            }
        }

        if files.count > 3 {
            let extraCount = files.count - 3
            cell.imgCount.setTitle("+\(extraCount)", for: .normal)
            cell.imgCount.isHidden = false
        }
    }
    // MARK: - Create Categories Array
    func createCategoriesArray(from assignment: Report) -> [SubCategories] {
        var cats: [SubCategories] = []
        if let subject = assignment.created_date {
            cats.append(SubCategories(
                name: "Assigned : \(assignment.created_date?.convertToTargetDateFormat() ?? "")",
                icon: "calendar",
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
        if let subject = assignment.subject {
            cats.append(SubCategories(
                name: subject,
                icon: "book.closed",
                backgroundColor: .systemBlue.withAlphaComponent(0.15),
                textColor: .systemBlue
            ))
        }
        if let endDate = assignment.end_date {
            cats.append(SubCategories(
                name: "Deadline \(endDate.convertToTargetDateFormat() ?? "")",
                icon: "calendar",
                backgroundColor: .systemOrange.withAlphaComponent(0.15),
                textColor: .systemOrange
            ))
        }
        
        
        return cats
    }
    @IBAction func edit(_ sender: UIButton) {
        let popoverContentVC = PopupVC(edit: self.edit ?? false, delete: self.delete ?? false, selectedId: selectedId)
        popoverContentVC.delegate = self
        popoverContentVC.preferredContentSize = CGSize(width: 120, height: edit ?? false ? 90:50)
        popoverContentVC.modalPresentationStyle = .popover
        if let popoverController = popoverContentVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .right
            popoverController.delegate = self
        }
        
        // For iPhones: Present as a pop-up instead of full-screen
        if UIDevice.current.userInterfaceIdiom == .phone {
            popoverContentVC.modalPresentationStyle = .overFullScreen
            popoverContentVC.view.backgroundColor = UIColor(white: 0, alpha: 0.3) // Optional dim effect
        }
        if let topVC = getCurrentViewController() {
            topVC.present(popoverContentVC, animated: true, completion: nil)
        }
    }
    func setBorderAndCornerRadius(for view: UIView, cornerRadius: CGFloat = 8.0, borderWidth: CGFloat = 1.0, borderColor: UIColor = .lightGray) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.clipsToBounds = true
    }
    // MARK: - Configure Progress
    func configureProgress(_ value: Float) {
        progressView.progress = value
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .systemGreen
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        switch value {
        case 0.0..<0.3:
            progressView.progressTintColor = UIColor.systemRed
        case 0.3..<0.7:
            progressView.progressTintColor = UIColor.systemOrange
        default:
            progressView.progressTintColor = UIColor.systemGreen
        }
        
    }
    func calculateProgressPercentage(submitted: Int?, total: Int?) -> Float {
        guard let submitted = submitted, let total = total, total > 0 else {
            return 0.0
        }
        return Float(submitted) / Float(total)
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
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Ensure the popup style is maintained on iPhone
        return .none
    }
}
