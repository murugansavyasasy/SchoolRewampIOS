//
//  Models.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import Foundation

struct ClassTestResponse: Codable {
    let status: Bool
    let message: String
    let data: [ClassTest]
}

struct ClassTest: Codable {
    let classTestId: String
    let examName: String
    let subjects: [TestsSubject]
    
    enum CodingKeys: String, CodingKey {
        case classTestId = "class_test_id"
        case examName = "exam_name"
        case subjects
    }
}

struct TestsSubject: Codable {
    let subjectId: String
    let subjectName: String
    let activities: [Activity]
    
    enum CodingKeys: String, CodingKey {
        case subjectId = "subject_id"
        case subjectName = "subject_name"
        case activities
    }
}

struct Activity: Codable {
    let classTestSubjectId: String
    let examDate: String
    let session: String
    let activityName: String
    let maxMark: String
    let minMark: String
    let syllabus: String
    
    enum CodingKeys: String, CodingKey {
        case classTestSubjectId = "class_test_subject_id"
        case examDate = "exam_date"
        case session, syllabus
        case activityName = "activity_name"
        case maxMark = "max_mark"
        case minMark = "min_mark"
    }
}
