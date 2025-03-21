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
    
    static let version_check            = "setup/version-check"
    static let country_list             = "setup/countries"
   
    static let cred_create_new_password = "cred/create-new-password"
    static let password_reset_password = "cred/reset-password"
    static let validate_validate_otp = "auth/validate-otp"
    static let validate_validate_user = "auth/validate-user"
    
}

struct localData{
    
    static var country_data : CountryData? = nil
    static var staff_data: [StaffDetails]?
    static var child_data: [ChildDetails]?
    static var user_details : UserDetails? = nil
    static var user_data : UserData? = nil

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


