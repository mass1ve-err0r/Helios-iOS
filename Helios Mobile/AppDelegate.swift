//
//  AppDelegate.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import UIKit
import UserNotifications


final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let hex = deviceToken.map { String(format: "%02x", $0) }.joined()

        PushRegistrationManager.shared.didRegisterForRemoteNotifications(deviceTokenHex: hex)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushRegistrationManager.shared.didFailToRegisterForRemoteNotifications(error: error)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        NotificationPersister.persist(request: notification.request, into: PersistenceController.shared.newBackgroundContext())

        // The Notification Service Extension may have written this
        // notification first. Consume that cross-process Core Data
        // transaction so @FetchRequest sees it immediately.
        PersistenceController.shared.processPersistentHistory()

        return [.banner, .list, .sound, .badge]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        NotificationPersister.persist(request: response.notification.request, into: PersistenceController.shared.newBackgroundContext())

        PersistenceController.shared.processPersistentHistory()
    }
    
}
