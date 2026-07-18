

import Foundation
import UIKit

struct ServiceUrl{
    static var baseurl = "https://apiv8.schoolchimes.net/"
    static var Reporting_baseurl = "https://apiv8.schoolchimes.net/"
    static var appStore_url = ""
    static var Pacukt_baseurl = "https://api.pauket.com/api/partner/"
    static var awsBucketName = ""
    static let country_list              = "app/api/setup/countries"
    static let version_check             = "app/api/setup/version-check"
    static let validate_validate_user    = "app/api/auth/validate-user"
    static let validate_validate_otp     = "app/api/auth/validate-otp"
    static let cred_change_password      = "app/api/cred/change-password"
    static let cred_forgot_password      = "app/api/cred/forgot-password"
    static let cred_reset_password       = "app/api/cred/reset-password"
    static let cred_create_new_password  = "app/api/cred/create-new-password"
    static let global_global_variables   = "app/api/global/global-variables"
    static let auth_device_token         = "app/api/auth/device-token"
    static let app_api_auth_logout       = "app/api/auth/logout"
    static let get_dashboard_details    = "dashboard/api/dashboard/menus"
    static let dashboard_api_dashboard_menu_counts    = "dashboard/api/dashboard/menu-counts"
    static let recipient_get_group_list   = "comm/api/recipient/get-group-list"
    static let recipient_get_standards    = "comm/api/recipient/get-standards"
    static let recipient_get_student_list = "comm/api/recipient/get-student-list"
    static let recipient_get_subject_list = "comm/api/recipient/get-subject-list"
    static let recipient_get_staff_list   = "comm/api/recipient/get-staff-list"
    static let comm_text_message_send_text = "comm/api/text-message/send-text"
    static let comm_voice_send_voice  = "comm/api/voice/send-voice"
    static let comm_voice_get_voice_history  = "comm/api/voice/get-voice-history"
    static let comm_text_message_get_text_history  = "comm/api/text-message/get-text-history"
    static let comm_homework_get_homework_report  = "comm/api/homework/report"
    static let comm_homework_get_homework_list_archive  = "comm/api/homework/list-archive"
    static let comm_homework_get_homework_list  = "comm/api/homework/list"
    static let homework_mark_complete  = "comm/api/homework/mark-complete"
    static let comm_homework_sendhomework  = "comm/api/homework/send-homework"
    static let comm_recipient_get_academic_year_list  = "comm/api/recipient/get-academic-year-list"
    static let comm_communication_list  = "comm/api/communication/list"
    static let comm_communication_list_archive  = "comm/api/communication/list-archive"
    static let comm_communication_read_status_update  = "comm/api/communication/read-status-update"
    static let comm_communication_read_status_update_archive  = "comm/api/communication/read-status-update-archive"
    static let  comm_attachment_send_attachment  = "comm/api/attachment/send-attachment"
    static let  comm_communication_attachment_list  = "comm/api/attachment/list"
    static let  comm_api_attachment_report  = "comm/api/attachment/report"
    static let  comm_communication_attachment_list_archive  = "comm/api/attachment/list-archive"
    static let  staff_attd_geometric_entry_using_app  = "staff-attd/api/geometric/entry-using-app"
    static let  staff_attd_geometric_set_geometric_location  = "staff-attd/api/geometric/set-geometric-location"
    static let  staff_attd_geometric_get_geometric_location_history  = "staff-attd/api/geometric/get-geometric-location-history"
    static let  geometric_principal_attendance_report  = "staff-attd/api/geometric/geometric-principal-attendance-report"
    static let  staff_attd_geometric_geometric_punch_history  = "staff-attd/api/geometric/geometric-punch-history"
    static let  staff_attd_geometric_geometric_staff_attendance_report  = "staff-attd/api/geometric/geometric-staff-attendance-report"
    static let  staff_attd_geometric_remove_geometric_location  = "staff-attd/api/geometric/remove-geometric-location"
    static let  staff_attd_geometric_remove_attendance_report_date_wise  = "staff-attd/api/geometric/geometric-principal-attendance-report-date-wise"
    static let  staff_attd_geometric_get_staff_geometric_location  = "staff-attd/api/geometric/get-staff-geometric-location"
    static let  staff_attd_geometric_update_geometric_location  = "staff-attd/api/geometric/update-geometric-location"
    static let api_notice_board_send_notice = "admin/api/notice-board/send-notice"
    static let api_notice_board_get_notice = "admin/api/notice-board/get-notice"
    static let admin_api_notice_board_report = "admin/api/notice-board/report"
    static let admin_api_notice_board_update = "admin/api/notice-board/update"
    static let admin_api_school_event_update = "admin/api/school-event/update"
    static let admin_api_notice_board_delete = "admin/api/notice-board/delete"
    static let admin_api_school_event_delete = "admin/api/school-event/delete"
    static let event_target_details = "admin/api/school-event/target-details"
    static let attendance_student_attendance_report = "stud-attd/api/attendance/student-attendance-report"
    static let api_school_event_send_event = "admin/api/school-event/send-event"
    static let api_fee_report_daily_collection = "fee/api/fee-report/daily-collection"
    static let api_fee_report_detailed_pending_report = "fee/api/fee-report/detailed-pending-report"
    static let api_fee_report_detailed_class_wise_pending_report = "fee/api/fee-report/detailed-class-wise-pending-report"
    static let  api_get_student_report = "admin/api/get-student-report"
    static let  api_school_event_get_event = "admin/api/school-event/get-event"
    static let admin_api_school_event_report = "admin/api/school-event/report"
    static let  admin_api_school_event_categories = "admin/api/school-event/categories"
    static let  school_event_view_holidays = "admin/api/school-event/view-holidays"
    static let  admin_api_get_school_strength = "admin/api/get-school-strength"
    static let  attendance_send_absentees_sms_with_session_type = "stud-attd/api/attendance/send-absentees-sms-with-session-type"
    static let  stud_attd_attendance_get_absent_dates_for_child = "stud-attd/api/attendance/get-absent-dates-for-child"
    static let  stud_attd_api_attendance_get_absentees_count_by_date = "stud-attd/api/attendance/get-absentees-count-by-date"
    static let  stud_attd_api_attendance_get_absentees_students_by_date = "stud-attd/api/attendance/get-absentees-students-by-date"
    static let   comm_assignment_send_assignment = "comm/api/assignment/send-assignment"
    static let   comm_api_assignment_delete = "comm/api/assignment/delete"
    static let   lms_api_lsrw_delete = "lms/api/lsrw/delete"
    static let   comm_api_assignment_delete_submission
    = "comm/api/assignment/delete-submission"
    static let   comm_api_assignment_update = "comm/api/assignment/update"
    static let comm_api_assignment_submit_assignment = "comm/api/assignment/submit-assignment"
    static let comm_api_assignment_update_submission = "comm/api/assignment/update-submission"
    static let comm_api_leave_req_apply = "comm/api/leave-req/apply"
    static let comm_api_leave_req_for_staff_apply = "comm/api/leave-req-for-staff/apply"
    static let comm_api_leave_req_list = "comm/api/leave-req/list"
    static let comm_api_leave_req_list_staff = "comm/api//leave-req-for-staff/list"
    static let comm_api_leave_req_update_status = "comm/api/leave-req/update-status"
    static let comm_api_leave_req_update_status_Staff = "comm/api/leave-req-for-staff/update-status"
    static let comm_api_assignment_report = "comm/api/assignment/report"
    static let comm_api_assignment_submissions_list = "comm/api/assignment/submissions-list"
    static let comm_api_assignment_list = "comm/api/assignment/list"
    static let comm_api_homework_update = "comm/api/homework/update"
    static let comm_api_attachment_update = "comm/api/attachment/update"
    static let comm_api_homework_delete = "comm/api/homework/delete"
    static let comm_api_attachment_delete = "comm/api/attachment/delete"
    static let attachment_target_details = "comm/api/attachment/target-details"
    static let comm_api_assignment_list_archive = "comm/api/assignment/list-archive"
    static let comm_api_my_submissions = "comm/api/assignment/my-submissions"
    static let lms_api_lesson_plan_staff_report = "lms/api/lesson-plan/staff-report"
    static let lms_api_lesson_plan_view = "lms/api/lesson-plan/view"
    static let lms_api_lesson_plan_get_data_for_edit = "lms/api/lesson-plan/get-data-for-edit"
    static let lms_api_lesson_plan_get_data_for_add = "lms/api/lesson-plan/get-data-for-add"
    static let lms_api_lesson_plan_update = "lms/api/lesson-plan/update"
    static let lms_api_lesson_plan_add = "lms/api/lesson-plan/add"
    static let lms_api_lesson_plan_delete = "lms/api/lesson-plan/delete"
    // MARK: PAUKET API URL
    static let activate_coupon = "activate_coupon"
    static let get_campaigns = "get_campaigns"
    static let get_campaign_details = "get_campaign_details"
    static let get_category_list = "get_category_list"
    static let my_coupons = "my_coupons"
    static let get_Points = "get-Points"
    static let comm_api_msg_from_management_get_messages_staff = "comm/api/msg-from-management/get-messages-staff"
    static let comm_api_msg_from_management_get_messages_staff_archive = "comm/api/msg-from-management/get-messages-staff-archive"
    static let interaction_staff_details_for_chat = "comm/api/interaction/staff-details-for-chat"
    static let interaction_get_staff_answers = "comm/api/interaction/get-staff-answers"
    static let interaction_student_ask_question = "comm/api/interaction/student-ask-question"
    static let interaction_staff_get_questions = "comm/api/interaction/staff-get-questions"
    static let lms_api_time_table_get_schedule = "lms/api/time-table/get-schedule"
    static let comm_api_certificate_request_list = "comm/api/certificate/request-list"
    static let comm_api_certificate_types = "comm/api/certificate/types"
    static let comm_api_certificate_send_request = "comm/api/certificate/send-request"
    static let exam_api_exam_get_exams = "exam/api/exam/get-exams"
    static let exam_api_exam_list = "exam/api/exam/list"
    static let exam_api_exam_view_marks = "exam/api/exam/view-marks"
    static let exam_api_get_progress_card = "exam/api/exam/get-progress-card"
    static let interaction_classes_for_chat = "comm/api/interaction/classes-for-chat"
    static let comm_api_leave_req_delete = "comm/api/leave-req/delete"
    static let comm_api_leave_req_update = "comm/api/leave-req/update"
    static let leave_req_for_staff_update_status = "comm/api/leave-req-for-staff/update-status"
    static let lms_api_lsrw_skill_list = "lms/api/lsrw/skill-list"
    static let lms_api_lsrw_submit_skill = "lms/api/lsrw/submit-skill"
    static let lms_api_lsrw_create_skill = "lms/api/lsrw/create-skill"
    static let comm_api_leave_req_leave_categories = "comm/api/leave-req/leave-categories"
    static let comm_api_leave_req_for_staff_leave_categories = "comm/api/leave-req-for-staff/leave-categories"
    static let stud_attd_api_attendance_student_stats = "stud-attd/api/attendance/student-stats"
    static let ptm_api_ptm_schedule_slot_details_for_staff = "ptm/api/ptm-schedule/slot-details-for-staff"
    static let ptm_api_ptm_schedule_validate_slots_for_staff = "ptm/api/ptm-schedule/validate-slots-for-staff"
    static let dashboard_notifications = "dashboard/api/dashboard/notifications"
    static let dashboard_delete_notification = "dashboard/api/dashboard/delete-notification"
    static let quiz_exam_list = "lms/api/quiz/quiz-exam-list"
    static let my_submissions = "lms/api/quiz/my-submissions"
    static let quiz_report = "lms/api/quiz/report"
    static let quiz_get_questions = "lms/api/quiz/get-questions"
    static let quiz_create_quiz = "lms/api/quiz/create-quiz"
    static let quiz_add_question = "lms/api/quiz/add-question"
    static let lms_api_lsrw_skills_report = "lms/api/lsrw/skills-report"
    static let quiz_questions_report = "lms/api/quiz/questions-report"
    static let quiz_submit = "lms/api/quiz/submit"
    static let quiz_submission_list = "lms/api/quiz/submission-list"
    static let check_level = "lms/api/quiz/check-level"
    
