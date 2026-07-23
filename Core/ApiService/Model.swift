

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
    var update_available: Bool?
    var force_update: Bool?
    let new_version: String?
    let new_version_updates: String?
    let country_details: CountryData?
    let toaster_title: String?
    let play_store_market_id: String?
    let play_store_link: String?
    let app_store_link: String?
    let description: String?
    var is_rate_as:Bool?
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
    let staff_id: String?
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
    let gps_type  : String?
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
    var access_token: String?
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
    let is_not_allow: Bool?
    let gps_type  : String?
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

struct SecondCommonApiSuc: Codable {
    let status: Bool?
    let message: String?
//    let data: [String]?
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
    var playDruration:Double?
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
    var isExpand: Bool?
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
    var created_on : String?
    var date : String?
    
}




struct HomeworListkResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [Homework]?
}
struct HomeworkList: Codable {
    let date: String?
    let completed_count: Int?
    let homework: [Homework]?
}

struct FilePath: Codable {
    let url: String?
    let type: String?
    var isBase64: Bool {
           return !(url?.lowercased().hasPrefix("http") ?? false)
       }
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
    let status: Bool?
    let message: String?
    let data: [CommunicationReciverData]?
}

class CommunicationReciverData: Codable {
    let type: String?
    let id: String?
    let header_id: String?
    let content: String?
    let title: String?
    let date: String?
    let time: String?
    let sender_info: String?
    let is_emergency : Bool?
    var is_unread: Bool?
    var isExpand:Bool?
    let is_archive: Bool?
    let duration : Int?
    var playbackSeconds: Double?
    var loadFile: Bool?
    let sent_by: String?
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
    let school_name: String?
}

//MARK: Attendence

struct AttendanceReportResponse: Codable {
    
    let status: Bool?
    let message: String?
    let data: [AttenenceReportData]?
}

struct AttenenceReportData: Codable{
    let holiday_message  : String?
    let attd_report : [AttendanceDataList]?
    
}
struct AttendanceDataList: Codable {
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
    let total_other_staffs_strength: String?
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
    let others_count: String?
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


struct LeaveTypesResponse: Codable {
    var status: Bool?
    var message: String?
    var data: [LeaveType]?
}

struct LeaveType : Codable {
    var id: Int?
    var name:String?
    var leave_name:String?
}

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
    var staff_id: String?
    var applied_on: String?
    var staff_name: String?
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
    var from_date: String?
    var to_date: String?
    var leave_type_id: FlexibleString?
    var status_id: String?
    var role: String?
    var mobile_no: String?
    var email: String?
    var address: String?
}

struct FlexibleString: Codable {
    let value: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let str = try? container.decode(String.self) {
            value = str
        } else if let int = try? container.decode(Int.self) {
            value = String(int)
        } else {
            value = nil
        }
    }

    // Optional: for encoding back
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

//MARK: ASSIGNMENT MY SUBMISION
struct SubmissionResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [Submission]?
}

struct Submission: Codable {
    let id: String?
    let description: String?
    let title: String?
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
    let created_on: String?
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
    let reason: String?
    let blocked_on: String?
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
    var class_name: String?
    var section_name: String?
    var class_id: String?
    var section_id: String?
    var reason: String?
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
    var report_id: Int?
    var reportName: String?
    var report_sent: Bool?
    var mark_sent: Bool?
    
  
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
    var percentage: String?
    var total_mark: String?
    var total_obtained: String?
    var grade: String?
    var message: String?
}

struct Groups: Codable {
    var name: String?
    var mark: String?
    var sub_groups: [SubGroup]?
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
    let event_link: String?
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
    let father_name: String?
    let mother_name: String?
    let event_link: String?
}

struct ClassSectionDetail: Codable {
    let class_id: String?
    let section_id: String?
    let class_name: String?
    let section_name: String?
}


//Booked slots for staff
struct BookedSlotsResponse: Codable {
    let status: Bool
    let message: String
    let data: [BookedSlotsData]
}

struct BookedSlotsData: Codable {
    let today: [BookedSlot]?
    let upcoming: [BookedSlot]?
    let completed: [BookedSlot]?
}

