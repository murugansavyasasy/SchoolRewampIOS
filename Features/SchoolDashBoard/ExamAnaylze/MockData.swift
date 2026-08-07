import Foundation

public struct MockData {
    public static let standardJSON = """
    {
      "status": true,
      "message": "Standards Fetched Successfully!",
      "data": [
        {
          "id": "2231",
          "name": "Class 6",
          "sections": [
            {
              "id": "8945",
              "name": "A"
            }
          ]
        },
        {
          "id": "2232",
          "name": "Class 7",
          "sections": [
            {
              "id": "8946",
              "name": "B"
            }
          ]
        }
      ]
    }
    """

    public static let studentJSON = """
    {
      "status": true,
      "message": "Student Details Fetched Successfully!",
      "data": [
        {
          "id": "9363519",
          "name": "JEEVA",
          "admission_no": "VS-262",
          "roll_no": ""
        },
        {
          "id": "9423858",
          "name": "RAJPUT SINGH",
          "admission_no": "PRE00040",
          "roll_no": "5"
        },
        {
          "id": "9423859",
          "name": "M. Adhi Vignesh",
          "admission_no": "VS-601",
          "roll_no": "1"
        },
        {
          "id": "9423860",
          "name": "P. Kavitha",
          "admission_no": "VS-602",
          "roll_no": "2"
        },
        {
          "id": "9423861",
          "name": "R. Suresh Kumar",
          "admission_no": "VS-603",
          "roll_no": "3"
        },
        {
          "id": "9423862",
          "name": "S. Meenakshi",
          "admission_no": "VS-604",
          "roll_no": "4"
        }
      ]
    }
    """

    public static let examJSON = """
    {
      "status": true,
      "message": "Student Details Fetched Successfully!",
      "data": [
        {
          "id": "drt1",
          "label": "DRT - 1",
          "type": "DRT",
          "conductedOn": "2025-07-10",
          "standardId": "s6a"
        },
        {
          "id": "drt2",
          "label": "DRT - 2",
          "type": "DRT",
          "conductedOn": "2025-07-10",
          "standardId": "s6a"
        },
        {
          "id": "drt3",
          "label": "DRT - 3",
          "type": "DRT",
          "conductedOn": "2025-07-10",
          "standardId": "s6a"
        },
        {
          "id": "drt4",
          "label": "DRT - 4",
          "type": "DRT",
          "conductedOn": "2025-07-10",
          "standardId": "s6a"
        },
        {
          "id": "drt5",
          "label": "DRT - 5",
          "type": "DRT",
          "conductedOn": "2025-07-10",
          "standardId": "s6a"
        }
      ]
    }
    """
    
    public static func loadStandards() -> [ExameAnaliseStandard] {
        guard let data = standardJSON.data(using: .utf8) else { return [] }
        do {
            let response = try JSONDecoder().decode(ExamAnaliseStandardResponse.self, from: data)
            return response.data
        } catch {
            print("Failed to decode standards:", error)
            return []
        }
    }
    
    public static func loadStudents() -> [Student] {
        guard let data = studentJSON.data(using: .utf8) else { return [] }
        do {
            let response = try JSONDecoder().decode(StudentResponse.self, from: data)
            return response.data
        } catch {
            print("Failed to decode students:", error)
            return []
        }
    }
    
    public static func loadExams() -> [Exam] {
        guard let data = examJSON.data(using: .utf8) else { return [] }
        do {
            let response = try JSONDecoder().decode(ExamResponse.self, from: data)
            return response.data
        } catch {
            print("Failed to decode exams:", error)
            return []
        }
    }
}
