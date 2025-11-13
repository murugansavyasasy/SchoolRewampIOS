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
    let child_id: String?
    let standard_name: String?
    let section_name: String?
    let school_name: String?
    let school_name_regional: String?
    let school_city: String?
    let school_logo_url: String?
    let profile: String?
    let roll_number: String?
    let display_message: String?
    var  access_token: String?
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
    let academic_year_id: Int?
    let academic_year_name: String?
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
    var isAbsent:Bool?
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
    var unread_count: Int?
    let description: String?
}

struct MenuResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [MenuData]?
}
struct MenuCountResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [MenuCount]?
}
struct MenuCount: Codable {
    let contact_details: ContactDetails?
    let menu_details: [MenuCountDetail]?
}
struct MenuCountDetail: Codable {
    let id:Int?
    let name:String?
    let unread_count:Int?
}

struct MenuData: Codable {
    let is_birthday : Bool?
    let contact_details: ContactDetails?
    let frequently_used: [MenuDetail]?
    let menus: [MenuDetail]?
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
    var playDruration:Int?
    var isPlaying:Bool?
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
    var title: String?
    var description: String?
    var subject_name: String?
    var sent_by: String?
    var file_path: [FilePath]?
    var is_completed : Bool?
    var id : String?
    var is_unread : Bool?
    var detail_id : String?
    var can_edit : Bool?
    var can_delete : Bool?
    
}




struct HomeworListkResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [HomeworkList]?
}
struct HomeworkList: Codable {
    let date: String?
    let completed_count: Int?
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
import AVFoundation
struct CommunicationReciverResponse: Codable {
    let status: Bool
    let message: String
    let data: [CommunicationReciverData]
}

class CommunicationReciverData: Codable {
    let type: String
    let id: String
    let header_id: String
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
    var playbackSeconds: Double?
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
    var id: String?
    var type: String?
    var title: String?
    var description: String?
    var date: String?
    var time: String?
    var sender_info: String?
    var sent_by: String?
    var header_id: String?
    var is_unread: Bool?
    var is_archive: Bool?
    var file_path: [FilePath]?
    var iframe: String?
    var can_edit: Bool?
    var can_delete: Bool?
    var isExpanded: Bool?
    var school_id: String?
    var target_type: String?
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
    let staff_id: String?
    let date: String?
    let leave_type: String?
    let designation: String?
    let role: String?
    let attendance_type : [String: String]?
    let in_time: String?
    let out_time: String?
    let working_hours: String?
}

struct attendanceType: Codable{
    let FD : String?
    let FH : String?
    let SH : String?
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
    let time:String?
    let visitedCount:String?
}

struct DailyCollectionResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [CollectionReportData]?
}
struct CollectionReportData: Codable {
    let collections: [DailyCollectionData]?
    let total_collection: String?
}
struct DailyCollectionData: Codable {
    let category: String?
    let total: String?
    let fee_data: [FeeData]?
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
    let id:String?
    let title: String?
    let description: String?
    let created_on: String?
    let day: String?
    let visible_from: String?
    let visible_to: String?
    let intended_for: String?
    let is_management: Bool?
    let file_path: [FilePath]?
    let iframe: String?
    let file_size: String?
    let thumbnail: String?
    let sent_by: String?
    let can_edit: Bool?
    let can_delete: Bool?
    let school_id: String?
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
    let roll_no: String?
}

struct StudentStatisticsResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [StudentStatistics]?
}

struct StudentStatistics: Codable {
    let total_working_days: Double?
    let present_days: Double?
    let absent_days: Double?
    let absent_limit: Double?
    let completed_working_days: Double?
    let upcoming_working_days: Double?
    let attendance_percentage: String?
    let weekly_status: WeeklyStatus?
}

struct WeeklyStatus: Codable {
    let start: String?
    let end: String?
    let student_name: String?
    let att_list: [String]?
}


struct EventResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [EventSection]?
}


struct EventSection: Codable {
    let categories: [EventCategory]?
    let on_going: [EventList]?
    let up_coming: [EventList]?
    let completed: [EventList]?
}
// MARK: - EventCatagoryResponse
struct EventCategoryResponse: Codable {
    let status: Bool
    let message: String
    let data: [EventCategory]
}
struct EventCategory: Codable {
    let id: Int?
    let name: String?
    let url: String?
}
struct EventList: Codable {
    let id :String?
    let title: String?
    let category: String?
    let description: String?
    let school_id: String?
    let date: String?
    let time: String?
    let venue: String?
    let iframe: String?
    let file_size: String?
    let thumbnail: String?
    let sent_by: String?
    let can_edit: Bool?
    let can_delete: Bool?
    let file_path: [FilePath]?
}
struct PendingReportsResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [PendingReportData]?
}

struct PendingReportData: Codable {
    let pending_details: [PendingDetail]?
    let total_pending: String?
}

struct PendingDetail: Codable {
    let category: String?
    let total: String?
    let pending_data: [FeeData]?
}


struct StudentReportResponse: Codable {
    let status: Bool
    let message: String
    let data: [StudentData]
}

struct StudentData: Codable {
    let id: String
    let name: String
    let primary_mobile: String?
    let admission_no: String
    let email: String?
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


//MARK: School Strength
struct SchoolStrengthResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [SchoolStrength]?
}


struct SchoolStrength: Codable {
    let previous : Previous?
    let total_student_strength: String?
    let total_staff_strength: String?
    let total_male_staffs_strength: String?
    let total_female_staffs_strength: String?
    let total_boys_strength: String?
    let total_girls_strength: String?
    let total_others_strength: String?
    let standards: [Standard]?
}

 struct Previous: Codable {
    let total_student_strength: String?
    let total_male_staffs_strength: String?
    let total_female_staffs_strength: String?
    let total_other_staffs_strength: String?
    let total_boys_strength: String?
    let total_girls_strength: String?
    let total_others_strength: String?
    let total_staff_strength: String?
    let message : String?
}
struct Standard: Codable {
    let id: String?
    let name: String?
    let level: String?
    let boys_count: String?
    let girls_count: String?
    let other_count: String?
    let total_students: String?
    let sections: [SectionList]?
}