struct BookedSlot: Codable {
    var slot_id : String?
    var date: String?
    var from_time: String?
    var to_time: String?
    var event_name: String?
    var event_mode: String?
    var event_link: String?
    var meeting_duration: Int?
    var sent_by: String?
    var student_id: String?
    var student_name: String?
    var father_name: String?
    var mother_name: String?
    var mobile_no: String?
    var class_id: String?
    var section_id: String?
    var class_name: String?
    var section_name: String?
    var slot_status: String?
    var is_booked: Bool?
    var profile_url: String?
    var can_cancel: Bool?
    var is_cancelled: Bool?
    var is_cancelled_by_staff: Bool?
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
    var is_cancelled_by_staff: Bool?
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
    var is_unread: Bool?
    let sent_by: String?
    let created_on: String?
    let iframe: String?
    let file_size: String?
    let thumbnail: String?
    let file_path: [FilePath]?
    var test: [TestQuestion]?
    let submittedCount: Int?
    let totalCount: Int?
    let can_delete: Bool?
    let submitted_average: String?
}

enum LSRWType: Codable {
    case listening
    case speaking
    case reading
    case writing
    case unknown(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = (try? container.decode(String.self)) ?? ""
        
        let value = raw.lowercased()
        
        // Normalize translated values back to English
        let mapToEnglish: [String: LSRWType] = [
            "listening": .listening,
            "speaking": .speaking,
            "reading": .reading,
            "writing": .writing,
            
            // Tamil
            "கேட்குதல்": .listening,
            "பேசுதல்": .speaking,
            "படித்தல்": .reading,
            "எழுதுதல்": .writing,
            
            // Hindi
            "सुनना": .listening,
            "बोलना": .speaking,
            "पढ़ना": .reading,
            "लिखना": .writing,
            
            // Thai
            "การฟัง": .listening,
            "การพูด": .speaking,
            "การอ่าน": .reading,
            "การเขียน": .writing
        ]
        
        if let mapped = mapToEnglish[value] {
            self = mapped
        } else {
            self = .unknown(raw)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .listening: try container.encode("listening")
        case .speaking:  try container.encode("speaking")
        case .reading:   try container.encode("reading")
        case .writing:   try container.encode("writing")
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
        case .listening: return "Listening".translated()
        case .speaking:  return "Speaking".translated()
        case .reading:   return "Reading".translated()
        case .writing:   return "Writing".translated()
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
    var student_id : String?
    var gender : String?
    var is_unread : Bool?
    
}


struct senderQuizListData: Codable {
    var id: String?
    var sent_time: String?
    var title: String?
    var description: String?
    var standard: String?
    var section: String?
    var level: Int?
    var level_flag: Bool?
    var subject_id: String?
    var subject: String?
    var sent_by: String?
    var submission_date: String?
    var mark: String?
    var type_name: String?
    var no_of_questions: Int?
    var submitted_count: Int?
    var can_edit: Bool?
    var can_delete: Bool?
    var open_to_student: Bool?
}
struct QstDetail: Codable {
    let id: String?
    let chapter: String?
    let question: String?
    let mark: String?
    let options: [OptionsDeatil]?
    let q_file_path: [FilePath]?
}
struct OptionsDeatil: Codable {
    let option: String?
    let value:String?
    let image: String?
}
struct QuizQuestionSuc : Codable{
    let status: Bool?
    let message: String?
    let data: [QstDetail]?
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
    var message : String?
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
    var mark : Int?
    var student_answer : String?
    var correct_answer : String?
    var options : [OptionsDeatil]?
    var file_path : [FilePath]?
    
}

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
    var q_file_path: [FilePath]?
    var a_image : String?
    var b_image : String?
    var c_image : String?
    var d_image : String?
    var ques_no : String?
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
        q_file_path: [FilePath]? = nil,
        a_image : String = "",
        b_image : String = "",
        c_image : String = "",
        d_image : String = "",
        ques_no : String = "") {
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
        self.q_file_path = q_file_path
        self.a_image = a_image
        self.b_image = b_image
        self.c_image = c_image
        self.d_image = d_image
        self.ques_no = ques_no
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
    var presigned_cred_base_url: String?
    var wl_privacy: String?
    var wl_terms: String?
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
    var is_leave_approved: Bool
    var leave_from: String?
    var leave_to: String?
    var reason: String?
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
    let remarks:[CategoriesSection]?
}
// MARK: - Models
struct CategoriesSection:Codable{
    let rating: Int?
    let value: String?
    let name: String?
    var category: [Categories]?
}

struct Categories:Codable{
    let name: String?
    var selected: Bool?
}

// MARK: - staff Exam mark

struct StaffExamListResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [StaffExamData]?
}

