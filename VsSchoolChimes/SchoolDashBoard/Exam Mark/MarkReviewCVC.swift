//
//  MarkReviewCVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/12/25.
//

import UIKit

class MarkReviewCVC: UICollectionViewCell {

    @IBOutlet weak var maxMarkLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var listTable: UITableView!

    private var columnIndex = 0
    private var columnConfig: ColumnConfig!
    private var studentRecords: [StudentRecord] = []
    private var flagReasons: [Int: String] = [:]
    weak var parentVC: MarkReviewVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTable()
        setupHeader()
        
        // Set proper backgrounds
        self.backgroundColor = .systemBackground
        self.contentView.backgroundColor = .systemBackground
    }
    
    private func setupTable() {
        listTable.register(UINib(nibName: "MarkReviewTVC", bundle: nil),
                          forCellReuseIdentifier: "MarkReviewTVC")
        listTable.dataSource = self
        listTable.delegate = self
        listTable.separatorStyle = .singleLine
        listTable.rowHeight = 50
        
        listTable.isScrollEnabled = true
        listTable.showsVerticalScrollIndicator = false
        listTable.showsHorizontalScrollIndicator = false
        listTable.bounces = true
        listTable.backgroundColor = .systemBackground
        listTable.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupHeader() {
        headerLbl.numberOfLines = 0
        headerLbl.textAlignment = .center
        headerLbl.font = UIFont.boldSystemFont(ofSize: 13)
        headerLbl.backgroundColor = .systemGray5
        
        // IMPORTANT: Ensure header has constraints
        headerLbl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        listTable.layoutIfNeeded()
        if listTable.frame.height < 100 {
            print("⚠️ WARNING: TableView height is too small! (\(listTable.frame.height))")
        }
    }
    
    func configure(columnIndex: Int,
                   columnConfig: ColumnConfig,
                   studentRecords: [StudentRecord],
                   parentVC: MarkReviewVC) {
        self.columnIndex = columnIndex
        self.columnConfig = columnConfig
        self.studentRecords = studentRecords
        self.parentVC = parentVC
        self.flagReasons.removeAll()
        
        // Configure header
        switch columnConfig.type {
        case .studentName, .rollNumber:
            headerLbl.text = columnConfig.displayName
        case .subject:
            let maxMarksText = columnConfig.maxMarks != nil ? "\nMax: \(columnConfig.maxMarks!)" : ""
            headerLbl.text = "\(columnConfig.displayName)"
            maxMarkLbl.text = "Max: \(columnConfig.maxMarks!)"
        }
        
        // Force layout before reload
        self.layoutIfNeeded()
        listTable.layoutIfNeeded()
        
        // Reload table
        listTable.reloadData()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        studentRecords = []
        flagReasons.removeAll()
        listTable.reloadData()
    }
}

// MARK: - TableView DataSource & Delegate

extension MarkReviewCVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = studentRecords.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarkReviewTVC",
                                                 for: indexPath) as! MarkReviewTVC
        
        guard indexPath.row < studentRecords.count else {
            print("❌ Index out of bounds")
            return cell
        }
        
        let record = studentRecords[indexPath.row]
        
        // Get value based on column type
        var displayValue = ""
        var isEditable = true
        var alignment: NSTextAlignment = .center
        var hasFlaggedIssue = false
        var reasonText = ""
        
        switch columnConfig.type {
        case .studentName:
            displayValue = record.studentName ?? "Unknown"
            isEditable = false
            alignment = .left
            
        case .rollNumber:
            displayValue = "\(record.regNo ?? 0)"
            isEditable = false
            alignment = .center
            
        case .subject:
            // Use subjectName from columnConfig to find the subject
            if let subjectName = columnConfig.subjectName,
               let subjects = record.subjects {
                if let subject = subjects.first(where: { $0.Subject == subjectName }) {
                    displayValue = subject.value
                    if !subject.cnfidenceLvl {
                        hasFlaggedIssue = true
                        reasonText = subject.reason
                    }
                }
            }
            alignment = .center
        }
        
        // Store reason for this row
        if hasFlaggedIssue {
            flagReasons[indexPath.row] = reasonText
        }
        
        cell.configure(
            mark: displayValue,
            rowIndex: indexPath.row,
            columnIndex: columnIndex,
            isEditable: isEditable,
            alignment: alignment,
            parentVC: parentVC,
            hasFlaggedIssue: hasFlaggedIssue,
            columnType: columnConfig.type
        )
        
        // Add tap gesture to info button
        cell.infoBtn.removeTarget(nil, action: nil, for: .allEvents)
        cell.infoBtn.tag = indexPath.row
        cell.infoBtn.addTarget(self, action: #selector(infoBtnTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func infoBtnTapped(_ sender: UIButton) {
        let rowIndex = sender.tag
        let reason = flagReasons[rowIndex] ?? "Issue detected"
        
        let popoverVC = PopoverViewVC(nibName: nil, bundle: nil)
        popoverVC.configureButtons(
            with: [("exclamationmark.circle.fill", reason, .systemRed)],
            type: .symbol
        )
        
        // Calculate dynamic width and height based on text
        let (width, height) = calculatePopoverSize(for: reason)
        popoverVC.preferredContentSize = CGSize(width: width, height: height)
        
        showPopover(from: sender, contentVC: popoverVC)
    }
    
    private func calculatePopoverSize(for text: String) -> (width: CGFloat, height: CGFloat) {
        let maxWidth: CGFloat = 400 // Maximum width allowed
        let minWidth: CGFloat = 120 // Minimum width
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.lineBreakMode = .byWordWrapping
        
        // Calculate bounding rect
        let boundingRect = (text as NSString).boundingRect(
            with: CGSize(width: maxWidth - 40, height: .greatestFiniteMagnitude), // 40 for padding
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)],
            context: nil
        )
        
        // Dynamic width: text width + padding (40) + icon width (30)
        let textWidth = boundingRect.width + 70
        let finalWidth = max(minWidth, min(textWidth, maxWidth))
        
        // Dynamic height: text height + padding (top 30 + bottom 30) + icon height (40)
        let finalHeight = boundingRect.height + 50
        
        return (width: finalWidth, height: finalHeight)
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        let subject = studentRecords[indexPath.row]

        let text = subject.studentName ?? ""
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let labelWidth: CGFloat = 160

        let dynamicHeight = textHeight(text: text,
                                       font: font,
                                       width: labelWidth)

        return max(50, dynamicHeight + 20)
    }

    func textHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)

        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )

        return ceil(boundingBox.height)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    // Sync vertical scroll between all columns
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        parentVC?.syncVerticalScroll(from: scrollView, offset: scrollView.contentOffset)
    }
}

// MARK: - Popover Presentation

extension MarkReviewCVC: UIPopoverPresentationControllerDelegate {
    func showPopover(from sender: UIView, contentVC: PopoverViewVC) {
        contentVC.modalPresentationStyle = .popover
        if let popover = contentVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            popover.delegate = self
            popover.backgroundColor = .white
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            contentVC.modalPresentationStyle = .overFullScreen
            contentVC.view.backgroundColor = .white
        }
        parentVC?.present(contentVC, animated: true)
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