struct SectionList: Codable {
    let name: String?
    let level: String?
    let id: String?
    let boys_count: String?
    let girls_count: String?
    let other_count: String?
    let total_students: String?
}


//MARK: Student attandance
struct StudentAttendanceResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [StudentAttendance]?
}

struct StudentAttendance: Codable {
    let date : String?
    let day : String?
    let type : String?
    let is_Archive : Bool?
}

// MARK: - Absentees Report
struct AbsenteesResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [AbsenteeDate]?
}

struct AbsenteeDate: Codable {
    let date: String?
    let day: String?
    let absent_date_only: String?
    let total_absentees: String?
    let class_wise: [ClassWise]?
}

struct ClassWise: Codable {
    let class_id: String?
    let student_counts: String?
    let class_name: String?
    let total_absentees: String?
    let section_wise: [SectionWise]?
}

struct SectionWise: Codable {
    let section_id: String?
    let section_name: String?
    let total_absentees: String?
    let student_counts: String?
}



//MARK: Absentis Report Student Report


struct AbsentisReportStudentResponse: Codable {
    let status: Bool
    let message: String
    let data: [AbsentisReportStudent]
}

struct AbsentisReportStudent: Codable {
    let student_id: String?
    let student_name: String?
    let roll_no: String?
    let admission_no: String?
    let photo_path: String?
    let primary_mobile: String?
    let gender: String?
    let attd_status: String?
    
}

//MARK: Leave Request History

//struct LeaveInfoResponse: Codable {
//    let status: Bool
//    let message: String
//    let data: [LeaveInfo]
//}

//struct LeaveInfo: Codable {
//    let id: String
//    let applied_on: String
//    let student_name: String
//    let class_name: String
//    let section_name: String
//    let leave_from: String
//    let leave_to: String
//    let no_of_days: String
//    let reason: String
//    var status: String
//    var updated_on: String
//}

struct LeaveInfoResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [LeaveMonth]?
}

struct LeaveMonth: Codable {
    var month: String?
    var details: [LeaveInfo]?
}

struct LeaveInfo: Codable {
    var id: String?
    var applied_on: String?
    var student_name: String?
    var class_name: String?
    var section_name: String?
    var leave_from: String?
    var leave_to: String?
    var no_of_days: String?
    var reason: String?
    var status: String?
    var updated_on: String?
    var from_session: String?
    var to_session: String?
    var approved_by: String?
    var leave_type: String?
}

////MARK: ASSIGINMENT LIST
//struct AssignmentResponse: Codable {
//    var status: Bool?
//    var message: String?
//    var data: [Assignment]?
//}

//struct Assignment: Codable {
//    var id: String?
//    var header_id: String?
//    var title: String?
//    var description: String?
//    var category: String?
//    var subject: String?
//    var date: String?
//    var time: String?
//    var submitted_count: Int?
//    var end_date: String?
//    var is_unread: Bool?
//    var sent_by: String?
//    var sort_order: String?
//    var is_archive: Bool?
//    var iframe: String?
//    var file_size: String?
//    var file_path: [FilePath]?
//}
//MARK: ASSIGNMENT MY SUBMISION
struct SubmissionResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [Submission]?
}

struct Submission: Codable {
    let id: String?
    let description: String?
    let tittle: String?
    let submitted_on: String?
    let file_path: [FilePath]?
}

//MARK: Lesson Plan

struct LessonPlanStaffReportResponse: Codable {
    let status: Bool
    let message: String
    let data: [LessonPlanStaffReport]
}

struct LessonPlanStaffReport: Codable {
    var  section_subject_id: String
    var  staff_name: String
    var  class_name: String
    var  section_name: String
    var  subject_name: String
    var  completed_items: String
    var  total_items: String
    var  percentage_value: Int
    var  items_completed: String
}

struct LessonPlanDetailResponse: Codable {
    let status: Bool
    let message: String
    let data: [LessonPlanDetail]
}

struct LessonPlanDetail: Codable {
    let particular_id: String
    let lesson_plan_status: Int
    let details: [LessonDetailItem]
}

struct LessonDetailItem: Codable {
    let name: String?
    let value: String?
}

struct LessonEditResponse: Codable {
    let status: Bool?
    let message: String?
    var data: [LessonEditData]?
}

struct LessonEditData: Codable {
    let id: String?
    let name: String?
    let field_id: String?
    var value: String?
    let field_type: String?
    let field_name: String?
    let field_data: [String]?
    let is_disable: Bool?
}

 

// MARK: Packet Modal
//

struct ActivateCouponResponse: Codable {
    var status: Bool?
    var message: String?
    var data: CouponDetails?
}

struct CouponDetails: Codable {
    var coupons: [Coupons]?
    var merchant_logo: String?
    var offer: String?
    var redirect_url: String?
    var isCTAvalid: Bool?
    var CTAname: String?
    var CTAredirect: String?
}

struct Coupons: Codable {
    var coupon_code: String?
    var qr_code: String?
    var expiry_date: String?
}





struct CampaignResponse: Codable {
    var status: Bool?
    var message: String?
    var data: CampaignDetailsData?
}

struct CampaignDetailsData: Codable {
    var campaign_details: CampaignDetails?
}

struct CampaignDetails: Codable {
    var campaign_name: String?
    var expiry_date: String?
    var cover_image: String?
    var merchant_name: String?
    var threshold_amount: String?
    var offer_text: String?
    var offer_type: String?
    var discount: Int?
    var how_to_use: String?
    var terms_and_conditions: String?
    var merchant_logo: String?
    var campaign_type: String?
    var coupon_valid_for: String?
    var customer_buys_value: String?
    var customer_gets_value: String?
    var template_file: String?
    var offer_to_show: String?
    var expiry_type: String?
    var points: String?
}



