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
    let description: String?
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
    let name: String?
    let emp_id: String?
    let mobile_no: String?
    let address: String?
    let email: String?
    let blood_group: String?
    let staff_profile: String?
    let school_id: String?
    let school_name: String?
    let school_name_regional: String?
    let school_city: String?
    let school_logo: String?
    let role: String?
    let priority_level: String?
    let is_payment_pending: String?
    let schedule_call_type: Int?
    let biometric_enable: Bool?
    let allow_video_download: Bool?
    let school_address: String?
    let access_token: String?
    var isSelected: Bool?
}

struct ChildDetails: Codable {
    let name: String?
    let standard_name: String?
    let section_name: String?
    let school_name: String?
    let school_name_regional: String?
    let school_city: String?
    let school_logo_url: String?
    let profile: String?
    let roll_number: String?
    let display_message: String?
    let access_token: String?
    let school_id: String?
    let address: String?
    let class_id: Int?
    let section_id: Int?
    let email: String?
    let father_name: String?
    let mother_name: String?
    let father_occupation: String?
    let mother_occupation: String?
    let blood_group: String?
    let secondary_mobile: String?
    let whatsapp_number: String?
    let class_teacher: String?
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
    let created_on:String?
    var isSelect:Bool?
}
//MARK: GetStandard API
struct  GetStandardsSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [StandardDetail]?
}
struct StandardDetail:Codable{
    let id:String?
    let name:String?
    var sections:[sectionsDetail]?
    var isSelect:Bool?
}
struct sectionsDetail:Codable{
    let id:String?
    let name:String?
    var isSelect:Bool?
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
    let admission_no : String?
    let roll_no : String?
    var isSelect:Bool?
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
    var isSelect:Bool?
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
    let emp_id:String?
    let designation:String?
    var isSelect:Bool?
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



//MARK: All SENDINg API COMMON MODEL :

struct CommonApiSuc: Codable {
    let status: Bool?
    let message: String?
    let data: [String]?
}

// MARK: - Get Voice History
struct VoiceResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [VoiceData]?
}

// MARK: - Voice Data
struct VoiceData: Codable {
    let file_path: String?
    let url: String?
    let title: String?
    let sent_on: String?
    let school_id: String?
    let header_id: String?
    let duration: Int?
}
struct TextDetailsResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [TextDetail]?
}

struct TextDetail: Codable {
    let id: String?
    let title: String?
    let content: String?
    let date: String?
}
struct HomeworkResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [Homework]?
}

struct Homework: Codable {
    let title: String?
    let description: String?
    let subject_name: String?
    let created_by: String?
    let file_path: [FilePath]? 
}
struct HomeworListkResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [HomeworkList]?
}
struct HomeworkList: Codable {
    let date: String?
    let homework: [Homework]?
}

struct FilePath: Codable {
    let url: String?
    let type: String?
    
}

struct AwsResps: Codable {
    let status: Int
    let message: String
    let data: AwsData?
}

struct AwsData: Codable {
    let presignedUrl: String
    let fileUrl: String
}

//MARK: - Get Communication List(Reciver)
struct CommunicationReciverResponse: Codable {
    let status: Bool
    let message: String
    let data: [CommunicationReciverData]
}

struct CommunicationReciverData: Codable {
    let type: String
    let id: String
    let content: String
    let title: String
    let date: String
    let time: String
    let sender_info: String
    let is_emergency : Bool
    var is_unread: Bool
    var isExpand:Bool?
    let is_archive: Bool?
    let duration : Int?
    
}

struct ReadStatusResponse: Codable {
    let status: Bool
    let message: String
    let data: [String]
}


struct get_academic_yearSuc : Codable {
    
    let status: Bool?
    let message: String?
    let data: [AcadimicYearData]?
    
}

struct AcadimicYearData : Codable {
    let id: Int?
    let year: String?
    let current_academic_year: Bool?
}

//MARK: Send Attachment

struct Send_AttachmentResponse : Codable {
    
    let status: Bool
    let message: String
    let data: [String]
    
}
struct AttachmentsResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [Attachment]?
}

struct Attachment: Codable {
    let id: String?
    let type: String?
    let title: String?
    let description: String?
    let date: String?
    let time: String?
    let sender_info: String?
    let is_unread: Bool?
    let is_archive: Bool?
    let file_path: [FilePath]?
    let iframe: String?
}

struct AttachmentFilePath: Codable {
    let path: String?
    let type:String?
}

struct StaffAttendanceResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [StaffAttendance]?
}

struct StaffAttendance: Codable {
    let name: String?
    let date: String?
    let leave_type: String?
    let attendance_type: String?
    let in_time: String?
    let out_time: String?
    let working_hours: String?
}




struct PunchHistoryResponse:Codable{
    let status:Bool?
    let message:String?
    let data:[PunchList]?
}
struct PunchList:Codable{
    let date:String?
    let timings:[puchHistoryList]?
}
struct puchHistoryList:Codable{
    let time:String?
    let punch_type:punchType?
    let device_model:String?
    let device_id:String?
}
struct punchType:Codable{
    let id:Int?
    let value:String?
}
struct StaffGeometricLocation:Codable{
    let status:Bool?
    let message:String?
    let data:[GeometricLocation]?
}
struct GeometricLocation:Codable{
    let id:Int?
    let latitude:String?
    let longitude:String?
    let location:String?
    let distance:String?
}

struct DailyCollectionResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [DailyCollectionData]?
}

struct DailyCollectionData: Codable {
    let category: String?
    let total: String?
    let fee_data: [FeeData]?
    let total_collection: String?
}

struct FeeData: Codable {
    let type_name: String?
    let amount: String?
}

//MARK: Get noticeboard
struct NoticeResponse: Codable {
 let status: Bool?
 let message: String?
 let data: [Notice]?
}

struct Notice: Codable {
    let title: String?
    let content: String?
    let created_on: String?
    let day: String?
    let visible_from: String?
    let visible_to: String?
    let intended_for: String?
    let is_management: Bool?
    let file_path: [FilePath]?
}


//MARK: Attendence

struct AttendanceReportResponse: Codable {
   
    let status: Bool?
    let message: String?
    let data: [AttenenceReportData]?
}

struct AttenenceReportData: Codable{
    
    let student_name: String?
    let admission_no: String?
    let att_status: String?
    let absent_on: String?
}
// MARK: - Root Response
struct EventResponse: Codable {
    let status: Bool
    let message: String
    let data: [EventList]
}

// MARK: - Event
struct EventList: Codable {
    let title: String
    let content: String
    let date: String
    let time: String
    let venue: String
    let file_path: [FilePath]
}

struct PendingReportsResponse: Codable {
    let status: Bool
    let message: String
    let data: [PendingReportData]
}

struct PendingReportData: Codable {
    let category: String?
    let total: String?
    let pending_data: [PendingFeeData]?
    let total_pending: String?
}

struct PendingFeeData: Codable {
    let type_name: String
    let amount: String
}
struct StudentReportResponse: Codable {
    let status: Bool
    let message: String
    let data: [StudentData]
}

struct StudentData: Codable {
    let id: String
    let name: String
    let primary_mobile: String
    let admission_no: String
    let email: String
    let profile: String
    let roll_no: String
    let gender: String
    let dob: String
    let class_id: String
    let class_name: String
    let section_id: String
    let section_name: String
    let father_name: String
    let class_teacher: String
}
// MARK:  Event Holiday

struct EventHolidayResponse: Codable{
    var status : Bool?
    var message : String?
    var data : [EventHolidayData]?
    
}

struct EventHolidayData: Codable{
    var name : String?
    var year : String?
    var date : String?
}
