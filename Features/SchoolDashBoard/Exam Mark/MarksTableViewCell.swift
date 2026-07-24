//
//  MarksTableViewCell.swift
//  School Chimes
//
//  Created by Chandhru on 07/01/26.
//

import UIKit

class MarksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameWidth: NSLayoutConstraint!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var rollNoLabel: UILabel!
    @IBOutlet weak var admissNoLabel: UILabel!
    @IBOutlet weak var marksCollectionView: UICollectionView!
    
    var studentIndex: Int = 0
    weak var parentVC: EnterMarkVC?
    private var isScrolling = false
    private var configuredStudentId: String?
    weak var delegate: MarksCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        studentNameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        studentNameLabel.textColor = .black
        
        rollNoLabel.font = .systemFont(ofSize: 12, weight: .regular)
        admissNoLabel.font = .systemFont(ofSize: 12, weight: .regular)
        rollNoLabel.textColor = .gray
        admissNoLabel.textColor = .gray
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        marksCollectionView.collectionViewLayout = layout
        marksCollectionView.register(UINib(nibName: "MarksCell", bundle: nil), forCellWithReuseIdentifier: "MarksCell")
        marksCollectionView.showsHorizontalScrollIndicator = false
        marksCollectionView.backgroundColor = .white
        marksCollectionView.bounces = true
        marksCollectionView.alwaysBounceHorizontal = true
        
        marksCollectionView.dataSource = self
        marksCollectionView.delegate = self
        
        self.selectionStyle = .none
        self.backgroundColor = .white
    }
    
    func configure(student: StudentMark, index: Int, parentVC: EnterMarkVC, nameWidth: CGFloat) {

        setStudentNameWithGender(label: studentNameLabel,
                                 student: student.student_name,
                                 gender: student.gender)

        if UIView.userInterfaceLayoutDirection(
            for: contentView.semanticContentAttribute
        ) == .rightToLeft {
            studentNameLabel.textAlignment = .right
            rollNoLabel.textAlignment = .right
            admissNoLabel.textAlignment = .right
            studentNameLabel.semanticContentAttribute = .forceRightToLeft
            rollNoLabel.semanticContentAttribute = .forceRightToLeft
            admissNoLabel.semanticContentAttribute = .forceRightToLeft
        } else {
            studentNameLabel.textAlignment = .left
            rollNoLabel.textAlignment = .left
            admissNoLabel.textAlignment = .left
        }

        if let rollNo = student.roll_no,
           let admissionNo = student.admission_no {
            rollNoLabel.text = "Roll No: \(rollNo)"
            admissNoLabel.text = "Adm No: \(admissionNo)"
            rollNoLabel.isHidden = rollNo.isEmpty
            admissNoLabel.isHidden = admissionNo.isEmpty
        } else {
            rollNoLabel.isHidden = true
            admissNoLabel.isHidden = true
        }

        self.nameWidth.constant = nameWidth
        self.studentIndex = index
        self.parentVC = parentVC
        marksCollectionView.tag = index
        
        let newId = student.student_id ?? "\(index)"
        if configuredStudentId != newId {
            configuredStudentId = newId
            marksCollectionView.reloadData()
        }
    }


    
    func setStudentNameWithGender(label: UILabel, student: String?, gender: String?) {

        let name = student ?? ""
        let gender = gender?.first?.uppercased()

        let fullText: String
        if let gender = gender, !gender.isEmpty {
            fullText = "\(name) (\(gender))"
        } else {
            fullText = name
        }

        let attr = NSMutableAttributedString(string: fullText)

        let nameRange = (fullText as NSString).range(of: name)
        attr.addAttribute(.foregroundColor,
                          value: UIColor.label,
                          range: nameRange)

        if let gender = gender {
            let genderText = "(\(gender))"
            let genderRange = (fullText as NSString).range(of: genderText)
            attr.addAttribute(.foregroundColor,
                              value: UIColor.systemPink,
                              range: genderRange)
        }

        // RTL Support
        if UIView.userInterfaceLayoutDirection(for: label.semanticContentAttribute) == .rightToLeft {
            label.textAlignment = .right
            label.semanticContentAttribute = .forceRightToLeft
        } else {
            label.textAlignment = .left
            label.semanticContentAttribute = .forceLeftToRight
        }

        label.attributedText = attr
    }

    func syncScroll(to offset: CGFloat) {
        isScrolling = true
        marksCollectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        isScrolling = false
    }
}

