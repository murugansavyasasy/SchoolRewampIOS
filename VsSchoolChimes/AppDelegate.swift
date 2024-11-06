    //
    //  AppDelegate.swift
    //  VsSchoolChimes
    //
    //  Created by admin on 12/06/24.
    //

import UIKit
import FirebaseCore
import FirebaseMessaging

    @main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {


    var DeviceToken : String!

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


    window?.overrideUserInterfaceStyle = .light

    FirebaseApp.configure()

    UNUserNotificationCenter.current().delegate = self

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in

    print("Permission granted: \(granted)")

    }

    application.registerForRemoteNotifications()

    Messaging.messaging().delegate = self



    return true

    }



    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {



    print("Firebase registration token: \(String(describing: fcmToken))")

    // Optionally, send the token to your server or save it for later

    }





    func application(_ application: UIApplication,



    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {



    Messaging.messaging().apnsToken = deviceToken



    print("MessagingDelegate",deviceToken)



    }


    func application(

    _ application: UIApplication,

    didFailToRegisterForRemoteNotificationsWithError error: Error

    ) {

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

    func userNotificationCenter(_ center: UNUserNotificationCenter,



    didReceive response: UNNotificationResponse) async {



    let userInfo = response.notification.request.content.userInfo




    print("didReceivedidReceivedidReceive",userInfo)



    }

    func application(_ application: UIApplication,



    didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async



    -> UIBackgroundFetchResult {



    // If you are receiving a notification message while your app is in the background,





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

    func userNotificationCenter(_ center: UNUserNotificationCenter,



    didReceive response: UNNotificationResponse,



    withCompletionHandler completionHandler: @escaping () -> Void) {

    completionHandler()



    }
    

