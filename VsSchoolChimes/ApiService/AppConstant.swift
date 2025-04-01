//
//  AppConstont.swift
//  MyGrocery
//
//  Created by Chandhru veeramalai on 21/10/24.
//

import Foundation

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
    static let recipient_get_group_list  = "recipient/get-group-list"
    static let recipient_get_standards   = "recipient/get-standards"
    static let recipient_get_student_list  = "recipient/get-student-list"
    static let recipient_get_subject_list  = "recipient/get-subject-list"
    static let recipient_get_staff_list  = "recipient/get-staff-list"
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
    static let is_noticeboard = "notice_board"
}
struct PriorityType{
    
    static let is_principal  = "high"
    static let is_staff  = "p3"
    static let is_student  = "low"
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