// MARK: - MarksTableViewCell CollectionView DataSource & Delegate
extension MarksTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let parentVC = parentVC else { return 0 }
        return parentVC.subjectColumns.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarksCell", for: indexPath) as! MarksCell
        
        guard let parentVC = parentVC else { return cell }
        
        let student = parentVC.studentRecords[studentIndex]
        let column = parentVC.subjectColumns[indexPath.item]
        
        var mark = ""
        var changeMark: String? = nil
        var hasFlaggedIssue = false
        var is_edit: Bool?
        
        if let subject = student.marks?.first(where: { $0.subject_id == column.subjectId }),
           let activity = subject.activities?.first(where: { $0.id == column.activityId }) {
            
            is_edit = activity.is_edit ?? true
            if column.isRubric, let rubricId = column.rubricId,
               let rubrics = activity.rubrics, !rubrics.isEmpty,
               let rubric = rubrics.first(where: { $0.id == rubricId }) {
                mark = rubric.mark ?? ""
                changeMark = rubric.change_mark
                hasFlaggedIssue = rubric.isReview ?? false
                is_edit = rubric.is_edit ?? is_edit ?? true
                
            } else {
                mark = activity.mark ?? ""
                changeMark = activity.change_mark
                hasFlaggedIssue = activity.isReview ?? false
            }
        }
        
        cell.configure(
            mark: mark,
            channgeMark: changeMark,
            rowIndex: studentIndex,
            columnIndex: indexPath.item,
            alignment: .center,
            parentVC: parentVC,
            hasFlaggedIssue: hasFlaggedIssue, is_edit: is_edit ?? true,
            maxMark: column.maxMarks ?? 0)
        cell.delegate = self
        cell.markTxt.tag = (studentIndex * 1000) + indexPath.item
        cell.infoBtn.removeTarget(nil, action: nil, for: .allEvents)
        cell.infoBtn.tag = indexPath.item
        cell.infoBtn.addTarget(self,
                               action: #selector(infoBtnTapped(_:)),
                               for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let parentVC = parentVC else {
            return CGSize(width: 120, height: 74)
        }

        let column = parentVC.subjectColumns[indexPath.item]

        var widths: [CGFloat] = []

        if let display = column.displayName {
            let font = UIFont.systemFont(ofSize: 13, weight: .medium)
            widths.append(display.width(usingFont: font))
        }

        if let max = column.maxMarks {
            let font = UIFont.systemFont(ofSize: 12, weight: .regular)
            widths.append("Max: \(max)".width(usingFont: font))
        }

        let padding: CGFloat = 16
        let minWidth: CGFloat = 110
        let maxWidth: CGFloat = 120

        let maxTextWidth = widths.max() ?? minWidth

        let finalWidth = min(max(maxTextWidth + padding, minWidth), maxWidth)

        return CGSize(width: finalWidth, height: 74)
    }
    
    @objc func infoBtnTapped(_ sender: UIButton) {
        let columnIndex = sender.tag
        var reason = "Issue detected"
        
        guard columnIndex < parentVC?.subjectColumns.count ?? 0 else { return }
        
        let column = parentVC?.subjectColumns[columnIndex]
        let student = parentVC?.studentRecords[studentIndex]
        
        if let subject = student?.marks?.first(where: { $0.subject_id == column?.subjectId }),
           let activity = subject.activities?.first(where: { $0.id == column?.activityId }) {
            reason = activity.reason ?? "Issue detected"
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
        
        let boundingRect = (text as NSString).boundingRect(
            with: CGSize(width: maxWidth - 40, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)],
            context: nil
        )
        
        let textWidth = boundingRect.width + 70
        let finalWidth = max(minWidth, min(textWidth, maxWidth))
        let finalHeight = boundingRect.height + 40
        
        return (width: finalWidth, height: finalHeight)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isScrolling else { return }
        parentVC?.syncAllCollectionViews(to: scrollView.contentOffset.x, excluding: scrollView)
    }
}

// MARK: - Popover Presentation
extension MarksTableViewCell: UIPopoverPresentationControllerDelegate {
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

extension MarksTableViewCell: MarksCellDelegate {
    func updateMark(row: Int,
                   column: Int,
                   value: String,
                   reson: String,
                   subjectName: String) {
        delegate?.updateMark(row: row,
                                 column: column,
                                 value: value,
                                 reson: reson,
                                 subjectName: subjectName)
    }
}
