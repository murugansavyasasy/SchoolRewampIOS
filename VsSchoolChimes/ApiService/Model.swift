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
   
    let country_id : String?
    let country_name : String?
    let country_code : String?
    let base_url : String?
    let mobile_number_length : String?
    let resend_otp_timer : String?
    let reporting_url : String?
    let flag_url : String?
    let terms_and_condition_url : String?
    let mobile_no_hint : String?
}

//MARK: Version Check API
struct VersionCheckResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [VersionData]?
}

struct VersionData: Codable {
    let updateAvailable: Bool?
    let forceUpdate: Bool?
    let newVersion: String?
    let newVersionUpdates: String?
    let redirect_url: String?
    let countryDetails: CountryData?
    let toasterTitle: String?
}



//MARK: Check Mobile No for change password API


struct MobileNumberValidationSuc: Codable {
    let status: Bool?
    let message: String?
    let data: [MobileNumberValidationData]?
}

struct MobileNumberValidationData: Codable {
    let is_number_exists: Bool?
    let is_password_updated: Bool?
    let otp_sent: Bool?
    let otp: String?
    let message: String?
    let more_info: String?
    let dial_numbers: String?
    
}

//MARK: Create New Password API
struct CreateNewPasswordSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [String]?
}

//MARK: Reset Password API
struct ResetPasswordSuc : Codable {
    let status : Bool?
    let message : String?
    let data : [String]?
}

// MARK: Validate OTP

struct ValidateOTPSuc: Codable {
    let status: Bool?
    let message: String?
    let data: [String]?
}

// MARK: Validate User

struct UserValidationResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [UserData]?
}

struct UserData: Codable {
    let isNumberExists: Bool?
    let isPasswordUpdated: Bool?
    let otpSent: Bool?
    let message: String?
    let moreInfo: String?
    let dialNumbers: String?
    let userDetails: UserDetails?
}

struct UserDetails: Codable {
    let isStaff: Bool?
    let staffRole: String?
    let roleName: String?
    let staffDetails: [StaffDetail]?
    let isParent: Bool?
    let childDetails: [ChildDetail]?
    let maxGeneralSmsCount: Int?
    let maxHomeworkSmsCount: Int?
    let maxEmergencyVoiceDuration: Int?
    let maxGeneralVoiceDuration: Int?
    let maxHwVoiceDuration: Int?
    let imageCount: Int?
}

struct StaffDetail: Codable {
    let staffID: String?
    let staffName: String?
    let schoolID: String?
    let schoolName: String?
    let schoolNameRegional: String?
    let city: String?
    let schoolLogo: String?
    let role: String?
    let isPaymentPending: String?
    let scheduleCallType: Int?
    let biometricEnable: Int?
    let allowVideoDownload: Bool?
}

struct ChildDetail: Codable {
    let childID: String?
    let childName: String?
    let standardName: String?
    let sectionName: String?
    let schoolID: String?
    let schoolName: String?
    let schoolNameRegional: String?
    let schoolCity: String?
    let schoolLogoURL: String?
    let rollNumber: String?
    let displayMessage: String?
    let classID: Int?
    let sectionID: Int?
}