    static let lms_api_lsrw_remark = "lms/api/lsrw/remark"
    static let lms_api_lsrw_submission_list = "lms/api/lsrw/submission-list"
    static let lms_api_lsrw_my_submissions = "lms/api/lsrw/my-submissions"
    static let lms_api_lsrw_stats = "lms/api/lsrw/stats"
    static let dashboard_api_pauket_add_points = "dashboard/api/pauket/add-points"
    static let ptm_api_ptm_schedule_cancel_and_reopen_slot = "ptm/api/ptm-schedule/cancel-and-reopen-slot"
    static let ptm_api_ptm_schedule_cancel_and_close_slot = "ptm/api/ptm-schedule/cancel-and-close-slot"
    static let ptm_api_ptm_schedule_create_slots = "ptm/api/ptm-schedule/create-slots"
    static let ptm_api_ptm_schedule_teacherwise_slots_availability_for_student = "ptm/api/ptm-schedule/teacherwise-slots-availability-for-student"
    static let ptm_api_ptm_schedule_subject_list_with_class_teacher = "ptm/api/ptm-schedule/subject-list-with-class-teacher"
    static let ptm_api_ptm_schedule_book_slots_for_student = "ptm/api/ptm-schedule/book-slots-for-student"
    static let ptm_api_ptm_schedule_slot_history_for_student = "ptm/api/ptm-schedule/slot-history-for-student"
    static let ptm_api_ptm_schedule_cancel_slot_by_student = "ptm/api/ptm-schedule/cancel-slot-by-student"
    static let ptm_api_ptm_schedule_available_slots_count_for_student = "ptm/api/ptm-schedule/available-slots-count-for-student"
    static let admin_api_student_profile_list = "admin/api/student-profile/list"
    static let admin_api_staff_profile_list = "admin/api/staff-profile/list"
    static let admin_api_student_profile_pre_submission = "admin/api/student-profile/pre-submission"
    static let fee_api_fee_details_student_invoice = "fee/api/fee-details/student-invoice"
    static let fee_api_fee_details_invoice_details = "fee/api/fee-details/invoice-details"
    static let lms_api_quiz_pick_from_qbank = "lms/api/quiz/pick-from-qbank"
    static let comm_api_interaction_staff_ans_question = "comm/api/interaction/staff-ans-question"
    static let dashboard_api_dashboard_new_updates = "dashboard/api/dashboard/new-updates"
    static let stud_attd_api_attendance_student_list = "stud-attd/api/attendance/student-list"
    static let comm_api_interaction_block_student = "comm/api/interaction/block-student"
    static let comm_api_interaction_blocked_students = "comm/api/interaction/blocked-students"
    static let comm_api_assignment_target_details = "comm/api/assignment/target-details"
    static let dashboard_api_dashboard_faqs = "dashboard/api/dashboard/faqs"
    static let dashboard_api_dashboard_features = "dashboard/api/dashboard/features"
    static let dashboard_api_reviews_list = "dashboard/api/reviews/list"
    static let dashboard_api_reviews_add = "dashboard/api/reviews/add"
    static let ptm_api_ptm_schedule_datewise_booked_slots = "ptm/api/ptm-schedule/datewise-booked-slots"
    static let exam_api_exam_get_staff_wise_exam = "exam/api/exam/get-staff-wise-exam"
    static let exam_get_subject_wise_activities = "exam/api/exam/get-subject-wise-activities"
    static let ocr_api_upload_marks = "ocr/api/upload-marks"
    static let lms_api_quiz_delete = "lms/api/quiz/delete"
    static let lms_api_quiz_update = "lms/api/quiz/update"
    static let lms_api_quiz_delete_question = "lms/api/quiz/delete-question"
    static let update_notification_call_log = "comm/api/voice/update-notification-call-log"
    static let exam_api_exam_get_mark_details = "exam/api/exam/get-mark-details"
    static let exam_api_exam_upload_marks = "exam/api/exam/upload-marks"
    static let hostel_attendance_hostel_list = "stud-attd/api/hostel-attendance/hostel-list"
    static let hostel_attendance_room_details = "stud-attd/api/hostel-attendance/room-details"
    static let hostel_attendance_students_for_hostel_attd = "stud-attd/api/hostel-attendance/students-for-hostel-attd"
    static let hostel_attendance_mark_attendance = "stud-attd/api/hostel-attendance/mark-attendance"
    static let hostel_attendance_session_types = "stud-attd/api/hostel-attendance/session-types"
    static let hostel_attendance_outpass_report = "stud-attd/api/hostel-attendance/outpass-report"
    static let hostel_attendance_apply_outpass = "stud-attd/api/hostel-attendance/apply-outpass"
    static let comm_api_hostel_attendance_attendance_report = "stud-attd/api/hostel-attendance/attendance-report"
    static let comm_api_homework_submissions_list = "comm/api/homework/submissions-list"
    static let hostel_attendance_parent_dashboard = "stud-attd/api/hostel-attendance/parent-dashboard"
    static let hostel_attendance_hostel_info = "stud-attd/api/hostel-attendance/hostel-info"
    static let comm_api_leave_req_for_staff_delete = "comm/api/leave-req-for-staff/delete"
    static let comm_api_leave_req_for_staff_update = "comm/api/leave-req-for-staff/update"
    static let hostel_attendance_update_status = "stud-attd/api/hostel-attendance/update-status" 
    
