//
//  LocalizableStrings.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import Foundation


let LocalizeUserDefaultKey = "LocalizeUserDefaultKey"
var LocalizeDefaultLanguage = "en"

struct StringsName {
   
    var appname  = ""
 
    var Home = "Home".translated()
    var Help = "Help".translated()
     var Settings = "Settings".translated()
     var Profile = "Profile".translated()
   
  
    
}


extension String {
    func translated() -> String {
        if let path = Bundle.main.path(forResource: LocalizeDefaultLanguage, ofType: "lproj"), let bundle = Bundle(path: path) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        
        return ""
    }
}
