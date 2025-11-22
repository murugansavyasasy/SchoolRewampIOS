//
//  AppDelegate.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import AWSCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate {
    
    
    var DeviceToken : String?
    var window: UIWindow?
    var languages : String!
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var childDetails = UserDefaultFileManager.getUserDetails()?.user_details?.child_details
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        
        NetworkMonitor.shared.startMonitoring()
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted:", granted)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self

        // 🔥 Handle Notification Click When App Was Killed
        if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            print("🔥 App opened from terminated state via notification")
            handleNotificationTap(userInfo: remoteNotification)
        }

        return true
    }

    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        DeviceToken = fcmToken
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Stop network monitoring when the app is terminated
        NetworkMonitor.shared.stopMonitoring()
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    
    }
 
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func handleNotificationTap(userInfo: [AnyHashable: Any]) {

        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else { return }

        // Login Check
        guard let login = UserDefaultFileManager.getLoginCredentials(),
              !login.mobile_number.isEmpty,
              !login.pwd.isEmpty else {

            if #available(iOS 14.0, *) {
                presentLogin(from: rootVC)
            }
            return
        }

        print("🔔 Notification tapped:", userInfo)

        let type = userInfo["type"] as? String

        if type == "normal" {

            let loginAs = userInfo["receiver_type"] as? String

            if loginAs == "student" {

                guard let menuId = userInfo["menu_id"] as? String,
                      let instituteId = userInfo["institute_id"] as? String,
                      let childId = userInfo["receiver_id"] as? String,
                      let headerId = userInfo["header_id"] as? String else { return }

                guard let childDetails = UserDefaultFileManager.getUserDetails()?.user_details?.child_details else { return }

                if #available(iOS 14.0, *) {
                    handleNavigation(
                        instituteId: instituteId,
                        childId: childId,
                        childDetails: childDetails,
                        menuID: menuId,
                        header_id: headerId,
                        logintype: 2,
                        from: rootVC
                    )
                }
            }
//            else if loginAs == "student" {
            

        } else if type == "call" {
            let vc = NotificationCallVC()
            vc.modalPresentationStyle = .fullScreen
            rootVC.present(vc, animated: true)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        handleNotificationTap(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        print("📩 Foreground notification:", notification.request.content.userInfo)
        completionHandler([.alert,.sound])
    }

    
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//    
//        print("willPresentwillPresent",notification.request.content.userInfo)
//        completionHandler([.alert,.sound]) // Use .badge and .banner based on your need
//    }
//    
// 
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        
//        defer { completionHandler() } // Always call completionHandler at the end
//        
//        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else { return }
//        
//        // ✅ Check Login
//        guard let login = UserDefaultFileManager.getLoginCredentials(),
//              !login.mobile_number.isEmpty,
//              !login.pwd.isEmpty else {
//            if #available(iOS 14.0, *) {
//                presentLogin(from: rootVC)
//            }
//            return
//        }
//        
//        // ✅ Extract Notification Data
//        let userInfo = response.notification.request.content.userInfo
//        let type = userInfo["type"] as? String
//        if type == "normal"{
//            let loginAs = userInfo["receiver_type"] as? String
//            
//            if loginAs == "student"{
//                guard let menuId = userInfo["menu_id"] as? String,
//                      let instituteId = userInfo["institute_id"] as? String,
//                      let childId = userInfo["receiver_id"] as? String ,
//                      let headerid = userInfo["header_id"] as? String else { return }
//                
//                guard let childDetails = UserDefaultFileManager.getUserDetails()?.user_details?.child_details else { return }
//                
//                
//                if #available(iOS 14.0, *) {
//                    handleNavigation(
//                        instituteId: instituteId,
//                        childId: childId,
//                        childDetails: childDetails,
//                        menuID: menuId, header_id: headerid, logintype: 2,
//                        from: rootVC
//                    )
//                }
//            }
//        }else if type == "call"{
//            let vc = NotificationCallVC()
//            vc.modalPresentationStyle = .fullScreen
//            rootVC.present(vc, animated: true)
//        }
//    }

    @available(iOS 14.0, *)
    // MARK: - Handle Login
    private func presentLogin(from rootVC: UIViewController) {
        let loginVC = LoginVc(nibName: nil, bundle: nil)
        loginVC.modalPresentationStyle = .fullScreen
        rootVC.present(loginVC, animated: true)
    }

    // MARK: - Handle Navigation to tapbar(homePage)
    @available(iOS 14.0, *)
    private func handleNavigation(
        instituteId: String,
        childId: String,
        childDetails: [ChildDetails],
        menuID : String,
        header_id : String,
        logintype : Int,
        from rootVC: UIViewController
    ) {
        // Filter matching children
        let matchingChildren = childDetails.filter { $0.school_id == instituteId && $0.child_id == childId }
        
        if let firstChild = matchingChildren.first {
            UserDefaultFileManager.saveChildDetails(data: firstChild)
        }
        
        let vc = TapBarVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.login_astype = logintype
        vc.comfromNotification = true
        vc.menuId = menuID
        vc.messageId = header_id
        rootVC.present(vc, animated: true)
    }

    
}


