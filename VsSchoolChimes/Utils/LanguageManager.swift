//
//  LanguageManager.swift
//  VsSchoolChimes
//
//  Created by admin on 17/12/24.
//


import Foundation

class LanguageManager {
    static let shared = LanguageManager()
    
    // Save the selected language in UserDefaults
    func setLanguage(_ languageCode: String) {
        UserDefaults.standard.set(languageCode, forKey: "appLanguage")
        UserDefaults.standard.synchronize()
        
        // Update the Apple Languages setting
        Bundle.setLanguage(languageCode)
    }
    
    // Retrieve the current language
    func currentLanguage() -> String {
        return UserDefaults.standard.string(forKey: "appLanguage") ?? Locale.current.languageCode ?? "en"
    }
}
