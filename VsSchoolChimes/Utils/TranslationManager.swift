//
//  TranslationManager.swift
//  VsSchoolChimes
//
//  Created by admin on 11/12/24.
//

import Foundation

class TranslationManager {
    
    static let shared = TranslationManager() // Singleton for shared access
    
    // Default language (set to English initially)
    private var currentLanguageCode: String {
        get {
            return UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en" // Default to English if no language is set
        }
        set {
            UserDefaults.standard.set(newValue, forKey: DefaultsKeys.Language)
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {}
    
    /// Set the language for translation
    func setLanguage(_ languageCode: String) {
        currentLanguageCode = languageCode
        // Optionally, you can add additional actions to refresh UI or notify other components
    }
    
    /// Retrieve a translated string based on the current language
    func translate(key: String, comment: String = "") -> String {
        if let path = Bundle.main.path(forResource: currentLanguageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(key, bundle: bundle, comment: comment)
        }
        return key // Return the key itself if no translation is found
    }
}


