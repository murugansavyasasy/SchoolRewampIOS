//
//  APIInputParameters.swift
//  rghs
//
//  Created by admin on 22/01/25.
//

import Foundation
struct VersionCeck {
    static let versionCode = "version_code"
    static let device = "device_type"
}
struct MobileVerification {
    static let mobileNo = "mobile_number"
}
struct InitiateOtp  {
    static let mobileNo = "mobile_number"
}
struct ValidateUser   {
    static let mobileNo = "mobile_number"
    static let token = "token"
    static let device_id = "device_id"
    static let otp = "otp"
}
struct CreateMeetingList {
    static let meeting_mode = "meeting_mode"
    static let meeting_link = "meeting_link"
    static let to_time = "to_time"
    static let from_time = "from_time"
    static let event_content = "meeting_content"
    static let mobile_number = "mobile_number"
    static let event_date = "meeting_date"
    static let venue = "venue"
    static let groups_id = "groups_id"
    static let title = "title"
    static let created_by = "created_by"
    static let college_id = "college_id"
    static let locationDetails = "locationDetails"
    static let location_name = "location_name"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let distance = "distance"
    static let location_id = "location_id"
    
  
    
}

struct UpdateMeetingList {
    static let meeting_mode = "meeting_mode"
    static let meeting_link = "meeting_link"
    static let to_time = "to_time"
    static let from_time = "from_time"
    static let event_content = "meeting_content"
    static let mobile_number = "mobile_number"
    static let event_date = "meeting_date"
    static let venue = "venue"
    static let participants = "participants"
    static let title = "title"
    static let id = "id"
    static let longitude = "longitude"
    static let latitude = "latitude"
    static let address = "address"
    static let distance = "distance"
    
    
}
struct Getmeetingdetails{
    static let event_status = "event_status"
}
struct DeleteMeetingDetails{
    static let id = "id"
}
struct get_meeting_attendance{
    static let meeting_id = "id"
}
struct get_meeting_location{
    static let meeting_id = "meeting_id"
}

struct UpdateUserdetails{
    static let member_id = "member_id"
    static let name = "name"
    static let address = "address"
    static let type_id = "type_id"
    static let profile_url = "profile_url"
    static let designation = "designation"
    static let email = "email"
    static let whatsapp_number = "whatsapp_number"
    static let mobile_number = "mobile_number"
    static let city = "city"
    static let pincode = "pincode"
    static let state = "state"
    static let dob = "dob"
    static let gender = "gender"
    static let college_id = "college_id"
    static let college_name = "college_name"
    static let active_bank_id = "active_bank_id"
    static let pan_number = "pan_number"
    static let groups_id = "groups_id"
    static let account_details = "account_details"
    
}

struct AccountDetails{
    static let bank_name = "bank_name"
    static let branch = "branch"
    static let account_holder_name = "account_holder_name"
    static let account_type = "account_type"
    static let ifsc_code = "ifsc_code"
    static let active_bank_id = "active_bank_id"
}
struct AddLocation{
    static let longitude = "longitude"
    static let latitude = "latitude"
    static let address = "address"
    static let distance = "distance"
    static let location_name  = "location_name"
    static let landkmark = "landkmark"
    static let college_id  = "college_id"
    static let meeting_id  = "meeting_id"
}


class ApitTypeSringFile{
    static var POST = "POST"
    static var GET = "GET"
    static var Delete = "DELETE"
    static var Put = "PUT"
}
struct Get_location_historyStr{
    
    static let college_id = "college_id"
    
}

struct Punch_inStr{
    
    static let meeting_id = "meeting_id"
    static let member_id = "member_id"
    
    
    
}
