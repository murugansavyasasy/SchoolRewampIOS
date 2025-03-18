//
//  SecureidFile.swift
//  VsSchoolChimes
//
//  Created by admin on 18/03/25.
//

import Foundation

class SecureIDManager {
    static let secureIDKey = "com.voicesnap.schoolmessenger.secureID"

    static func getSecureID() -> String {
        // 1️⃣ Check if Secure ID already exists in Keychain
        if let savedData = KeychainHelper.shared.retrieve(key: secureIDKey),
           let savedSecureID = String(data: savedData, encoding: .utf8) {
            return savedSecureID
        }

        // 2️⃣ If not, generate a new one
        let newSecureID = UUID().uuidString
        if let data = newSecureID.data(using: .utf8) {
            KeychainHelper.shared.save(key: secureIDKey, data: data)
        }

        return newSecureID
    }
}
