import UIKit
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import UserNotifications
import os

private let logger = Logger(subsystem: "com.tagyourcar", category: "AppDelegate")

class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationHandler = NotificationHandler()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() == nil {
            if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
                FirebaseApp.configure()
                logger.info("Firebase configured")
            } else {
                logger.error("GoogleService-Info.plist not found — Firebase not configured")
            }
        } else {
            logger.info("Firebase already configured")
        }

        // Configurer le delegate des notifications
        UNUserNotificationCenter.current().delegate = notificationHandler

        // Verifications de sante au demarrage
        HealthCheck.performStartupChecks()

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
