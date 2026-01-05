//
//  MarkReviewVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/12/25.
//

import UIKit

class MarkReviewVC: UIViewController {
    
    @IBOutlet weak var errorDeclarationLbl: UILabel!
    @IBOutlet weak var nameWith: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var saveMarksBtn: UIButton!
    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    
    var studentRecords: [StudentMark] = []
    var aiRecords: [ConvertedStudentRecord] = []
    var subjectColumns: [ColumnConfig] = []
    var examId:String?
    private var isSyncing = false
    var editedMarks: [String: [String: String]] = [:]
    private var currentVerticalOffset: CGFloat = 0
    var payload:[String:Any]?
    private var isNameWidthCalculated = false
    private var isAdjustingForKeyboard = false
    var activeTextField: UITextField?
    var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        saveMarksBtn.layer.cornerRadius = 8
        Get_Marks(parameters: payload ?? [:])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !isNameWidthCalculated else { return }
        isNameWidthCalculated = true
        updateNameColumnWidth()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height - 70, right: 0)
        isAdjustingForKeyboard = true
        studentTableView.contentInset = inset
        studentTableView.scrollIndicatorInsets = inset
        for cell in subjectsCollectionView.visibleCells {
            if let colCell = cell as? MarkReviewCVC {
                colCell.listTable.contentInset = inset
                colCell.listTable.scrollIndicatorInsets = inset
            }
        }
        
        isAdjustingForKeyboard = false
    }
    
    
    @objc func keyboardWillHide(notification: Notification) {
        
        let inset = UIEdgeInsets.zero
        
        isAdjustingForKeyboard = true
        
        studentTableView.contentInset = inset
        studentTableView.scrollIndicatorInsets = inset
        
        for cell in subjectsCollectionView.visibleCells {
            if let colCell = cell as? MarkReviewCVC {
                colCell.listTable.contentInset = inset
                colCell.listTable.scrollIndicatorInsets = inset
            }
        }
        
        isAdjustingForKeyboard = false
    }
    
    
    func Get_Marks(parameters payload: [String: Any]) {
        let parameters = buildGetMarksParams(from: payload)
        
        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_exam_get_mark_details,
            parameters: parameters,
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<MarkDetailsResponse, Error>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let data = response.data, !data.isEmpty {
                        self.studentRecords = data.first?.upload_details ?? []
                        self.examId = data.first?.exam_section_id
                        self.setupColumnsFromPayload(self.payload ?? [:])
                        if !self.aiRecords.isEmpty {
                            self.updateMarksWithAIData()
                        } else {
                            self.errorDeclarationLbl.text = "⚠️ \(self.getFormattedReasonSummary())"
                            self.isNameWidthCalculated = false
                            self.studentTableView.reloadData()
                            self.subjectsCollectionView.reloadData()
                        }
                    }
                    
                case .failure(let error):
                    print("❌ Error:", error.localizedDescription)
                }
            }
        }
    }
    
    private func updateMarksWithAIData() {
        for studentIndex in 0..<studentRecords.count {
            
            guard let studentId = studentRecords[studentIndex].student_id,
                  let aiStudent = aiRecords.first(where: { $0.studentId == studentId }) else {
                continue
            }
            
            for subjectIndex in 0..<(studentRecords[studentIndex].marks?.count ?? 0) {
                
                guard let activities = studentRecords[studentIndex].marks?[subjectIndex].activities else {
                    continue
                }
                
                for activityIndex in 0..<activities.count {
                    
                    let currentMark = studentRecords[studentIndex]
                        .marks?[subjectIndex]
                        .activities?[activityIndex]
                        .mark ?? ""
                    
                    let selectedName = studentRecords[studentIndex]
                        .marks?[subjectIndex]
                        .activities?[activityIndex]
                        .selected_name ?? ""
                    
                    guard let aiMark = aiStudent.marks.first(where: {
                        normalizeName($0.name) == normalizeName(selectedName)
                    }) else { continue }
                    
                    let aiValue = aiMark.value
                    let aiReason = aiMark.reason ?? ""
                    let aiReviewStatus = aiMark.isReview
                    if !aiValue.isEmpty {
                        if let _ = Int(aiValue) {
                            
                            if !currentMark.isEmpty && currentMark != aiValue {
                                
                                studentRecords[studentIndex]
                                    .marks?[subjectIndex]
                                    .activities?[activityIndex]
                                    .change_mark = currentMark
                                
                                studentRecords[studentIndex]
                                    .marks?[subjectIndex]
                                    .activities?[activityIndex]
                                    .mark = aiValue
                                
                                studentRecords[studentIndex]
                                    .marks?[subjectIndex]
                                    .activities?[activityIndex]
                                    .reason = "Existing marks differ from the newly uploaded data."
                                
                            } else if currentMark.isEmpty {
                                
                                studentRecords[studentIndex]
                                    .marks?[subjectIndex]
                                    .activities?[activityIndex]
                                    .mark = aiValue
                            }
                            
                        } else {
                            studentRecords[studentIndex]
                                .marks?[subjectIndex]
                                .activities?[activityIndex]
                                .change_mark = currentMark
                            
                            studentRecords[studentIndex]
                                .marks?[subjectIndex]
                                .activities?[activityIndex]
                                .mark = aiValue == "AB" ? "AB" : ""
                            
                            studentRecords[studentIndex]
                                .marks?[subjectIndex]
                                .activities?[activityIndex]
                                .reason = aiValue
                        }
                        
                        studentRecords[studentIndex]
                            .marks?[subjectIndex]
                            .activities?[activityIndex]
                            .isReview = aiReviewStatus
                        
                    } else if !currentMark.isEmpty, !aiReason.isEmpty {
                        
                        studentRecords[studentIndex]
                            .marks?[subjectIndex]
                            .activities?[activityIndex]
                            .isReview = aiReviewStatus
                        
                        studentRecords[studentIndex]
                            .marks?[subjectIndex]
                            .activities?[activityIndex]
                            .reason = aiReason
                    }
                }
            }
        }
        
        // STEP 3: Reload UI
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.errorDeclarationLbl.text = "⚠️ \(self.getFormattedReasonSummary())"
            self.isNameWidthCalculated = false
            self.studentTableView.reloadData()
            self.subjectsCollectionView.reloadData()
        }
    }
    
    
    private func updateNameColumnWidth() {
        
        subjectsCollectionView.layoutIfNeeded()
        
        let frameWidth = view.bounds.width
        let contentWidth = subjectsCollectionView
            .collectionViewLayout
            .collectionViewContentSize.width
        
        let baseNameWidth: CGFloat = 160
        let availableWidth = frameWidth - baseNameWidth
        
        if contentWidth < availableWidth {
            nameWith.constant = baseNameWidth + (availableWidth - contentWidth)
        } else {
            nameWith.constant = baseNameWidth
        }
    }
    
    func normalizeName(_ text: String) -> String {
        return text
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: ".", with: "")
    }
    
    func buildGetMarksParams(from payload: [String: Any]) -> [String: Any] {
        
        let classId   = payload["class_id"] as? String ?? ""
        let sectionId = payload["section_id"] as? String ?? ""
        let examId    = payload["exam_id"] as? String ?? ""
        
        var resultSubjects: [[String: Any]] = []
        
        guard let selected = payload["selected_activities"] as? [[String: Any]] else {
            return [:]
        }
        
        for subject in selected {
            
            let subjectId = subject["subject_id"] as? String ?? ""
            var activitiesArray: [[String: Any]] = []
            
            if let activities = subject["activities"] as? [[String: Any]] {
                
                for act in activities {
                    let actId = act["activity_id"] as? String ?? ""
                    let activity_name = act["activity_name"] as? String ?? ""
                    let selectedName = act["ai_option"] as? String ?? activity_name
                    
                    activitiesArray.append([
                        "id": actId,
                        "selected_name": selectedName
                    ])
                }
            }
            
            resultSubjects.append([
                "subject_id": subjectId,
                "activities": activitiesArray
            ])
        }
        
        return [
            "class_id": classId,
            "section_id": sectionId,
            "exam_id": examId,
            "selected_activities": resultSubjects
        ]
    }
    
    
    private func setupColumnsFromPayload(_ payload: [String: Any]) {
        
        subjectColumns.removeAll()
        var uniqueKeys = Set<String>()
        
        guard let selectedActivities = payload["selected_activities"] as? [[String: Any]] else {
            return
        }
        
        for subjectDict in selectedActivities {
            
            let subjectId   = subjectDict["subject_id"] as? String ?? ""
            let subjectName = subjectDict["subject_name"] as? String ?? ""
            
            guard let activities = subjectDict["activities"] as? [[String: Any]] else { continue }
            
            for activity in activities {
                
                let activityId   = activity["activity_id"] as? String ?? ""
                let activityName = activity["activity_name"] as? String ?? ""
                let aiOption     = activity["ai_option"] as? String ?? ""
                let maxMarkStr   = activity["max_mark"] as? String ?? "100"
                let maxMark      = Int(maxMarkStr) ?? 100
                let displayName = aiOption.isEmpty ? activityName : aiOption
                
                let uniqueKey = "\(subjectId)_\(activityId)"
                
                if !uniqueKeys.contains(uniqueKey) {
                    
                    uniqueKeys.insert(uniqueKey)
                    
                    subjectColumns.append(
                        ColumnConfig(
                            displayName: activityName,
                            subjectName: subjectName,
                            subjectId: subjectId,
                            activityId: activityId,
                            activityName: displayName,
                            maxMarks: maxMark
                        )
                    )
                }
            }
        }
        
        subjectColumns.sort { $0.subjectName ?? "" < $1.subjectName ?? ""}
    }
    
    
    @IBAction func saveAllMarks(_ sender: UIButton) {
        
        var uploadDetails: [[String: Any]] = []
        var invalidMarkCount = 0
        
        for student in studentRecords {
            
            let rollNo = student.roll_no ?? ""
            var studentMarks: [[String: Any]] = []
            
            for subject in student.marks ?? [] {
                
                let subjectId = subject.subject_id ?? ""
                var activitiesArray: [[String: Any]] = []
                
                for activity in subject.activities ?? [] {
                    
                    let activityId = activity.id ?? ""
                    let key = "\(subjectId)_\(activityId)"
                    let editedMark = editedMarks[rollNo]?[key]
                    
                    let finalMarkStr = editedMark ?? activity.mark ?? ""
                    let maxMarkStr   = activity.max_mark ?? ""
                    
                    let finalMark = Double(finalMarkStr) ?? 0
                    let maxMark   = Double(maxMarkStr) ?? 0
                    
                    if finalMark > maxMark {
                        invalidMarkCount += 1
                    }
                    
                    activitiesArray.append([
                        "id": activityId,
                        "name": activity.name ?? "",
                        "mark": finalMarkStr,
                        "max_mark": maxMarkStr
                    ])
                }
                
                studentMarks.append([
                    "subject_id": subjectId,
                    "subject_name": subject.subject_name ?? "",
                    "activities": activitiesArray
                ])
            }
            
            uploadDetails.append([
                "student_id": student.student_id ?? "",
                "student_name": student.student_name ?? "",
                "roll_no": rollNo,
                "admission_no": student.admission_no ?? "",
                "marks": studentMarks
            ])
        }
        
        if invalidMarkCount > 0 {
            CustomAlert().showAlert(
                title: "Invalid Marks",
                message: "\(invalidMarkCount) marks are greater than Max Mark. Please correct them before saving.",
                on: self
            )
            return
        }
        
        let finalPayload: [String: Any] = [
            "exam_section_id": examId ?? "",
            "upload_details": uploadDetails
        ]
        
        CustomAlert().showAlertCancel(
            title: AlertstringFile.Confirm,
            message: AlertstringFile.uploadMark,
            actionLbl1: AlertstringFile.save,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: { self.sendMarksToAPI(with: finalPayload) },
            onNo: { print("User canceled upload") }
        )
    }
    
    
    func sendMarksToAPI(with parameters:[String: Any]) {
        
        guard !isSyncing else {
            print("⚠️ Already syncing")
            return
        }
        isSyncing = true
        saveMarksBtn.isEnabled = false
        
        let loadingAlert = UIAlertController(title: "Saving Marks", message: "Please wait...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        APIService.shared.makeApi(url:  ServiceUrl.exam_api_exam_upload_marks, parameters: parameters, type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [weak self] (result: Result<Send_AttachmentResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isSyncing = false
                self.saveMarksBtn.isEnabled = true
                loadingAlert.dismiss(animated: true) {
                    
                    switch result {
                        
                    case .success(let response):
                        CustomAlert.showAlertWithOkAction(
                            title: response.status ? AlertstringFile.Success : AlertstringFile.Alert_title,
                            message: response.message,
                            on: self
                        ) {
                            self.dismiss(animated: true)
                        }
                        
                    case .failure(_):
                        CustomAlert.showAlertWithOkAction(
                            title: AlertstringFile.Alert_title,
                            message: "Failed to upload marks. Please try again.",
                            on: self
                        ) { }
                    }
                }
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        setupStudentTable()
        setupSubjectsCollection()
    }
    
    private func setupStudentTable() {
        studentTableView.register(UINib(nibName: "StudentNameTVC", bundle: nil),
                                  forCellReuseIdentifier: "StudentNameTVC")
        
        studentTableView.dataSource = self
        studentTableView.delegate = self
        studentTableView.separatorStyle = .singleLine
        studentTableView.rowHeight = 50
        studentTableView.isScrollEnabled = true
        studentTableView.showsVerticalScrollIndicator = false
        studentTableView.showsHorizontalScrollIndicator = false
        studentTableView.alwaysBounceHorizontal = false
        studentTableView.alwaysBounceVertical = false
        studentTableView.bounces = true
        studentTableView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
    }
    
    private func setupSubjectsCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        subjectsCollectionView.collectionViewLayout = layout
        subjectsCollectionView.register(UINib(nibName: "MarkReviewCVC", bundle: nil),
                                        forCellWithReuseIdentifier: "MarkReviewCVC")
        
        subjectsCollectionView.dataSource = self
        subjectsCollectionView.delegate = self
        subjectsCollectionView.showsHorizontalScrollIndicator = true
        subjectsCollectionView.bounces = true
        subjectsCollectionView.backgroundColor = .systemBackground
    }
    
    // MARK: - Scroll Synchronization
    func syncVerticalScroll(from sender: UIScrollView, offset: CGPoint) {
        guard !isSyncing else { return }
        isSyncing = true
        currentVerticalOffset = offset.y
        if studentTableView != sender {
            studentTableView.setContentOffset(
                CGPoint(x: 0, y: offset.y),
                animated: false
            )
        }
        for cell in subjectsCollectionView.visibleCells {
            if let colCell = cell as? MarkReviewCVC,
               colCell.listTable != sender {
                colCell.listTable.setContentOffset(
                    CGPoint(x: 0, y: offset.y),
                    animated: false
                )
            }
        }
        
        isSyncing = false
    }
    
    func getCurrentVerticalOffset() -> CGFloat {
        return currentVerticalOffset
    }
    
    func restoreVerticalPosition(for tableView: UITableView) {
        guard !isSyncing else { return }
        if tableView.contentOffset.y != currentVerticalOffset {
            tableView.setContentOffset(
                CGPoint(x: 0, y: currentVerticalOffset),
                animated: false
            )
        }
    }
    
    func moveToNextColumn(row: Int, column: Int) {
        focusTextField(row: row, column: column + 1)
    }
    
    func moveToPreviousColumn(row: Int, column: Int) {
        focusTextField(row: row, column: column - 1)
    }
    
    func moveToNextRow(row: Int, column: Int) {
        focusTextField(row: row + 1, column: column)
    }
    
    func moveToPreviousRow(row: Int, column: Int) {
        focusTextField(row: row - 1, column: column)
    }
    
    func focusTextField(row: Int, column: Int) {
        
        guard row >= 0, column >= 0,
              row < studentRecords.count,
              column < subjectColumns.count else { return }
        
        let rowIndexPath = IndexPath(row: row, section: 0)
        let colIndexPath = IndexPath(item: column, section: 0)
        
        // Horizontal scroll
        subjectsCollectionView.scrollToItem(at: colIndexPath,
                                            at: .centeredHorizontally,
                                            animated: false)
        
        // Vertical scroll
        studentTableView.scrollToRow(at: rowIndexPath,
                                     at: .middle,
                                     animated: false)
        
        DispatchQueue.main.async {
            
            guard let columnCell = self.subjectsCollectionView.cellForItem(at: colIndexPath) as? MarkReviewCVC else { return }
            
            columnCell.listTable.scrollToRow(at: rowIndexPath,
                                             at: .middle,
                                             animated: false)
            
            DispatchQueue.main.async {
                
                if let cell = columnCell.listTable.cellForRow(at: rowIndexPath) as? MarkReviewTVC {
                    cell.markTxt.becomeFirstResponder()
                }
            }
        }
    }
    
    
    func updateMark(row: Int,
                    column: Int,
                    value: String,
                    reson: String,
                    subjectName: String) {
        
        guard row < studentRecords.count,
              column < subjectColumns.count else { return }
        
        let col = subjectColumns[column]
        let rollNo = studentRecords[row].roll_no ?? ""
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        
        var hasError = false
        if let entered = Int(trimmed) {
            hasError = entered < 0 || entered > (col.maxMarks ?? 0)
        } else {
            hasError = true
        }
        
        let key = makeMarkKey(col: col)
        
        if editedMarks[rollNo] == nil { editedMarks[rollNo] = [:] }
        editedMarks[rollNo]?[key] = trimmed
        
        for s in 0..<(studentRecords[row].marks?.count ?? 0) {
            
            let currentSubject = studentRecords[row].marks?[s].subject_name ?? ""
            
            // ✅ SUBJECT MATCH
            guard normalizeName(currentSubject) == normalizeName(subjectName) else { continue }
            
            for a in 0..<(studentRecords[row].marks?[s].activities?.count ?? 0) {
                
                let activity = studentRecords[row].marks?[s].activities?[a]
                
                // ✅ ACTIVITY MATCH
                guard normalizeName(activity?.name ?? "") == normalizeName(col.activityName ?? "") else { continue }
                
                let original = activity?.mark ?? ""
                
                studentRecords[row].marks?[s].activities?[a].mark = trimmed
                studentRecords[row].marks?[s].activities?[a].isReview = !hasError
                studentRecords[row].marks?[s].activities?[a].reason = reson
                
                errorDeclarationLbl.text = "⚠️ \(getFormattedReasonSummary())"
                
                if trimmed == original {
                    editedMarks[rollNo]?.removeValue(forKey: key)
                    if editedMarks[rollNo]?.isEmpty == true {
                        editedMarks.removeValue(forKey: rollNo)
                    }
                }
                return
            }
        }
    }
    
    
    func makeMarkKey(col: ColumnConfig) -> String {
        return "AN:\(col.activityName ?? UUID().uuidString)"
    }
}

