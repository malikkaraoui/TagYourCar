import UIKit
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import os

private let logger = Logger(subsystem: "com.tagyourcar", category: "AppDelegate")

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() == nil,
           Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            logger.info("Firebase configured")
        } else {
            logger.warning("GoogleService-Info.plist not found — Firebase not configured")
        }
        
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
