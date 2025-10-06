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
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {
    
    
    var DeviceToken : String?
    var window: UIWindow?
    var languages : String!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NetworkMonitor.shared.startMonitoring()
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            print("Permission granted: \(granted)")
            
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APSouth1, identityPoolId: AwsCredentials.CognitoPoolID)//3-2
        let configuration = AWSServiceConfiguration(region: .APSouth1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
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
        
        // Called when the user discards a scene session.
        
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        
    }
    
    
    
    
    
    //    MARK: NOTIFICATION LANDING
    
    private func handleNotification(userInfo: [AnyHashable: Any]) {
        if let redirectDetails = userInfo["gcm.notification.redirect_details"] as? String {
            
            if let data = redirectDetails.data(using: .utf8),
               
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               
                let pageLink = json["page_link"] as? String {
                
                let noti = json["target_id"] as? Int
                
                print("pageLinkssss",pageLink)
                
                NotificationCenter.default.post(name: NSNotification.Name("NavigateToPageLink"), object: pageLink)
                
            }
            
        }
        
    }
    
    
    
    // MARK: PUSH NOTIFICATION
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will Presentfvfevfevefvefwill Presentfvfevfevefvef")
        // Create a custom notification banner (example)
        let message = notification.request.content.body
        completionHandler([.alert,.sound]) // Use .badge and .banner based on your need
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        print("didReceivedidReceivedidReceive",userInfo)
        
    }
    
    
//    func application(_ application: UIApplication,
//                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//
//        if let menuId = userInfo["menu_id"] as? String,
//           let messageId = userInfo["message_id"] as? String {
//            NotificationCenter.default.post(name: .notificationTapped,
//                                            object: nil,
//                                            userInfo: ["menu_id": menuId, "message_id": messageId])
//        }
//
//        completionHandler(.newData)
//    }
    
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        
        if let wavURLString = userInfo["wav_url"] as? String, let wavURL = URL(string: wavURLString) {
            print("WAV File URL: \(wavURL)")
            // Navigate to the specific view controller
        }
        print("didReceiveRemoteNotification",userInfo)
        return UIBackgroundFetchResult.newData
    }
    
    
    
    func getCurrentViewController() -> UIViewController? {
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("Permission: \(granted)")
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
}

//MARK: -  UNUserNotificationCenterDelegate

@available(iOS 10, *)

func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
    completionHandler()
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
