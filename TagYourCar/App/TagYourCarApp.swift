import SwiftUI

@main
struct TagYourCarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            BootstrapRootView(notificationHandler: delegate.notificationHandler)
        }
    }
}
