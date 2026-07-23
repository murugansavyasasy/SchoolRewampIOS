//
//  EnterMarkVC.swift
//  School Chimes
//
//  Created by Chandhru on 07/01/26.
//

import UIKit

class EnterMarkVC: UIViewController, MarksCellDelegate {
    @IBOutlet weak var filtterBtn: UIButton!
    @IBOutlet weak var noteLbl: LocalizationLabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var subjectHeight: NSLayoutConstraint!
    @IBOutlet weak var nameWidth: NSLayoutConstraint!
    @IBOutlet weak var headerCollectionview: UICollectionView!
    @IBOutlet weak var nodataImg: UIImageView!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var listLableView: UITableView!
    @IBOutlet weak var saveMarksBtn: UIButton!
    @IBOutlet weak var publishMarksBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var errorDeclarationLbl: UILabel!
    @IBOutlet weak var aiIndimationLbl: UILabel!
    var examId: String?
    private var isSyncing = false
    private var isNavigatingCells = false
    var editedMarks: [String: [String: String]] = [:]
    var payload: [String: Any]?
    var studentRecords: [StudentMark] = []
    var allStudents: [StudentMark] = []
    var aiRecords: [ConvertedStudentRecord] = []
    var headerColumns: [HeaderColumnConfig] = []
    var subjectColumns: [ColumnConfig] = []
    private var isNameWidthCalculated = false
    private var isKeyboardVisible = false
    private var popoverWidth: CGFloat = 393
    private var popoverHeight: CGFloat = 400
    var isUpdatingPopover = false
    var uploadTest = false
    var sectionId:String?
    var viewModel: CreateTestViewModel?
    var selectedFilters: [(type: String, sortValue: String)] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        publishMarksBtn.isHidden = !uploadTest
        if uploadTest {
            allStudents = studentRecords
            titleLbl.text = MenuStringFile.selectedMenuName
            setupColumnsFromGetMarksResponse()
        } else {
//            Get_Marks(parameters: payload ?? [:])
            Get_Marks(parameters: [
                "exam_id": "1",
                "section_id": "68575",
                "academic_year_id": "7",
                "selected_activities": [
                    [
                        "subject_id": "29",
                        "activities": [
                            [
                                "id": "77",
                                "selected_name": "Subject Enrichment 1",
                                "rubrics": [
                                    [
                                        "id": "1",
                                        "selected_name": "Presentation"
                                    ],
                                    [
                                        "id": "2",
                                        "selected_name": "Content"
                                    ]
                                ]
                            ],
                            [
                                "id": "78",
                                "selected_name": "Notebook Work 1"
                            ],
                            [
                                "id": "76",
                                "selected_name": "Monthly Assessment 1"
                            ]
                        ]
                    ],
                    [
                        "subject_id": "28",
                        "activities": [
                            [
                                "id": "73",
                                "selected_name": "Monthly Assessment 1"
                            ],
                            [
                                "id": "74",
                                "selected_name": "Subject Enrichment 1"
                            ],
                            [
                                "id": "75",
                                "selected_name": "Notebook Work 1"
                            ]
                        ]
                    ],
                    [
                        "subject_id": "30",
                        "activities": [
                            [
                                "id": "80",
                                "selected_name": "Subject Enrichment 1"
                            ],
                            [
                                "id": "81",
                                "selected_name": "Notebook Work 1"
                            ],
                            [
                                "id": "79",
                                "selected_name": "Monthly Assessment 1"
                            ]
                        ]
                    ]
                ]
            ])
            titleLbl.configureAsBackTitle(
                firstLine: MenuStringFile.selectedMenuName,
                secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? ""
            )
        }
        noteLbl.text = uploadTest
            ? "Note: Use \("AB") for absent students and \("NA") for marks that are not applicable." : "Note: Use \("AB") for absent students."
        setupHeaderCollectionView()
        setupTableView()
        setupKeyboardObservers()
        saveMarksBtn.layer.cornerRadius = 8
        publishMarksBtn.layer.cornerRadius = 8
        searchBar.searchTextField.backgroundColor = .systemGray5
        searchBar.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        aiIndimationLbl.isHidden = aiRecords.isEmpty
    }

    deinit {
        removeKeyboardObservers()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isNameWidthCalculated && !subjectColumns.isEmpty {
            updateNameColumnWidth()
            isNameWidthCalculated = true
        }
    }
    
    @IBAction func searchBtn(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        
        if sender.isSelected {
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
        } else {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            searchBar.isHidden = true
            studentRecords = allStudents
            listLableView.reloadData()
        }
    }
    @IBAction func filterBtn(_ sender: UIButton) {

        let popoverVC = FilterPopover(nibName: "FilterPopover", bundle: nil)
        popoverVC.delegate = self
        popoverVC.previouslyAppliedFilters = selectedFilters
        showPopover(from: sender, contentVC: popoverVC)
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func setupColumnsFromGetMarksResponse() {
        headerColumns.removeAll()
        subjectColumns.removeAll()
        var uniqueKeys = Set<String>()

        guard let firstStudent = studentRecords.first else {
            print("❌ No student records")
            return
        }

        for subject in firstStudent.marks ?? [] {
            for activity in subject.activities ?? [] {
                guard let subjectId = subject.subject_id, !subjectId.isEmpty,
                      let activityId = activity.id, !activityId.isEmpty else {
                    continue
                }

                let key = "\(subjectId)_\(activityId)"
                if uniqueKeys.contains(key) { continue }
                uniqueKeys.insert(key)

                if let rubrics = activity.rubrics, !rubrics.isEmpty {
                    var rubricConfigs: [RubricMark] = []

                    for rubric in rubrics {
                        guard let rubricId = rubric.id, !rubricId.isEmpty else { continue }

                        rubricConfigs.append(
                            RubricMark(
                                id: rubricId,
                                name: rubric.name,
                                max_mark: rubric.max_mark,
                                subjectName: subject.subject_name,
                                displayName: rubric.selected_name ?? rubric.name
                            )
                        )

                        // flat leaf column for data entry
                        subjectColumns.append(
                            ColumnConfig(
                                displayName: rubric.selected_name ?? rubric.name,
                                subjectName: subject.subject_name,
                                subjectId: subjectId,
                                activityId: activityId,
                                activityName: activity.name,
                                maxMarks: Int(rubric.max_mark ?? "0"),
                                isRubric: true,
                                rubricId: rubricId
                            )
                        )
                    }

                    // only add a grouped header if at least one valid rubric was found
                    guard !rubricConfigs.isEmpty else { continue }

                    headerColumns.append(
                        HeaderColumnConfig(
                            displayName: activity.selected_name ?? activity.name,
                            subjectName: subject.subject_name,
                            subjectId: subjectId,
                            activityId: activityId,
                            activityName: activity.name,
                            maxMarks: Int(activity.max_mark ?? "0"),
                            rubrics: rubricConfigs
                        )
                    )

                } else {
                    headerColumns.append(
                        HeaderColumnConfig(
                            displayName: activity.selected_name ?? activity.name,
                            subjectName: subject.subject_name,
                            subjectId: subjectId,
                            activityId: activityId,
                            activityName: activity.name,
                            maxMarks: Int(activity.max_mark ?? "0"),
                            rubrics: nil
                        )
                    )

                    subjectColumns.append(
                        ColumnConfig(
                            displayName: activity.selected_name ?? activity.name,
                            subjectName: subject.subject_name,
                            subjectId: subjectId,
                            activityId: activityId,
                            activityName: activity.name,
                            maxMarks: Int(activity.max_mark ?? "0"),
                            isRubric: false,
                            rubricId: nil
                        )
                    )
                }
            }
        }
    }

    
    func Get_Marks(parameters payload: [String: Any]) {
//        let parameters = buildGetMarksParams(from: payload)
        showActivityLoader()

        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_exam_get_mark_details,
            parameters: payload,
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "",
            isBaseUrl: true
        ) { [weak self] (result: Result<MarkDetailsResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideActivityLoader()

                switch result {
                case .success(let response):
                    guard let data = response.data?.first else { return }
                    self.studentRecords = data.upload_details ?? []
                    self.allStudents = data.upload_details ?? []
                    self.examId = data.exam_section_id
                    self.errorDeclarationLbl.text = "⚠️ \(self.getFormattedReasonSummary())"
                    self.isNameWidthCalculated = false
                    self.setupColumnsFromGetMarksResponse()

                    if !self.aiRecords.isEmpty {
                        self.updateMarksWithAIData()
                    }

                    // 👈 NEW: show empty-state if no activities configured
                    let hasColumns = !self.subjectColumns.isEmpty
                    self.nodataImg.isHidden = hasColumns
                    self.nodataLbl.isHidden = hasColumns
                    if !hasColumns {
                        self.nodataLbl.text = "No exam activities configured for this section yet."
                        self.nodataLbl.textAlignment = .center
                    }

                    DispatchQueue.main.async {
                        self.subjectHeight.constant = self.calculateHeaderHeight()
                        self.headerCollectionview.reloadData()
                        self.listLableView.reloadData()
                        self.headerCollectionview.layoutIfNeeded()
                        self.updateNameColumnWidth()
                        self.listLableView.reloadData()
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
            self.isNameWidthCalculated = false
            self.allStudents = studentRecords
            self.errorDeclarationLbl.text = "⚠️ \(self.getFormattedReasonSummary())"
            self.headerCollectionview.reloadData()
            self.listLableView.reloadData()
            self.headerCollectionview.layoutIfNeeded()
            self.updateNameColumnWidth()
            self.listLableView.reloadData()
        }
    }
    
    private func updateNameColumnWidth() {
        view.layoutIfNeeded()
        headerCollectionview.layoutIfNeeded()
        
        let frameWidth = view.bounds.width
        let contentWidth = headerCollectionview
            .collectionViewLayout
            .collectionViewContentSize.width
        
        let baseNameWidth: CGFloat = 160
        let availableWidth = frameWidth - baseNameWidth
        if contentWidth < availableWidth {
            let extraSpace = availableWidth - contentWidth
            nameWidth.constant = baseNameWidth + extraSpace
        } else {
            nameWidth.constant = baseNameWidth
        }
        view.layoutIfNeeded()
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
//        let classId   = payload["class_id"] as? String ?? ""
        let sectionId = payload["section_id"] as? String ?? ""
        let examId    = payload["exam_id"] as? String ?? ""
        let academicYearId    = payload["academic_year_id"] as? String ?? ""
        self.sectionId = sectionId
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
            "section_id": sectionId,
            "exam_id": examId,
            "selected_activities": resultSubjects,
            "academic_year_id" : academicYearId
        ]
    }
    
    private func setupHeaderCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        headerCollectionview.collectionViewLayout = layout
        headerCollectionview.dataSource = self
        headerCollectionview.delegate = self
        headerCollectionview.register(UINib(nibName: "MarkReviewCVC", bundle: nil), forCellWithReuseIdentifier: "MarkReviewCVC")
        headerCollectionview.showsHorizontalScrollIndicator = false
        headerCollectionview.backgroundColor = .systemGray6
        headerCollectionview.bounces = true
        headerCollectionview.alwaysBounceHorizontal = true
    }
    
    private func setupTableView() {
        listLableView.dataSource = self
        listLableView.delegate = self
        listLableView.register(UINib(nibName: "MarksTableViewCell", bundle: nil), forCellReuseIdentifier: "MarksTableViewCell")
    }
    
    // MARK: - Sync All Collection Views
    func syncAllCollectionViews(to offset: CGFloat, excluding scrollView: UIScrollView? = nil) {
        guard !isSyncing else { return }
        isSyncing = true
        if scrollView != headerCollectionview {
            headerCollectionview.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        }
        for cell in listLableView.visibleCells {
            if let marksCell = cell as? MarksTableViewCell {
                if scrollView != marksCell.marksCollectionView {
                    marksCell.syncScroll(to: offset)
                }
            }
        }
        
        isSyncing = false
    }
    
    @IBAction func saveAllMarks(_ sender: UIButton) {
        if sender.tag == 1 {
            let emptyStudentCount = studentRecords.filter { student in
                (student.marks ?? []).contains { subject in
                    (subject.activities ?? []).contains {
                        ($0.mark ?? "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                    }
                }
            }.count

            if emptyStudentCount > 0 {
                CustomAlert().showAlert(
                    title:"",
                    message:AlertstringFile.fillAllMarksBeforePublish.translated(),
                    on: self
                )
                return
            }
        }
        if uploadTest{
                CustomAlert().showAlertCancel(
                    title: AlertstringFile.Confirm.translated(),
                    message:sender.tag == 1 ? AlertstringFile.publishMark.translated(): AlertstringFile.uploadMark.translated(),
                    actionLbl1: sender.tag == 1 ? AlertstringFile.puplish.translated(): AlertstringFile.save.translated(),
                    actionLbl2: AlertstringFile.Cancel.translated(),
                    on: self,
                    onOk: {

                        print("OK button clicked")

                        self.showActivityLoader()

                        self.viewModel?.createSaveRequest(
                            studentRecords: self.studentRecords, isPublished: sender.tag == 1
                        ) { [weak self] result in

                            print("createSaveRequest called")

                            guard let self = self else { return }

                            DispatchQueue.main.async {
                                self.hideActivityLoader()

                                switch result {

                                case .success(let response):
                                    CustomAlert.showAlertWithOkAction(
                                        title: response.status ? AlertstringFile.Success : AlertstringFile.Alert_title,
                                        message: response.message,
                                        on: self
                                    ) {
                                        self.dismiss(animated: true)
                                    }

                                case .failure(let error):
                                    CustomAlert.showAlertWithOkAction(
                                        title: AlertstringFile.Alert_title,
                                        message: "Failed to upload marks. Please try again.",
                                        on: self
                                    ) { }
                                }
                            }
                        }
                    },
                    onNo: {
                        print("Cancelled")
                    }
                )
        }else{
            
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
                        let activityKey = "\(subjectId)_\(activityId)"
                        let editedActivityMark = editedMarks[rollNo]?[activityKey]

                        var rubricsArray: [[String: Any]] = []

                        if let rubrics = activity.rubrics, !rubrics.isEmpty {
                            for rubric in rubrics {
                                let rubricId = rubric.id ?? ""
                                let rubricKey = "RU:\(activityId)_\(rubricId)"
                                let editedRubricMark = editedMarks[rollNo]?[rubricKey]

                                let finalRubricMarkStr = editedRubricMark ?? rubric.mark ?? ""
                                let maxRubricMarkStr = rubric.max_mark ?? ""

                                let finalRubricMark = Double(finalRubricMarkStr) ?? 0
                                let maxRubricMark = Double(maxRubricMarkStr) ?? 0

                                if finalRubricMark > maxRubricMark {
                                    invalidMarkCount += 1
                                }

                                rubricsArray.append([
                                    "id": rubricId,
                                    "mark": finalRubricMarkStr,
                                    "max_mark": maxRubricMarkStr
                                ])
                            }
                        }

                        let finalMarkStr = editedActivityMark ?? activity.mark ?? ""
                        let maxMarkStr = activity.max_mark ?? ""

                        if rubricsArray.isEmpty {
                            let finalMark = Double(finalMarkStr) ?? 0
                            let maxMark = Double(maxMarkStr) ?? 0
                            if finalMark > maxMark {
                                invalidMarkCount += 1
                            }
                        }

                        activitiesArray.append([
                            "id": activityId,
                            "mark": finalMarkStr,
                            "max_mark": maxMarkStr,
                            "rubrics": rubricsArray
                        ])
                    }

                    studentMarks.append([
                        "subject_id": subjectId,
                        "activities": activitiesArray
                    ])
                }

                uploadDetails.append([
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

            let finalPayload: [String: Any] = [
                "exam_id": examId ?? "",
                "section_id": sectionId ?? "",
                "upload_details": uploadDetails
            ]

            // 🖨️ print exactly what will be sent
            print("📤 Final Upload Payload:")
            if let jsonData = try? JSONSerialization.data(withJSONObject: finalPayload, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }

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
    }
    
    func sendMarksToAPI(with parameters: [String: Any]) {
        guard !isSyncing else {
            print("⚠️ Already syncing")
            return
        }
        isSyncing = true
        saveMarksBtn.isEnabled = false
        
        let loadingAlert = UIAlertController(title: "Saving Marks", message: "Please wait...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        APIService.shared.makeApi(url: ServiceUrl.exam_api_exam_upload_marks, parameters: parameters, type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true) { [weak self] (result: Result<Send_AttachmentResponse, Error>) in
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
    
}
// MARK: - Utility Extensions
extension EnterMarkVC {
    
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
        guard !map.isEmpty else {
            errorDeclarationLbl.isHidden = true
            return "No issues found.".translated()
        }
        errorDeclarationLbl.isHidden = false
        let total = map.values.reduce(0,+)
        
        let details = map
            .sorted { $0.key < $1.key }
            .map { "\($0.value) \($0.key)" }
            .joined(separator: ", ")
        
        return "Found \(total) issue(s): " + details.translated()
    }
}
// MARK: - Header CollectionView DataSource & Delegate
extension EnterMarkVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return headerColumns.count   // 👈 grouped count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MarkReviewCVC", for: indexPath
        ) as! MarkReviewCVC

        let header = headerColumns[indexPath.item]

        cell.configure(
            title: header.displayName ?? "",
            subtitle: header.subjectName?.uppercased() ?? "",
            max_Mark: "Max: \(header.maxMarks ?? 0)",
            rubrics: header.rubrics
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let header = headerColumns[indexPath.item]
        let width = headerColumnWidth(for: header)
        return CGSize(width: width, height: subjectHeight.constant)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == headerCollectionview {
            syncAllCollectionViews(to: scrollView.contentOffset.x, excluding: scrollView)
        }
    }
}


// MARK: - TableView DataSource & Delegate
extension EnterMarkVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MarksTableViewCell", for: indexPath) as? MarksTableViewCell else {
            return UITableViewCell()
        }
        
        let student = studentRecords[indexPath.row]
        cell.configure(student: student, index: indexPath.row, parentVC: self, nameWidth: nameWidth.constant)
        cell.delegate = self
        cell.syncScroll(to: headerCollectionview.contentOffset.x)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let student = studentRecords[indexPath.row]
        let name = student.student_name ?? ""
        let rollNo = student.roll_no ?? ""
        
        let nameFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let rollFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        let labelWidth: CGFloat = nameWidth.constant - 32
        
        let nameHeight = textHeight(text: name, font: nameFont, width: labelWidth)
        let rollHeight = textHeight(text: "Roll No: \(rollNo)", font: rollFont, width: labelWidth)
        
        let totalHeight = nameHeight + rollHeight + 24
        
        return max(totalHeight, 74)
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
}

