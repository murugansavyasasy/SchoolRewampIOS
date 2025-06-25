//
//  AppConstont.swift
//  MyGrocery
//
//  Created by Chandhru veeramalai on 21/10/24.
//

import Foundation
import UIKit

struct ServiceUrl{
    static var baseurl = "http://apiv7.schoolchimes.net/"
    static var report_url = ""
    static var token = ""
    static var awsBucketName = ""
    
    
    static let country_list              = "app/api/setup/countries"
    static let version_check             = "app/api/setup/version-check"
    static let validate_validate_user    = "app/api/auth/validate-user"
    static let validate_validate_otp     = "app/api/auth/validate-otp"
    static let cred_change_password      = "app/api/cred/change-password"
    static let cred_forgot_password      = "app/api/cred/forgot-password"
    static let cred_reset_password       = "app/api/cred/reset-password"
    static let  cred_create_new_password = "app/api/cred/create-new-password"
    static let global_global_variables   = "app/global/global-variables"
    static let  auth_device_token        = "app/api/auth/device-token"
    static let  get_dashboard_details    = "dashboard/api/dashboard/get-dashboard-details"
    static let recipient_get_group_list  = "comm/api/recipient/get-group-list"
    static let recipient_get_standards   = "comm/api/recipient/get-standards"
    static let recipient_get_student_list  = "comm/api/recipient/get-student-list"
    static let recipient_get_subject_list  = "comm/api/recipient/get-subject-list"
    static let recipient_get_staff_list  = "comm/api/recipient/get-staff-list"
    static let comm_text_message_send_text  = "comm/api/text-message/send-text"
    static let comm_voice_send_voice  = "comm/api/voice/send-voice"
    static let comm_voice_get_voice_history  = "comm/api/voice/get-voice-history"
    static let comm_text_message_get_text_history  = "comm/api/text-message/get-text-history"
    static let comm_homework_get_homework_report  = "comm/api/homework/report"
    static let comm_homework_get_homework_list_archive  = "comm/api/homework/list-archive"
    static let comm_homework_get_homework_list  = "comm/api/homework/list"
    static let comm_homework_sendhomework  = "comm/api/homework/send-homework"
    static let comm_recipient_get_academic_year_list  = "comm/api/recipient/get-academic-year-list"
    static let comm_communication_list  = "comm/api/communication/list"
    static let comm_communication_list_archive  = "comm/api/communication/list-archive"
    static let comm_communication_read_status_update  = "comm/api/communication/read-status-update"
    static let  comm_communication_read_status_update_archive  = "comm/api/communication/read-status-update-archive"
    static let  comm_attachment_send_attachment  = "comm/api/attachment/send-attachment"
    static let  comm_communication_attachment_list  = "comm/api/attachment/list"
    static let  comm_communication_attachment_list_archive  = "comm/api/attachment/list-archive"
    static let  staff_attd_geometric_entry_using_app  = "staff-attd/api/geometric/entry-using-app"
    static let  staff_attd_geometric_set_geometric_location  = "staff-attd/api/geometric/set-geometric-location"
    static let  staff_attd_geometric_get_geometric_location_history  = "staff-attd/api/geometric/get-geometric-location-history"
    static let  geometric_principal_attendance_report  = "staff-attd/api/geometric/geometric-principal-attendance-report"
    static let  staff_attd_geometric_geometric_punch_history  = "staff-attd/api/geometric/geometric-punch-history"
    static let  staff_attd_geometric_geometric_staff_attendance_report  = "staff-attd/api/geometric/geometric-staff-attendance-report"
    static let  staff_attd_geometric_remove_geometric_location  = "staff-attd/api/geometric/remove-geometric-location"
    
    static let  staff_attd_geometric_get_staff_geometric_location  = "staff-attd/api/geometric/get-staff-geometric-location"
    static let  staff_attd_geometric_update_geometric_location  = "staff-attd/api/geometric/update-geometric-location"
    static let api_notice_board_send_notice = "admin/api/notice-board/send-notice"
    static let api_notice_board_get_notice = "admin/api/notice-board/get-notice"
    static let attendance_student_attendance_report = "stud-attd/api/attendance/student-attendance-report"
    static let api_school_event_send_event = "admin/api/school-event/send-event"
    
