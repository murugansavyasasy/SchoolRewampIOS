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