struct CampaignsResponse: Codable {
    var status: Bool?
    var message: String?
    var data: CampaignData?
}

struct CampaignData: Codable {
    var total_count: Int?
    var campaigns: CampaignPagination?
}

struct CampaignPagination: Codable {
    var current_page: Int?
    var data: [Campaign]?
    var first_page_url: String?
    var from: Int?
    var next_page_url: String?
    var path: String?
    var per_page: String?
    var prev_page_url: String?
    var to: Int?
    
}

struct Campaign: Codable {
    var temp_id: Int?
    var source_link: String?
    var campaign_name: String?
    var campaign_type: String?
    var threshold_amount: String?
    var offer_text: String?
    var thumbnail: String?
    var expiry_date: String?
    var end_date: String?
    var offer_type: String?
    var discount: Int?
    var merchant_name: String?
    var category_name: String?
    var category_image: String?
    var points: String?
    var merchant_logo: String?
    var offer_to_show: String?
    var coupon_status: String?
    var coupon_code: String?
    var isCTAvalid: Bool?
}


struct CategoriesResponse: Codable {
    var status: Bool?
    var message: String?
    var data: CategoryData?
}

struct CategoryData: Codable {
    var categories: [Categorys]?
    var total_pages: Int?
}

struct Categorys: Codable {
    var id: Int?
    var category_name: String?
    var category_image: String?
    
    init(id: Int, category_name: String) {
        self.id = id
        self.category_name = category_name
    }
}


struct MyCouponResponse: Codable {
    let status: Bool?
    let data: CouponData?
    let message: String?
}

struct CouponData: Codable {
    let couponList: CouponList?
    let totalPages: Int?

    enum CodingKeys: String, CodingKey {
        case couponList = "coupon_list"
        case totalPages = "total_pages"
    }
}

struct CouponList: Codable {
    let firstPageURL: String?
    let nextPageURL: String?
    let currentPage: Int?
    let from: Int?
    let to: Int?
    let path: String?
    let data: [Coupon]?

    enum CodingKeys: String, CodingKey {
        case firstPageURL = "first_page_url"
        case nextPageURL = "next_page_url"
        case currentPage = "current_page"
        case from, to, path, data
    }
}

struct Coupon: Codable {
    let qrCode: String?
    let campaignType: String?
    let ctaName: String?
    let merchantName: String?
    let expiryDate: String?
    let coverImage: String?
    let industryName: String?
    let couponStatus: String?
    let sourceLink: String?
    let templateFiles: [String]?
    let expiresIn: Int?
    let merchantID: Int?
    let discount: Int?
    let offerType: String?
    let id: Int?
    let categoryName: String?
    let locationList: [Location]?
    let aboutMerchant: String?
    let couponCode: String?
    let offerToShow: String?
    let expiryType: String?
    let campaignName: String?
    let merchantLogo: String?
    let ctaURL: String?
    let isCTAvalid: Bool?
    let ctaRedirect: String?
    let howToUse: String?
    let termsAndConditions: String?

    enum CodingKeys: String, CodingKey {
        case qrCode = "qr_code"
        case campaignType = "campaign_type"
        case ctaName = "CTAname"
        case merchantName = "merchant_name"
        case expiryDate = "expiry_date"
        case coverImage = "cover_image"
        case industryName = "industry_name"
        case couponStatus = "coupon_status"
        case sourceLink = "source_link"
        case templateFiles = "template_files"
        case expiresIn = "expires_in"
        case merchantID = "merchant_id"
        case offerType = "offer_type"
        case categoryName = "category_name"
        case locationList = "location_list"
        case aboutMerchant = "about_merchant"
        case couponCode = "coupon_code"
        case offerToShow = "offer_to_show"
        case expiryType = "expiry_type"
        case campaignName = "campaign_name"
        case merchantLogo = "merchant_logo"
        case ctaURL = "cta_url"
        case isCTAvalid = "isCTAvalid"
        case ctaRedirect = "CTAredirect"
        case howToUse = "how_to_use"
        case termsAndConditions = "terms_and_conditions"
        case discount, id
    }
}

struct Location: Codable {
    let longitude: String?
    let latitude: String?
    let locationName: String?

    enum CodingKeys: String, CodingKey {
        case locationName = "location_name"
        case longitude, latitude
    }
}


struct GetCoinResponse: Codable {
    var status: Int?
    var message: String?
    var data: GetCoinData?
}

struct GetCoinData: Codable {
    var pointsEarned : Int?
    var pointsSpent : Int?
    var pointsRemaining : Int?
    var pointsPerCoupon : Int?
}

// MARK: - Assignment List Response

struct AssignmentReportResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [Report]?
}

struct Report: Codable {
    let id: String?
    let header_id: String?
    let title: String?
    let description: String?
    let category: String?
    let subject: String?
    let date: String?
    let time: String?
    let school_id: String?
    let school_name: String?
    let recipient_type: String?
    let target_type: String?
    let created_date: String?
    let created_time: String?
    let progress: Float?
    let submitted_count: Int?
    let total_count: Int?
    let end_date: String?
    let is_unread: Bool?
    let sent_by: String?
    let can_edit: Bool?
    let can_delete: Bool?
    let sort_order: String?
    let is_archive: Bool?
    let iframe: String?
    let file_size: String?
    let thumbnail: String?
    let file_path: [FilePath]?
}

// MARK: - Student Submission Report

struct StudentSubmissionResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [StudentSubmission]?
}

struct StudentSubmission: Codable {
    let student_id: String?
    let student_name: String?
    let standard: String?
    let section: String?
    let submit_status: String?
    let is_archive: Bool?
    let submissions_details: [SubmissionDetail]?
}

struct SubmissionDetail: Codable {
    let id: String?
    let description: String?
    let submitted_on: String?
    let iframe: String?
    let file_size: String?
    let file_path: [FilePath]?
}

//MARK: Message from management