extension EnterMarkVC {
    func updateMark(row: Int, column: Int, value: String, reson: String, subjectName: String) {
        guard row < studentRecords.count, column < subjectColumns.count else { return }

        let col = subjectColumns[column]
        let rollNo = studentRecords[row].roll_no ?? ""
        let trimmed = value.trimmingCharacters(in: .whitespaces)

        var hasError = false
        if let entered = Int(trimmed) { hasError = entered > (col.maxMarks ?? 0) }

        let key = makeMarkKey(col: col)
        if editedMarks[rollNo] == nil { editedMarks[rollNo] = [:] }
        editedMarks[rollNo]?[key] = trimmed

        for s in 0..<(studentRecords[row].marks?.count ?? 0) {
            let currentSubject = studentRecords[row].marks?[s].subject_name ?? ""
            guard normalizeName(currentSubject) == normalizeName(subjectName) else { continue }

            for a in 0..<(studentRecords[row].marks?[s].activities?.count ?? 0) {
                guard studentRecords[row].marks?[s].activities?[a].id == col.activityId else { continue }

                if col.isRubric, let rubricId = col.rubricId {
                    guard var rubrics = studentRecords[row].marks?[s].activities?[a].rubrics,
                          let rIndex = rubrics.firstIndex(where: { $0.id == rubricId }) else { return }

                    let original = rubrics[rIndex].mark ?? ""
                    rubrics[rIndex].mark = trimmed
                    rubrics[rIndex].isReview = hasError
                    rubrics[rIndex].reason = reson
                    studentRecords[row].marks?[s].activities?[a].rubrics = rubrics
                    errorDeclarationLbl.text = "⚠️ \(getFormattedReasonSummary())"

                    if trimmed == original {
                        editedMarks[rollNo]?.removeValue(forKey: key)
                        if editedMarks[rollNo]?.isEmpty == true { editedMarks.removeValue(forKey: rollNo) }
                    }
                    return
                } else {
                    let original = studentRecords[row].marks?[s].activities?[a].mark ?? ""
                    studentRecords[row].marks?[s].activities?[a].mark = trimmed
                    studentRecords[row].marks?[s].activities?[a].isReview = hasError
                    studentRecords[row].marks?[s].activities?[a].reason = reson
                    errorDeclarationLbl.text = "⚠️ \(getFormattedReasonSummary())"

                    if trimmed == original {
                        editedMarks[rollNo]?.removeValue(forKey: key)
                        if editedMarks[rollNo]?.isEmpty == true { editedMarks.removeValue(forKey: rollNo) }
                    }
                    return
                }
            }
        }
    }