    static let api_fee_report_daily_collection = "fee/api/fee-report/daily-collection"
    static let api_fee_report_detailed_pending_report = "fee/api/fee-report/detailed-pending-report"
    static let api_fee_report_detailed_class_wise_pending_report = "fee/api/fee-report/detailed-class-wise-pending-report"
    static let  api_get_student_report = "admin/api/get-student-report"
    static let  api_school_event_get_event = "admin/api/school-event/get-event"
    static let  school_event_view_holidays = "admin/api/school-event/view-holidays"
    static let  admin_api_get_school_strength = "admin/api/get-school-strength"
    static let  attendance_send_absentees_sms_with_session_type = "stud-attd/api/attendance/send-absentees-sms-with-session-type" 
    static let  stud_attd_attendance_get_absent_dates_for_child = "stud-attd/api/attendance/get-absent-dates-for-child"
    static let  stud_attd_api_attendance_get_absentees_count_by_date = "stud-attd/api/attendance/get-absentees-count-by-date"
    static let  stud_attd_api_attendance_get_absentees_students_by_date = "stud-attd/api/attendance/get-absentees-students-by-date" 
    static let   comm_assignment_send_assignment = "comm/api/assignment/send-assignment"
    static let comm_api_assignment_submit_assignment = "comm/api/assignment/submit-assignment"
    static let comm_api_leave_req_apply = "comm/api/leave-req/apply"
    static let comm_api_leave_req_list = "comm/api/leave-req/list"
    static let comm_api_leave_req_update_status = "comm/api/leave-req/update-status"
    static let comm_api_assignment_report = "comm/api/assignment/report"
    static let comm_api_assignment_submissions_list = "comm/api/assignment/submissions-list"
    static let   comm_api_assignment_list = "comm/api/assignment/list"
    static let   comm_api_assignment_list_archive = "comm/api/assignment/list-archive"
    static let comm_api_my_submissions = "comm/api/assignment/my-submissions"
    static let comm_api_assignment_submissions_list_archive = "comm/api/assignment/submissions-list-archive"
  
    static let lms_api_lesson_plan_staff_report = "lms/api/lesson-plan/staff-report"
    static let lms_api_lesson_plan_view = "lms/api/lesson-plan/view"
    static let lms_api_lesson_plan_get_data_for_edit = "lms/api/lesson-plan/get-data-for-edit"
    static let lms_api_lesson_plan_update = "lms/api/lesson-plan/update"
    static let lms_api_lesson_plan_delete = "lms/api/lesson-plan/delete"
    // MARK: PAUKET API URL
    static let activate_coupon = "activate_coupon"
    static let get_campaigns = "get_campaigns"
    static let get_campaign_details = "get_campaign_details"
    static let get_category_list = "get_category_list"
    static let my_coupons = "my_coupons"
    static let get_Points = "get-Points"
    //
    static let comm_api_assignment_delete = "comm/api/assignment/delete"
    static let comm_api_msg_from_management_get_messages_staff = "comm/api/msg-from-management/get-messages-staff"
    static let comm_api_msg_from_management_get_messages_staff_archive = "comm/api/msg-from-management/get-messages-staff-archive"
    
}

struct localData{
    
    static var country_data : CountryData? = nil
    static var staff_data: [StaffDetails]?
    static var child_data: [ChildDetails]?
    static var user_details : UserDetails? = nil
    static var user_data : UserData? = nil
    static var  accidamic_year_data : get_academic_yearSuc? = nil

}
struct screenType{
    
    static let isMobileNumber  = 1
    static let isLoginPage  = 2
    static let isPassword  = 3
    static let isSplash  = 4
    static let isForgotPassword  = 5
    static let is_noticeboard = 23
    static let isAssaignment = 2
    static var staffSelectedMenuId = 0
    static var communicationMenuId = 0
    static let communication_text = 2
    static let is_emergencyvoice =  1
    static let non_emergencyvoice =  3
}

struct Menu_id{
    static var staffSelectedMenuId = -1
    static var communicationMenuId = 7
    static var homeWorkMenuId = 15
    static let isAssaignment = 2
    static let AttachmentMenuId = 39
    static let staffGeoAttendaceReport = 33
    static let geoMatricAttendace = 21
    static let noticeboardMenuId = 23
    static let event = 29
    static let studentReport = 35
    static let attendance = 3
    static let feependingreport = 14
    static let dailyCollection = 8
    static let schoolStrength = 31
    static let  AbsenteeismReport = 1
    static let  LessonPlan = 19
}
struct TargetTypes{
    
