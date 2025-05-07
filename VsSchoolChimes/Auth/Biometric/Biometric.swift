//
//  Biometric.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 28/03/25.
//
import Foundation
import LocalAuthentication
import UIKit

class BiometricAuthentication {
    
    static let shared = BiometricAuthentication()
    private let biometricEnabledKey = "BiometricEnabled"
    private let biometricDecline = "BiometricDecline"
    
    // MARK: - Authenticate User (Face ID, Touch ID & Passcode)
    func authenticateUser(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        if !isBiometricEnabledInApp() {
            completion(false)
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        // Biometric + Passcode fallback support
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            let errorMessage = getBiometricStatus()
            DispatchQueue.main.async {
                self.showEnableBiometricPopup(from: viewController, message: errorMessage)
            }
            completion(false)
            return
        }
        
        let reason = "Authenticate using Face ID / Touch ID / Passcode"
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    completion(true)
                } else {
                    let errorMessage = self.errorMessage(for: authenticationError?._code ?? -1)
                    self.showAlertWithTitle(from: viewController, title: "Authentication Failed", message: errorMessage)
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Enable Biometric for This App
    func enableBiometric(_ enable: Bool) {
        UserDefaults.standard.set(enable, forKey: biometricEnabledKey)
    }
    func DeclineBiometric(_ enable: Bool) {
        UserDefaults.standard.set(enable, forKey: biometricDecline)
    }
    func isBiometricEnabledInApp() -> Bool {
        return UserDefaults.standard.bool(forKey: biometricEnabledKey)
    }
    func isBiometricDeclineInApp() -> Bool {
        return UserDefaults.standard.bool(forKey: biometricDecline)
    }

    // MARK: - Check Biometric Status
    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    func getBiometricStatus() -> String {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            if let error = error {
                switch error.code {
                case LAError.biometryNotAvailable.rawValue:
                    return "Biometric authentication is not available on this device"
                case LAError.biometryNotEnrolled.rawValue:
                    return "No biometric data enrolled. Please set up Face ID or Touch ID"
                case LAError.passcodeNotSet.rawValue:
                    return "Biometric authentication requires a passcode setup"
                default:
                    return "Biometric authentication is not enabled"
                }
            }
            return "Unknown error"
        }
        return "Biometric Authentication is Enabled"
    }
    
    // MARK: - Show Enable Biometric Popup
    func showEnableBiometricPopup(from viewController: UIViewController, message: String) {
        let alert = UIAlertController(title: "Enable Face ID / Touch ID", message: "Do you want to enable biometric authentication for this app?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Enable", style: .default) { _ in
            self.enableBiometric(true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.enableBiometric(false)
            self.DeclineBiometric(true)
        })
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
    
    // MARK: - Show Alert
    private func showAlertWithTitle(from viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            exit(0)
        })
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }

    // MARK: - Biometric Error Handling
    private func errorMessage(for errorCode: Int) -> String {
        switch errorCode {
        case LAError.authenticationFailed.rawValue:
            return "Authentication Failed"
        case LAError.userCancel.rawValue:
            return "User canceled the authentication"
        case LAError.systemCancel.rawValue:
            return "System canceled authentication"
        case LAError.passcodeNotSet.rawValue:
            return "Biometric authentication requires a passcode setup"
        case LAError.biometryNotAvailable.rawValue:
            return "Biometric authentication is not available on this device"
        case LAError.biometryNotEnrolled.rawValue:
            return "No biometric data enrolled. Please set up Face ID or Touch ID"
        case LAError.biometryLockout.rawValue:
            return "Biometric authentication is locked. Retry after some time"
        default:
            return "Unknown error. Please try again"
        }
    }
}