    func makeMarkKey(col: ColumnConfig) -> String {
        if col.isRubric, let rubricId = col.rubricId {
            return "RU:\(col.activityId ?? "")_\(rubricId)"
        }
        return "AN:\(col.activityId ?? UUID().uuidString)"
    }
    
}

// Add to EnterMarkVC

extension EnterMarkVC {
    func moveToCell(row: Int, column: Int) {

            guard row >= 0 && row < studentRecords.count,
                  column >= 0 && column < subjectColumns.count else { return }

            isNavigatingCells = true

            let indexPath = IndexPath(row: row, section: 0)
            if !isRowFullyVisible(at: indexPath) {
                listLableView.scrollToRow(at: indexPath, at: .none, animated: false)
                listLableView.layoutIfNeeded()
            }

            guard let cell = listLableView.cellForRow(at: indexPath) as? MarksTableViewCell else {
                isNavigatingCells = false
                return
            }

            let colX = columnX(column)
            let colWidth = getColumnWidth(column: column)

            let visibleStart = cell.marksCollectionView.contentOffset.x
            let visibleWidth = cell.marksCollectionView.bounds.width
            let visibleEnd = visibleStart + visibleWidth
            var newOffsetX = visibleStart

            if colX < visibleStart {
                newOffsetX = colX
            } else if colX + colWidth > visibleEnd {
                newOffsetX = colX + colWidth - visibleWidth
            }

            let maxOffsetX = max(0, cell.marksCollectionView.contentSize.width - visibleWidth)
            newOffsetX = min(max(0, newOffsetX), maxOffsetX)

            let offsetChanged = abs(newOffsetX - visibleStart) > 0.5

            if offsetChanged {
                cell.marksCollectionView.setContentOffset(CGPoint(x: newOffsetX, y: 0), animated: false)
                headerCollectionview.setContentOffset(CGPoint(x: newOffsetX, y: 0), animated: false)
            }

            let itemPath = IndexPath(item: column, section: 0)
            if let marksCell = cell.marksCollectionView.cellForItem(at: itemPath) as? MarksCell {
                marksCell.markTxt.becomeFirstResponder()
                isNavigatingCells = false
            } else {
                cell.marksCollectionView.layoutIfNeeded()
                focusCell(in: cell.marksCollectionView, at: itemPath)
            }
        }

 
        private func isRowFullyVisible(at indexPath: IndexPath) -> Bool {
            guard listLableView.indexPathsForVisibleRows?.contains(indexPath) == true else {
                return false
            }

            let rowRect = listLableView.rectForRow(at: indexPath)
            let visibleTop = listLableView.contentOffset.y + listLableView.contentInset.top
            let visibleBottom = listLableView.contentOffset.y
                + listLableView.bounds.height
                - listLableView.contentInset.bottom

            return rowRect.minY >= visibleTop && rowRect.maxY <= visibleBottom
        }

