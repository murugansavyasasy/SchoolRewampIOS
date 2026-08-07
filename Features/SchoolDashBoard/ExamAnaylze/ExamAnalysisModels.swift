import Foundation

// MARK: - Standard API Response Models
public struct ExamAnaliseStandardResponse: Decodable {
    public let status: Bool
    public let message: String
    public let data: [ExameAnaliseStandard]
}

public struct ExameAnaliseStandard: Decodable {
    public let id: String
    public let name: String
    public let sections: [ExameAnaliseSection]
}

public struct ExameAnaliseSection: Decodable {
    public let id: String
    public let name: String
}

// MARK: - Student API Response Models
public struct StudentResponse: Decodable {
    public let status: Bool
    public let message: String
    public let data: [Student]
}

public struct Student: Decodable {
    public let id: String
    public let name: String
    public let admissionNo: String
    public let rollNo: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case admissionNo = "admission_no"
        case rollNo = "roll_no"
    }
}

// MARK: - Exam API Response Models
public struct ExamResponse: Decodable {
    public let status: Bool
    public let message: String
    public let data: [Exam]
}

public struct Exam: Decodable {
    public let id: String
    public let label: String
    public let type: String
    public let conductedOn: String
    public let standardId: String
}