struct MessageFromManagementResp: Codable {
    let status: Bool?
    let message: String?
    let data: [ManagemantMessageData]?
}

struct StaffListResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [StaffMember]?
}

struct StaffMember: Codable {
    let id: String?
    let name: String?
    let is_blocked: Bool?
    let profile: String?
    let subject_id: String?
    let subject_name: String?
    let is_assigned: Bool?
    let is_class_teacher: Bool?
    var unread_count: Int?
    let last_msg_time: String?
    let last_msg: String?
    let section_id: String?
    let section_name: String?
    init() {
        self.id = nil
        self.name = nil
        self.is_blocked = nil
        self.profile = ""
        self.subject_id = nil
        self.subject_name = nil
        self.is_assigned = nil
        self.is_class_teacher = nil
        self.unread_count = nil
        self.section_id = nil
        self.section_name = nil
        self.last_msg_time = nil
        self.last_msg = nil
    }
    
}




struct ChatMessageSuc: Codable {
    
    var status : Bool?
    var message: String?
    var data :[ChatMessage]?
}

struct ChatMessage: Codable {
    let question_id: String?
    let question: String?
    let student_id: String?
    let student_name: String?
    let asked_on: String?
    let quesfilepath: [MediaFile]?
    let reply_type: String?
    let answer: String?
    let answered_on: String?
    let ansfilepath: [MediaFile]?
    let chat_count: Int?
    let my_question: Bool?
}

struct StaffChatResponse: Codable {
    
    var status : Bool?
    var message: String?
    var data :[StaffChatMessage]?
}

struct StaffChatMessage: Codable {
    
        var id: String?
        var question: String?
        var student_id: String?
        var student_name: String?
        var is_blocked: Bool?
        var reason: String?
        var created_on: String?
        var chat_count: Int?
        var ques_file_path: [String]?
        var answer: String?
        var answer_on: String?
        var change_answer: Bool?
        var ans_file_path: [String]?
        var reply_type: String?
}

struct BlockedStudentsResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [BlockedStudent]?
}

struct BlockedStudent: Codable {
    var id: String?
    var name: String?
    var gender: String?
    var blocked_on: String?
}


struct MediaFile: Codable {
    let url: String
    let type: String  // Example: "IMAGE", "PDF", etc.
}

struct ChatSection {
    let date: String              // e.g. "03 Jul 2025"
    let messages: [ChatMessage]  // messages under that date
}




struct MessageSuc: Codable {
    let status: Bool?
    let message: String?
    let data: [MessageSucResp]?
}

struct MessageSucResp: Codable {
    let  id : String?
    let  name : String?
    let  section_id : String?
    let  question : String?
    let  created_on : String?
    let  chat_count : Int?
    let  file_path : [String]?
}


struct StaffAnswerResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [AnswerData]?
}

struct AnswerData: Codable {
    let question_id: String?
    let answer: String?
    let answer_on: String?
    let reply_type: String?
    let created_on: String?
    let file_path: [MediaFile]?
}

struct ManagemantMessageData: Codable {
    var type: String?
    var id: String?
    var header_id: String?
    var title: String?
    var description: String?
    var content: String?
    var file_path: [FilePath]?
    var iframe: String?
    var file_size: String?
    var thumbnail: String?
    var date: String?
    var time: String?
    var sender_info: String?
    var sent_by: String?
    var role: String?
    var school_id: String?
    var school_name: String?
    var is_unread: Bool?
    var is_archive: Bool?
    var is_emergency: Bool?
    var duration: Int?
    
    // Local-only fields (not part of API)
    var order_date: String?
    var isExpand: Bool?
}

//MARK: CLASS TIMETABLE
struct TimetableResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [TimetableHour]?
}

struct TimetableHour: Codable {
    let name: String?
    let start_time: String?
    let end_time: String?
    let duration: String?
    let order: Int?
    let hour_type: String?
    let subject_name: String?
    let staff_name: String?
    let facalty_name: String?
}

//MARK: Certificate
struct CertificateResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [CertificateRequest]?
}

struct CertificateRequest: Codable {
    var url: String?
    var type: String?
    var reason: String?
    var urgency_level: String?
    var requested_on: String?
    var status: String?
    var issued_on: String?
    var message: String?
}
//MARK: DetailedExamList
struct DetailedExamListResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [DetailedExamItem]?
}

struct DetailedExamItem: Codable {
    var id: String?
    var name: String?
    var description: String?
    var created_on: String?
    var exam_subject_details: [SubjectDetail]?
}

struct SubjectDetail: Codable {
    var subject_name: String?
    var exam_date: String?
    var exam_session: String?
    var max_mark: String?
    var syllabus: String?
    var start_time: String?
    var end_time: String?
}

//MARK: ExamList
struct ExamListResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [ExamItem]?
}

struct ExamItem: Codable {
    var id: String?
    var name: String?
    var mark_id: String?
    var is_unread: Bool?
}
//MARK: ExamMarks
struct ExamMarksResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [ExamData]?
}

struct ExamData: Codable {
    var subject_marks: [SubjectMark]?
    var assessments: [Assessment]?
    var groups: [Groups]?
    var is_unread: Bool?
}

struct SubjectMark: Codable {
    var name: String?
    var split: [SplitMark]?
    var max_mark: String?
    var mark_obtained: String?
    var percentage: String?
}

struct SplitMark: Codable {
    var name: String?
    var max_mark: String?
    var mark_obtained: String?
}

struct Assessment: Codable {
    var Rank: String?
    var Total: String?
    var PresentDays: String?
    var TotalWorkingDays: String?
    var Remarks: String?
    var Percentage: String?
    var total_mark: String?
    var total_obtained: String?
    var grade: String?
    var message: String?
}

struct Groups: Codable {
    var name: String?
    var mark: String?
    var subgroups: [SubGroup]?
}

struct SubGroup: Codable {
    var name: String?
    var mark: String?
}

struct FileData: Codable {
    var url: String
    var type: String // "image", "video", "audio", "document", etc.
}

