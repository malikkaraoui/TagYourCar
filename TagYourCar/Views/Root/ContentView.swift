import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var plateService = PlateService()
    @StateObject private var networkMonitor = NetworkMonitor()
    @ObservedObject var notificationHandler: NotificationHandler
    @State private var showSplash = true

    var body: some View {
        ZStack {
            Theme.Colors.bgPrimary
                .ignoresSafeArea()

            if showSplash {
                // Splash branding 2s — Firebase s'initialise en parallèle
                VStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.Colors.accentInteractive)
                    Text("TagYourCar")
                        .font(Theme.Typography.display)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .tracking(-0.5)
                }
                .transition(.opacity)
            } else if authService.isAuthenticated {
                TabBarView(plateService: plateService)
                    .transition(.opacity)
            } else {
                LoginView(authService: authService)
                    .transition(.opacity)
            }

            // Bandeau hors connexion
            if !showSplash && !networkMonitor.isConnected {
                VStack {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Pas de connexion internet")
                            .font(Theme.Typography.caption)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Theme.Colors.error)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(3)
            }

            // Ecran detail signalement par-dessus (deep link notification)
            if notificationHandler.showReportDetail,
               let reportData = notificationHandler.pendingReport {
                ReportDetailView(
                    reportData: reportData,
                    onDismiss: { notificationHandler.dismissDetail() }
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
        .animation(.easeInOut(duration: 0.3), value: notificationHandler.showReportDetail)
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .task {
            // Splash branding : 2 secondes minimum
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showSplash = false
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
            .toolbarBackground(Theme.Colors.bgPrimary, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
    }
}
