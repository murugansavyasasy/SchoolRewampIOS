//
//  userDefaultFileManager.swift
//  VsSchoolChimes
//
//  Created by admin on 17/03/25.
//

import Foundation


struct UserDefaultFileManager {
    
   

    static let countryKey = "country_data"
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
    
    
    
}


