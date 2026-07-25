import Foundation

// MARK: - Response

class NewExamResponseSuc: Codable {
    let status: Bool?
    let message: String?
    let data: [NewExam]?
}

// MARK: - Exam

class NewExam: Codable {
    
    let examId: String?
    let examName: String?
    let subjects: [NewSubject]?
    
    enum CodingKeys: String, CodingKey {
        case examId = "exam_id"
        case examName = "exam_name"
        case subjects
    }
}

// MARK: - Subject

class NewSubject: Codable {
    
    let subjectId: String?
    let subjectName: String?
    let total_mark: String?
    let activities: [NewActivity]?
    
    enum CodingKeys: String, CodingKey {
        case subjectId = "subject_id"
        case subjectName = "subject_name"
        case total_mark = "total_mark"
        case activities
    }
}

// MARK: - Activity

class NewActivity: Codable {
    
    let activityId: String?
    let activityName: String?
    let max_mark: String?
    let pass_mark: String?
    let schedulingDetails: SchedulingDetails?
    let rubrics: [Rubric]?
    
    enum CodingKeys: String, CodingKey {
        case activityId = "activity_id"
        case activityName = "activity_name"
        case schedulingDetails = "scheduling_details"
        case max_mark = "max_mark"
        case pass_mark = "pass_mark"
        case rubrics
    }
    
    var hasSchedulingDetails: Bool {
        guard let details = schedulingDetails else {
            return false
        }
        
        return details.date != nil ||
               details.startTime != nil ||
               details.venue != nil ||
               details.syllabus != nil
    }
}

// MARK: - Rubric

class Rubric: Codable {
    
    let rubricId: String?
    let rubricName: String?
    let max_mark: String?
    let pass_mark: String?
    let schedulingDetails: SchedulingDetails?
    
    enum CodingKeys: String, CodingKey {
        case rubricId = "rubric_id"
        case rubricName = "rubric_name"
        case schedulingDetails = "scheduling_details"
        case max_mark = "max_mark"
        case pass_mark = "pass_mark"
    }
}

// MARK: - Scheduling Details

class SchedulingDetails: Codable {
    
    let date: String?
    let startTime: String?
    let endTime: String?
    let session: String?
    let venue: String?
    let syllabus: String?
    enum CodingKeys: String, CodingKey {
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case session
        case venue
        case syllabus
    }
    
    var formattedTimeRange: String? {
        guard let start = startTime, !start.isEmpty else {
            return nil
        }
        
        if let end = endTime, !end.isEmpty {
            return "\(start) - \(end)"
        }
        
        return start
    }
    
    var formattedDate: String? {
        guard let rawDate = date, !rawDate.isEmpty else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let parsedDate = formatter.date(from: rawDate) {
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: parsedDate)
        }
        
        return rawDate
    }
}