        private func focusCell(in collectionView: UICollectionView, at itemPath: IndexPath) {
            collectionView.scrollToItem(at: itemPath, at: .centeredHorizontally, animated: false)
            DispatchQueue.main.async {
                collectionView.layoutIfNeeded()
                (collectionView.cellForItem(at: itemPath) as? MarksCell)?.markTxt.becomeFirstResponder()
                self.isNavigatingCells = false
            }
        }
    private func columnX(_ column: Int) -> CGFloat {
        var x: CGFloat = 0
        for i in 0..<column {
            x += getColumnWidth(column: i)
        }
        return x
    }

    func moveToNextRow(row: Int, column: Int) {
        let nextRow = row + 1
        if nextRow < studentRecords.count {
            moveToCell(row: nextRow, column: column)
        } else {
            print("⚠️ Already at last row")
        }
    }

    func moveToPreviousRow(row: Int, column: Int) {
        let prevRow = row - 1
        if prevRow >= 0 {
            moveToCell(row: prevRow, column: column)
        } else {
            print("⚠️ Already at first row")
        }
    }

    func moveToNextColumn(row: Int, column: Int) {
        let nextCol = column + 1
        if nextCol < subjectColumns.count {
            moveToCell(row: row, column: nextCol)
        } else {
            print("⚠️ Already at last column")
        }
    }

