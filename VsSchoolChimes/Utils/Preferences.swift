//
//  Preferences.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import Foundation



class PreferencesUtil{

    static func saveToPrefs(key : String, value : String) -> Void{

        UserDefaults.standard.set(value, forKey: key)

    }

    

    static func getFromPrefs(key : String) -> String{

        return UserDefaults.standard.string(forKey: key)!

    }

    

    static func removePrefs(key : String) -> Void{

        UserDefaults.standard.removeObject(forKey: key)

    }

    

    static func checkPrefs(key : String) -> Bool{

        return UserDefaults.standard.object(forKey: key) != nil

    }

    

    static func isObjectNotNil(object:AnyObject!) -> Bool{

        if let _:AnyObject = object{

            return true

        }

        return false

    }

    

    static func getUniCodeString(unicodeString : String) -> String{

        let transform = "Any-Hex/Java"

        let input = "\(unicodeString)" as NSString

        let convertedString = input.mutableCopy() as! NSMutableString

        CFStringTransform(convertedString, nil, transform as NSString, true)

        return convertedString as String

    }

}