struct LSRW: Codable {
    var title: String
    var description: String
    var subject: String
    var submitedOn: String
    var duration: String
    var recording: String
    var iframe:String
    var type:String //read ,write,listen,speach
    var filePath: [FileData]
    var test:[TestQuestion]
}

struct SkillListResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [SkillData]?
}

struct SkillData: Codable {
    let id: String?
    let detail_id: String?
    let title: String?
    let description: String?
    let activity_type: String?
    let subject: String?
    let date: String?
    let time: String?
    let submitted_date: String?
    let is_submitted: Bool?
    let is_unread: Bool?
    let sent_by: String?
    let iframe: String?
    let file_size: String?
    let thumbnail: String?
    let file_path: [FilePath]?
    var test:[TestQuestion]?
    var duration: String?
}




struct TestQuestion: Codable {
    var question: String
    var options: [String]
}


//MARK: PTM Model class

struct PTMSlotResponse: Codable {
    let status: Bool
    let message: String
    let data: [SlotDateData]?
}

struct SlotDateData: Codable {
    let today: [EventGroup]?
    let upcoming: [EventGroup]?
    let completed: [EventGroup]?
}

struct EventGroup: Codable {
    let details: [SlotEventDetail]?
}

struct SlotEventDetail: Codable {
    let date: String?
    let start_time: String?
    let end_time: String?
    let event_name: String?
    let event_mode: String?
    let meeting_duration: Int?
    let break_duration: Int?
    let profiles: [String]?
    var slots: [SlotItem]?
    let std_sec_details: [ClassSectionDetail]?
}

struct SlotItem: Codable {
    let slot_id: String?
    let from_time: String?
    let to_time: String?
    var is_cancelled: Bool?
    var is_booked: Bool?
    let booked_by: String?
    let my_class: String?
    let my_section: String?
    let profile_url: String?
    let mobile_no: String?
    var status: String?
    let event_name: String?
    let event_mode: String?
    let meeting_duration: Int?
    let break_duration: Int?
    var is_cancelled_by_staff: Bool?
    let date: String?
    let sent_by: String?
    let can_cancel: Bool?
}

struct ClassSectionDetail: Codable {
    let class_id: String?
    let section_id: String?
    let class_name: String?
    let section_name: String?
}


struct SlotValidationResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [ValidatedSlotData]?
}

struct ValidatedSlotData: Codable {
    var institute_id: String?
    var staff_id: String?
    var break_time: Int?
    var date: String?
    var duration: Int?
    var event_name: String?
    var meeting_mode: String?
    var from_time: String?
    var to_time: String?
    var slots: [Slot]?
    var std_sec_details: [StdSecDetail]?
}

struct Slot: Codable {
    var slot_from: String?
    var slot_to: String?
    var slot_availablity: String?
    var type: Int?
}

struct StdSecDetail: Codable {
    var class_id: String?
    var section_id: String?
}

struct ValidatedSlot: Codable {
    var slot_from: String?
    var slot_to: String?
    var type: Int?
    var slot_availablity: String?
}

//MARK: Student PTM

struct StudentSlotResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [EventData]?
}

struct EventData: Codable {
    var staff_id: String?
    var staff_name: String?
    var event_name: String?
   // var subject_name: String?
    var start_time: String?
    var end_time: String?
    var slots: [StudentSlot]?
}

struct StudentSlot: Codable {
    let id: String?
    let slot_from: String?
    let slot_to: String?
    let is_booked: Bool?
    let staff_id: String?
    let staff_name: String?
    let subject_name: [String]?
    let event_name: String?
    let event_mode: String?
    let event_link: String?
    let my_booking: Bool?

    // Local state (not from API)
    var userSelected: Bool? = false // temporary selection
    var is_conflictDisabled: Bool? = false // disabled due to overlap
}

struct SubjectListResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [Subject]?
}

struct Subject: Codable {
    var id: String?
    var name: String?
}

struct SlotDetailsResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [SlotCategory]?
}

struct SlotCategory: Codable {
    var today: [BookedSlotItem]?
    var upcoming: [BookedSlotItem]?
    var completed: [BookedSlotItem]?
}

struct BookedSlotItem: Codable {
    var id: String?
    var date: String?
    var time: String?
    var status: String?
    var purpose: String?
    var mode: String?
    var event_link: String?
    var staff_id: String?
    var staff_name: String?
    var subject_name: [String]?
    var duration: Int?
    var staff_mobile_no: String?
}

struct AvailableSlotsResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [AvailableSlot]?
}

struct AvailableSlot: Codable {
    var event_date: String?
    var count: String?
}


//-----------------------------------------------
struct LSRWReportResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [LSRWData]?
}
struct LSRWListResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [LSRWTask]?
}
// MARK: - Top level "data"
struct LSRWData: Codable {
    let overview: [Overview]?
    let active: [LSRWTask]?
    let completed: [LSRWTask]?
}

// MARK: - Overview
struct Overview: Codable {
    let title: String?
    let value: String?
    let subtitle: String?
}

// MARK: - Task
struct LSRWTask: Codable {
    let id: String?
    let detail_id: String?
    let title: String?
    let description: String?
    let sent_to: String?
    let activity_type: LSRWType?
    let subject: String?
    let date: String?
    let time: String?
    let submitted_date: String?
    let is_submitted: Bool?
    let is_unread: Bool?
    let sent_by: String?
    let created_on: String?
    let iframe: String?
    let file_size: String?
    let thumbnail: String?
    let file_path: [FilePath]?
    var test: [TestQuestion]?
    let submittedCount: Int?
    let totalCount: Int?
    let submitted_average: String?
}

// MARK: - Enum for activity_type
enum LSRWType: Codable {
    case listening
    case speaking
    case reading
    case writing
    case unknown(String)  // store raw value if it doesn't match

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = (try? container.decode(String.self)) ?? ""

