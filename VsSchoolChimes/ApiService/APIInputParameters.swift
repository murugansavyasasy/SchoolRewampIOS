//
//  APIInputParameters.swift
//  rghs
//
//  Created by admin on 22/01/25.
//

import Foundation



class COMMON_PARAMETER{
    static var device_type = "device_type"
    static var version_code = "version_code"
    static var mobile_number = "mobile_number"
    static var new_password = "new_password"
    static var  country_id = "country_id"
    static var  academic_year_id = "academic_year_id"
    static var section_ids = "section_ids"
    static var old_password = "old_password"
    static var member_type = "member_type"
    static var secure_id = "secure_id"
}

class mobileNumber{

    static var mobile_number = "mobile_number"
    static var password = "password"
    static var device_type = "device_type"
    static var secure_id = "secure_id"
   
}

class OTP_PARAMETER{
    static var otp = "otp"
}

class ApitTypeSringFile{
    static var POST = "POST"
    static var GET = "GET"
    static var Delete = "DELETE"
    static var PUT = "PUT"
}
 
class CreateNewPasswordStringFile{
    static var old_password = "old_password"
}

class GlobalVariablesStringFile {
    
    static var key_names = "key_names"
    static var new_version = "new_version"
    static var new_updates = "new_updates"
}

class DeviceTokenStringFile {
    
    static var device_token = "device_token"
    static var secure_id = "secure_id"
    static var device_info = "device_info"
    static var manufacturer = "manufacturer"
    static var model = "model"
    static var device = "device"
    static var brand = "brand"
    static var hardware = "hardware"
    static var product = "product"
    static var os_version = "os_version"
    static var sdk_int = "sdk_int"
    static var app_version = "app_version"
}
class  send_textmessageStringFile {
    static var target_code = "target_code"
    static var target_type = "target_type"
    static var message = "title"
    static var description = "content"
    static var academic_year_id = "academic_year_id"
   
}
class send_voicemeassageStringFile {
    
    static var voice_link = "voice_link"
    static var target_code = "target_code"
    static var target_type = "target_type"
    static var duration = "duration"
    static var description = "title"
    static var is_emergency = "is_emergency"
    static var is_schedule = "is_schedule"
    static var schedule_date = "schedule_date"
    static var start_time = "start_time"
    static var end_time = "end_time"
    static var file_name = "file_name"
    static var circular_type = "circular_type"
    static var academic_year_id = "academic_year_id"
  
}

class homeWorkViewStringFile {
    static let id = "id"
    static let section_id = "section_id"
    static let date = "date"
    static let academic_year_id = "academic_year_id"
}

class ReadStatusUpdateStringFile {
    
    static var type = "type"
    static var detail_id = "detail_id"
}

class speficStudentStringFile{
    
    
    static var section_id = "section_id"
    static var academic_year_id = "academic_year_id"
}

enum UploadMessageKeys {
    static let title = "title"
    static let description = "description"
    static let target_type = "target_type"
    static let target_code = "target_code"
    static let subjectId = "subject_id"
    static let filePath = "file_path"
    static let academic_year_id = "academic_year_id"
}
enum UploadEvent {
    static let title = "title"
    static let content = "content"
    static let venue = "venue"
    static let target_code = "target_code"
    static let event_date = "event_date"
    static let event_time = "event_time"
    static let target_type = "target_type"
    static let filePath = "file_path"
}


class SendAttachmentStringFile {
    
    static let title = "title"
    static let id = "id"
    static let file_type = "file_type"
    static let file_path = "file_path"
    static let target_type = "target_type"
    static let target_code = "target_code"
    static let description = "description"
    static let iframe = "iframe"
    static let file_size = "file_size"
    static let academic_year_id = "academic_year_id"
    static let venue = "venue"
    static let event_date = "event_date"
    static let event_time = "event_time"
    static var intended_for = "intended_for"
    static var visible_from = "visible_from"
    static var visible_to = "visible_to"
   
}


class PunchStringFile {
    
    static var staff_or_student = "staff_or_student"
    static var device_id = "device_id"
    static var punch_type = "punch_type"
    static  var device_model  = "device_model"
    
}


class punchDetaiShapeStringFile {
    
    static var location = "location"
    static var longitude = "longitude"
    static var latitude = "latitude"
    static var distance = "distance"
}

class principalAttendenceReportStringFile {
    
    static var attendance_month = "attendance_month"
    static var attendance_dt = "attendance_dt"
    static var staff_id = "staff_id"
}

class punchHistoryStringFile {
    
    static var from_date = "from_date"
    static var to_date = "to_date"
    static var staff_id = "staff_id"
}

class StaffAttendanceReportStringFile {
    static var attendance_dt = "attendance_dt"
}

class Daily_collectionStringFile {
    static var type = "type"
    static var from_date = "from_date"
    static var to_date = "to_date"
    
}
class SendNoticeStringFile {
    static var title = "title"
    static let description = "description"
    static var target_code = "target_code"
    static var intended_for = "intended_for"
    static var visible_from = "visible_from"
    static var visible_to = "visible_to"
    static var file_path = "file_path"
}

class AttendanceReportStringFile {
    
    static var from_date = "from_date"
    static var to_date = "to_date"
    static var standard_id = "standard_id"
    static var section_id = "section_id"
}
enum GetStudentReport {
    static var class_id = "class_id"
    static var section_id = "section_id"
}
class MarkAttendenceStringFile {
    
