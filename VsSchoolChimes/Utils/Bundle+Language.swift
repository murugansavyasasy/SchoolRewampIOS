//
//  Bundle+Language.swift
//  VsSchoolChimes
//
//  Created by admin on 17/12/24.
//

import Foundation


private var bundleKey: UInt8 = 0

extension Bundle {
    
    // Change the language dynamically
    class func setLanguage(_ language: String) {
        object_setClass(Bundle.main, LanguageBundle.self)
        
        let newBundlePath = Bundle.main.path(forResource: language, ofType: "lproj")
        let languageBundle = newBundlePath != nil ? Bundle(path: newBundlePath!) : nil
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, languageBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

class LanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let languageBundle = objc_getAssociatedObject(Bundle.main, &bundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return languageBundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
