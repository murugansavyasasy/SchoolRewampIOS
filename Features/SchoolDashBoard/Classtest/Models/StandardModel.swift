import Foundation

public struct TestStandardResponse: Codable {
    public let status: Bool
    public let message: String
    public let data: [TestStandard]
    
    public init(status: Bool, message: String, data: [TestStandard]) {
        self.status = status
        self.message = message
        self.data = data
    }
}

public struct TestStandard: Codable {
    public let id: String
    public let name: String
    public let sections: [TestSection]
    
    public init(id: String, name: String, sections: [TestSection]) {
        self.id = id
        self.name = name
        self.sections = sections
    }
}

public struct TestSection: Codable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct TestSubjectsResponse: Codable {
    public let status: Bool
    public let message: String
    public let data: [TestSectionSubjects]
    
    public init(status: Bool, message: String, data: [TestSectionSubjects]) {
        self.status = status
        self.message = message
        self.data = data
    }
}

public struct TestSectionSubjects: Codable {
    public let sectionId: String
    public let sectionName: String
    public let subjects: [TestSubject]
    
    enum CodingKeys: String, CodingKey {
        case sectionId = "section_id"
        case sectionName = "section_name"
        case subjects
    }
    
    public init(sectionId: String, sectionName: String, subjects: [TestSubject]) {
        self.sectionId = sectionId
        self.sectionName = sectionName
        self.subjects = subjects
    }
}

public struct TestSubject: Codable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct TestDetails: Codable {
    public var id: UUID
    public var examName: String
    public var testDate: String
    public var session: String // "FN" or "AN"
    public var maxMarks: String
    public var minMarks: String
    public var syllabus: String
    public var activity_name : String
    public init(id: UUID = UUID(), examName: String = "", testDate: String = "", session: String = "FN", maxMarks: String = "100", minMarks: String = "35", syllabus: String = "",activity_name: String = "") {
        self.id = id
        self.examName = examName
        self.testDate = testDate
        self.session = session
        self.maxMarks = maxMarks
        self.minMarks = minMarks
        self.syllabus = syllabus
        self.activity_name = activity_name
    }
}

public struct SubjectExamConfig: Codable {
    public let subjectId: String
    public let subjectName: String
    public let sectionId: String
    public let sectionName: String
    public var tests: [TestDetails]
    
    public init(subjectId: String, subjectName: String, sectionId: String, sectionName: String, tests: [TestDetails] = []) {
        self.subjectId = subjectId
        self.subjectName = subjectName
        self.sectionId = sectionId
        self.sectionName = sectionName
        self.tests = tests
    }
}

public struct ExamRequestItem: Codable {
    public let examName: String
    public let sectionId: String
    public let subjectId: String
    public let testDate: String
    public let session: String
    public let maxMark: Int
    public let minMark: Int
    public let syllabus: String
    
    enum CodingKeys: String, CodingKey {
        case examName = "exam_name"
        case sectionId = "section_id"
        case subjectId = "subject_id"
        case testDate = "test_date"
        case session
        case maxMark = "max_mark"
        case minMark = "min_mark"
        case syllabus
    }
    
    public init(examName: String, sectionId: String, subjectId: String, testDate: String, session: String, maxMark: Int, minMark: Int, syllabus: String) {
        self.examName = examName
        self.sectionId = sectionId
        self.subjectId = subjectId
        self.testDate = testDate
        self.session = session
        self.maxMark = maxMark
        self.minMark = minMark
        self.syllabus = syllabus
    }
}

struct StaffClassTestResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [StaffClassTest]?
}

struct StaffClassTest: Codable {
    var class_test_id: String?
    var exam_name: String?
    var sent_by: String?
    var sent_on: String?
    var sections: [StaffSection]?
}

struct StaffSection: Codable {
    var section_id: String?
    var section_name: String?
    var subjects: [StaffSubject]?
}

struct StaffSubject: Codable {
    var subject_id: String?
    var subject_name: String?
    var activities: [StaffActivity]?
}

struct StaffActivity: Codable {
    var class_test_subject_id: String?
    var exam_date: String?
    var status: String?
    var session: String?
    var activity_name: String?
    var max_mark: String?
    var min_mark: String?
    var syllabus: String?
}