    static let school = 1
    static let standard = 2
    static let section = 3
    static let group = 4
    static let student = 5
    static let staff = 6
    
}
struct PriorityType{
    static let is_grouphead  = "p1"
    static let is_principal  = "p2"
    static let is_staff  = "p3"
    static let is_admin = "p4"
    static let is_non_teaching_staff = "p5"
   
}
struct recipeint_tabBarName{
    static let Standard = "Standards"
    static let Group = "Groups"
    static let Section_Student = "Section/Students"
    static let Staff = "Staff"
    static let Entier_School = "Entire School"
}

struct user_inputs {
    static var voice_link = ""
    static var duration: Int = 0
    static var is_schedule: Bool = false
    static var title = ""
    static var description = ""
    static var is_emergency: Bool = false
    static var schedule_date: [String] = []
    static var selectedImgData: [Data] = [] // ✅ replaced [UIImage]
    static var selectedImgUrls: [FilePath] = []
    static var SelectedUrls: [AttachmentItem] = []
    static var fileUrl: URL?
    static var thumbNail: Data? // ✅ changed UIImage? to Data?
    static var docUrl = [String]()
    static var start_time = ""
    static var end_time = ""
    static var file_name = ""
    static var circular_type = ""
    static var selectedFileType = ""
    static var VideoPath: URL?
    static var FromDate = ""
    static var ToDate = ""
    static var venue = ""
    static var class_id = ""
    static var section_id = ""
    static var all_present = ""
    static var attendance_type = ""
    static var session_type = ""
    static var attendance_date = ""
    static var submissionDate = ""
    static var assigmentCategory = ""

    static func clearTempData() -> Bool {
        selectedImgData.removeAll()
        selectedImgUrls.removeAll()
        SelectedUrls.removeAll()
        VideoPath = nil
        thumbNail = nil
        fileUrl = nil
        docUrl.removeAll()
        voice_link = ""
        title = ""
        description = ""
        file_name = ""
        circular_type = ""
        return true
    }
}




struct circular_type{
    static var school =  "A"
    static var  standard = "C"
    static var  section = "S"
    static var  group  =  "G"
    static var  student = "student"
    static var staff = "staff"
    
}


func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailTest.evaluate(with: email)
}
func isValidIndianMobileNumber(_ mobileNumber: String) -> Bool {
    let mobileNumberRegex = "^[6-9]\\d{9}$"
    let mobileNumberTest = NSPredicate(format: "SELF MATCHES %@", mobileNumberRegex)
    return mobileNumberTest.evaluate(with: mobileNumber)
}

func getCurrentDateString(format: String = "dd-MM-yyyy") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: Date())
}
func AwsCurrentDateString(format: String = "YYYY-MM-DD") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: Date())
}
func ConvertDateStringSmart(_ date: String?, toFormat: String = "dd-MM-yyyy") -> String {
    guard let date = date else { return "" }
    
    let possibleFormats = [
        "yyyy-MM-dd",
        "dd-MM-yyyy",
        "EEE d MMM yyyy",
        "dd/MM/yyyy",
        "MMM d, yyyy",
        "d MMM yyyy",
        "yyyy/MM/dd",
        "dd MMM yy",
        "MMM dd,yyyy",
        "dd",
        "MMMM",
        "EEEE",
        "EEE d MMM yyyy",
        "EEE d",
        "dd-MM-yyyy hh:mm a"
    ]
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = toFormat
    outputFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    for format in possibleFormats {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = format
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let dateObj = inputFormatter.date(from: date) {
            return outputFormatter.string(from: dateObj)
        }
    }

    print("❌ Could not match format for: \(date)")
    return ""
}

class DateFormatterHelpers {
    
    static func convertToStandardFormat(dateString: String, inputFormat: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: dateString) else {
            return nil
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        
        return outputFormatter.string(from: date)
    }
}


func formatDuration(_ duration: Int) -> String {
    let minutes = duration / 60
    let seconds = duration % 60
    return String(format: "%02d:%02d", minutes, seconds)
}


func applyShadowAndCornerRadius(to view: UIView, cornerRadius: CGFloat = 10, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 4, height: 4), shadowOpacity: Float = 0.5, shadowRadius: CGFloat = 4, backgroundColor: UIColor = .white) {
    view.layer.cornerRadius = cornerRadius
    view.layer.shadowColor = shadowColor.cgColor
    view.layer.shadowOffset = shadowOffset
    view.layer.shadowOpacity = shadowOpacity
    view.layer.shadowRadius = shadowRadius
    view.backgroundColor = backgroundColor
}

