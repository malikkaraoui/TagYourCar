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
            ReportPlaceholderView()
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

// Placeholder — sera remplace dans Epic 3
struct ReportPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                Spacer()
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.Colors.accentMuted)
                Text("Signalement")
                    .font(Theme.Typography.h1)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Text("Bientot disponible")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                Spacer()
            }
            .navigationTitle("Signaler")
        }
    }
}
