//
//  SceneDelegate.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var languages :String!

    // Called when the app is opened OR reopened
       func scene(_ scene: UIScene,
                  willConnectTo session: UISceneSession,
                  options connectionOptions: UIScene.ConnectionOptions) {

           UNUserNotificationCenter.current().delegate = self

           // 🔥 When app is killed and launched by tapping notification
           if let response = connectionOptions.notificationResponse {
               let userInfo = response.notification.request.content.userInfo
               print("🔥 SceneDelegate -> launched by notification (killed state)")
               forwardToAppDelegate(userInfo)
           }
       }

       // 🔥 Called when tapping a notification in:
       // - Foreground
       // - Background
       // - Notification Center
       func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   didReceive response: UNNotificationResponse,
                                   withCompletionHandler completionHandler: @escaping () -> Void) {

           print("🔥 SceneDelegate: notification tapped (foreground/background)")

           let userInfo = response.notification.request.content.userInfo
           forwardToAppDelegate(userInfo)

           completionHandler()
       }

       // 🔥 Show banner while in foreground (needed so user can tap)
       func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   willPresent notification: UNNotification,
                                   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

           if #available(iOS 14.0, *) {
               completionHandler([.banner, .sound, .badge, .list])
           }
       }

       // 🔥 Pass info to AppDelegate for navigation
       private func forwardToAppDelegate(_ userInfo: [AnyHashable: Any]) {
           if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
               appDelegate.handleNotificationTap(userInfo: userInfo)
           }
       }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect")
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
     // Called when the scene has moved from an inactive state to an active state.
     // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("sceneDidBecomeActive")
     NetworkMonitor.shared.startMonitoring()
     
     
     }

     func sceneWillResignActive(_ scene: UIScene) {
     // Called when the scene will move from an active state to an inactive state.
     // This may occur due to temporary interruptions (ex. an incoming phone call).
         print("sceneWillResignActive")
     NetworkMonitor.shared.stopMonitoring()
     }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        print("sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("sceneDidEnterBackground")
    }


}


