//
//  SecureidFile.swift
//  VsSchoolChimes
//
//  Created by admin on 18/03/25.
//

import Foundation


//class SecureIDManager {
//    static let secureIDKey = "com.voicesnap.schoolmessenger.secureID"
//
//    static func getSecureID() -> String {
//        // 1️⃣ Check Keychain first
//        if let savedID = KeychainHelper.shared.retrieve(key: secureIDKey) {
//            return savedID
//        }
//        
//        // 2️⃣ If missing, check iCloud
//        if let cloudID = iCloudHelper.getFromiCloud(key: secureIDKey) {
//            KeychainHelper.shared.save(key: secureIDKey, value: cloudID) // Restore to Keychain
//            return cloudID
//        }
//        
//        // 3️⃣ If missing, generate a new Secure ID
//        let newSecureID = UUID().uuidString
//        KeychainHelper.shared.save(key: secureIDKey, value: newSecureID)
//        iCloudHelper.saveToiCloud(newSecureID, key: secureIDKey)
//        
//        return newSecureID
//    }
//}