struct StaffExamData: Codable {
    let id: String?
    let name: String?
    let date: String?
    let ref_flag: Int?
    let ai_mark_entry: Bool?
}

struct SubjectWiseExamResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [SubjectExamData]?
}

struct SubjectExamData: Codable {
    let section_id: String?
    let section_name: String?
    let class_id: String?
    let class_name: String?
    let subject_id: String?
    let subject_name: String?
    var splitup_details: [SplitDetail]?
}

struct SplitDetail: Codable {
    let id: String?
    let name: String?
    let max_mark: String?
    
    // UI STATE
    var isChecked: Bool? = false
    var selectedAIOption: String? = nil
}

struct SelectedSplit {
    let subjectId: String
    let subjectName: String
    let splitId: String
    let splitName: String
    var aiOption: String?   // nil for Manual
}

//MARK: mark upload AI Api response

struct MarksAIresponse: Codable {
    
    let status: Bool?
    let message: String?
    let data: MarkAiData?
}

struct MarkAiData: Codable {
    let table_structure: TableStructure?
    let review_flags: [ReviewFlag]?
    let records: [DynamicRecord]?
}

struct TableStructure: Codable {
    let selected_columns: [String]?
}


struct ReviewFlag: Codable {
    let student_id: String?
    let field: String?
    let value: String?
    let reason: String?
}

enum RecordValue: Codable {
    case int(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else {
            self = .string(try container.decode(String.self))
        }
    }

    var stringValue: String {
        switch self {
        case .int(let value):
            return String(value)
        case .string(let value):
            return value
        }
    }
}

struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) { nil }
}

struct DynamicRecord: Codable {
    let values: [String: RecordValue]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        var temp: [String: RecordValue] = [:]
        for key in container.allKeys {
            temp[key.stringValue] = try container.decode(
                RecordValue.self,
                forKey: key
            )
        }
        values = temp
    }
}


struct RecordItem:Codable {
    let name: String
    let value: String
    let isReview: Bool
    let reason: String?
}

struct ConvertedStudentRecord:Codable {
    let studentId: String
    let sNo: String
    let regNo: String
    let studentName: String
    let marks: [RecordItem]
}
 
struct HostelListSuc : Codable{
    let status : Bool?
    let message : String?
    let data : [HostelListData]?
    
}

struct HostelListData : Codable{
    let id : String?
    let name : String?
    let institute_id : String?
    let institute_name : String?
    let type : String?
    let max_capacity : Int?
    let address : String?
    
}

struct HostelDashBoardSuc : Codable{
    let status : Bool?
    let message : String?
    let data : [HostelDashBoardData]?
}
struct HostelDashBoardData : Codable{
    let stats  : statsDataDetails?
    let floors : [HostelDashBoardFloor]?
}

struct statsDataDetails : Codable{
    let total_students : String?
    let outpass_requests :String?
}
struct HostelDashBoardFloor : Codable{
    
    let id : String?
    let floor_no : String?
    let floor_name : String?
    let rooms : [HostelDashBoardRooms]?
    
}

struct HostelDashBoardRooms : Codable{
    let id : String?
    let number : String?
    let max_occupancy : Int?
    let current_occupancy : Int?
    let total_beds : Int?
    let students : [String]?
}

struct HostelStudentListSuc : Codable{
    let status : Bool?
    let message : String?
    let data : [HostelStudentListData]?
}

struct HostelStudentListData : Codable{
    let id : String?
    let name : String?
    let admission_no : String?
    let roll_no : String?
    let gender : String?
    let class_id : String?
    let class_name : String?
    let section_id : String?
    let section_name: String?
    let primary_mobile : String?
    let status : String?
    let outpass_id : String?
    let out_date : String?
    let in_date : String?
    let reason : String?
    let outpasss_status : String?
    var is_select: String?
    
}

struct HostelSessionListSuc : Codable{
    let status : Bool?
    let message : String?
    let data : [HostelSessionListData]?
}
struct HostelSessionListData : Codable{
    let id : String?
    let name : String?
}


//-------------------------------------------------------------------------------------------------------//

//-------------------------------------------------------------------------------------------------------
struct HomeWorkSubmissionList:Codable{
    let status:Bool?
    let message:String?
    let data:[HomeworkDetails]?
}
struct HomeworkDetails:Codable{
    let id:String?
    let name:String?
    let admission_no:String?
    let roll_no:String?
    let status:String?
}

