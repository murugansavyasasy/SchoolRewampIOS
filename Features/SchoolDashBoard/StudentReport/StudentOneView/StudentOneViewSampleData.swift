//
//  StudentOneViewSampleData.swift
//  School Chimes
//
//  Sample responses of the 18 One View APIs (test data from the One View API explorer).
//  Used only when StudentOneViewConfig.useSampleData is true.
//

import Foundation

enum StudentOneViewSampleData {

    static func response(for api: OneViewAPI) -> OneViewResponse? {
        guard let text = json[api], let data = text.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(OneViewResponse.self, from: data)
    }

    private static let json: [OneViewAPI: String] = [
        .profile: #"""
{
 "status": true,
 "message": "Student profile details loaded.",
 "data": [
  {
   "student_id": "100",
   "academic_year_id": "3",
   "is_older_details": "No",
   "student_name": "Arun Kumar",
   "last_name": "",
   "photo_path": "",
   "admission_no": "ADM100",
   "house_or_group": "1",
   "primary_mobile": "",
   "secondary_mobile": "",
   "whatsapp_number": "",
   "email": "",
   "roll_no": "",
   "gender": "Male",
   "student_type": "Old",
   "medium": "",
   "nationality": "",
   "religion": "",
   "caste": "",
   "sub_caste": "",
   "community_certificate_number": "",
   "emis_number": "",
   "student_adhaar_number": "",
   "rte_number": "",
   "sts_number": "",
   "pen_number": "",
   "bhavishya_jyothi_number": "",
   "apl_bpl_card_number": "",
   "school_dise_number": "",
   "income_certificate_number": "",
   "bank_account_number": "",
   "bank_name": "",
   "height": "",
   "weight": "",
   "mark_identification_a": "",
   "mark_identification_b": "",
   "medical_inspection": "",
   "medical_condition": "",
   "physically_challeged": "",
   "vaccination": "",
   "acheivements": "",
   "hobbies": "",
   "remarks": "",
   "father_name": "",
   "father_occupation": "",
   "father_qualification": "",
   "father_annual_income": "",
   "father_adhaar_number": "",
   "mother_name": "",
   "mother_occupation": "",
   "mother_qualification": "",
   "mother_annual_income": "",
   "mother_adhaar_number": "",
   "residental_address": "",
   "residental_city": "",
   "residental_state": "",
   "residental_country": "",
   "residental_pincode": "",
   "school_and_location": "",
   "class_previously": "",
   "year_of_study": "",
   "percentage_or_grade": "",
   "leaving_certificate_no": "",
   "is_bus_student": "Yes",
   "is_hostel_student": "No",
   "class_name": "Grade 5",
   "section_name": "A",
   "dob": "02/04/2015",
   "doj": "",
   "admission_date": "",
   "joining_class_name": "Grade 4",
   "blood_group_name": "O+",
   "community_name": "BC",
   "fee_category_name": "General",
   "house_group_name": "Red House",
   "additional_details": {
    "adhaar_name": "",
    "gr_number": "",
    "student_apaar_no": "",
    "mother_language": "",
    "second_language": "",
    "relation_child": "",
    "father_mobile": "9000000003",
    "father_email_address": "",
    "father_organisation": "",
    "father_office_address": "",
    "father_office_contact_no": "",
    "father_photo": "",
    "mother_mobile": "9000000004",
    "mother_email_address": "",
    "mother_organisation": "",
    "mother_office_address": "",
    "mother_office_contact_no": "",
    "mother_photo": "",
    "guardian_name": "Uncle",
    "guardian_contact": "",
    "guardian_email_address": "",
    "guardian_occupation": "",
    "guardian_office_address": "",
    "guardian_photo": ""
   },
   "sibling_details": [
    {
     "student_name": "Divya Kumar",
     "last_name": "",
     "class_name": "Grade 4",
     "section_name": "B"
    }
   ]
  }
 ]
}
"""#,
        .attendanceWellbeingSummary: #"""
{
 "status": true,
 "message": "Attendance and well-being summary loaded.",
 "data": [
  {
   "positive_behaviour_count": "1",
   "accomplishment_count": "1",
   "negative_incident_count": "1",
   "indisciplinary_activity_count": "1",
   "attendance": {
    "present_percentage": "97.5",
    "absent_percentage": "2.5"
   }
  }
 ]
}
"""#,
        .certificateExamSummary: #"""
{
 "status": true,
 "message": "Certificate and exam summary loaded.",
 "data": [
  {
   "certificate_count": "3",
   "certificates": [
    {
     "certificate_type": "1",
     "certificate_name": "Bonafide",
     "count": "3"
    }
   ],
   "exam_name": "Half Yearly",
   "exam_total": "180"
  }
 ]
}
"""#,
        .feeSummary: #"""
{
 "status": true,
 "message": "Fee summary loaded.",
 "data": [
  {
   "fee": {
    "total_amount": "₹42,000.00",
    "paid_amount": "₹30,000.00",
    "pending_amount": "₹10,500.00",
    "discount_amount": "₹1,500.00",
    "paid_percentage": "71.43",
    "pending_percentage": "25",
    "discount_percentage": "3.57"
   },
   "transport": {
    "paid_amount": "₹800.00",
    "pending_amount": "₹150.00",
    "month_given": "June, July"
   },
   "hostel": {
    "hostel_name": "Boys Hostel",
    "paid_amount": "₹4,000.00",
    "pending_amount": "₹2,000.00"
   }
  }
 ]
}
"""#,
        .feeDetails: #"""
{
 "status": true,
 "message": "Fee details loaded.",
 "data": [
  {
   "total_fee_amount": "₹15,000.00",
   "total_paid_amount": "₹10,000.00",
   "total_pending_amount": "₹4,500.00",
   "total_discount_amount": "₹500.00",
   "paid_percentage": "66.67",
   "fees": [
    {
     "fee_name": "Tuition Fee",
     "fee_group_type_name": "Term 1",
     "amount": "₹15,000.00",
     "student_paid": "₹10,000.00",
     "discount_given": "₹500.00",
     "pending_amount": "₹4,500.00",
     "pending_status": "0",
     "paid_details": [
      {
       "paid_date": "15/06/2026",
       "amount_given": "₹10,000.00",
       "paid_amount": "₹10,000.00",
       "discount_amount": "₹500.00",
       "pending_amount": "₹4,500.00"
      }
     ],
     "carry_over_fee": []
    }
   ]
  }
 ]
}
"""#,
        .receipts: #"""
{
 "status": true,
 "message": "Receipts loaded.",
 "data": [
  {
   "receipts": [
    {
     "id": "3",
     "invoice_no": "INV-003",
     "invoice_date": "20/07/2026",
     "paid_amount": "₹500.00",
     "invoice_path": ""
    },
    {
     "id": "2",
     "invoice_no": "INV-002",
     "invoice_date": "15/07/2026",
     "paid_amount": "₹2,000.00",
     "invoice_path": ""
    },
    {
     "id": "1",
     "invoice_no": "INV-001",
     "invoice_date": "15/06/2026",
     "paid_amount": "₹5,000.00",
     "invoice_path": "/r/1.pdf"
    }
   ]
  }
 ]
}
"""#,
        .onlinePayments: #"""
{
 "status": true,
 "message": "Online payments loaded.",
 "data": [
  {
   "payments": [
    {
     "receipt_no": "INV-002",
     "receipt_date": "15/07/2026",
     "receipt_amount": "₹2,000.00",
     "order_id": "778899",
     "transaction_id": "",
     "provider": "razorpay"
    }
   ]
  }
 ]
}
"""#,
        .discounts: #"""
{
 "status": true,
 "message": "Discount details loaded.",
 "data": [
  {
   "count": "2",
   "discounts": [
    {
     "discount_type": "Sibling Discount",
     "fee_name": "Tuition Fee",
     "fee_group_type_name": "Term 1",
     "discount_amount": "₹500.00",
     "created_date": "15/07/2026"
    }
   ]
  }
 ]
}
"""#,
        .examList: #"""
{
 "status": true,
 "message": "Exam list loaded.",
 "data": [
  {
   "exams": [
    {
     "exam_id": "1",
     "exam_name": "Unit Test 1"
    },
    {
     "exam_id": "2",
     "exam_name": "Quarterly"
    },
    {
     "exam_id": "3",
     "exam_name": "Half Yearly"
    }
   ]
  }
 ]
}
"""#,
        .markAnalysis: #"""
{
 "status": true,
 "message": "Mark analysis loaded.",
 "data": [
  {
   "student_name": "Arun Kumar",
   "class_name": "Grade 5",
   "section_name": "A",
   "exam_names": [
    "Unit Test 1",
    "Quarterly",
    "Half Yearly"
   ],
   "subjects": [
    {
     "subject_name": "English",
     "marks": [
      {
       "exam_name": "Unit Test 1",
       "marks": "40",
       "max_marks": "50",
       "grade": "A"
      },
      {
       "exam_name": "Quarterly",
       "marks": "70",
       "max_marks": "100",
       "grade": "B"
      },
      {
       "exam_name": "Half Yearly",
       "marks": "88",
       "max_marks": "100",
       "grade": "A"
      }
     ],
     "split_up": [
      {
       "name": "Theory",
       "marks": [
        {
         "exam_name": "Unit Test 1",
         "marks": "",
         "max_marks": ""
        },
        {
         "exam_name": "Quarterly",
         "marks": "50",
         "max_marks": "80"
        },
        {
         "exam_name": "Half Yearly",
         "marks": "",
         "max_marks": ""
        }
       ]
      },
      {
       "name": "Oral",
       "marks": [
        {
         "exam_name": "Unit Test 1",
         "marks": "",
         "max_marks": ""
        },
        {
         "exam_name": "Quarterly",
         "marks": "20",
         "max_marks": "20"
        },
        {
         "exam_name": "Half Yearly",
         "marks": "",
         "max_marks": ""
        }
       ]
      }
     ]
    },
    {
     "subject_name": "Maths",
     "marks": [
      {
       "exam_name": "Unit Test 1",
       "marks": "45",
       "max_marks": "50",
       "grade": "A+"
      },
      {
       "exam_name": "Quarterly",
       "marks": "AB",
       "max_marks": "100",
       "grade": ""
      },
      {
       "exam_name": "Half Yearly",
       "marks": "92",
       "max_marks": "100",
       "grade": "A+"
      }
     ],
     "split_up": []
    }
   ],
   "overall": [
    {
     "exam_name": "Unit Test 1",
     "exam_total": "85",
     "max_marks": "100",
     "percentage": "85",
     "grade": "A"
    },
    {
     "exam_name": "Quarterly",
     "exam_total": "70",
     "max_marks": "200",
     "percentage": "35",
     "grade": ""
    },
    {
     "exam_name": "Half Yearly",
     "exam_total": "180",
     "max_marks": "200",
     "percentage": "90",
     "grade": "A"
    }
   ]
  }
 ]
}
"""#,
        .leaveRequests: #"""
{
 "status": true,
 "message": "Leave requests loaded.",
 "data": [
  {
   "count": "2",
   "leave_requests": [
    {
     "applied_on": "01/08/2026",
     "from_date": "02/08/2026",
     "to_date": "02/08/2026",
     "no_of_days": "1",
     "reason": "Function",
     "status": "Waiting",
     "status_id": ""
    },
    {
     "applied_on": "01/07/2026",
     "from_date": "02/07/2026",
     "to_date": "03/07/2026",
     "no_of_days": "2",
     "reason": "Fever",
     "status": "Approved",
     "status_id": "1"
    }
   ]
  }
 ]
}
"""#,
        .workingDays: #"""
{
 "status": true,
 "message": "Working days loaded.",
 "data": [
  {
   "terms": [
    {
     "id": "1",
     "name": "Term 1"
    },
    {
     "id": "2",
     "name": "Term 2"
    }
   ]
  }
 ]
}
"""#,
        .attendancePercentage: #"""
{
 "status": true,
 "message": "Attendance percentage loaded.",
 "data": [
  {
   "overall": {
    "present_percentage": "97.5",
    "absent_percentage": "2.5"
   },
   "terms": [
    {
     "name": "Term 1",
     "present_percentage": "96.88",
     "absent_percentage": "3.13"
    },
    {
     "name": "Term 2",
     "present_percentage": "98.33",
     "absent_percentage": "1.67"
    }
   ]
  }
 ]
}
"""#,
        .transport: #"""
{
 "status": true,
 "message": "Transport details loaded.",
 "data": [
  {
   "route_name": "Route 7 - Anna Nagar",
   "stop_name": "2nd Avenue",
   "route_fee_type_name": "Two way",
   "month_given": "June, July",
   "total_fee_amount": "₹1,000.00",
   "total_paid_amount": "₹800.00",
   "total_pending_amount": "₹150.00",
   "total_discount_amount": "₹50.00"
  }
 ]
}
"""#,
        .hostel: #"""
{
 "status": true,
 "message": "Hostel details loaded.",
 "data": [
  {
   "hostel_name": "Boys Hostel",
   "floor_name": "First Floor",
   "room_no": "101",
   "bed_no": "B2",
   "room_type": "AC Triple",
   "mess_type": "Veg",
   "total_fee_amount": "₹6,000.00",
   "total_paid_amount": "₹4,000.00",
   "total_pending_amount": "₹2,000.00",
   "total_discount_amount": "₹0.00"
  }
 ]
}
"""#,
        .certificates: #"""
{
 "status": true,
 "message": "Certificates loaded.",
 "data": [
  {
   "count": "3",
   "certificates": [
    {
     "certificate_type": "1",
     "certificate_name": "Bonafide",
     "created_date": "01/08/2026",
     "certificate_url": "https://x/c2.pdf"
    },
    {
     "certificate_type": "1",
     "certificate_name": "Bonafide",
     "created_date": "01/07/2026",
     "certificate_url": "https://x/c1.pdf"
    },
    {
     "certificate_type": "1",
     "certificate_name": "Bonafide",
     "created_date": "01/08/2025",
     "certificate_url": "https://x/old.pdf"
    }
   ]
  }
 ]
}
"""#,
        .accomplishments: #"""
{
 "status": true,
 "message": "Accomplishments loaded.",
 "data": [
  {
   "count": "2",
   "accomplishments": [
    {
     "accomplishment_type": "Good Behvaiour",
     "report_type": "Positive Behaviour",
     "accomplishment_date": "20/10/2026"
    },
    {
     "accomplishment_type": "Good Behvaiour",
     "report_type": "Accomplishments",
     "accomplishment_date": "10/08/2026"
    }
   ]
  }
 ]
}
"""#,
        .incidents: #"""
{
 "status": true,
 "message": "Incident reports loaded.",
 "data": [
  {
   "count": "2",
   "incidents": [
    {
     "incident_type": "Late coming",
     "report_type": "Indisciplinary Activity",
     "incident_date": "13/07/2026"
    },
    {
     "incident_type": "Late coming",
     "report_type": "Negative Incident",
     "incident_date": "12/07/2026"
    }
   ]
  }
 ]
}
"""#
    ]
}
