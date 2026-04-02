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

        #if DEBUG
        // Diagnostics retardés pour ne jamais polluer le premier affichage
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            HealthCheck.scheduleStartupChecks()
        }
        #endif

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