        switch rawValue.lowercased() {
        case "listening": self = .listening
        case "speaking":  self = .speaking
        case "reading":   self = .reading
        case "writing":   self = .writing
        default:          self = .unknown(rawValue)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .listening: try container.encode("Listening")
        case .speaking:  try container.encode("Speaking")
        case .reading:   try container.encode("Reading")
        case .writing:   try container.encode("Writing")
        case .unknown(let value): try container.encode(value)
        }
    }

    var icon: String {
        switch self {
        case .listening: return "🎧"
        case .speaking:  return "🎤"
        case .reading:   return "📖"
        case .writing:   return "✏️"
        case .unknown:   return "❓"
        }
    }

    var displayName: String {
        switch self {
        case .listening: return "Listening"
        case .speaking:  return "Speaking"
        case .reading:   return "Reading"
        case .writing:   return "Writing"
        case .unknown(let value): return value
        }
    }
}
extension LSRWType {
    init(_ rawValue: String) {
        switch rawValue.lowercased() {
        case "listening": self = .listening
        case "speaking":  self = .speaking
        case "reading":   self = .reading
        case "writing":   self = .writing
        default:          self = .unknown(rawValue)
        }
    }
}




struct notificationSuc : Codable{
    
    let status : Bool?
    let message : String?
    let data : [notificationData]?
}

struct notificationData : Codable{
    let menu_id : Int?
    let menu_name : String?
    var details : [notificationDetails]?
    
}

struct notificationDetails : Codable{
    let id : String?
    let name : String?
    let member_id : String?
    let type : String?
    let menu_id : Int?
    let message : String?
    let sent_on : String?
    let header_id : String?
    let device : String?
}

struct QuizListSuc : Codable{
    
    let status : Bool?
    let message : String?
    let data : [QuizListData]?

}

struct senderQuizListSuc : Codable{
    
    let status : Bool?
    let message : String?
    let data : [senderQuizListData]?

}

           

           
struct QuizListData : Codable{
    let id : String?
    let standard : String?
    let mark : String?
    let type_name : String?
    let submission_date : String?
    let section : String?
    let sent_time : String?
    let quiz_id : String?
    let title : String?
    let description : String?
    let max_mark : Int?
    let subject_id : String?
    let subject : String?
    let level : Int?
    let submitted_on : String?
    let created_on : String?
    let is_submitted : Bool?
    let is_unread : Bool?
    let SentBy : String?
    let sent_by : String?
    let no_of_questions : Int?
    let right_answer : Int?
    let wrong_answer : Int?
    let submitted_count : Int?
    let total_mark : String?
    let no_of_levels : String?
}
    

struct QuizStudentReportSuc : Codable{
    
    let status : Bool?
    let message : String?
    let data : [QuizStudentReportData]?
}
struct QuizStudentReportData : Codable{
    var id : String?
    var standard : String?
    var section : String?
    var student_name : String?
    var mobile_no : String?
    var is_submitted : String?
    var is_submit : Bool?
    var submitted_on : String?
    var gender : String?
    var is_unread : Bool?

}
        
            
struct senderQuizListData : Codable{
    var id : String?
    var sent_time : String?
    var title : String?
    var description : String?
    var standard : String?
    var section : String?
    var level : Int?
    var subject_id : String?
    var subject : String?
    var sent_by : String?
    var submission_date : String?
    var type_name : String?
    var no_of_questions : Int?
    var submitted_count : Int?
    var mark : String?
    
}

struct QuizQuestionSuc : Codable{
    
    let status : Bool?
    let message : String?
    let data : [QuizQuestionData]?
}
struct QuizQuestionData : Codable{
    
    let level : Int?
    let total_questions : Int?
    let question_details : [QuizQuestionDataDetails]?
    
}

struct QuizQuestionDataDetails : Codable{
    let id : String?
    let question : String?
    let mark : Int?
    let correctOptionIndex : Int?
    let options : [String]?
    var file_path: [FilePath]?
}

struct QuizaddQuestionSuc : Codable{
    
    let status : Bool?
    let message : String?
    let data : [QuizQuestiondata]?
}



struct MyQuizSuc: Codable {
    var status : Bool?
    var message : String?
    var data : [myQuizDetails]?
}

struct myQuizDetails : Codable  {
    var student_id : String?
    var right_answer : String?
    var wrong_answer : String?
    var un_answer : String?
    var quiz_details : [MyQuizDetails]?
            
}
struct MyQuizDetails : Codable  {
    var id : String?
    var quiz_id : String?
    var question : String?
    var a_option : String?
    var b_option : String?
    var c_cption : String?
    var d_option : String?
    var mark : Int?
    var student_answer : String?
    var correct_answer : String?
    var file_path : [FilePath]?
    
}


//struct QuizQuestiondata: Codable {
//    var ques_no: String?
//    var id: String?         // for Quizdata from API
//    var quiz_id: String?     // for API
//    var chapter: String
//    var question: String
//    var answer: String?
//    var a_option: String
//    var b_option: String
//    var c_option: String
//    var d_option: String
//    var mark:Int?
//    var option_a_count:Int?
//    var option_b_count:Int?
//    var option_c_count:Int?
//    var option_d_count:Int?
//    var correct_answer_count:Int?
//    var incorrect_answer_count:Int?
//    var correct_answer_text:String?
//    var correct_answer: String?
//    var file_path: [FilePath]?
//    
//    // Local init for empty question (when adding manually)
//    init(
//        id: String? = nil,
//        ques_no: String? = nil,
//        quizId: String? = nil,
//        chapter: String = "",
//        question: String = "",
//        answer: String? = nil,
//        optionA: String = "",
//        optionB: String = "",
//        optionC: String = "",
//        optionD: String = "",
//        marks: Int = 0,
//        correctAnswer: String? = nil,
//        filePath: [FilePath]? = nil,
//        filePaths: [FilePaths]? = nil
//    ) {
//        self.id = id
//        self.quiz_id = quizId
//        self.chapter = chapter
//        self.question = question
//        self.answer = answer
//        self.a_option = optionA
//        self.b_option = optionB
//        self.c_option = optionC
//        self.d_option = optionD
//        self.mark = marks
//        self.ques_no = ques_no
//        self.correct_answer = correctAnswer
//        self.file_path = filePath
//    
//    }
//}

