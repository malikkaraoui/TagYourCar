import Foundation
import FirebaseCore
import os

enum FirebaseBootstrap {
    private static let logger = Logger(subsystem: "com.tagyourcar", category: "FirebaseBootstrap")

    static func configureIfNeeded() {
        guard FirebaseApp.app() == nil else { return }

        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            logger.error("GoogleService-Info.plist introuvable — Firebase non configure")
            return
        }

        FirebaseApp.configure()
        logger.info("Firebase configure")
    }
}