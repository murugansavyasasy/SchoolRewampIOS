//
//  AppDelegate.swift
//  VsSchoolChimes
//
//  Created by SARAN on 12/06/24.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import AWSCore
import FirebaseCrashlytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var notificationAlreadyHandled = false
    var deviceTokenString: String?
    var window: UIWindow?
    
    var languages: String!
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var childDetails = UserDefaultFileManager.getUserDetails()?.user_details?.child_details
    let tempKey = "TempRecordings"
    // MARK: - Application Life Cycle
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
//            }else{
//                self.checkNotificationPermission()
//            }
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cleanupTempRecordings),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        return true
    }
    @objc func cleanupTempRecordings() {
        let tempKey = "TempRecordings"
        let list = UserDefaults.standard.stringArray(forKey: tempKey) ?? []
        for item in list {
            if let url = URL(string: item){
                deleteFile(at: url)
            }
        }
        UserDefaults.standard.removeObject(forKey: tempKey)
    }
    
    func checkNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    print("✅ Notification Allowed")

                case .denied:
                    print("❌ Notification Denied")
                    self.showNotificationPermissionAlert()

                case .notDetermined:
                    print("⚠️ Not Determined")
                    self.requestNotificationPermission()

                @unknown default:
                    break
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ User Granted Permission")
                } else {
                    print("❌ User Denied Permission")
                    self.showNotificationPermissionAlert()
                }
            }
        }
    }
    
    func showNotificationPermissionAlert() {
        let alert = UIAlertController(
            title: "Enable Notifications",
            message: "Please enable notifications to receive important updates.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        UIApplication.shared.windows.first?.rootViewController?
            .present(alert, animated: true)
    }
    func deleteFile(at url: URL) {

        var list = UserDefaults.standard.stringArray(forKey: tempKey) ?? []

        if let index = list.firstIndex(where: { storedPath in
            let storedURL = URL(fileURLWithPath: storedPath)
            return storedURL.path == url.path
        }) {

            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("❌ Delete failed:", error.localizedDescription)
                }
            }

            list.remove(at: index)
            UserDefaults.standard.set(list, forKey: tempKey)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    // MARK: - Firebase Token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        deviceTokenString = fcmToken
        print("FCM Token:", fcmToken ?? "")
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS TOKEN RECEIVED FOR NEW TARGET")
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push registration failed:", error.localizedDescription)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        NetworkMonitor.shared.stopMonitoring()
    }

    // MARK: - Scene
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration",
                             sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // MARK: - Notification Handler
    func handleNotificationTap(userInfo: [AnyHashable: Any]) {

        guard let topVC = UIApplication.topViewController() else {
            print("❌ No top visible view controller")
            return
        }

        guard let login = UserDefaultFileManager.getLoginCredentials(),
              !login.mobile_number.isEmpty,
              !login.pwd.isEmpty else {
            presentLogin(from: topVC)
            return
        }

        print("userInfouserInfo",userInfo)
        if notificationAlreadyHandled {
            print("🚫 Notification already handled — skipping duplicate.")
            return
        }
        notificationAlreadyHandled = true

        let type = userInfo["type"] as? String
        let voiceUrl = userInfo["voice_url"] as? String ?? ""
        let welcomeURL = userInfo["WelcomeUrl"] as? String ?? ""
        if type == "normal" {
            handleNormalNotification(userInfo: userInfo, from: topVC)
        } else if type == "isCall" {
            let vc = NotificationCallVC()
            vc.userInfo = userInfo
            vc.voiceUrl = userInfo["url"] as? String ?? ""
            vc.welcomeFileUrl = userInfo["welcome"] as? String ?? ""
            vc.modalPresentationStyle = .fullScreen
            topVC.present(vc, animated: true)
        }
    }

    
    // MARK: - Notification Types
    private func handleNormalNotification(userInfo: [AnyHashable: Any], from topVC: UIViewController) {

        let loginAs = userInfo["receiver_type"] as? String

        if loginAs == "student" {
            guard let menuId = userInfo["menu_id"] as? String,
                  let instituteId = userInfo["institute_id"] as? String,
                  let childId = userInfo["receiver_id"] as? String,
                  let headerId = userInfo["header_id"] as? String,
                  let childDetails = UserDefaultFileManager.getUserDetails()?.user_details?.child_details else { return }

            handleStudentNavigation(
                instituteId: instituteId,
                childId: childId,
                childDetails: childDetails,
                menuID: menuId,
                header_id: headerId,
                logintype: 2,
                from: topVC
            )
        }

        else if loginAs == "staff" {
            guard let menuId = userInfo["menu_id"] as? String,
                  let instituteId = userInfo["institute_id"] as? String,
                  let staffId = userInfo["receiver_id"] as? String,
                  let headerId = userInfo["header_id"] as? String,
                  let staffDetails = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details else { return }

            handleStaffNavigation(
                instituteId: instituteId,
                staffId: staffId,
                staffdetails: staffDetails,
                menuID: menuId,
                header_id: headerId,
                logintype: 1,
                from: topVC
            )
        }
    }

    // MARK: - Foreground & Tap Notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completion: @escaping () -> Void) {
        print("response.notification.request.content.userInforesponse.notification.request.content.userInfo",response.notification.request.content.userInfo)
        handleNotificationTap(userInfo: response.notification.request.content.userInfo)
        completion()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completion: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("📩 Foreground notification:", notification.request.content.userInfo)
        completion([.alert, .sound])
    }

    // MARK: - Login & Navigation Helpers
    private func presentLogin(from rootVC: UIViewController) {
        if #available(iOS 14.0, *) {
            let loginVC = LoginVc()
            loginVC.modalPresentationStyle = .fullScreen
            rootVC.present(loginVC, animated: true)
        }
        
    }

    private func handleStudentNavigation(
        instituteId: String,
        childId: String,
        childDetails: [ChildDetails],
        menuID: String,
        header_id: String,
        logintype: Int,
        from rootVC: UIViewController
    ) {
        if let match = childDetails.first(where: { $0.school_id == instituteId && $0.child_id == childId }) {
            UserDefaultFileManager.saveChildDetails(data: match)
        }

        presentHome(menuID: menuID, headerID: header_id, loginType: logintype)
    }

    private func handleStaffNavigation(
        instituteId: String,
        staffId: String,
        staffdetails: [StaffDetails],
        menuID: String,
        header_id: String,
        logintype: Int,
        from rootVC: UIViewController
    ) {
        if let match = staffdetails.first(where: { $0.school_id == instituteId && $0.staff_id == staffId }) {
            UserDefaultFileManager.saveStaffDetails(data: match)
        }
        presentHome(menuID: menuID, headerID: header_id, loginType: logintype)
    }

    private func presentHome(menuID: String, headerID: String, loginType: Int) {
        guard let topVC = UIApplication.topViewController() else { return }
        if #available(iOS 14.0, *) {
            let vc = TapBarVC()
            vc.modalPresentationStyle = .fullScreen
            vc.login_astype = loginType
            vc.comfromNotification = true
            vc.menuId = menuID
            vc.messageId = headerID
            topVC.present(vc, animated: true)
        }
    }
}


// MARK: - UIApplication Helpers
extension UIApplication {
    var currentWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    class func topViewController(_ vc: UIViewController? = UIApplication.shared.currentWindow?.rootViewController) -> UIViewController? {
        if let nav = vc as? UINavigationController { return topViewController(nav.visibleViewController) }
        if let tab = vc as? UITabBarController { return topViewController(tab.selectedViewController) }
        if let presented = vc?.presentedViewController { return topViewController(presented) }
        return vc
    }
  


}