struct QuizQuestiondata: Codable {
    var id: String?
    var quiz_id: String?
    var chapter: String
    var question: String
    var answer: String?
    var a_option: String
    var b_option: String
    var c_option: String
    var d_option: String
    var mark: Int?
    var option_a_counts: Int?
    var option_b_counts: Int?
    var option_c_counts: Int?
    var option_d_counts: Int?
    var correct_answer_counts: Int?
    var incorrect_answer_counts: Int?
    var correct_answer_text: String?
    var file_path: [FilePath]?

    init(
        id: String? = nil,
        quiz_id: String? = nil,
        chapter: String = "",
        question: String = "",
        answer: String? = nil,
        a_option: String = "",
        b_option: String = "",
        c_option: String = "",
        d_option: String = "",
        mark: Int? = nil,
        option_a_counts: Int? = nil,
        option_b_counts: Int? = nil,
        option_c_counts: Int? = nil,
        option_d_counts: Int? = nil,
        correct_answer_counts: Int? = nil,
        incorrect_answer_counts: Int? = nil,
        correct_answer_text: String? = nil,
        file_path: [FilePath]? = nil
    ) {
        self.id = id
        self.quiz_id = quiz_id
        self.chapter = chapter
        self.question = question
        self.answer = answer
        self.a_option = a_option
        self.b_option = b_option
        self.c_option = c_option
        self.d_option = d_option
        self.mark = mark
        self.option_a_counts = option_a_counts
        self.option_b_counts = option_b_counts
        self.option_c_counts = option_c_counts
        self.option_d_counts = option_d_counts
        self.correct_answer_counts = correct_answer_counts
        self.incorrect_answer_counts = incorrect_answer_counts
        self.correct_answer_text = correct_answer_text
        self.file_path = file_path
    }
}


struct QuestionsResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [QuestionItem]?
}

struct QuestionItem: Codable {
    var id: String?
    var topic: String?
    var chapter: String?
    var class_id: String?
    var section_id: String?
    var subject_id: String?
    var level: Int?
    var question: String?
    var answer: String?
    var a_option: String?
    var b_option: String?
    var c_option: String?
    var d_option: String?
    var correct_answer_text: String?
    var mark: Int?
}


struct SubmittedActivitiesResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [SubmittedActivity]?
}

struct SubmittedActivity: Codable {
    let id: String?
    let header_id: String?
    let submitted_date: String?
    let iframe: String?
    let file_size: String?
    let thumbnail: String?
    let file_path: [FilePath]?
}
 //MARK: LSRWSUBMISION
struct LSWSubmissionResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [LSRWStudent]?
}

struct LSRWStudent: Codable {
    let id: String?
    let student_id: String?
    let student_name: String?
    let standard: String?
    let description: String?
    let header_id: String?
    let remark: String?
    let section: String?
    let mobile_no: String?
    let submit_status: String?
    let submitted_date: String?
    let iframe: String?
    let file_size: String?
    let thumbnail: String?
    let file_path: [FilePath]?
}
// MARK: - Main Response
struct SkillResponse: Codable {
    let status: Bool
    let message: String
    let data: [PerformanceData]
}

// MARK: - Skill Data
struct PerformanceData: Codable {
    let today_submitted: [SkillSubmission]?
    let listening: SkillCategory?
    let speaking: SkillCategory?
    let reading: SkillCategory?
    let writing: SkillCategory?
}

// MARK: - Skill Category
struct SkillCategory: Codable {
    let over_all_percentage: String?
    let student_count: String?
    let details: [SkillSubmission]?
}

// MARK: - Skill Submission
struct SkillSubmission: Codable {
    let id: String?
    let title: String?
    let description: String?
    let activity_type: String?
    let sent_by: String?
    let subject: String?
    let submitted_average: String?
    let member_count: Int?
    let submission_date: String?
    let submitted_count: Int?
    let student_id: String?
    let student_name: String?
    let remark: String?
    let std_sec: String?
    let student_submited_on: String?
    let is_submitted: Bool?
    let file_path: [FilePath]?
    let created_on: String?
}
// MARK: - Main Response Structure
struct UserProfileResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [ProfileData]?
}

// MARK: - Profile Data Structure
struct ProfileData: Codable {
    var general: [UserDetailItem]?
    var fatherDetails: [UserDetailItem]?
    var motherDetails: [UserDetailItem]?
    var communication: [UserDetailItem]?
    var address: [UserDetailItem]?
    var physical: [UserDetailItem]?
    var identifiers: [UserDetailItem]?
    var community: [UserDetailItem]?
    var bankDetails: [UserDetailItem]?
    var photoPath: [UserDetailItem]?
    var documents: [UserDetailItem]?
    var transportDetails: [UserDetailItem]?
    
    enum CodingKeys: String, CodingKey {
        case general = "General"
        case fatherDetails = "Father Details"
        case motherDetails = "Mother Details"
        case communication = "Communication"
        case address = "Address"
        case physical = "Physical"
        case identifiers = "Identifiers"
        case community = "Community"
        case bankDetails = "Bank Details"
        case photoPath = "PhotoPath"
        case documents = "Documents"
        case transportDetails = "Transport Details"
    }
}

// MARK: - User Detail Item
struct UserDetailItem: Codable {
    var title: String
    var type: UserDetailFieldType
    var value: String?
    var is_editable: Bool?
    var optional: Bool?
    var options: [String]?
    var file_path: [DocumentFile]? 
    var node: String?
    
}
struct DocumentFile: Codable {
    var documentPath: String?
    var documentName: String?
    var documentDisplayName: String?
    var isViewChange: Int?
}

