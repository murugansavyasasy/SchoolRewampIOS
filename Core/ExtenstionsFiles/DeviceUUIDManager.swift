import Foundation
import Security
 
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

