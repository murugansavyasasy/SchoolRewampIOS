//
//  MarkReviewCVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/12/25.
//

import UIKit

protocol MarkReviewTVCDelegate: AnyObject {
    func markDidChange(row: Int, column: Int, value: String, reason: String)
}

class MarkReviewCVC: UICollectionViewCell {
    
    @IBOutlet weak var maxMarkLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var listTable: UITableView!
    
    var columnIndex = 0
    var columnConfig: ColumnConfig!
    var studentRecords: [StudentMark] = []
    private var flagReasons: [Int: String] = [:]
    weak var parentVC: MarkReviewVC?
    private var isConfiguring = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTable()
        setupHeader()
        
        self.backgroundColor = .systemBackground
        self.contentView.backgroundColor = .systemBackground
    }
    
    private func setupTable() {
        listTable.register(UINib(nibName: CellConfingName.MarkReviewTVC, bundle: nil),
                           forCellReuseIdentifier: CellConfingName.MarkReviewTVC)
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
        headerLbl.font = UIFont.boldSystemFont(ofSize: 13)
        headerLbl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isConfiguring, let parent = parentVC {
            let currentOffset = listTable.contentOffset.y
            let expectedOffset = parent.getCurrentVerticalOffset()
            if abs(currentOffset - expectedOffset) > 1.0 {
                listTable.setContentOffset(
                    CGPoint(x: 0, y: expectedOffset),
                    animated: false
                )
            }
        }
    }
    
    func configure(columnIndex: Int,
                   columnConfig: ColumnConfig,
                   studentRecords: [StudentMark],
                   parentVC: MarkReviewVC) {
        isConfiguring = true
        
        self.columnIndex = columnIndex
        self.columnConfig = columnConfig
        self.studentRecords = studentRecords  // ✅ Store reference directly
        self.parentVC = parentVC
        self.flagReasons.removeAll()
        
        headerLbl.text = "\(columnConfig.displayName ?? "")"
        subjectLbl.text = "\(columnConfig.subjectName ?? "")"
        maxMarkLbl.text = "Max: \(columnConfig.maxMarks!)"
        listTable.reloadData()
        listTable.layoutIfNeeded()  // ✅ Force layout
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let storedOffset = self.parentVC?.getCurrentVerticalOffset() ?? 0
            self.listTable.setContentOffset(
                CGPoint(x: 0, y: storedOffset),
                animated: false
            )
            self.isConfiguring = false
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isConfiguring = true
        studentRecords = []
        flagReasons.removeAll()
        isConfiguring = false
    }
}

// MARK: - TableView DataSource & Delegate

