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
    static var Put = "PUT"
}
 
class CreateNewPasswordStringFile{
    static var old_password = "old_password"
}

class GlobalVariablesStringFile {
    
    static var key_names = "key_names"
    static var new_version = "new_version"
    static var new_updates = "new_updates"
}

class  DeviceTokenStringFile {
    
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
    static let sectionCode = "section_code"
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
    static let file_type = "file_type"
    static let file_path = "file_path"
    static let target_type = "target_type"
    static let target_code = "target_code"
    static let description = "description"
    static let iframe = "iframe"
    static let file_size = "file_size"
    static let academic_year_id = "academic_year_id"
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
    static var content = "content"
    static var target_code = "target_code"
    static var intended_for = "intended_for"
    static var visible_from = "visible_from"
    static var visible_to = "visible_to"
    static var file_path = "file_path"
}
enum GetStudentReport {
    static var class_id = "class_id"
    static var section_id = "section_id"
}
