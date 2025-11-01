//
//  userDefaultFileManager.swift
//  VsSchoolChimes
//
//  Created by admin on 17/03/25.
//

import Foundation


struct UserDefaultFileManager {
    static let countryKey = "country_data"
    static let  mobileNumber = "mobile_number"
    static let  password = "password"
    static let  User_details = "User_details"
    static let staffDetails = "staff_details"
    static let childDetails = "child_details"
    static let selectionKey = "SelectionDetails"
    static func saveCountryDetails(data: CountryData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: countryKey)
        }
    }
    
    
    static func getCountryDetails() -> CountryData? {
        if let savedData = UserDefaults.standard.data(forKey: countryKey),
           let user = try? JSONDecoder().decode(CountryData.self, from: savedData) {
            return user
        }
        return nil
    }
    
    static func saveLoginCredentials(mobile_number : String , pwd : String){
        let userDefault = UserDefaults.standard
        userDefault
            .set(
                mobile_number,
                forKey: mobileNumber
            )
        userDefault
            .set(
                pwd,
                forKey: password
            )
        
    }
    
    static func getLoginCredentials() -> (mobile_number : String , pwd : String)?{
        let userDefault = UserDefaults.standard
        guard let mobile_number = userDefault.string(forKey: mobileNumber) else {
            return nil
        }
        guard let pwd = userDefault.string(forKey: password) else {
            return nil
        }
        return (mobile_number,pwd)
    }
    
    static func removeLoginCredentials() {
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: mobileNumber)
        userDefault.removeObject(forKey: password)
        userDefault.synchronize() // Optional, ensures changes are saved immediately
    }
    
    
    static func saveUserDetails(data: UserData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: User_details)
        }
    }
    
    static func getUserDetails() -> UserData? {
        if let savedData = UserDefaults.standard.data(forKey: User_details),
           let user = try? JSONDecoder().decode(UserData.self, from: savedData) {
            return user
        }
        return nil
    }
    
    static func saveStaffDetails(data: StaffDetails) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: staffDetails)
        }
    }
    
    static func get_staff_Details() -> StaffDetails? {
        if let savedData = UserDefaults.standard.data(forKey: staffDetails),
           let user = try? JSONDecoder().decode(StaffDetails.self, from: savedData) {
            return user
        }
        return nil
    }
    static func saveChildDetails(data: ChildDetails) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: childDetails)
        }
    }
    
    static func get_child_Details() -> ChildDetails? {
        if let savedData = UserDefaults.standard.data(forKey: childDetails),
           let user = try? JSONDecoder().decode(ChildDetails.self, from: savedData) {
            return user
        }
        return nil
    }
    
    
    static func save_global_Selection(data: GlobalVariable) {
            if let encoded = try? JSONEncoder().encode(data) {
                UserDefaults.standard.set(encoded, forKey: selectionKey)
            }
        }
        
        // Get Selection Data
        static func get_globalSelection() -> GlobalVariable? {
            if let savedData = UserDefaults.standard.data(forKey: selectionKey),
               let details = try? JSONDecoder().decode(GlobalVariable.self, from: savedData) {
                return details
            }
            return nil
        }
    

}