extension MarkReviewCVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentRecords.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.MarkReviewTVC,
            for: indexPath
        ) as! MarkReviewTVC
        
        guard indexPath.row < studentRecords.count else {
            print("❌ Index out of bounds")
            return cell
        }
        
        let studentRecord = studentRecords[indexPath.row]
        let studentMarks = studentRecord.marks
        
        var displayValue = ""
        var alignment: NSTextAlignment = .center
        var hasFlaggedIssue = false
        var reasonText = ""
        var changeMark: String? = nil
        
        let rollNo = studentRecord.roll_no ?? ""
        let key = "\(columnConfig.subjectId ?? "")_\(columnConfig.activityId ?? "")"
        
        if let editedValue = parentVC?.editedMarks[rollNo]?[key] {
            displayValue = editedValue
        } else {
            let columnActivityName = columnConfig.activityName ?? columnConfig.displayName ?? ""
            
            for subject in studentMarks ?? [] {
                if subject.subject_name == columnConfig.subjectName {
                    
                    for activity in subject.activities ?? [] {
                        let activitySelectedName = activity.selected_name ?? ""
                        if !activitySelectedName.isEmpty &&
                           parentVC?.normalizeName(activitySelectedName) == parentVC?.normalizeName(columnActivityName) {
                            
                            displayValue = activity.mark ?? ""
                            changeMark = activity.change_mark
                            
                            if let isReview = activity.isReview, isReview {
                                hasFlaggedIssue = true
                                reasonText = activity.reason ?? ""
                            }
                            break
                        }
                    }
                }
            }
        }
        
        // Validate mark
        if !displayValue.isEmpty {
            let trimmed = displayValue.trimmingCharacters(in: .whitespaces)
            if let entered = Int(trimmed), let maxMark = columnConfig.maxMarks {
                if entered > maxMark {
                    hasFlaggedIssue = true
                    reasonText = "Maximum mark exceeded"
                }
            }
        }
        
        if hasFlaggedIssue {
            flagReasons[indexPath.row] = reasonText
        }
        cell.configure(
            mark: displayValue,
            channgeMark: changeMark,
            rowIndex: indexPath.row,
            columnIndex: columnIndex,
            alignment: alignment,
            parentVC: parentVC,
            hasFlaggedIssue: hasFlaggedIssue
        )
        
        cell.delegate = self
        cell.infoBtn.removeTarget(nil, action: nil, for: .allEvents)
        cell.infoBtn.tag = indexPath.row
        cell.infoBtn.addTarget(self,
                               action: #selector(infoBtnTapped(_:)),
                               for: .touchUpInside)
        return cell
    }
    
    @objc func infoBtnTapped(_ sender: UIButton) {
        let rowIndex = sender.tag
        var reason = "Issue detected"
        
        if rowIndex < studentRecords.count {
            let columnActivityName = columnConfig.activityName ?? columnConfig.displayName ?? ""
            
            for subject in studentRecords[rowIndex].marks ?? [] {
                if subject.subject_name == columnConfig.subjectName {
                    
                    for activity in subject.activities ?? [] {
                        let activitySelectedName = activity.selected_name ?? ""
                        
                        if !activitySelectedName.isEmpty &&
                           parentVC?.normalizeName(activitySelectedName) == parentVC?.normalizeName(columnActivityName) {
                            reason = activity.reason ?? "Issue detected"
                            break
                        }
                    }
                }
            }
        }
        
        let popoverVC = PopoverViewVC(nibName: nil, bundle: nil)
        popoverVC.configureButtons(
            with: [("exclamationmark.circle.fill", reason, .systemRed)],
            type: .symbol
        )
        
        let (width, height) = calculatePopoverSize(for: reason)
        popoverVC.preferredContentSize = CGSize(width: width, height: height)
        
        showPopover(from: sender, contentVC: popoverVC)
    }
    
    private func calculatePopoverSize(for text: String) -> (width: CGFloat, height: CGFloat) {
        let maxWidth: CGFloat = 400
        let minWidth: CGFloat = 120
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.lineBreakMode = .byWordWrapping
        
        let boundingRect = (text as NSString).boundingRect(
            with: CGSize(width: maxWidth - 40, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)],
            context: nil
        )
        
        let textWidth = boundingRect.width + 70
        let finalWidth = max(minWidth, min(textWidth, maxWidth))
        let finalHeight = boundingRect.height + 30
        
        return (width: finalWidth, height: finalHeight)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let student = studentRecords[indexPath.row]
        let name = student.student_name ?? ""
        let rollNo = student.roll_no ?? ""
        
        let nameFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let rollFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        let labelWidth: CGFloat = 160
        let nameHeight = textHeight(text: name, font: nameFont, width: labelWidth)
        let rollHeight = textHeight(text: "Roll No: \(rollNo)", font: rollFont, width: labelWidth)
        
        let totalHeight = nameHeight + rollHeight + 24
        return max(50, totalHeight)
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
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView == listTable else { return }

            let offsetY = scrollView.contentOffset.y
            let contentHeight = listTable.contentSize.height
            let visibleHeight = listTable.bounds.height
            let maxOffset = contentHeight - visibleHeight
            let scrollPercentage = maxOffset > 0 ? (offsetY / maxOffset) * 100 : 0
            
            // Get expected offset from parent
            let expectedOffset = parentVC?.getCurrentVerticalOffset() ?? 0
            let isSynced = abs(offsetY - expectedOffset) < 1.0
            let syncStatus = isSynced ? "✅ SYNCED" : "❌ OUT OF SYNC"
            let offsetDifference = offsetY - expectedOffset
            
            // Get visible rows
            var visibleRowsInfo = ""
            if let indexPaths = listTable.indexPathsForVisibleRows {
                let rowNumbers = indexPaths.map { "\($0.row)" }.joined(separator: ", ")
                visibleRowsInfo = "Visible Rows: \(rowNumbers)"
            } else {
                visibleRowsInfo = "No visible rows"
            }
            
            print("""
            ═══════════════════════════════════════════════════════════════════════
            📊 COLUMN \(columnIndex) LIST TABLE SCROLL - \(columnConfig?.displayName ?? "Unknown")
            ═══════════════════════════════════════════════════════════════════════
            Current Offset Y: \(String(format: "%.2f", offsetY)) pt
            Expected Offset Y: \(String(format: "%.2f", expectedOffset)) pt
            Offset Difference: \(String(format: "%.2f", offsetDifference)) pt
            Content Height: \(String(format: "%.2f", contentHeight)) pt
            Visible Height: \(String(format: "%.2f", visibleHeight)) pt
            Scroll Progress: \(String(format: "%.1f", scrollPercentage))%
            Sync Status: \(syncStatus)
            \(visibleRowsInfo)
            ═══════════════════════════════════════════════════════════════════════
            """)

            // Sync with parent
            parentVC?.syncVerticalScroll(from: scrollView, offset: offsetY)
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

// MARK: - Delegate

extension MarkReviewCVC: MarkReviewTVCDelegate {
    func markDidChange(row: Int, column: Int, value: String, reason: String) {

        guard row < studentRecords.count else { return }

        let trimmed = value.trimmingCharacters(in: .whitespaces)
        let columnActivityName = columnConfig.activityName ?? columnConfig.displayName ?? ""
        let columnSubjectName  = columnConfig.subjectName ?? ""

        for s in 0..<(studentRecords[row].marks?.count ?? 0) {

            let subjectName = studentRecords[row].marks?[s].subject_name ?? ""

            // ✅ SUBJECT NORMALIZED MATCH
            guard parentVC?.normalizeName(subjectName) ==
                  parentVC?.normalizeName(columnSubjectName) else { continue }

            for a in 0..<(studentRecords[row].marks?[s].activities?.count ?? 0) {

                let activitySelectedName = studentRecords[row].marks?[s].activities?[a].selected_name ?? ""

                // ✅ ACTIVITY MATCH
                guard parentVC?.normalizeName(activitySelectedName) ==
                      parentVC?.normalizeName(columnActivityName) else { continue }

                let maxMarks = columnConfig.maxMarks ?? 0
                let isError = (Int(trimmed) ?? 0) > maxMarks

                studentRecords[row].marks?[s].activities?[a].mark = value
                studentRecords[row].marks?[s].activities?[a].isReview = isError
                studentRecords[row].marks?[s].activities?[a].reason = reason

                // 🔥 SUBJECT NAME PASS PANNROM
                parentVC?.updateMark(row: row,
                                     column: columnIndex,
                                     value: value,
                                     reson: reason,
                                     subjectName: subjectName ?? "")
                return
            }
        }
    }

}
