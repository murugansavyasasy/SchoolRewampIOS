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
    
    static let country_list              = "app/setup/countries"
    static let version_check             = "app/setup/version-check"
    static let validate_validate_user    = "app/auth/validate-user"
    static let validate_validate_otp     = "app/auth/validate-otp"
    static let cred_change_password      = "app/cred/change-password"
    static let cred_forgot_password      = "app/cred/forgot-password"
    static let cred_reset_password       = "app/cred/reset-password"
    static let  cred_create_new_password = "app/cred/create-new-password"
    static let global_global_variables   = "app/global/global-variables"
    static let  auth_device_token        = "app/auth/device-token"
    static let  get_dashboard_details    = "dashboard/dashboard/get-dashboard-details"
    static let recipient_get_group_list  = "comm/recipient/get-group-list"
    static let recipient_get_standards   = "comm/recipient/get-standards"
    static let recipient_get_student_list  = "comm/recipient/get-student-list"
    static let recipient_get_subject_list  = "comm/recipient/get-subject-list"
    static let recipient_get_staff_list  = "comm/recipient/get-staff-list"
    static let comm_text_message_send_text  = "comm/text-message/send-text"
    static let comm_voice_send_voice  = "comm/voice/send-voice"
    static let comm_voice_get_voice_history  = "comm/voice/get-voice-history"
    static let comm_text_message_get_text_history  = "comm/text-message/get-text-history"
    static let comm_homework_get_homework_report  = "comm/homework/get-homework-report"
    static let comm_homework_get_homework_list_archive  = "comm/homework/get-homework-list-archive"
    static let comm_homework_get_homework_list  = "comm/homework/get-homework-list"
    static let comm_homework_sendhomework  = "comm/homework/send-homework"
    static let comm_recipient_get_academic_year_list  = "comm/recipient/get-academic-year-list"
    static let comm_communication_list  = "comm/communication/list"
    static let comm_communication_list_archive  = "comm/communication/list-archive"
    static let comm_communication_read_status_update  = "comm/communication/read-status-update"
    static let  comm_communication_read_status_update_archive  = "comm/communication/read-status-update-archive"
    static let  comm_attachment_send_attachment  = "comm/attachment/send-attachment"
    static let  comm_communication_attachment_list  = "comm/communication/attachment-list"
    static let  comm_communication_attachment_list_archive  = "comm/communication/attachment-list-archive"
    static let  staff_attd_geometric_entry_using_app  = "staff-attd/geometric/entry-using-app"
    static let  staff_attd_geometric_set_geometric_location  = "staff-attd/geometric/set-geometric-location" 
    static let  staff_attd_geometric_get_geometric_location_history  = "staff-attd/geometric/get-geometric-location-history"
    static let  geometric_principal_attendance_report  = "staff-attd/geometric/geometric-principal-attendance-report" 
    static let  staff_attd_geometric_get_staff_geometric_location  = "staff-attd/geometric/get-staff-geometric-location"
    
    
    
}

struct localData{
    
    static var country_data : CountryData? = nil
    static var staff_data: [StaffDetails]?
    static var child_data: [ChildDetails]?
    static var user_details : UserDetails? = nil
    static var user_data : UserData? = nil

}
struct screenType{
    
    static let isMobileNumber  = 1
    static let isLoginPage  = 2
    static let isPassword  = 3
    static let isSplash  = 4
    static let isForgotPassword  = 5
    static let is_noticeboard = 23
    static let isAssaignment = 22
    static var staffSelectedMenuId = 0
    static var communicationMenuId = 0
    static let communication_text = 2
    static let is_emergencyvoice =  1
    static let non_emergencyvoice =  3
}

struct Menu_id{
    static var communicationMenuId = 0
    static var homeWorkMenuId = 9
    static let isAssaignment = 22
    static let AttachmentMenuId = 11
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

struct user_inputs{
    static var voice_link = ""
    static var duration : Int = 0
    static var is_schedule : Bool = false
    static var title = ""
    static var description = ""
    static var is_emergency : Int = 0
    static var schedule_date : [String] = []
    static var selectedImg : [UIImage] = []
    static var selectedImgUrls : [FilePath] = []
    static var SelectedUrls : [AttachmentItem] = []
    static var fileUrl:URL?
    static var docUrl = [String]()
    static var start_time = ""
    static var end_time = ""
    static var file_name = ""
    static var circular_type = ""
    static var selectedFileType = ""
    
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
        "yyyy/MM/dd"
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