    func moveToPreviousColumn(row: Int, column: Int) {
        let prevCol = column - 1
        if prevCol >= 0 {
            moveToCell(row: row, column: prevCol)
        } else {
            print("⚠️ Already at first column")
        }
    }

    private func getColumnWidth(column: Int) -> CGFloat {
        guard column < subjectColumns.count else { return 110 }

        let col = subjectColumns[column]
        var widths: [CGFloat] = []

        if let display = col.displayName {
            let font = UIFont.systemFont(ofSize: 13, weight: .medium)
            widths.append(display.width(usingFont: font))
        }

        if let max = col.maxMarks {
            let font = UIFont.systemFont(ofSize: 12, weight: .regular)
            widths.append("Max: \(max)".width(usingFont: font))
        }

        let padding: CGFloat = 16
        let minWidth: CGFloat = 110
        let maxTextWidth = widths.max() ?? minWidth
        let finalWidth = max(maxTextWidth + padding, minWidth)

        return finalWidth
    }
}
extension EnterMarkVC: UISearchBarDelegate, UIPopoverPresentationControllerDelegate {
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard !isKeyboardVisible else { return }
        isKeyboardVisible = true

        guard let keyboardFrame =
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height - 40

        UIView.animate(withDuration: 0.25) {
            self.listLableView.contentInset.bottom = keyboardHeight
            self.listLableView.scrollIndicatorInsets.bottom = keyboardHeight
        }

