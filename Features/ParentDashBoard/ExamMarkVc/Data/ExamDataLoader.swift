import Foundation

//public struct ExamDataLoader {
//    public static let sampleJSON = """
//    {
//      "status": "SUCCESS",
//      "message": "AVAILABLE_EXAMS_RETRIEVED",
//      "data": [
//        {
//          "exam_id": 1,
//          "exam_name": "Term 1 Final Examination",
//          "subjects": [
//            {
//              "subject_id": 101,
//              "subject_name": "Science",
//              "activities": [
//                {
//                  "activity_id": 501,
//                  "activity_name": "Lab Work",
//                  "scheduling_details": {
//                    "date": "2026-03-14",
//                    "start_time": "09:00 AM",
//                    "end_time": "12:00 PM",
//                    "session": "Morning",
//                    "venue": "Hall 10",
//                    "syllabus": "Chapter 1-5"
//                  },
//                  "rubrics": []
//                },
//                {
//                  "activity_id": 502,
//                  "activity_name": "Theory Examination",
//                  "scheduling_details": {
//                    "date": "",
//                    "start_time": "",
//                    "end_time": "",
//                    "session": "",
//                    "venue": "",
//                    "syllabus": ""
//                  },
//                  "rubrics": [
//                    {
//                      "rubric_id": 901,
//                      "rubric_name": "Botany Practical",
//                      "scheduling_details": {
//                        "date": "2026-03-15",
//                        "start_time": "10:00 AM",
//                        "end_time": "11:30 AM",
//                        "session": "Morning",
//                        "venue": "Science Lab",
//                        "syllabus": "Plants"
//                      }
//                    },
//                    {
//                      "rubric_id": 902,
//                      "rubric_name": "Microscope Setup",
//                      "scheduling_details": {
//                        "date": "2026-03-15",
//                        "start_time": "12:00 PM",
//                        "end_time": "01:00 PM",
//                        "session": "Afternoon",
//                        "venue": "Science Lab",
//                        "syllabus": "Cells"
//                      }
//                    }
//                  ]
//                },
//                    {
//                      "activity_id": 502,
//                      "activity_name": "Theory Examination",
//                      "scheduling_details": {
//                        "date": "",
//                        "start_time": "",
//                        "end_time": "",
//                        "session": "",
//                        "venue": "",
//                        "syllabus": ""
//                      },
//                      "rubrics": [
//                        {
//                          "rubric_id": 901,
//                          "rubric_name": "Botany Practical",
//                          "scheduling_details": {
//                            "date": "2026-03-15",
//                            "start_time": "10:00 AM",
//                            "end_time": "11:30 AM",
//                            "session": "Morning",
//                            "venue": "Science Lab",
//                            "syllabus": "Plants"
//                          }
//                        },
//                        {
//                          "rubric_id": 902,
//                          "rubric_name": "Microscope Setup",
//                          "scheduling_details": {
//                            "date": "2026-03-15",
//                            "start_time": "12:00 PM",
//                            "end_time": "01:00 PM",
//                            "session": "Afternoon",
//                            "venue": "Science Lab",
//                            "syllabus": "Cells"
//                          }
//                        }
//                      ]
//                    },
//    
//                    {
//                      "activity_id": 501,
//                      "activity_name": "Lab Work",
//                      "scheduling_details": {
//                        "date": "2026-03-14",
//                        "start_time": "09:00 AM",
//                        "end_time": "12:00 PM",
//                        "session": "Morning",
//                        "venue": "Hall 10",
//                        "syllabus": "Chapter 1-5"
//                      },
//                      "rubrics": []
//                    }
//              ]
//            },
//            {
//              "subject_id": 102,
//              "subject_name": "Mathematics",
//              "activities": [
//                {
//                  "activity_id": 503,
//                  "activity_name": "Written Test",
//                  "scheduling_details": {
//                    "date": "2026-03-16",
//                    "start_time": "09:30 AM",
//                    "end_time": "12:30 PM",
//                    "session": "Morning",
//                    "venue": "Room 201",
//                    "syllabus": "Algebra & Geometry"
//                  },
//                  "rubrics": []
//                }
//              ]
//            }
//          ]
//        },
//        {
//          "exam_id": 2,
//          "exam_name": "Term 2 Final Examination",
//          "subjects": [
//            {
//              "subject_id": 201,
//              "subject_name": "English",
//              "activities": [
//                {
//                  "activity_id": 601,
//                  "activity_name": "Essay Writing",
//                  "scheduling_details": {
//                    "date": "2026-04-10",
//                    "start_time": "09:00 AM",
//                    "end_time": "11:00 AM",
//                    "session": "Morning",
//                    "venue": "Hall A",
//                    "syllabus": "Grammar & Essay"
//                  },
//                  "rubrics": []
//                },
//                {
//                  "activity_id": 602,
//                  "activity_name": "Oral Assessment",
//                  "scheduling_details": {
//                    "date": "",
//                    "start_time": "",
//                    "end_time": "",
//                    "session": "",
//                    "venue": "",
//                    "syllabus": ""
//                  },
//                  "rubrics": [
//                    {
//                      "rubric_id": 903,
//                      "rubric_name": "Pronunciation",
//                      "scheduling_details": {
//                        "date": "2026-04-11",
//                        "start_time": "10:00 AM",
//                        "end_time": "10:30 AM",
//                        "session": "Morning",
//                        "venue": "Language Lab",
//                        "syllabus": "Reading Skills"
//                      }
//                    },
//                    {
//                      "rubric_id": 904,
//                      "rubric_name": "Communication Skills",
//                      "scheduling_details": {
//                        "date": "2026-04-11",
//                        "start_time": "10:30 AM",
//                        "end_time": "11:00 AM",
//                        "session": "Morning",
//                        "venue": "Language Lab",
//                        "syllabus": "Conversation"
//                      }
//                    }
//                  ]
//                }
//              ]
//            },
//            {
//              "subject_id": 202,
//              "subject_name": "Computer Science",
//              "activities": [
//                {
//                  "activity_id": 603,
//                  "activity_name": "Programming Practical",
//                  "scheduling_details": {
//                    "date": "2026-04-12",
//                    "start_time": "02:00 PM",
//                    "end_time": "05:00 PM",
//                    "session": "Afternoon",
//                    "venue": "Computer Lab",
//                    "syllabus": "Swift Programming"
//                  },
//                  "rubrics": []
//                }
//              ]
//            }
//          ]
//        }
//      ]
//    }
//    """
//    
//    public static func loadSampleData() -> NewExamResponseSuc? {
//        guard let data = sampleJSON.data(using: .utf8) else { return nil }
//        return try? JSONDecoder().decode(NewExamResponseSuc.self, from: data)
//    }
//}
