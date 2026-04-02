import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var networkMonitor = NetworkMonitor()
    @ObservedObject var notificationHandler: NotificationHandler
    @State private var showLaunchBridge = true

    var body: some View {
        ZStack {
            if showLaunchBridge {
                LaunchBridgeView()
                    .transition(.identity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.18), value: showLaunchBridge)
        .task {
            authService.activateIfNeeded()
            dismissLaunchBridgeIfNeeded()
        }
    }

    private var mainContent: some View {
        ZStack {
            Theme.Colors.bgPrimary
                .ignoresSafeArea()

            if authService.isAuthenticated {
                AuthenticatedRootView()
                    .transition(.opacity)
            } else {
                LoginView(authService: authService)
                    .transition(.opacity)
            }

            // Bandeau hors connexion
            if !networkMonitor.isConnected {
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
    }

    private func dismissLaunchBridgeIfNeeded() {
        guard showLaunchBridge else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showLaunchBridge = false
        }
    }
}

private struct LaunchBridgeView: View {
    var body: some View {
        ZStack {
            Theme.Colors.bgPrimary
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.md) {
                Text("TagYourCar")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Theme.Colors.textPrimary)

                Text("Signalez. Protégez. Communauté.")
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            .offset(y: -34)
        }
    }
}

private struct AuthenticatedRootView: View {
    @StateObject private var plateService = PlateService()

    var body: some View {
        TabBarView(plateService: plateService)
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