        if let indexPath = getActiveTextFieldIndexPath() {
            listLableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard !isNavigatingCells else { return }
        
        isKeyboardVisible = false
        UIView.animate(withDuration: 0.2) {
            self.listLableView.contentInset.bottom = 0
            self.listLableView.scrollIndicatorInsets.bottom = 0
        }
    }
    
    private func getActiveTextFieldIndexPath() -> IndexPath? {
        for cell in listLableView.visibleCells {
            if let marksCell = cell as? MarksTableViewCell,
               let indexPath = listLableView.indexPath(for: marksCell) {
                
                for visibleMarksCell in marksCell.marksCollectionView.visibleCells {
                    if let marksCellItem = visibleMarksCell as? MarksCell,
                       marksCellItem.markTxt.isFirstResponder {
                        return indexPath
                    }
                }
            }
        }
        return nil
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearchAndReload(searchText: searchText)
    }
    
    func applySearchAndReload(searchText: String) {
        guard !searchText.isEmpty else {
            studentRecords = allStudents
            nodataImg.isHidden = true
            nodataLbl.isHidden = true
            listLableView.reloadData()
            return
        }

        let key = searchText.lowercased()

        studentRecords = allStudents.filter {
            ($0.student_name ?? "").lowercased().contains(key) ||
            ($0.roll_no ?? "").lowercased().contains(key) ||
            ($0.admission_no ?? "").lowercased().contains(key)
        }

        if studentRecords.isEmpty {
            nodataImg.isHidden = false
            nodataLbl.isHidden = false
            nodataLbl.text = "No students found for \"\(searchText)\""
            nodataLbl.textAlignment = .center
        } else {
            nodataImg.isHidden = true
            nodataLbl.isHidden = true
        }

        listLableView.reloadData()
    }