    static var class_id = "class_id"
    static var section_id = "section_id"
    static var all_present = "all_present"
    static var attendance_type = "attendance_type"
    static var session_type = "session_type"
    static var attendance_date = "attendance_date"
    static var student_id = "student_id"
    static var student_details = "student_details"
    static var date = "date"
}

class AbsenteesReportStringFile {
    
    static var absent_on = "absent_on"
    static var section_id = "section_id"
    static var standard_id = "standard_id"
}

class assignmentResquestStringKey{
    
    static let title = "title"
    static let description = "description"
    static let target_code = "target_code"
    static let submission_date = "submission_date"
    static let category = "category"
    static let subject_code = "subject_code"
    static let target_type = "target_type"
    static let filePath = "file_path"
    static let academic_year_id = "academic_year_id"
    static let iframe = "iframe"
    static let file_size = "file_size"
    static let venue = "venue"
    static let event_date = "event_date"
    static let event_time = "event_time"
    static let activity_type = "activity_type"
   
}

class LeaveRequestStringFile{
    
    static let leave_from = "leave_from"
    static let leave_to = "leave_to"
    static let reason = "reason"
    static let member_type = "member_type"
    static let id = "id"
    static let is_approve = "is_approve"
    static let f_session = "f_session"
    static let t_session = "t_session"
    static let leave_type = "leave_type"
}


class LessonPlanStringFile{
    
    static let request_type = "request_type"
    static let section_subject_id = "section_subject_id"
    static let lesson_plan_status = "lesson_plan_status"
    static let particular_id = "particular_id"
    static let myclass = "myclass"
    static let allclass = "allclass"
    static let key_value_data = "key_value_data"
}

class PaucketHeader{
    
    static let api_key = "api-key"
    static let partner_name = "partner-name"
    static let api_key_value = "33adab6a67a9eee6e72be49acfb6c100"
    static let partner_name_value = "savyasasy"
    static let Paucket = "Paucket"
    static let source_link = "source_link"
    static let mobile_no = "mobile_no"
}


class PTMRequestStringFile{
    
    static let event_date = "event_date"
    static let event_name = "event_name"
    static let date = "date"
    static let from_time = "from_time"
    static let to_time = "to_time"
    static let duration = "duration"
    static let event_link = "event_link"
    static let break_time = "break_time"
    static let meeting_mode = "meeting_mode"
    static let std_sec_details = "std_sec_details"
    static let section_id = "section_id"
    static let class_id = "class_id"
    static let slots = "slots"
    static let subject_id = "subject_id"
    static let class_teacher_id = "class_teacher_id"
    static let slot_ids = "slot_ids"
    static let cancelled_reason = "cancelled_reason"
    static let slot_id = "slot_id"
    static let is_management = "is_management"
}

class createQuizStringFile{
    
    static let  target_type = "target_type"
    static let  target_code = "target_code"
    static let  subject_id = "subject_id"
    static let  class_id = "class_id"
}

class addPonintsPackut{
    
    static let mobile_number = "mobile_number"
    static let activity = "activity"
    static let user_type = "user_type"
    static let menu_id = "menu_id"
}
class get_quizLevel{
    static let class_id = "class_id"
    static let subject_id = "subject_id"
}

class QuizRequestStringFile{
    static let title = "title"
    static let description = "description"
    static let no_of_question = "no_of_question"
    static let level = "level"
    static let level_flag = "level_flag"
}

class QuizKeys {
    static let quiz_id = "quiz_id"
    static let questions = "questions"
    static let max_mark = "max_mark"
    static let ok_flag = "ok_flag"
    static let update_question_bank = "update_question_bank"

    // Question keys
    static let ques_no = "ques_no"
    static let chapter = "chapter"
    static let question = "question"
    static let a_option = "a_option"
    static let b_option = "b_option"
    static let c_option = "c_option"
    static let d_option = "d_option"
    static let answer = "answer"
    static let mark = "mark"

    // File keys
    static let iframe = "iframe"
    static let file_size = "file_size"
    static let thumbnail = "thumbnail"
    static let file_path = "file_path"
    static let url = "url"
    static let type = "type"
    static let status_type = "status_type"
    static let id = "id"
   
    // Bank keys
    static let subject_id = "subject_id"
}

class ChatAPIKeys {
    static let staffId = "staff_id"
    static let question_id = "question_id"
    static let answer = "answer"
    static let reply_type = "reply_type"
    static let is_change_answer = "is_change_answer"
    static let subjectId = "subject_id"
    static let question = "question"
    static let isClassTeacher = "is_class_teacher"
    static let filePath = "file_path"
    static let offset = "offset"
    static let student_id = "student_id"
    static let is_block = "is_block"
    static let reason = "reason"
    static let Types = "Type"
    static let section_id = "section_id"
    static let detail_id = "detail_id"
}
class LessonPlanAPIKeys {

    static let activity = "activity"
    static let mobileNumber = "mobile_number"
    static let userType = "user_type"
    static let menuId = "menu_id"
    static let fieldId = "field_id"
    static let value = "value"
}
class AttendanceAPIKeys{
    static let mobile_number = "mobile_number"
    static let activity = "activity"
    static let user_type = "user_type"
    static let menu_id = "menu_id"
}
