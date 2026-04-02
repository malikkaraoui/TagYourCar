import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var plateService = PlateService()
    @ObservedObject var notificationHandler: NotificationHandler

    var body: some View {
        ZStack {
            Theme.Colors.bgPrimary
                .ignoresSafeArea()

            if !authService.isReady {
                // Splash SwiftUI — remplace le LaunchScreen dès que la vue est montée
                VStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Theme.Colors.accentInteractive)
                    Text("TagYourCar")
                        .font(Theme.Typography.display)
                        .foregroundStyle(Theme.Colors.textPrimary)
                        .tracking(-0.5)
                }
            } else if authService.isAuthenticated {
                TabBarView(plateService: plateService)
            } else {
                LoginView(authService: authService)
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
        .animation(.easeInOut(duration: 0.3), value: notificationHandler.showReportDetail)
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
