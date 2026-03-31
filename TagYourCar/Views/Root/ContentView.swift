import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var plateService = PlateService()

    var body: some View {
        Group {
            if authService.isAuthenticated {
                TabBarView(plateService: plateService)
            } else {
                LoginView(authService: authService)
            }
        }
    }
}

struct TabBarView: View {
    @EnvironmentObject var authService: AuthService
    let plateService: PlateService

    var body: some View {
        TabView {
            ReportView()
                .tabItem {
                    Label("Signaler", systemImage: "exclamationmark.triangle")
                }

            PlateListView(plateService: plateService)
                .tabItem {
                    Label("Mes plaques", systemImage: "car.fill")
                }
        }
        .tint(Theme.Colors.accentPrimary)
    }
}

