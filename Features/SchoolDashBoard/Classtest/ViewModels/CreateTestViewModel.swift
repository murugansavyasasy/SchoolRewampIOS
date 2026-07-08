import Foundation

public final class CreateTestViewModel {
    
    // MARK: - Properties
    public private(set) var currentStep: Int = 1 {
        didSet {
            onStepChanged?(currentStep)
        }
    }
    var studentRecords: [StudentMark] = []
    public private(set) var standards: [TestStandard] = []
    public private(set) var sectionSubjects: [TestSectionSubjects] = []
    public private(set) var examConfigurations: [SubjectExamConfig] = []
    public private(set) var selectedSubjects: Set<String> = [] {
        didSet {
            onSelectionChanged?()
        }
    }
    public var selectedStandard: TestStandard? {
        didSet {
            selectedSections.removeAll()
            selectedSubjects.removeAll()
            examConfigurations.removeAll()
            onSelectionChanged?()
        }
    }
    
    public private(set) var selectedSections: Set<String> = [] {
        didSet {
            let selectedSectionString = selectedSections.sorted().joined(separator: ",")
            print(selectedSectionString) // "1,2"
            
            selectedSubjects.removeAll()
            examConfigurations.removeAll()
            onSelectionChanged?()
        }
    }
    
    // MARK: - Callbacks
    public var onDataLoaded: (() -> Void)?
    public var onStepChanged: ((Int) -> Void)?
    public var onSelectionChanged: (() -> Void)?
    public var exameName = ""
    var class_test_id:String?
    var section_id:String?
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Logic
    public func getStandardsAPI(academic_year_id:Int) {
        
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [COMMON_PARAMETER.academic_year_id : academic_year_id], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false) { [self] (result:Result <TestStandardResponse,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        self.standards = successMessage.data
                        // Auto-select standard I for demo/testing convenience
                        if !self.standards.isEmpty {
                            self.selectedStandard = self.standards[0]
                        }
                        onDataLoaded?()
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    print(error.localizedDescription)
                    
                }
                
            }
        }
    }
    
    
    public func getSubject(){
        
        var selectedSectionIds: String {
            selectedSections.sorted().joined(separator: ",")
        }
        APIService.shared.makeApi(url: ServiceUrl.exam_section_wise_subjects, parameters: ["section_ids" : selectedSectionIds], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false) { [self] (result:Result <TestSubjectsResponse,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        self.sectionSubjects = successMessage.data
                        onDataLoaded?()
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    print(error.localizedDescription)
                    
                }
                
            }
        }
    }
    
    
    public func selectStandard(_ standard: TestStandard) {
        self.selectedStandard = standard
    }
    
    public func toggleSection(_ section: TestSection) {
        if selectedSections.contains(section.id) {
            selectedSections.remove(section.id)
        } else {
            selectedSections.insert(section.id)
        }
    }
    
    public func isSectionSelected(_ section: TestSection) -> Bool {
        return selectedSections.contains(section.id)
    }
    
    public func nextStep() -> Bool {
        if currentStep == 1 && selectedStandard == nil {
            return false // Must select standard first
        }
        if currentStep == 2 && selectedSections.isEmpty {
            return false // Must select at least one section
        }
        if currentStep == 3 && selectedSubjects.isEmpty {
            return false // Must select at least one subject
        }
        if currentStep == 4 && (examConfigurations.isEmpty || !examConfigurations.allSatisfy { isSubjectConfigured(subjectId: $0.subjectId, sectionId: $0.sectionId) }) {
            return false // Must configure all subjects
        }
        
        if currentStep < 5 {
            currentStep += 1
            return true
        }
        return false
    }
    
    public func previousStep() -> Bool {
        if currentStep > 1 {
            currentStep -= 1
            return true
        }
        return false
    }
    
    // MARK: - Exam Details Setup & Editing
    public func setupExamConfigurationsIfNeeded() {
        let previousConfigs = examConfigurations
        var configs: [SubjectExamConfig] = []
        
        // Find all selected subjects in sectionSubjects
        for sec in sectionSubjects {
            for sub in sec.subjects {
                let key = "\(sec.sectionId)-\(sub.id)"
                if selectedSubjects.contains(key) {
                    if let prev = previousConfigs.first(where: { $0.subjectId == sub.id && $0.sectionId == sec.sectionId }) {
                        configs.append(prev)
                    } else {
                        // Pre-populate with exactly 1 default test configuration details
                        let defaultTest = TestDetails(examName: "", maxMarks: "100", minMarks: "35")
                        configs.append(SubjectExamConfig(subjectId: sub.id, subjectName: sub.name, sectionId: sec.sectionId, sectionName: sec.sectionName, tests: [defaultTest]))
                    }
                }
            }
        }
        self.examConfigurations = configs
    }
    
    public func addTest(to subjectId: String, sectionId: String) {
        guard let idx = examConfigurations.firstIndex(where: { $0.subjectId == subjectId && $0.sectionId == sectionId }) else { return }
        // Create another test with incremental default name "Test X"
        let nextIndex = examConfigurations[idx].tests.count + 1
        examConfigurations[idx].tests.append(TestDetails(examName: "", maxMarks: "100", minMarks: "35"))
        onSelectionChanged?()
    }
    
    public func removeTest(at testIndex: Int, from subjectId: String, sectionId: String) {
        guard let idx = examConfigurations.firstIndex(where: { $0.subjectId == subjectId && $0.sectionId == sectionId }) else { return }
        guard examConfigurations[idx].tests.count > testIndex else { return }
        examConfigurations[idx].tests.remove(at: testIndex)
        onSelectionChanged?()
    }
    
    public func updateTest(_ test: TestDetails, for subjectId: String, sectionId: String, at testIndex: Int) {
        guard let idx = examConfigurations.firstIndex(where: { $0.subjectId == subjectId && $0.sectionId == sectionId }) else { return }
        guard examConfigurations[idx].tests.count > testIndex else { return }
        examConfigurations[idx].tests[testIndex] = test
        onSelectionChanged?()
    }
    
    public func isSubjectConfigured(subjectId: String, sectionId: String) -> Bool {
        guard let config = examConfigurations.first(where: { $0.subjectId == subjectId && $0.sectionId == sectionId }) else { return false }
        return !config.tests.isEmpty && config.tests.allSatisfy { !$0.examName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !$0.syllabus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !$0.testDate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !$0.maxMarks.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !$0.minMarks.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    public func printExamConfigurationsJSON() {
        var requestItems: [ExamRequestItem] = []
        for config in examConfigurations {
            for test in config.tests {
                let maxVal = Int(test.maxMarks.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 100
                let minVal = Int(test.minMarks.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 35
                
                // Format input date "dd/MM/yyyy" to standard "yyyy-MM-dd"
                var formattedDate = test.testDate
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "dd/MM/yyyy"
                if let date = inputFormatter.date(from: test.testDate) {
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "yyyy-MM-dd"
                    formattedDate = outputFormatter.string(from: date)
                }
                
                let item = ExamRequestItem(
                    examName: test.examName,
                    sectionId: config.sectionId,
                    subjectId: config.subjectId,
                    testDate: formattedDate,
                    session: test.session,
                    maxMark: maxVal,
                    minMark: minVal,
                    syllabus: test.syllabus
                )
                requestItems.append(item)
            }
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        do {
            let data = try encoder.encode(requestItems)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("================ EXAM DETAILS JSON REQUEST ================")
                print(jsonString)
                print("==========================================================")
            }
        } catch {
            print("Failed to encode exam configurations to JSON: \(error)")
        }
    }
    
    // MARK: - Subject Merging Helpers
    public func getMergeableConfig(for subjectName: String, currentSectionId: String) -> SubjectExamConfig? {
        guard let currentConfig = examConfigurations.first(where: { $0.subjectName.uppercased() == subjectName.uppercased() && $0.sectionId == currentSectionId }) else {
            return nil
        }
        
        // Find another counterpart config that IS fully configured
        guard let counterpartConfig = examConfigurations.first(where: {
            $0.subjectName.uppercased() == subjectName.uppercased() &&
            $0.sectionId != currentSectionId &&
            isSubjectConfigured(subjectId: $0.subjectId, sectionId: $0.sectionId)
        }) else {
            return nil
        }
        
        let isCurrentConfigured = isSubjectConfigured(subjectId: currentConfig.subjectId, sectionId: currentSectionId)
        
        // Merge is available if:
        // 1. Current config is not configured OR it has fewer tests than the completed counterpart.
        // 2. AND current tests count is less than or equal to counterpart tests count (prevents wrong banners when adding more tests).
        if (!isCurrentConfigured || currentConfig.tests.count < counterpartConfig.tests.count) &&
            currentConfig.tests.count <= counterpartConfig.tests.count {
            return counterpartConfig
        }
        
        return nil
    }
    
    public func mergeConfigurations(from sourceSectionId: String, to targetSectionId: String, subjectName: String) {
        guard let sourceConfig = examConfigurations.first(where: { $0.subjectName.uppercased() == subjectName.uppercased() && $0.sectionId == sourceSectionId }),
              let targetIdx = examConfigurations.firstIndex(where: { $0.subjectName.uppercased() == subjectName.uppercased() && $0.sectionId == targetSectionId }) else {
            return
        }
        self.examConfigurations[targetIdx].tests = sourceConfig.tests
        onSelectionChanged?()
    }
    
    // MARK: - Subject Selection Helpers (Step 3)
    public func toggleSubjectSelection(sectionId: String, subjectId: String) {
        let key = "\(sectionId)-\(subjectId)"
        if selectedSubjects.contains(key) {
            selectedSubjects.remove(key)
        } else {
            selectedSubjects.insert(key)
        }
        onSelectionChanged?()
    }
    
    public func isSubjectSelected(sectionId: String, subjectId: String) -> Bool {
        return selectedSubjects.contains("\(sectionId)-\(subjectId)")
    }
    
    public func selectAllSubjects(in sectionId: String) {
        guard let section = sectionSubjects.first(where: { $0.sectionId == sectionId }) else { return }
        for sub in section.subjects {
            selectedSubjects.insert("\(sectionId)-\(sub.id)")
        }
        onSelectionChanged?()
    }
    
    public func deselectAllSubjects(in sectionId: String) {
        guard let section = sectionSubjects.first(where: { $0.sectionId == sectionId }) else { return }
        for sub in section.subjects {
            selectedSubjects.remove("\(sectionId)-\(sub.id)")
        }
        onSelectionChanged?()
    }
    
    public func selectedSubjectsCount(in sectionId: String) -> Int {
        guard let section = sectionSubjects.first(where: { $0.sectionId == sectionId }) else { return 0 }
        return section.subjects.filter { selectedSubjects.contains("\(sectionId)-\($0.id)") }.count
    }
    
    public func totalSubjectsCount() -> Int {
        // Find selected section names
        let selectedSectionNames = Set(selectedStandard?.sections
            .filter { isSectionSelected($0) }
            .map { $0.name.uppercased() } ?? [])
        
        let activeSections = sectionSubjects.filter {
            selectedSectionNames.contains($0.sectionName.uppercased())
        }
        
        let finalSections = activeSections.isEmpty ? sectionSubjects : activeSections
        return finalSections.reduce(0) { $0 + $1.subjects.count }
    }
    
    
    func getMarkDetails(completion: @escaping (Result<[StudentMark], Error>) -> Void
    ) {
        let params: [String: String] = [
            "class_test_id": class_test_id ?? "",
            "section_id": section_id ?? ""]
        
        APIService.shared.makeApi(
            url: ServiceUrl.exam_test_mark_details,
            parameters: params,
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "",
            isBaseUrl: true
        ) { [weak self] (result: Result<TestMarkDetailsResponse<TestMarkData>, Error>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard let testData = response.data?.first else {
                    completion(.failure(NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No data found"]
                    )))
                    return
                }
                
                let converted = self.mapTestMarkDataToStudentRecords(testData)
                self.studentRecords = converted
                completion(.success(converted))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Mapping function (same as before)
    func mapTestMarkDataToStudentRecords(_ testData: TestMarkData) -> [StudentMark] {
        var studentOrder: [String] = []
        var studentInfoMap: [String: TestMarkStudent] = [:]
        
        for subject in testData.subjects {
            for activity in subject.activities {
                for student in activity.students {
                    if studentInfoMap[student.studentId] == nil {
                        studentInfoMap[student.studentId] = student
                        studentOrder.append(student.studentId)
                    }
                }
            }
        }
        
        var result: [StudentMark] = []
        
        for studentId in studentOrder {
            guard let baseInfo = studentInfoMap[studentId] else { continue }
            
            var subjectMarksArray: [SubjectMarks] = []
            
            for subject in testData.subjects {
                var activityMarksArray: [ActivityMark] = []
                
                for activity in subject.activities {
                    guard let entry = activity.students.first(where: { $0.studentId == studentId }) else {
                        continue
                    }
                    
                    activityMarksArray.append(
                        ActivityMark(
                            id: activity.classTestSubjectId,
                            name: activity.activityName,
                            mark: entry.mark,
                            max_mark: String(Int(Double(activity.maxMark) ?? 0)),
                            is_edit: true,
                            selected_name: activity.activityName,
                            change_mark: nil,
                            isReview: false,
                            reason: entry.remarks.isEmpty ? nil : entry.remarks
                        )
                    )
                }
                
                guard !activityMarksArray.isEmpty else { continue }
                
                subjectMarksArray.append(
                    SubjectMarks(
                        subject_id: subject.subjectId,
                        subject_name: subject.subjectName,
                        activities: activityMarksArray
                    )
                )
            }
            
            result.append(
                StudentMark(
                    student_id: baseInfo.studentId,
                    student_name: baseInfo.studentName,
                    roll_no: baseInfo.rollNo,
                    admission_no: baseInfo.admissionNo,
                    gender: nil,
                    marks: subjectMarksArray
                )
            )
        }
        do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [
                    .prettyPrinted,
                    .sortedKeys
                ]

                let jsonData = try encoder.encode(result)

                if let jsonString = String(
                    data: jsonData,
                    encoding: .utf8
                ) {
                    print(jsonString)
                }

            } catch {
                print(error)
            }
        return result
    }
    func createSaveRequest(
        studentRecords: [StudentMark],
        completion: @escaping (Result<Send_AttachmentResponse, Error>) -> Void
    ){

        var subjectsDict: [String: [String: Any]] = [:]

        for student in studentRecords {

            guard let studentId = student.student_id else {
                continue
            }

            for subject in student.marks ?? [] {

                guard let subjectId = subject.subject_id else {
                    continue
                }

                var subjectData =
                subjectsDict[subjectId] ?? [
                    "subject_id": subjectId,
                    "activities": [[String: Any]]()
                ]

                var activities =
                subjectData["activities"]
                    as? [[String: Any]] ?? []

                // use original model object here
                for activity in subject.activities ?? [] {

                    guard let activityId = activity.id else {
                        continue
                    }

                    let studentData: [String: Any] = [
                        "student_id": studentId,
                        "mark": activity.mark ?? "",
                        "remarks": activity.reason ?? ""
                    ]

                    if let index = activities.firstIndex(
                        where: {
                            ($0["class_test_subject_id"] as? String)
                            == activityId
                        }
                    ) {

                        var existing = activities[index]

                        var students =
                        existing["students"]
                            as? [[String: Any]] ?? []

                        students.append(studentData)

                        existing["students"] = students
                        activities[index] = existing

                    } else {

                        activities.append([
                            "class_test_subject_id": activityId,
                            "students": [studentData]
                        ])
                    }
                }

                subjectData["activities"] = activities
                subjectsDict[subjectId] = subjectData
            }
        }
            
            APIService.shared.makeApi(
                url: ServiceUrl.exam_api_exam_test_upload_marks,
                parameters: [
                    "class_test_id": class_test_id ?? "",
                    "section_id": section_id ?? "",
                    "subjects": Array(subjectsDict.values)
                ],
                type: ApitTypeSringFile.POST,
                token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "",
                isBaseUrl: true
            ) { [weak self] (result: Result<Send_AttachmentResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
