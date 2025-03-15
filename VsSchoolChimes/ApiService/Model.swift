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
}

//MARK: Version Check API
struct VersionResponse:Codable{
    let status : Bool?
    let message : String?
    let data : [VersioncheckData]
}

struct VersioncheckData:Codable{
    
    let update_available : Bool?
    let force_update : String?
    let new_version : String?
    let new_version_updates : String?
    let toaster_title : String?
}

//MARK: Check Mobile No for change password API


