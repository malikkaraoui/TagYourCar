import SwiftUI

@main
struct TagYourCarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            UIKitBootstrapView(notificationHandler: delegate.notificationHandler)
                .ignoresSafeArea()
        }
    }
}