    func showPopover(from sender: UIView, contentVC: FilterPopover) {

        let popoverWidth = self.view.frame.width - 40
        let popoverHeight: CGFloat = 170

        contentVC.modalPresentationStyle = .popover
        contentVC.preferredContentSize = CGSize(width: popoverWidth,
                                                height: popoverHeight)

        if let pop = contentVC.popoverPresentationController {
            pop.sourceView = self.view
            pop.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 1,
                height: 1
            )
            pop.permittedArrowDirections = []
            pop.delegate = self
            pop.backgroundColor = .white
        }

        present(contentVC, animated: true)
    }

    // MARK: - Update Popover Size When Stack Added
    func updatePopoverSizeForStackCount(_ stackCount: Int) {
        guard !isUpdatingPopover else { return }
        isUpdatingPopover = true
        
        guard let popoverVC = self.presentedViewController as? FilterPopover else {
            self.isUpdatingPopover = false
            return
        }
        
        popoverVC.loadViewIfNeeded()
        popoverVC.view.layoutIfNeeded()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let rowHeight: CGFloat = 70
            let extraPadding: CGFloat = 50
            let stackHeight = CGFloat(stackCount) * rowHeight + extraPadding
            
            let paddingX: CGFloat = 20
            let width = self.view.frame.width - (paddingX * 2)
            let height = min(stackHeight, self.view.frame.height * 0.85)
            popoverVC.preferredContentSize = CGSize(width: width, height: height)
            if let popover = popoverVC.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(
                    x: (self.view.frame.width - width) / 2,
                    y: (self.view.frame.height - height) / 2,
                    width: width,
                    height: height
                )
            }
            
            self.isUpdatingPopover = false
        }
    }

    // MARK: - Popover Presentation Delegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
   }
extension EnterMarkVC {
    
    func applyFiltersToStudents(_ filters: [(type: String, sortValue: String)]) {
        // Start with base student records
        var sortedRecords = studentRecords
        for filter in filters.reversed() {
            sortedRecords = sortStudentsBy(
                filter.type,
                sortOrder: filter.sortValue,
                students: sortedRecords
            )
        }
        
        studentRecords = sortedRecords
        listLableView.reloadData()
    }
    