    static let online_payment_details_for_student = "dashboard/api/reconcile/online-payment-details-for-student"
    static let update_unreceived_for_student = "dashboard/api/reconcile/update-unreceived-payment-status-for-student"
    static let get_student_route_list = "transport/api/get-student-route-list"
    static let get_vehicle_live_tracking_details = "transport/api/get-vehicle-live-tracking-details"
    static let get_latest_geo_location = "transport/api/get-latest-geo-location" 
    static let exam_section_wise_subjects = "exam/api/exam-test/section-wise-subjects"
    static let exam_create_class_test = "exam/api/exam-test/create-class-test"
    static let exam_test_mark_details = "exam/api/exam-test/mark-details"
    static let exam_api_exam_test_upload_marks = "exam/api/exam-test/upload-marks"
 
    static let exam_class_test_details = "exam/api/exam-test/class-test-details"
    static let exam_class_test_details_for_student = "exam/api/exam-test/class-tests-for-student"
    static let exam_view_marks_for_student = "exam/api/exam-test/view-marks-for-student"
    static let exam_api_exam_test_delete_class_test_subject = "exam/api/exam-test/delete-class-test-subject"
    static let exam_api_exam_test_delete = "exam/api/exam-test/delete"
    static let exam_api_exam_test_publish_marks = "exam/api/exam-test/publish-marks"

}

