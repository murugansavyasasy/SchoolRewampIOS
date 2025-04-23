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
}
class  send_textmessageStringFile {
    static var target_code = "target_code"
    static var target_type = "target_type"
    static var message = "message"
    static var description = "description"
    static var academic_year_id = "academic_year_id"
}
class send_voicemeassageStringFile {
    
    static var voice_link = "voice_link"
    static var target_code = "target_code"
    static var target_type = "target_type"
    static var duration = "duration"
    static var description = "description"
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
    static let topic = "topic"
    static let text = "text"
    static let sectionCode = "section_code"
    static let subjectId = "subject_id"
    static let filePath = "file_path"
    static let academic_year_id = "academic_year_id"
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
    
    var staff_or_student = "staff_or_student"
    var device_id = "device_id"
    var punch_type = "punch_type"
    var device_model  = "device_model"
    
}


class punchDetaiShapeStringFile {
    
    var location = "location"
    var longitude = "longitude"
    var latitude = "latitude"
    var distance = "distance"
}