struct DashboardModel {
    var attendanceOverview: AttendanceOverviewModel
    var sessionAnalysis: SessionAnalysisModel
    var weeklyTrend: WeeklyTrendModel
    var detailedRecords: DetailedAttendanceModel
}

struct AttendanceOverviewModel {
    let title: String
    let presentCount: Int
    let absentCount: Int
}

struct SessionAnalysisSession {
    let title: String
    let presentCount: Int
    let absentCount: Int
    let percentageString: String
}

struct SessionAnalysisModel {
    let title: String
    let sessions: [SessionAnalysisSession]
}

struct WeeklyTrendPoint {
    let dateLabel: String
    let percentage: Double
}

struct WeeklyTrendModel {
    let title: String
    let points: [WeeklyTrendPoint]
}

// New detailed records models
struct DetailedAttendanceDay: Codable {
    let dayLabel: String
    let status: [String] // "Present", "Absent", "Not Taken"
}

struct DetailedAttendanceModel: Codable {
    let sessions: [String]
    let days: [DetailedAttendanceDay]
}

struct OutpassStatsModel {
    let totalRequests: String
    let pending: String
    let accepted: String
    let declined: String // Extracted logically
}

struct OverallStatsModel {
    let percentage: String
    let presentCount: String
    let absentCount: String
}

struct TodayAttendanceSession {
    let rawString: String // e.g. "morning : Present"
    
    var sessionName: String {
        return String(rawString.split(separator: ":").first ?? "").trimmingCharacters(in: .whitespacesAndNewlines).capitalized
    }
    
    var status: String {
        return String(rawString.split(separator: ":").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct TodayAttendanceModel {
    let sessions: [TodayAttendanceSession]
}
struct OutpassRequestData {
    let reason: String
    let fromToDate: String
    let requestTime: String
    var status: String = "Pending" // Adding logically from UI since omitted in payload
}

struct OutpassRequestsModel {
    let requests: [OutpassRequestData]
}

struct HostelInfoData {
    let title: String
    let value: String
    
    // Kept for backward compatibility if used elsewhere
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
    
    init(rawString: String) {
        let parts = rawString.split(separator: ":", maxSplits: 1)
        self.title = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines).capitalized ?? ""
        if parts.count > 1 {
            self.value = parts.last?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: "") ?? ""
        } else {
            self.value = ""
        }
    }
}

struct HostelInformationModel {
    let infoBlocks: [HostelInfoData]
}

struct AttendanceHistoryResponse: Codable {
    let status: Bool
    let message: String
    let data: [AttendanceHistoryData]
}

struct AttendanceHistoryData: Codable {
    let roomId: String
    let roomNo: String
    let sessions: [AttendanceHistorySession]
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case roomNo = "room_no"
        case sessions
    }
}

struct AttendanceHistorySession: Codable {
    let sessionTypeId: String
    let sectionName: String
    let presentStudent: String
    let absentStudent: String
    let students: [AttendanceHistoryStudent]
    
    enum CodingKeys: String, CodingKey {
        case sessionTypeId = "session_type_id"
        case sectionName = "session_name"
        case presentStudent = "present_count"
        case absentStudent = "absent_count"
        case students
    }
}

struct AttendanceHistoryStudent: Codable {
    let studentId: String
    let studentName: String
    let admissionNo: String
    let className: String
    let sectionName: String
    let primaryMobile: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case studentId = "student_id"
        case studentName = "student_name"
        case admissionNo = "admission_no"
        case className = "class_name"
        case sectionName = "section_name"
        case primaryMobile = "primary_mobile"
        case status
    }
}
// MARK: - Root Model
struct OutpassResponseSuc : Codable {
    var status: Bool
    var message: String
    var data: [OutpassSection]
}

// MARK: - Section Model
struct OutpassSection  : Codable {
    var status: String?
    var attd_details: [OutpassStudent]?
}

// MARK: - Student Model
struct OutpassStudent   : Codable{
    var id: String?
    var room_no: String?
    var student_id: String?
    var student_name: String?
    var admission_no: String?
    var class_name: String?
    var section_name: String?
    var primary_mobile: String?
    var gender: String?
    var out_date: String?
    var in_date: String?
    var reason: String?
    var status: String?
}
// MARK: - Root
struct HostelDashboardResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [HostelDashboardData]?
}

