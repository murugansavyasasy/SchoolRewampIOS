import Foundation
import Security
 
//class DeviceUUIDManager {
//    static let uuidKey = "com.voicesnap.schoolmessenger"
//    
//    // Public method to get the persistent UUID
//    static func getDeviceUUID() -> String {
//        // Check if UUID exists
//        if let uuid = loadUUIDFromKeychain() {
//            return uuid
//        } else {
//            // Generate and store new UUID
//            let newUUID = UUID().uuidString
//            saveUUIDToKeychain(uuid: newUUID)
//            return newUUID
//        }
//    }
//    
//    // Save UUID to Keychain (default accessibility, persists after uninstall)
//    private static func saveUUIDToKeychain(uuid: String) {
//        
//        
//        if let uuidData = uuid.data(using: .utf8) {
//            let query: [String: Any] = [
//                kSecClass as String: kSecClassGenericPassword,
//                kSecAttrAccount as String: uuidKey,
//                kSecValueData as String: uuidData,
//                // Optional: set access attribute (default is fine, or explicitly use this line)
//                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
//            ]
//            // Delete any existing item first (to avoid duplication)
//            SecItemDelete(query as CFDictionary)
//            // Add the new UUID
////            SecItemAdd(query as CFDictionary, nil)
//            
//            let status = SecItemAdd(query as CFDictionary, nil)
//            if status == errSecSuccess {
//            print("✅ UUID saved to Keychain")
//            } else {
//            print("❌ Failed to save UUID to Keychain. Status: \(status)")
//            }
//            
//        }
//    }
//    
//    // Load UUID from Keychain
//    private static func loadUUIDFromKeychain() -> String? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: uuidKey,
//            kSecReturnData as String: true,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//        
//        var item: AnyObject?
//        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
//            if let data = item as? Data,
//               let uuid = String(data: data, encoding: .utf8) {
//                return uuid
//            }
//        }
//        return nil
//    }
//}



class KeychainHelper {
    static let shared = KeychainHelper()
    
    func save(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary) // Delete existing key if any
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func retrieve(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }
}

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

