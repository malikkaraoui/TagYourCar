import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var plateService = PlateService()
    @ObservedObject var notificationHandler: NotificationHandler

    var body: some View {
        ZStack {
            Group {
                if authService.isAuthenticated {
                    TabBarView(plateService: plateService)
                } else {
                    LoginView(authService: authService)
                }
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
    }
}
