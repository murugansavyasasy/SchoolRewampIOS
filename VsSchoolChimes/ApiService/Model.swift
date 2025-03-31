//
//  Model.swift
//  rghs
//
//  Created by admin on 17/01/25.
//

import Foundation

//MARK: Country List API
struct CountryListSuccess : Codable{
    let status : Bool?
    let message : String?
    let data : [CountryData]?
}

struct CountryData : Codable{
    
    let id : Int?
    let name : String?
    let code : Int?
    let mobile_number_length : Int?
    let mobile_no_hint : String?
    let base_url : String?
    let reporting_url : String?
    let flag_url : String?
    
}

//MARK: Version Check API
struct VersionCheckResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [VersionData]?
}

struct VersionData: Codable {
    let update_available: Bool?
    let force_update: Bool?
    let new_version: String?
    let new_version_updates: String?
    let country_details: CountryData?
    let toaster_title: String?
    let play_store_market_id: String?
    let play_store_link: String?
    let app_store_link: String?
}

// MARK: Validate User
struct UserValidationResponseSuc: Codable {
    let status: Bool?
    let message: String?
    let data: [UserData]?
}

struct UserData: Codable {
    let is_number_exists: Bool?
    let is_password_updated: Bool?
    let otp_sent: Bool?
    let message: String?
    let more_info: String?
    let dial_numbers: String?
    let user_details: UserDetails?
}

struct UserDetails: Codable {
    let is_staff: Bool?
    let staff_role: String?
    let role_name: String?
    let staff_details: [StaffDetails]? // Can remain empty
    let is_parent: Bool?
    let child_details: [ChildDetails]?
    let max_general_sms_count: Int?
    let max_homework_sms_count: Int?
    let max_emergency_voice_duration: Int?
    let max_general_voice_duration: Int?
    let max_hw_voice_duration: Int?
    let image_count: Int?
}

struct StaffDetails: Codable {
    let staff_name: String?
    let school_name: String?
    let school_name_regional: String?
    let city: String?
    let school_logo: String?
    let role: String?
    let is_payment_pending: String?  // Changed from String? to Bool?
    let schedule_call_type: Int?
    let biometric_enable: Int?
    let allow_video_download: Bool?
    let access_token: String?
    let school_address : String?
}

struct ChildDetails: Codable {
    let name: String?
    let standard_name: String?
    let section_name: String?
    let school_name: String?
    let school_name_regional: String?
    let school_city: String?
    let school_logo_url: String?
    let roll_number: String?
    let display_message: String?
    let access_token: String?
}

// MARK: Validate OTP
struct ValidateOTPSuc: Codable {
    let status: Bool?
    let message: String?
    let data: [String]?
}

//MARK: Change Password API
struct ChangePasswordSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [String]?
}


//MARK: Forgot Password API
struct ForgotPasswordResponeSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [ForgotPasswordData]?
}

struct ForgotPasswordData : Codable {
    let dial_numbers: String?
    let more_info: String?
    let forgot_otp_message: String?
}

//MARK: Reset Password API
struct ResetPasswordSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [String]?
}

//MARK: Create New Password API
struct CreateNewPasswordSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [String]?
}

//MARK: Global Variables API
struct GlobalVariablesResponseSuc : Codable {
    
    let status : Bool?
    let message : String?
    let data : [GlobalVariablesData]?
}

struct GlobalVariablesData : Codable {
    
    let new_version : String?
    let new_updates : String?
}

//MARK: Device Token API
struct DeviceTokenResponseSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [String]?
}
//MARK: Grouplist API
struct  GrouplistSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [GroupDetail]?
}
struct GroupDetail:Codable{
    let id:String?
    let name:String?
}
//MARK: GetStandard API
struct  GetStandardsSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [GroupDetail]?
}
struct StandardDetail:Codable{
    let id:String?
    let name:String?
    let sections:[sectionsDetail]?
}
struct sectionsDetail:Codable{
    let id:String?
    let name:String?
}


//MARK: GetStudentlist API
struct  GetStudentlistSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [StudentDetails]?
}
struct StudentDetails:Codable{
    let id:String?
    let name:String?
}

//MARK: GetSubjectlist API
struct  GetSubjectlistSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [GetSubjectDetails]?
}
struct GetSubjectDetails:Codable{
    let id:String?
    let name:String?
}

//MARK: GetStafflist API
struct  GetStafflistSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [GetStaffDetails]?
}
struct GetStaffDetails:Codable{
    let id:String?
    let name:String?
}

//MARK: Dashboard API
    struct DashboardResponse: Codable {
        let status: Bool?
        let message: String?
        let data: [DashboardData]?
    }
    
    struct DashboardData: Codable {
        let contact_details: ContactDetails?
        let menu_details: [MenuDetail]?
    }
    
    struct ContactDetails: Codable {
        let alert_message: String?
        let alert_content: String?
        let alert_title: String?
        let display_name: String?
        let numbers: String?
        let button_content: String?
    }
    
    struct MenuDetail: Codable {
        let id: Int?
        let name: String?
        let unread_count: Int?
    }

struct MenuDetail: Codable {
    let id: Int?
    let name: String?
    let unread_count: Int?
}
