//
//  AppConstont.swift
//  MyGrocery
//
//  Created by Chandhru veeramalai on 21/10/24.
//

import Foundation
enum Environments : String{
    case development = "http://rgu.savyasasy.com/v1/setup/"
}

struct AppConficuration{
    static let enviranment = Environments.development
}
struct ServiceUrl{
    static let baseurl = AppConficuration.enviranment.rawValue
    static var token = ""
    static var awsBucketName = "rgu-meet-files"
    
    
    static let setupcountries           = "setup/countries"
    static let version_check            = "version-check"
    static let validate_mobile_number   = "validate-mobile-number"
    static let initiate_otp             = "initiate-otp"
    static let validate_user            = "validate-user"
    static let auto_login               = "auto-login"
    static let get_members              = "get-members"
    static let  get_groups              = "get-groups"
    
    static let create_meeting           = "create-meeting"
    static let get_meeting_details      = "get-meeting-details-history"
    static let delete_meeting_details   = "delete-meeting/"
    static let update_meeting_details   = "update-meeting-details"
    static let get_meeting_details_list = "get-meeting-details-list"
    static let get_meeting_attendance   = "get-meeting-attendance"
    static let add_location             = "add-location"
    static let Get_Meeting_Location     = "get-meeting-location"
    static let get_location_history     = "get-location-history"
    static let attendance_members_Punch = "create-attendance" // Punch
    static let update_member_details    = "update-member-details"
    static let get_claim_details        = "get-claim-list"
    static let create_claim             = "create-claim"
    static let getclaimgroup            = "get-claim-for-group"
    static let claim_validation            = "claim-validation"
  
   
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


class Save_validate_user_data {
    
    func saveVerifyData(_ data: VerifyData) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(data) {
            UserDefaults.standard.set(encodedData, forKey: "verifyData")
        } else {
            print("Failed to encode VerifyData")
        }
    }
    
    
    
    func saveToken(_ token: String,forKey: String) {
        UserDefaults.standard.set(token, forKey: forKey)
        print("Token saved successfully!")
    }
    static func removeToken(forKey: String) {
        UserDefaults.standard.removeObject(forKey: forKey)
        UserDefaults.standard.synchronize() // Ensures the change is saved immediately
        print("Token removed successfully!")
    }
    func getToken(forKey: String) -> String? {
        return UserDefaults.standard.string(forKey: forKey)
    }
    
}
