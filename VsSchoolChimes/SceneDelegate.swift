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

    func scene(_ scene: UIScene,
                  willConnectTo session: UISceneSession,
                  options connectionOptions: UIScene.ConnectionOptions) {

           UNUserNotificationCenter.current().delegate = self

           // 🔥 App launched from killed state by tapping notification
           if let response = connectionOptions.notificationResponse {
               let userInfo = response.notification.request.content.userInfo
               print("🔥 SceneDelegate → launched by notification (killed)")
               forwardToAppDelegate(userInfo)
           }
       }

       // 🔥 Foreground → Background → Notification Center tap handler
       func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   didReceive response: UNNotificationResponse,
                                   withCompletionHandler completionHandler: @escaping () -> Void) {

           print("🔥 SceneDelegate → notification tapped (foreground/background)")

           forwardToAppDelegate(response.notification.request.content.userInfo)
           completionHandler()
       }

       // 🔥 Foreground banner
       func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   willPresent notification: UNNotification,
                                   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

           if #available(iOS 14.0, *) {
               completionHandler([.banner, .sound, .list])
           } else {
               // Fallback on earlier versions
           }
       }

       // 🔥 Reset duplicate flag whenever app becomes active
       func sceneDidBecomeActive(_ scene: UIScene) {
           if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
               appDelegate.notificationAlreadyHandled = false
           }
           NetworkMonitor.shared.startMonitoring()
       }
       private func forwardToAppDelegate(_ userInfo: [AnyHashable: Any]) {
           if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
               appDelegate.handleNotificationTap(userInfo: userInfo)
           }
       }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect")
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

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

}


