//
//  AppConstont.swift
//  MyGrocery
//
//  Created by Chandhru veeramalai on 21/10/24.
//

import Foundation

struct ServiceUrl{
    static var baseurl = "http://apiv7.schoolchimes.net/app/"
    static var report_url = ""
    static var token = ""
    static var awsBucketName = ""
    
    static let version_check            = "/setup/version-check"
    static let country_list             = "setup/countries"
    static let validate_validate_user_for_password_update             = "validate/validate-user-for-password-update"
    static let password_create_new_password = "/password/create-new-password"
    static let password_reset_password = "/password/reset-password"
    static let validate_validate_otp = "validate/validate-otp"
    
}

struct localData{
    
    static var country_data : CountryData? = nil
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