struct localData{
    
    static var country_data : CountryData? = nil
    static var staff_data: [StaffDetails]?
    static var child_data: [ChildDetails]?
    static var user_details : UserDetails? = nil
    static var user_data : UserData? = nil
    static var  accidamic_year_data : get_academic_yearSuc? = nil
    static var  editToken : String?
    
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
    static let lsrw = 20
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
    static let  MessageFromManagement = 22
    static let  senderChat = 17
    static let  quiz = 27
    static let  ptm = 26
    static let  e_books = 25
    static let  Market_place = 30
    static let  Alert = 36
    static let leaveReq = 18
    static let Upload_Marks = 41
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
    static let Standard = "Standards".translated()
    static let Group = "Groups".translated()
    static let Section_Student = "Section/Students".translated()
    static let Staff = "Staff".translated()
    static let Entier_School = "Entire School".translated()
}

struct Filecount{
    static let SelectImageAndDocumetCount = 10
    static let SelectVideoCount = 2
    
}

class FileTypeConstants {
    static let publicData = "public.data"
    static let publicContent = "public.content"
    static let adobePDF = "com.adobe.pdf"
    static let publicText = "public.text"
}
struct DateInputs{
    
    static let dd_MM_yyyy =  "dd-MM-yyyy"
    static let MMMM_yyyy =  "MMMM yyyy"
    static let dd_MMM_yy =  "dd MMM yy"
    static let dd_MMM_yyyy =  "dd MMM yyyy"
    static let ddMMMyyyyhhmma =  "dd MMM yyyy hh:mm a"
    
}
struct DateOutPut{
    static let EE_MMM_dd_yyyy =  "EE MMM dd, yyyy"
    static let EEEE =  "EEEE"
    static let EEEE_d =  "EEE d"
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
    static var thumbNail: UIImage? // ✅ changed UIImage? to Data?
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
    static var menuList:[String] = []
    static var level : Int = 1
    
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
    dateFormatter.locale = LocaleManager.shared.apiLocale
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: Date())
}