// MARK: - Student TableView (Fixed Column)

extension MarkReviewVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentNameTVC",
                                                 for: indexPath) as! StudentNameTVC
        
        let record = studentRecords[indexPath.row]
        cell.configure(name: record.student_name ?? "Unknown", rollNo: "\(record.roll_no ?? "")")
        
        return cell
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == studentTableView {
            // Prevent horizontal scroll
            if scrollView.contentOffset.x != 0 {
                scrollView.setContentOffset(
                    CGPoint(x: 0, y: scrollView.contentOffset.y),
                    animated: false
                )
            }
            // Sync vertical scroll
            syncVerticalScroll(from: scrollView, offset: scrollView.contentOffset)
        }
    }
}

// MARK: - Subjects CollectionView (Scrollable Columns)

extension MarkReviewVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subjectColumns.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarkReviewCVC",
                                                      for: indexPath) as! MarkReviewCVC
        
        let column = subjectColumns[indexPath.item]
        cell.configure(
            columnIndex: indexPath.item,
            columnConfig: column,
            studentRecords: studentRecords,
            parentVC: self)
        
        // Reset any previous border first
        cell.layer.sublayers?.removeAll(where: { $0.name == "rightBorder" })
        
        // Add right border only for last cell
        if indexPath.item == subjectColumns.count - 1 {
            let borderWidth: CGFloat = 1.0
            let border = CALayer()
            border.name = "rightBorder"
            border.backgroundColor = UIColor.systemGray4.cgColor
            border.frame = CGRect(
                x: cell.bounds.width - borderWidth,
                y: 0,
                width: borderWidth,
                height: cell.bounds.height
            )
            cell.layer.addSublayer(border)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let column = subjectColumns[indexPath.item]
        
        var widths: [CGFloat] = []
        
        if let display = column.displayName {
            let font = UIFont.systemFont(ofSize: 13, weight: .medium)
            widths.append(display.width(usingFont: font))
        }
        
        if let subject = column.subjectName {
            let font = UIFont.systemFont(ofSize: 13, weight: .bold)
            widths.append(subject.width(usingFont: font))
        }
        
        if let max = column.maxMarks {
            let font = UIFont.systemFont(ofSize: 12, weight: .regular)
            widths.append("Max: \(max)".width(usingFont: font))
        }
        
        let padding: CGFloat = 24
        let minWidth: CGFloat = 110
        let maxTextWidth = widths.max() ?? minWidth
        let finalWidth = max(maxTextWidth + padding, minWidth)
        return CGSize(width: finalWidth,
                      height: collectionView.frame.height)
    }
}