    private func sortStudentsBy(_ filterType: String,
                                sortOrder: String,
                                students: [StudentMark]) -> [StudentMark] {

        let isAscending = sortOrder == "Ascending"

        switch filterType {

        case "Student Name":
            return students.sorted {
                let n1 = $0.student_name ?? ""
                let n2 = $1.student_name ?? ""
                return isAscending ? n1 < n2 : n1 > n2
            }

        case "Roll Number":
            return students.sorted {
                let r1 = $0.roll_no ?? ""
                let r2 = $1.roll_no ?? ""

                if let i1 = Int(r1), let i2 = Int(r2) {
                    return isAscending ? i1 < i2 : i1 > i2
                }
                return isAscending ? r1 < r2 : r1 > r2
            }

        case "Admission Number":
            return students.sorted {
                let a1 = $0.admission_no ?? ""
                let a2 = $1.admission_no ?? ""

                if let i1 = Int(a1), let i2 = Int(a2) {
                    return isAscending ? i1 < i2 : i1 > i2
                }
                return isAscending ? a1 < a2 : a1 > a2
            }

        case "Gender":
            return students.sorted {
                func normalizeGender(_ gender: String?) -> String {
                    guard let gender = gender, !gender.isEmpty else { return "" }
                    return gender.prefix(1).uppercased() + gender.dropFirst().lowercased()
                }

                let g1 = normalizeGender($0.gender)
                let g2 = normalizeGender($1.gender)

                switch sortOrder.lowercased() {
                case "male":
                    return g1 == "Male"
                case "female":
                    return g1 == "Female"
                case "others":
                    return g1 == "Others"
                default:
                    return true
                }
            }

        default:
            return students
        }
    }
    
}

// MARK: - Update FilterPopoverDelegate in EnterMarkVC
extension EnterMarkVC: FilterPopoverDelegate {
    func didApplyFilters(_ filters: [(type: String, sortValue: String)]) {
        selectedFilters = filters
        if filters.isEmpty{
            studentRecords = allStudents
            listLableView.reloadData()
        }
        applyFiltersToStudents(filters)
        dismiss(animated: true)
    }
}
struct HeaderColumnConfig: Codable {
    let displayName: String?
    let subjectName: String?
    let subjectId: String?
    let activityId: String?
    let activityName: String?
    let maxMarks: Int?
    var rubrics: [RubricMark]?
}
struct RubricMark: Codable {
    let id: String?
    let name: String?
    let max_mark: String?
    let subjectName: String?
    let displayName: String?
}
struct ColumnConfig: Codable {
    let displayName: String?
    let subjectName: String?
    let subjectId: String?
    let activityId: String?
    let activityName: String?
    let maxMarks: Int?
    let isRubric: Bool
    let rubricId: String?
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
    let gender: String?
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
    let is_edit: Bool?
    var selected_name: String?
    var change_mark: String?
    var isReview: Bool?
    var reason: String?
    var rubrics: [RubricActivityMark]?
}

struct RubricActivityMark: Codable {
    let id: String?
    let name: String?
    var mark: String?
    let max_mark: String?
    let is_edit: Bool?
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
extension EnterMarkVC {

    private static let minRubricWidth: CGFloat = 110
    private static let minActivityWidth: CGFloat = 110
    private static let maxColumnWidth: CGFloat = 120
    private static let padding: CGFloat = 16

    func columnWidth(for column: ColumnConfig) -> CGFloat {
        let headerFont = UIFont.systemFont(ofSize: 13, weight: .medium)
        let maxFont = UIFont.systemFont(ofSize: 12, weight: .regular)

        var widths: [CGFloat] = []
        if let display = column.displayName {
            widths.append(display.width(usingFont: headerFont))
        }
        if let max = column.maxMarks {
            widths.append("Max: \(max)".width(usingFont: maxFont))
        }

        let minWidth = column.isRubric ? Self.minRubricWidth : Self.minActivityWidth
        let maxTextWidth = widths.max() ?? minWidth
        return min(max(maxTextWidth + Self.padding, minWidth), Self.maxColumnWidth)
    }

    func headerColumnWidth(for header: HeaderColumnConfig) -> CGFloat {
        let leaves = subjectColumns.filter {
            $0.subjectId == header.subjectId && $0.activityId == header.activityId
        }
        guard !leaves.isEmpty else { return Self.minActivityWidth }
        return leaves.reduce(0) { $0 + columnWidth(for: $1) }
    }

    func leafWidths(for header: HeaderColumnConfig) -> [CGFloat] {
        subjectColumns
            .filter { $0.subjectId == header.subjectId && $0.activityId == header.activityId }
            .map { columnWidth(for: $0) }
    }
    private func calculateHeaderHeight() -> CGFloat {
        let headerFont  = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let subjectFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        var maxHeight: CGFloat = 70
        for header in headerColumns {
            let hasRubrics = header.rubrics?.isEmpty == false
            let topHeight = headerFont.lineHeight + subjectFont.lineHeight
            let bottomHeight: CGFloat = hasRubrics ? (headerFont.lineHeight * 2 + subjectFont.lineHeight) : subjectFont.lineHeight
            maxHeight = max(maxHeight, topHeight + bottomHeight + 24)
        }
        return maxHeight
    }
}