// MARK: - Data
struct HostelDashboardData: Codable {
    let gate_pass: [GatePass]?
    let today_attendance: [String]?
    let out_pass_requests: [OutPassRequest]?
    let hostel_info: [HostelInfo]?
    let attendance_details: [AttendanceDetails]?
    let fee_details: [HostelFeeDetails]?
}

// MARK: - Gate Pass
struct GatePass: Codable {
    let action_by: String?
    let admission_no: String?
    let reason: String?
    let profile: String?
    let floor_no: String?
    let room_no: String?
    let fromdate_todate: String?
    let request_time: String?
    let status: String?
}

// MARK: - Out Pass Requests
struct OutPassRequest: Codable {
    let reason: String?
    let fromdate_todate: String?
    let request_time: String?
    let status: String?
    let action_by: String?
}

// MARK: - Hostel Info
struct HostelInfo: Codable {
    let hostel_id: String?
    let hostel_name: String?
    let hostel_type: String?
    let no_of_floors: Int?
    let no_of_rooms: Int?
    let warden_type: String?
    let max_capacity: Int?
    let warden_name: [String]?
    let institute_name: String?
    let institute_address: String?
}

// MARK: - Attendance Details
struct AttendanceDetails: Codable {
    let sessions: [String]?
    let days: [AttendanceDay]?
}

struct AttendanceDay: Codable {
    let date_label: String?
    let status: [String]?
}

// MARK: - Fee Details
struct HostelFeeDetails: Codable {
    let fee_id: Int?
    let fee_name: String?
    let fee_group: String?
    let hostel_details: HostelRoomDetails?
    let summary: hostelFeeSummary?
    let payments: [Payment]?
}

// MARK: - Hostel Room Details
struct HostelRoomDetails: Codable {
    let hostel_name: String?
    let room_no: String?
    let bed_no: String?
}

// MARK: - Fee Summary
struct hostelFeeSummary: Codable {
    let total_amount: Int?
    let paid_amount: Int?
    let pending_amount: Int?
    let discount: Int?
    let status: String?
}

// MARK: - Payment
struct Payment: Codable {
    let paid_amount: Int?
    let paid_date: String?
    let payment_mode: String?
}
// MARK: - Root
struct HostelDetailsResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [HostelDetailsData]?
}

// MARK: - Data
struct HostelDetailsData: Codable {
    let room_allocation_id: String?
    let hostel_id: String?
    let hostel_name: String?
    let student_id: String?
    let student_name: String?
    let admission_no: String?
    let primary_mobile: String?
    let gender: String?
    let floor_id: String?
    let floor_no: String?
    let floor_name: String?
    let room_id: String?
    let room_no: String?
    let room_type_id: String?
    let room_type: String?
}

// MARK: - Root
struct StaffAttendanceResponseSuc: Codable {
    let status: Bool?
    let message: String?
    let data: [DatasClasss]?
}

// MARK: - Data
struct DatasClasss: Codable {
    let overall_stat: OverallStat?
    let all_attd: [String: AttendanceDays]?
}

// MARK: - Overall Stat
struct OverallStat: Codable {
    let present: Int?
    let absent: Int?
    let not_marked: Int?
}

// MARK: - Each Date Object
struct AttendanceDays: Codable {
    let stat: DayStat?
    let attd_details: [NewStaffAttendance]?
}

// MARK: - Day Stat
struct DayStat: Codable {
    let present: Int?
    let absent: Int?
    let not_marked: Int?
}

// MARK: - Staff Attendance
struct NewStaffAttendance: Codable {
    let staff_id: String?
    let name: String?
    let date: String?
    let designation: String?
    let role: String?
    let attendance_type:  [String: String]?
    let in_time: String?
    let out_time: String?
    let working_hours: String?
}

struct transactionDataSuc : Codable{
    
    let status : Bool?
    let message : String?
    let data : [transactionData]?
}

struct transactionData : Codable{
 
    let id: String?
    let student_id: String?
    let total_amount: String?
    let order_status: String?
    let order_id: String?
    let created_on: String?
    let order_status_update_on: String?
    
}

struct student_routDataDetails: Codable{
    let status : Bool?
    let message : String?
    let data : [student_routData]?
    
}

struct student_routData : Codable{
    let student_id: String?
    let student_name: String?
    let admission_no: String?
    let route_id: String?
    let route_name: String?
    let stop_id: String?
    let stop_name: String?
    let vehicle_id: String?
    let vehicle_no: String?
    let tentative_pickup_time: String?
    let tentative_drop_time: String?
}



