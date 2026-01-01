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
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var saveMarksBtn: UIButton!
    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    
    var studentRecords: [StudentMark] = []
    var aiRecords: [ConvertedStudentRecord] = []
    var subjectColumns: [ColumnConfig] = []
    private var isSyncing = false
    var editedMarks: [String: [String: String]] = [:]
    private var currentVerticalOffset: CGFloat = 0
    var payload:[String:Any]?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if #available(iOS 15.0, *) {
            studentTableView.sectionHeaderTopPadding = 0
        }
        setupColumnsFromPayload(payload ?? [:])
        saveMarksBtn.layer.cornerRadius = 8
        Get_Marks(parameters: payload ?? [:])
    }
    
    var activeTextField: UITextField?
    var keyboardHeight: CGFloat = 0
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        keyboardHeight = keyboardFrame.height
        
        guard let textField = activeTextField else { return }
        
        // Find the parent cell and collection view
        if let cell = textField.superview(of: MarkReviewTVC.self),
           let collectionCell = cell.superview(of: MarkReviewCVC.self),
           let indexPath = collectionCell.listTable.indexPath(for: cell) {
            
            let visibleRect = collectionCell.listTable.convert(cell.frame, to: self.view)
            let bottomY = visibleRect.maxY
            let screenHeight = UIScreen.main.bounds.height - keyboardHeight
            
            if bottomY > screenHeight {
                let offsetY = bottomY - screenHeight + 20
                let newOffset = CGPoint(x: 0, y: collectionCell.listTable.contentOffset.y + offsetY)
                collectionCell.listTable.setContentOffset(newOffset, animated: true)
                
                // Update stored offset and sync
                currentVerticalOffset = newOffset.y
                syncVerticalScroll(from: collectionCell.listTable, offset: newOffset)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        keyboardHeight = 0
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
                        self.studentRecords = data
                        
                        if !self.aiRecords.isEmpty {
                            
                            for studentIndex in 0..<self.studentRecords.count {
                                
                                let studentId = self.studentRecords[studentIndex].student_id ?? ""
                                
                                guard let aiStudent = self.aiRecords.first(where: {
                                    $0.studentId == studentId
                                }) else { continue }
                                
                                for subjectIndex in 0..<(self.studentRecords[studentIndex].marks?.count ?? 0) {
                                    
                                    guard let activities = self.studentRecords[studentIndex]
                                        .marks?[subjectIndex].activities else { continue }
                                    
                                    for activityIndex in 0..<activities.count {
                                        
                                        let studentActivityName = self.normalizeName(
                                            activities[activityIndex].name ?? ""
                                        )
                                        
                                        guard let aiRecord = aiStudent.marks.first(where: {
                                            self.normalizeName($0.name) == studentActivityName
                                        }) else { continue }
                                        
                                        let studentMark = activities[activityIndex].mark ?? ""
                                        let aiMark = aiRecord.value
                                        
                                        if !studentMark.isEmpty,
                                           !aiMark.isEmpty,
                                           studentMark != aiMark {
                                            
                                            self.studentRecords[studentIndex]
                                                .marks?[subjectIndex]
                                                .activities?[activityIndex]
                                                .change_mark = studentMark
                                            
                                            self.studentRecords[studentIndex]
                                                .marks?[subjectIndex]
                                                .activities?[activityIndex]
                                                .mark = aiMark
                                        }
                                        
                                        // confidence + reason
                                        self.studentRecords[studentIndex]
                                            .marks?[subjectIndex]
                                            .activities?[activityIndex]
                                            .cnfidenceLvl = !aiRecord.isReview
                                        
                                        self.studentRecords[studentIndex]
                                            .marks?[subjectIndex]
                                            .activities?[activityIndex]
                                            .reason = aiRecord.reason ?? ""
                                    }
                                }
                            }
                        }
                        
                    }
                    self.studentTableView.reloadData()
                    self.subjectsCollectionView.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        let frameWidth = self.view.frame.width
                        let contentWidth = self.subjectsCollectionView.contentSize.width
                        let extra: CGFloat = 160
                        let referenceWidth = frameWidth - extra
                        let balance = referenceWidth - contentWidth
                        
                        if contentWidth < referenceWidth {
                            self.nameWith.constant = balance + extra
                        }
                        let errorReason = self.getFormattedReasonSummary()
                        self.errorDeclarationLbl.text = "⚠️ \(errorReason)"
                    }
                case .failure(let error):
                    print("❌ Error:", error.localizedDescription)
                }
            }
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
        
        var resultActivities: [[String: Any]] = []
        
        guard let selected = payload["selected_activities"] as? [[String: Any]] else {
            return [:]
        }
        
        for subject in selected {
            
            let subjectId = subject["subject_id"] as? String ?? ""
            var activityIds: [String] = []
            
            if let activities = subject["activities"] as? [[String: Any]] {
                
                for act in activities {
                    if let actId = act["activity_id"] as? String {
                        activityIds.append(actId)
                    }
                }
            }
            
            resultActivities.append([
                "subject_id": subjectId,
                "activities": activityIds
            ])
        }
        
        return [
            "class_id": classId,
            "section_id": sectionId,
            "exam_id": examId,
            "selected_activities": resultActivities
        ]
    }
    