extension MarkReviewVC {
    
    func getReasonCounts() -> [String: Int] {
        
        var reasonMap: [String: Int] = [:]
        
        for student in studentRecords {
            for subject in student.marks ?? [] {
                for activity in subject.activities ?? [] {
                    
                    guard let reason = activity.reason?
                        .trimmingCharacters(in: .whitespacesAndNewlines),
                          !reason.isEmpty else { continue }
                    
                    reasonMap[reason, default: 0] += 1
                }
            }
        }
        return reasonMap
    }
    
    func getFormattedReasonSummary() -> String {
        
        let map = getReasonCounts()
        guard !map.isEmpty else { return "No issues found." }
        
        let total = map.values.reduce(0,+)
        
        let details = map
            .sorted { $0.key < $1.key }
            .map { "\($0.value) \($0.key)" }
            .joined(separator: ", ")
        
        return "Found \(total) issue(s): " + details
    }
}

struct ColumnConfig: Codable {
    let displayName: String?
    let subjectName: String?
    let subjectId: String?
    let activityId: String?
    let activityName: String?
    let maxMarks: Int?
}

struct MarkDetailsResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [MarkDetails]?
}
struct MarkDetails:Codable{
    let exam_section_id : String?
    let upload_details:[StudentMark]?
}
struct StudentMark: Codable {
    let student_id: String?
    let student_name: String?
    let roll_no: String?
    let admission_no: String?
    var marks: [SubjectMarks]?
}

struct SubjectMarks: Codable {
    let subject_id: String?
    let subject_name: String?
    var activities: [ActivityMark]?
}

struct ActivityMark: Codable {
    let id: String?
    let name: String?
    var mark: String?
    let max_mark: String?
    var selected_name: String?
    var change_mark: String?
    var isReview: Bool?
    var reason: String?
}

extension String {
    func width(usingFont font: UIFont) -> CGFloat {
        let size = (self as NSString).size(withAttributes: [.font: font])
        return ceil(size.width)
    }
}

extension UIView {
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview?.superview(of: type)
    }
}
