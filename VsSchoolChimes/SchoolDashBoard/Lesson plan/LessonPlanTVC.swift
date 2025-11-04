//
//  LessonPlanTVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/08/25.
//

import UIKit

class LessonPlanTVC: UITableViewCell, SelectedId, UIPopoverPresentationControllerDelegate {
    func selectId(id: String?, edit: Bool?) {
        delegate?.selectId(id:id, edit: edit)
    }
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var subTitlleStack: UIStackView!
    @IBOutlet weak var rollBtn: UILabel!
    @IBOutlet weak var levelBtn: UIButton!
    @IBOutlet weak var EditBtn1: UIButton!
    @IBOutlet weak var EditBtn: UIButton!
    @IBOutlet weak var chapterLbl: UILabel!
    @IBOutlet weak var titleNameLbl: UILabel!
    var delegate:SelectedId?
    var selectedId:String?
    var edit:Bool?
    var delete:Bool?
    override func awakeFromNib() {
        super.awakeFromNib()
        outerView.setShadow()
        levelBtn.layer.cornerRadius = levelBtn.layer.frame.width/2
        iconBtn.layer.cornerRadius = 4
    }
    func edit(edit:Bool,delete:Bool,selectedId:String){
        self.selectedId = selectedId
        self.delete = !delete
        self.edit = edit
        EditBtn.isHidden = !(edit || delete)
        EditBtn1.isHidden = !(edit || delete)
    }
    @IBAction func edit(_ sender: UIButton) {
        let popoverContentVC = PopupVC(edit: self.edit ?? false, delete: self.delete ?? false, selectedId: selectedId)
        popoverContentVC.delegate = self
        popoverContentVC.preferredContentSize = CGSize(width: 120, height: edit ?? false ? 90:50)
        popoverContentVC.modalPresentationStyle = .popover
        if let popoverController = popoverContentVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .down
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
    func configure(with details: [LessonDetailItem]) {
        // Clear old views
        subTitlleStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var pillItems: [LessonDetailItem] = []
        
        for detail in details {
            guard let name = detail.name, let value = detail.value else { continue }
            
            switch name {
            case "Topic":
                titleNameLbl.text = value
            case "Activity":
                chapterLbl.text = value
            default:
                pillItems.append(detail)
            }
        }

        
        let pillsStack = createSubCategoriesStack(with: pillItems)
        subTitlleStack.addArrangedSubview(pillsStack)
    }
    /// Try to parse a string into Date
    func convertToDate(from string: String) -> Date? {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ssZ", // ISO format
            "yyyy-MM-dd",
            "dd/MM/yyyy"
        ]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }

    /// Convert Date into desired output format
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"  // 👈 unga required format
        return formatter.string(from: date)
    }

    // MARK: - Create Vertical Stack of Pills
    func createSubCategoriesStack(with tags: [LessonDetailItem]) -> UIStackView {
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
                    currentLineStack.addArrangedSubview(createFlexibleSpacer())
                    containerStack.addArrangedSubview(currentLineStack)
                    currentLineStack = createHorizontalStack()
                    currentLineWidth = 0
                }

                currentLineStack.addArrangedSubview(pill)
                currentLineWidth += estimatedPillWidth + 8
            }
        }

        if currentLineStack.arrangedSubviews.count > 0 {
            currentLineStack.addArrangedSubview(createFlexibleSpacer())
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

    // **MARK: - Create Pill View**
    func createPill(for item: LessonDetailItem) -> UIView? {
        guard let name = item.name, let value = item.value else { return nil }
        
        // 🔹 Format value if it's a date
        var finalValue = value
        if let date = convertToDate(from: value) {
            finalValue = formatDate(date)   // e.g. "02 Sep 2025"
        }
        
        let pillView = UIView()
        pillView.backgroundColor = UIColor.systemGray6
        pillView.layer.cornerRadius = 8
        pillView.layer.masksToBounds = true
        
        // Icon view setup
        let iconView = UIImageView()
        configureIcon(iconView, for: name)
        iconView.tintColor = .systemBlue
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Label setup
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Build attributed text
        let fullText = "\(name): \(finalValue)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Configure paragraph style with zero spacing and padding
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.paragraphSpacingBefore = 0
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 0
        paragraphStyle.tailIndent = 0
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        // Style name part
        if let nameRange = fullText.range(of: name) {
            let nsRange = NSRange(nameRange, in: fullText)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 11, weight: .medium), range: nsRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: nsRange)
        }
        
        // Style value part
        if let valueRange = fullText.range(of: finalValue) {
            let nsRange = NSRange(valueRange, in: fullText)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12, weight: .regular), range: nsRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.darkGray, range: nsRange)
        }
        
        label.attributedText = attributedString
        
        // Horizontal stack setup
        let hStack = UIStackView(arrangedSubviews: [iconView, label])
        hStack.axis = .horizontal
        hStack.spacing = 4
        hStack.alignment = .top  // Keep this as .top for proper alignment
        hStack.distribution = .fill
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        pillView.addSubview(hStack)
        
        NSLayoutConstraint.activate([
            // Padding around the stack
            hStack.topAnchor.constraint(equalTo: pillView.topAnchor, constant: 6),
            hStack.bottomAnchor.constraint(equalTo: pillView.bottomAnchor, constant: -6),
            hStack.leadingAnchor.constraint(equalTo: pillView.leadingAnchor, constant: 8),
            hStack.trailingAnchor.constraint(equalTo: pillView.trailingAnchor, constant: -8),
            
            // Fix icon size
            iconView.widthAnchor.constraint(equalToConstant: 14),
            iconView.heightAnchor.constraint(equalToConstant: 14),
            
            // Ensure label starts at the same vertical position as icon
            label.topAnchor.constraint(equalTo: iconView.topAnchor,constant:-5)
        ])
        
        return pillView
    }


    // MARK: - Configure Icon Based on Name
    func configureIcon(_ iconView: UIImageView, for name: String) {
        var systemName = "tag.fill"
        
        if name.contains("Month") { systemName = "calendar" }
        else if name.contains("Date") { systemName = "clock" }
        else if name.contains("Remarks") { systemName = "person.text.rectangle" }
        else if name.contains("Admin") { systemName = "person.crop.circle.badge.checkmark" }
        
        let image = UIImage(systemName: systemName)
        iconView.image = image
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
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

    // MARK: - Flexible Spacer
    func createFlexibleSpacer() -> UIView {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return spacer
    }
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Ensure the popup style is maintained on iPhone
        return .none
    }
}
