import UIKit
import FirebaseMessaging
import GoogleSignIn
import UserNotifications

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationHandler = NotificationHandler()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configurer le delegate des notifications
        UNUserNotificationCenter.current().delegate = notificationHandler

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        FirebaseBootstrap.configureIfNeeded()
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
