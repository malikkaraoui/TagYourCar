import SwiftUI

@main
struct TagYourCarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService: AuthService

    init() {
        FirebaseBootstrap.configureIfNeeded()
        _authService = StateObject(wrappedValue: AuthService())
    }

    var body: some Scene {
        WindowGroup {
            ContentView(notificationHandler: delegate.notificationHandler)
                .environmentObject(authService)
        }
    }
}
