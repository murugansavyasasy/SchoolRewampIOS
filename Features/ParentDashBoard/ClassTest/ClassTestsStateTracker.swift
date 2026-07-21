//
//  ClassTestsStateTracker.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import Foundation

class ClassTestsStateTracker {
    // Tracks expanded exam IDs
    private var expandedExams: Set<String> = []
    
    // Tracks expanded subjects (Key format: "examID_subjectID")
    private var expandedSubjects: Set<String> = []
    
    func isExamExpanded(_ examId: String) -> Bool {
        return expandedExams.contains(examId)
    }
    
    func toggleExam(_ examId: String) {
        if expandedExams.contains(examId) {
            expandedExams.remove(examId)
        } else {
            expandedExams.insert(examId)
        }
    }
    
    func isSubjectExpanded(examId: String, subjectId: String) -> Bool {
        return expandedSubjects.contains("\(examId)_\(subjectId)")
    }
    
    func toggleSubject(examId: String, subjectId: String) {
        let key = "\(examId)_\(subjectId)"
        if expandedSubjects.contains(key) {
            expandedSubjects.remove(key)
        } else {
            expandedSubjects.insert(key)
        }
    }
}