func AwsCurrentDateString(format: String = "dd-MM-yyyy") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = LocaleManager.shared.apiLocale
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: Date())
}

func ConvertDateStringSmart(_ date: String?, toFormat: String = "dd-MM-yyyy") -> String {
    guard let date = date else { return "" }
    
    // All possible input formats
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
        "dd-MM-yyyy hh:mm a",
        "d EEE, MMM yyyy",
        "EEE, dd MMM yyyy"
    ]
    let outputFormatter = DateFormatter()
    outputFormatter.locale = LocaleManager.shared.displayLocale
    outputFormatter.dateFormat = toFormat
    for format in possibleFormats {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = LocaleManager.shared.displayLocale
        inputFormatter.dateFormat = format
        
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
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return outputFormatter.string(from: date)
    }
}


func formatDuration(_ duration: Int) -> String {
    let minutes = duration / 60
    let seconds = duration % 60
    return String(format: CommonStringFile.Time_formate, minutes, seconds)
}


func applyShadowAndCornerRadius(to view: UIView, cornerRadius: CGFloat = 10, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 4, height: 4), shadowOpacity: Float = 0.5, shadowRadius: CGFloat = 4, backgroundColor: UIColor = .white) {
    view.layer.cornerRadius = cornerRadius
    view.layer.shadowColor = shadowColor.cgColor
    view.layer.shadowOffset = shadowOffset
    view.layer.shadowOpacity = shadowOpacity
    view.layer.shadowRadius = shadowRadius
    view.backgroundColor = backgroundColor
}

