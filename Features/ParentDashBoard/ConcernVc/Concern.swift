import Foundation

enum ConcernStatus: String, Codable {
    case pending = "Pending"
    case acknowledged = "Acknowledged"
    case actiontaken = "Action Taken"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()
        if rawValue.contains("pending") {
            self = .pending
        } else if rawValue.contains("acknowled") {
            self = .acknowledged
        } else {
            self = .actiontaken // Fallback default
        }
    }
}

//struct ConcernAttachment: Codable {
//    let url: String?
//    let type: String?
//    
////    var fileName: String {
////        guard let fileUrl = URL(string: url ?? "") else { return "attachment.png" }
////        return fileUrl.lastPathComponent
////    }
//}

struct Concern: Codable {
    let id: String
    let studentId: String
    let studentName: String
    let className: String
    let sectionName: String
    let typeName: String
    let description: String
    let status: ConcernStatus
    let filePath: [FilePath]
    let actionFilePath: [FilePath]
    let acknowledgedBy: String
    let acknowledgedOn: String
    let actionTaken: String
    let actionTakenBy: String
    let actionTakenOn: String
    let raisedOn: String
    let can_delete: Bool
    let acknowledgement: String
    let is_acknowledged : Bool
    let is_action: Bool
   
    // UI Helpers
    var initials: String {
        let components = studentName.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        if components.count >= 2 {
            let first = components[0].prefix(1).uppercased()
            let last = components[components.count - 1].prefix(1).uppercased()
            return "\(first)\(last)"
        } else if let first = components.first?.prefix(1).uppercased() {
            return String(first)
        }
        return "BM"
    }
    
    var classAndSection: String {
        return "Class \(className)-\(sectionName) · ID: \(studentId)"
    }
    
    var formattedAcknowledgedOn: String {
        return ConcernDateFormatter.formatDateString(acknowledgedOn)
    }
    
    var formattedActionByDate: String {
        // If the action_taken_by looks like a date, we format it. Otherwise we format action_taken_on.
        let cleanActionBy = actionTakenBy.trimmingCharacters(in: .whitespacesAndNewlines)
        if ConcernDateFormatter.isDateString(cleanActionBy) {
            return ConcernDateFormatter.formatDateString(cleanActionBy)
        }
        return ConcernDateFormatter.formatDateString(actionTakenOn)
    }
    
    var formattedActionByName: String {
        // If the action_taken_by contains a date, we show the action_taken name or default.
        let cleanActionBy = actionTakenBy.trimmingCharacters(in: .whitespacesAndNewlines)
        if ConcernDateFormatter.isDateString(cleanActionBy) {
            return actionTaken.trimmingCharacters(in: .whitespacesAndNewlines) == "--" ? "" : actionTaken
        }
        return actionTakenBy
    }
    
    var formattedRaisedOn: String {
        return ConcernDateFormatter.formatDateTimeString(raisedOn)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case studentId = "student_id"
        case studentName = "student_name"
        case className = "class_name"
        case sectionName = "section_name"
        case typeName = "type_name"
        case description
        case status
        case filePath = "file_path"
        case actionFilePath = "action_file_path"
        case acknowledgedBy = "acknowledged_by"
        case acknowledgedOn = "acknowledged_on"
        case actionTaken = "action_taken"
        case actionTakenBy = "action_taken_by"
        case actionTakenOn = "action_taken_on"
        case raisedOn = "raised_on"
        case can_delete = "can_delete"
        case acknowledgement = "acknowledgement"
        case is_acknowledged = "is_acknowledged"
        case is_action = "is_action"
    }
}

struct ConcernResponse: Codable {
    let status: Bool
    let message: String
    let data: [Concern]
}

// Utility to parse various date formats from the API and format them uniformly
class ConcernDateFormatter {
    private static let inputFormatters: [DateFormatter] = {
        let formats = [
            "dd-MM-yyyy HH:mm a",
            "dd-MM-yyyy",
            "dd/MM/yyyy",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        return formats.map { fmt in
            let formatter = DateFormatter()
            formatter.dateFormat = fmt
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
        }
    }()
    
    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd Max yyyy" // Temporary to get 'Aug' format
        // Let's use custom pattern or standard "d MMM yyyy"
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    private static let displayDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    static func isDateString(_ str: String) -> Bool {
        let clean = str.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty || clean == "--" { return false }
        for formatter in inputFormatters {
            if formatter.date(from: clean) != nil {
                return true
            }
        }
        return false
    }
    
    static func formatDateString(_ str: String) -> String {
        let clean = str.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty || clean == "--" { return "--" }
        for formatter in inputFormatters {
            if let date = formatter.date(from: clean) {
                return displayDateFormatter.string(from: date)
            }
        }
        return str // Fallback to raw string
    }
    
    static func formatDateTimeString(_ str: String) -> String {
        let clean = str.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty || clean == "--" { return "--" }
        for formatter in inputFormatters {
            if let date = formatter.date(from: clean) {
                return displayDateTimeFormatter.string(from: date)
            }
        }
        return str // Fallback to raw string
    }
}
