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
    
    
}