struct livebusDetails : Codable{
    let status : Bool?
    let message : String?
    let data : [livebusData]?
}

struct livebusData : Codable{
    let thing_id: String?
    let tracking_url: String?
}

struct GeoLocationResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [GeoLocationData]?
}
struct GeoLocationData: Codable {
    let id: String?
    let deviceId: String?
    let vehicleId: String?
    let latitude: String?
    let longitude: String?
    let speed: String?
    let altitudeLevel: String?
    let vehicleDirection: String?
    let gpsTime: String?
}




struct StudentRouteDetailsResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [StudentRouteData]?
}

struct StudentRouteData: Codable {
    let student_id: String?
    let map_url_schoolchimes: String?
    let student_name: String?
    let admission_no: String?
    let route_id: String?
    let route_name: String?
    let stop_id: String?
    let stop_name: String?
    let latitude: String?
    let longitude: String?
    let landmark: String?
    let vehicle_id: String?
    let vehicle_no: String?
    let vehicle_reg_no: String?
    let tentative_pickup_time: String?
    let tentative_drop_time: String?
    var stopping_points: [StoppingPoint]?
}

struct StoppingPoint: Codable {
    let vehicle_id: String?
    let route_name: String?
    let journey_type: String?
    let start_time: String?
    let end_time: String?
    let working_days: [String]?
    var stops: [Stops]?
}

struct Stops: Codable {
    var  stop_id: String?
    var stop_name: String?
    var  stop_time: String?
    var latitude: String?
    var  longitude: String?
    var  landmark: String?
    var isCompleted : Bool?
    var isCurrent : Bool?
    
}



struct ClassTestResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [ClassTest]?
}

struct ClassTest: Codable {
    let classTestId: String?
    let examName: String?
    let subjects: [TestsSubject]

    enum CodingKeys: String, CodingKey {
        case classTestId = "class_test_id"
        case examName = "exam_name"
        case subjects
    }
}

struct TestsSubject: Codable {
    let subjectId: String?
    let subjectName: String?
    let activities: [TestsActivity]

    enum CodingKeys: String, CodingKey {
        case subjectId = "subject_id"
        case subjectName = "subject_name"
        case activities
    }
}

struct TestsActivity: Codable {
    let classTestSubjectId: String?
    let examDate: String?
    let session: String?
    let activityName: String?
    let maxMark: String?
    let minMark: String?
    let syllabus: String?
    let status: String?
    let isMarkUploaded: Bool?
    let attendance: String?
    let mark: String?
    let remarks: String?

    enum CodingKeys: String, CodingKey {
        case classTestSubjectId = "class_test_subject_id"
        case examDate = "exam_date"
        case session
        case activityName = "activity_name"
        case maxMark = "max_mark"
        case minMark = "min_mark"
        case syllabus
        case status
        case isMarkUploaded = "is_mark_uploaded"
        case attendance
        case mark
        case remarks
    }
}

struct ClassTestMarksResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [ClassTestMarks]?
}

struct ClassTestMarks: Codable {
    let classTestId: String?
    let examName: String?
    let overAllStudentMarks: String?
    let overAllMarks: String?
    let overAllPersentage: String?
    let subjects: [MarksSubject]

    enum CodingKeys: String, CodingKey {
        case classTestId = "class_test_id"
        case examName = "exam_name"
        case overAllStudentMarks = "over_all_student_marks"
        case overAllMarks = "over_all_Marks"
        case overAllPersentage = "over_all_persentage"
        case subjects
    }
}

struct MarksSubject: Codable {
    let subjectId: String?
    let subjectName: String?
    let activities: [MarksActivity]

    enum CodingKeys: String, CodingKey {
        case subjectId = "subject_id"
        case subjectName = "subject_name"
        case activities
    }
}

struct MarksActivity: Codable {
    let classTestSubjectId: String?
    let examDate: String?
    let session: String?
    let activityName: String?
    let maxMark: String?
    let minMark: String?
    let syllabus: String?
    let attendance: String?
    let mark: String?
    let remarks: String?

    enum CodingKeys: String, CodingKey {
        case classTestSubjectId = "class_test_subject_id"
        case examDate = "exam_date"
        case session
        case activityName = "activity_name"
        case maxMark = "max_mark"
        case minMark = "min_mark"
        case syllabus
        case attendance
        case mark
        case remarks
    }
}