// MARK: Ios Home Wallpapper Widets



//func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//
//    window?.overrideUserInterfaceStyle = .light
//    NetworkMonitor.shared.startMonitoring()
//    FirebaseApp.configure()
//
//    UNUserNotificationCenter.current().delegate = self
//
//    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//
//        print("Permission granted: \(granted)")
//
//    }
//
//    application.registerForRemoteNotifications()
//    Messaging.messaging().delegate = self
//    let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APSouth1, identityPoolId: AwsCredentials.CognitoPoolID)//3-2
//    let configuration = AWSServiceConfiguration(region: .APSouth1, credentialsProvider: credentialsProvider)
//    AWSServiceManager.default().defaultServiceConfiguration = configuration
//
//    let attendanceAction = UIApplicationShortcutItem(
//               type: "com.voicesnap.schoolmessenger.attendance",
//               localizedTitle: "Attendance",
//               localizedSubtitle: "Mark your attendance",
//               icon: UIApplicationShortcutIcon(systemImageName: "checkmark.circle"),
//               userInfo: nil
//           )
//
//           let feeDetailsAction = UIApplicationShortcutItem(
//               type: "com.voicesnap.schoolmessenger.feeDetails",
//               localizedTitle: "Fee Details",
//               localizedSubtitle: "Check your fees",
//               icon: UIApplicationShortcutIcon(systemImageName: "dollarsign.circle"),
//               userInfo: nil
//           )
//
//           let videoAction = UIApplicationShortcutItem(
//               type: "com.voicesnap.schoolmessenger.video",
//               localizedTitle: "Videos",
//               localizedSubtitle: "Watch learning videos",
//               icon: UIApplicationShortcutIcon(systemImageName: "video"),
//               userInfo: nil
//           )
//
//           UIApplication.shared.shortcutItems = [attendanceAction, feeDetailsAction, videoAction]
//
//
//
//
//
//    return true
//
//}
//
//
//// Handle Menu Selection
//  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
//      guard let rootVC = window?.rootViewController as? UINavigationController else {
//          completionHandler(false)
//          return
//      }
//
//      switch shortcutItem.type {
//      case "com.voicesnap.schoolmessenger.attendance":
//          let attendanceVC = ReciverAttendanceReportVC()
//          rootVC.pushViewController(attendanceVC, animated: true)
//      case "com.voicesnap.schoolmessenger.feeDetails":
//          let feeVC = VideoVC()
//          rootVC.pushViewController(feeVC, animated: true)
//      case "com.voicesnap.schoolmessenger.video":
//          let videoVC = VideoVC()
//          rootVC.pushViewController(videoVC, animated: true)
//      default:
//          completionHandler(false)
//          return
//      }
//
//      completionHandler(true)
//  }