//    
//    private func generateDummyStudents(count: Int) -> [StudentMark] {
//        
//        let subjects: [(id: String, name: String)] = [
//            ("112625", "TAMIL"),
//            ("112626", "ENGLISH"),
//            ("112627", "MATHS"),
//            ("112628", "SCIENCE"),
//            ("112629", "SOCIAL")
//        ]
//        
//        let activities: [(id: String, name: String)] = [
//            ("3062", "Activity 1"),
//            ("3063", "Activity 2")
//        ]
//        
//        let flaggedIndexes = Set((0..<count).shuffled().prefix(5))
//        
//        var students: [StudentMark] = []
//        
//        for i in 0..<count {
//            
//            var subjectMarks: [SubjectMarks] = []
//            
//            for subject in subjects {
//                
//                var activityMarks: [ActivityMark] = []
//                
//                for activity in activities {
//                    
//                    let isFlagged = flaggedIndexes.contains(i) && Bool.random()
//                    
//                    let activityMark = ActivityMark(
//                        id: activity.id,
//                        name: activity.name,
//                        mark: "\(Int.random(in: 40...100))",
//                        max_mark: "100",
//                        cnfidenceLvl: !isFlagged,
//                        reason: isFlagged ? "Please verify the entered mark." : ""
//                    )
//                    
//                    activityMarks.append(activityMark)
//                }
//                
//                subjectMarks.append(
//                    SubjectMarks(
//                        subject_id: subject.id,
//                        subject_name: subject.name,
//                        activities: activityMarks
//                    )
//                )
//            }
//            
//            let student = StudentMark(
//                student_id: "\(1001 + i)",
//                student_name: "Student \(i + 1)",
//                roll_no: "\(i + 1)",
//                admission_no: "AD-\(1001 + i)",
//                marks: subjectMarks
//            )
//            
//            students.append(student)
//        }
//        
//        return students
//    }
    
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
                            displayName: displayName,
                            subjectName: subjectName,
                            subjectId: subjectId,
                            activityId: activityId, activityName: activityName,
                            maxMarks: maxMark
                        )
                    )
                }
            }
        }
        
        subjectColumns.sort { $0.subjectName ?? "" < $1.subjectName ?? ""}
    }
    
    
    
    @IBAction func saveAllMarks(_ sender: UIButton) {
        
        var marksPayload: [[String: Any]] = []
        var invalidMarkCount = 0
        for studentIndex in 0..<studentRecords.count {
            var student = studentRecords[studentIndex]
            var studentMarks: [[String: Any]] = []
            for subjectIndex in 0..<(student.marks?.count ?? 0) {
                guard var subject = student.marks?[subjectIndex] else { continue }
                var activitiesArray: [[String: Any]] = []
                for activityIndex in 0..<(subject.activities?.count ?? 0) {
                    guard var activity = subject.activities?[activityIndex] else { continue }
                    
                    let key = "\(subject.subject_id ?? "")_\(activity.id ?? "")"
                    let editedMark = editedMarks[student.roll_no ?? ""]?[key]
                    
                    let finalMarkStr = editedMark ?? activity.mark ?? ""
                    let maxMarkStr   = activity.max_mark ?? ""
                    
                    let finalMark = Double(finalMarkStr) ?? 0
                    let maxMark   = Double(maxMarkStr) ?? 0
                    
                    if finalMark > maxMark {
                        invalidMarkCount += 1
                        activity.cnfidenceLvl = false
                        activity.reason = "Mark exceeds maximum (\(maxMarkStr))"
                    } else {
                        activity.cnfidenceLvl = true
                        activity.reason = ""
                    }
                    
                    activity.change_mark = finalMarkStr
                    subject.activities?[activityIndex] = activity
                    
                    activitiesArray.append([
                        "id": activity.id ?? "",
                        "name": activity.name ?? "",
                        "mark": finalMarkStr,
                        "max_mark": maxMarkStr,
                        "cnfidenceLvl": activity.cnfidenceLvl,
                        "reason": activity.reason
                    ])
                }
                
                studentMarks.append([
                    "subject_id": subject.subject_id ?? "",
                    "activities": activitiesArray
                ])
                
                student.marks?[subjectIndex] = subject
            }
            
            studentRecords[studentIndex] = student
            
            marksPayload.append([
                "student_id": student.student_id ?? "",
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
        
        CustomAlert().showAlertCancel(
            title: AlertstringFile.Confirm,
            message: AlertstringFile.uploadMark,
            actionLbl1: AlertstringFile.save,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                self.sendMarksToAPI(with: marksPayload)
            },
            onNo: {
                print("User canceled upload")
            }
        )
    }
    
    
    
    func sendMarksToAPI(with parameters: [[String: Any]]) {
        
        guard !isSyncing else {
            print("⚠️ Already syncing")
            return
        }
        isSyncing = true
        saveMarksBtn.isEnabled = false
        
        let loadingAlert = UIAlertController(title: "Saving Marks", message: "Please wait...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        APIService.shared.PtmApi(url:  ServiceUrl.exam_api_exam_upload_marks, parameters: parameters, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [weak self] (result: Result<Send_AttachmentResponse, Error>) in
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
        layout.sectionInset = .zero
        subjectsCollectionView.collectionViewLayout = layout
        subjectsCollectionView.register(UINib(nibName: "MarkReviewCVC", bundle: nil),
                                        forCellWithReuseIdentifier: "MarkReviewCVC")
        
        subjectsCollectionView.dataSource = self
        subjectsCollectionView.delegate = self
        subjectsCollectionView.showsHorizontalScrollIndicator = true
        subjectsCollectionView.bounces = true
        subjectsCollectionView.backgroundColor = .systemBackground
        subjectsCollectionView.contentInsetAdjustmentBehavior = .never
        subjectsCollectionView.contentInset = .zero
        
        if #available(iOS 15.0, *) {
            subjectsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    // MARK: - Scroll Synchronization (KEY FIX)
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
    
    
    func updateMark(row: Int, column: Int, value: String, reson: String) {
        
        guard row < studentRecords.count,
              column < subjectColumns.count else { return }
        
        let col = subjectColumns[column]
        let rollNo = studentRecords[row].roll_no ?? ""
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        
        var hasError = false
        if trimmed.isEmpty || trimmed.uppercased() == "AB" {
            hasError = true
        } else if let entered = Int(trimmed) {
            hasError = entered < 0 || entered > (col.maxMarks ?? 0)
        } else {
            hasError = true
        }
        
        let key = makeMarkKey(col: col)
        
        if editedMarks[rollNo] == nil { editedMarks[rollNo] = [:] }
        editedMarks[rollNo]?[key] = trimmed
        
        for s in 0..<(studentRecords[row].marks?.count ?? 0) {
            
            for a in 0..<(studentRecords[row].marks?[s].activities?.count ?? 0) {
                
                let activity = studentRecords[row].marks?[s].activities?[a]
                
                guard activity?.name == col.activityName else { continue }
                
                let original = activity?.mark ?? ""
                
                studentRecords[row].marks?[s].activities?[a].mark = trimmed
                studentRecords[row].marks?[s].activities?[a].cnfidenceLvl = !hasError
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
        let rollHeight = textHeight(text: "Reg: \(rollNo)", font: rollFont, width: labelWidth)
        
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
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension MarkReviewVC {
    
    func getReasonCounts() -> [String: Int] {
        
        var reasonMap: [String: Int] = [:]
        
        for student in studentRecords {
            for subject in student.marks ?? [] {
                for activity in subject.activities ?? [] {
                    
                    let reason = activity.reason?.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    guard ((reason?.isEmpty) == nil) else { continue }
                    
                    reasonMap[reason ?? "", default: 0] += 1
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

struct ColumnConfig {
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
    let data: [StudentMark]?
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
    var change_mark: String?
    let max_mark: String?
    var cnfidenceLvl: Bool?
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