// MARK: - Field Types
enum UserDetailFieldType: String, Codable {
    case text
    case address
    case mobile
    case calendar
    case gender
    case dropdown
    case number
    case image
    case document
}

// MARK: - Helper Struct for UI Display (Optional)
struct ProfileSection {
    let title: String
    let items: [UserDetailItem]
}

// MARK: - Extension for easier data access
extension ProfileData {
    func getAllSections() -> [ProfileSection] {
        var sections: [ProfileSection] = []
        
        if let general = general, !general.isEmpty {
            sections.append(ProfileSection(title: "General", items: general))
        }
        if let fatherDetails = fatherDetails, !fatherDetails.isEmpty {
            sections.append(ProfileSection(title: "Father Details", items: fatherDetails))
        }
        if let motherDetails = motherDetails, !motherDetails.isEmpty {
            sections.append(ProfileSection(title: "Mother Details", items: motherDetails))
        }
        if let communication = communication, !communication.isEmpty {
            sections.append(ProfileSection(title: "Communication", items: communication))
        }
        if let address = address, !address.isEmpty {
            sections.append(ProfileSection(title: "Address", items: address))
        }
        if let physical = physical, !physical.isEmpty {
            sections.append(ProfileSection(title: "Physical", items: physical))
        }
        if let identifiers = identifiers, !identifiers.isEmpty {
            sections.append(ProfileSection(title: "Identifiers", items: identifiers))
        }
        if let community = community, !community.isEmpty {
            sections.append(ProfileSection(title: "Community", items: community))
        }
        if let bankDetails = bankDetails, !bankDetails.isEmpty {
            sections.append(ProfileSection(title: "Bank Details", items: bankDetails))
        }
        if let photoPath = photoPath, !photoPath.isEmpty {
            sections.append(ProfileSection(title: "Photo", items: photoPath))
        }
        if let documents = documents, !documents.isEmpty {
            sections.append(ProfileSection(title: "Documents", items: documents))
        }
        if let transportDetails = transportDetails, !transportDetails.isEmpty {
            sections.append(ProfileSection(title: "Transport Details", items: transportDetails))
        }
        
        return sections
    }
}


//MARK: Student Fee reciept Inovoice

struct InvoiceDetailsResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [InvoiceItem]?
}

struct InvoiceItem: Codable {
    var id: String?
    var invoice_no: String?
    var invoice_date: String?
    var invoice_amount: String?
}




// MARK: - Root model
struct TargetDetailsResponse: Codable {
    let status: Bool
    let message: String
    let data: [TargetDetail]?
}

// MARK: - Data model
struct TargetDetail: Codable {
    let type: String?
    let name: [TargetName]?
}

// MARK: - Name model
struct TargetName: Codable {
    var institute : [String]?
    var standard : [String]?
    var group_name : [String]?
    var sections : [String]?
    var name : String?
}

struct targetSuc : Codable{
    
    var status : Bool?
    var message : String?
    var data : [targetDataDetails]?
    
}

struct targetDataDetails : Codable{
    var type : String?
    var name: [targetInfoData]?
    
}

struct targetInfoData : Codable{
    var institute : [String]?
    var standard : [String]?
    var group : [String]?
    var section : [String]?
    var name : String?
    var role:  String?
    var sec : String?
    var std : String?
    var mobile : String?
    
}



struct GlobalVariablesResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [GlobalVariable]?
}

struct GlobalVariable: Codable {
    var resend_otp_timer: String?
    var image_size: String?
    var pdf_size: String?
    var file_content: String?
    var video_size_limit: String?
    var video_size_limit_alert: String?
    var aws_access_key: String?
    var aws_secrete_key: String?
    var in_app_update: String?
    var offers_link: String?
    var alert_content: String?
    var aws_master_bucket_name: String?
    var aws_master_bucket_region: String?
    var aws_trans_bucket_name: String?
    var aws_trans_bucket_region: String?
    var aws_trans_cognito_pool_id: String?
    var aws_master_cognito_pool_id: String?
    var version_alert_content: String?
    var helpline_url: String?
    var reports_link: String?
    var profile_link: String?
    var is_alert_available: String?
    var ad_timer_interval: String?
    var new_version: String?
    var new_updates: String?
    var otp_dial_inbound: String?
    var video_vimeo_token: String?
    var ebooks_url: String?
    var market_place_url: String?
    var fees_url: String?
    var v_card_numbers: String?
    var contact_display_name: String?
    var contact_alert_title: String?
    var contact_alert_content: String?
    var support_email: String?
    var support_contact: String?
    var privacy_policy: String?
    var about_the_app: String?
    var how_to_use: String?
}

struct checkQuizLevelSuc : Codable{
    var status : Bool?
    var message : String?
    var data : [checkQuizLevelData]?
}

struct checkQuizLevelData : Codable{
    var level : Int?
}
// MARK: - API Models
struct UpdateResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [UpdateItem]?
}

struct UpdateItem: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let app_redirect_link: String?
    let video_link: String?
    let downloadable_image: String?
}
struct IntroResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [IntroFeature]?
}

struct IntroFeature: Codable {
    let id: String?
    let title: String?
    let description: String?
    let file_path: [FilePath]?
}
struct AttendanceStudentListResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [AttendanceStudentListData]?
}

struct AttendanceStudentListData: Codable {
    let is_edit: Bool?
    let attd_details: [AttendanceStudentListDetails]?
}

struct AttendanceStudentListDetails: Codable {
    let id: String?
    let name: String?
    let admission_no: String?
    let roll_no: String?
    var att_type: String?
    var att_status: String?
}

// MARK: - FAQ Models
struct FAQResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [SchoolQA]?
}

struct SchoolQA: Codable {
    let id: String?
    let question: String?
    let answer: [String]?
}
struct ReviewResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [Review]?
}

struct Review: Codable {
    let id: String?
    let mobile: String?
    let rating: Int?
    let description: String?
    let created_on: String?
    let updated_on: String?
}