func formattedDateStatus(from selectedDateString: String, isTimeNeeded: Bool = false) -> String {
    
    let savedCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
    
    let todayText: String
    let yesterdayText: String
    
    switch savedCode {
    case "ta": // Tamil
        todayText = "இன்று"
        yesterdayText = "நேற்று"
    case "hi": // Hindi
        todayText = "आज"
        yesterdayText = "कल"
    case "th": // Thai
        todayText = "วันนี้"
        yesterdayText = "เมื่อวานนี้"
    default: // English
        todayText = "Today"
        yesterdayText = "Yesterday"
    }
    
    // Recognizable formats
    let possibleFormats = [
        // Date only
        "dd-MM-yyyy","yyyy-MM-dd","dd/MM/yyyy","MM/dd/yyyy",
        "dd MMM yyyy","dd MMMM yyyy","yyyy/MM/dd","MMM dd, yyyy",
        
        // Date + Time
        "dd-MM-yyyy HH:mm","dd-MM-yyyy HH:mm:ss","dd-MM-yyyy hh:mm a","dd-MM-yyyy hh:mm:ss a",
        "yyyy-MM-dd HH:mm","yyyy-MM-dd HH:mm:ss","yyyy-MM-dd hh:mm a","yyyy-MM-dd hh:mm:ss a",
        "yyyy/MM/dd HH:mm:ss","MM/dd/yyyy HH:mm","MM/dd/yyyy hh:mm a",
        "dd MMM yyyy HH:mm","dd MMM yyyy hh:mm a",
        "dd MMMM yyyy HH:mm","dd MMMM yyyy hh:mm a",
        "MMM dd, yyyy HH:mm","MMM dd, yyyy hh:mm a"
    ]
    
    let inputFormatter = DateFormatter()
    inputFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    var selectedDate: Date?
    
    for format in possibleFormats {
        inputFormatter.dateFormat = format
        if let date = inputFormatter.date(from: selectedDateString) {
            selectedDate = date
            break
        }
    }
    
    guard let date = selectedDate else {
        print("❌ No match for: \(selectedDateString)")
        return selectedDateString
    }
    
    let calendar = Calendar.current
    let today = Date()
    
    // Output formatters
    let timeFormatter = DateFormatter()
    timeFormatter.locale = LocaleManager.shared.displayLocale
    timeFormatter.dateFormat = "h:mm a"
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = LocaleManager.shared.displayLocale
    dateFormatter.dateFormat = "dd MMM yyyy"
    
    if calendar.isDate(date, inSameDayAs: today) {
        return isTimeNeeded ? timeFormatter.string(from: date) : todayText
    }
    
    if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
       calendar.isDate(date, inSameDayAs: yesterday) {
        return isTimeNeeded ? "\(yesterdayText) \(timeFormatter.string(from: date))" : yesterdayText
    }
    
    // Normal date
    return isTimeNeeded
    ? "\(dateFormatter.string(from: date)), \(timeFormatter.string(from: date))"
    : dateFormatter.string(from: date)
}


