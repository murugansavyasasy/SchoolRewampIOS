//
//  LocalizableStrings.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import Foundation



struct StringsName {
   
    var appname  = ""
 
    var Home = "Home".translated()
    var Help = "Help".translated()
     var Settings = "Settings".translated()
     var Profile = "Profile".translated()
   
  
    
}



extension String {
    /// Translates the string using the language bundle defined in `UserDefaults`.
    func translated() -> String {
        let defaults = UserDefaults.standard
        
        // Retrieve the language code saved in UserDefaults
        if let languageCode = defaults.string(forKey: DefaultsKeys.Language),
           let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            // Translate using the specific language bundle
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        
        // Return the key itself if no translation is available
        return self
    }
}
