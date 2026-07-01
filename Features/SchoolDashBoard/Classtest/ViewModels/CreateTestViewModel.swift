import Foundation

public final class CreateTestViewModel {
    
    // MARK: - Properties
    public private(set) var currentStep: Int = 1 {
        didSet {
            onStepChanged?(currentStep)
        }
    }
    
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
            // Reset selected sections and subjects when standard changes
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
}
