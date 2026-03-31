import SwiftUI
import FirebaseCore

@main
struct TagYourCarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService: AuthService

    init() {
        // Firebase est configuré dans AppDelegate - pas de duplication
        _authService = StateObject(wrappedValue: AuthService())
    }

    var body: some Scene {
        WindowGroup {
            ContentView(notificationHandler: delegate.notificationHandler)
                .environmentObject(authService)
                .task {
                    authService.activateIfNeeded()
                }
        }
    }
}
