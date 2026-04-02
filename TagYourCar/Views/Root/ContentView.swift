import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var networkMonitor = NetworkMonitor()
    @ObservedObject var notificationHandler: NotificationHandler

    var body: some View {
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
}

private struct AuthenticatedRootView: View {
    @StateObject private var plateService = PlateService()
    @StateObject private var reportViewModel = ReportViewModel()
    @State private var selectedTab: AppTab = .report

    var body: some View {
        TabBarView(
            plateService: plateService,
            reportViewModel: reportViewModel,
            selectedTab: $selectedTab
        )
    }
}

enum AppTab: Hashable {
    case report
    case plates
}

struct TabBarView: View {
    @EnvironmentObject var authService: AuthService
    let plateService: PlateService
    @ObservedObject var reportViewModel: ReportViewModel
    @Binding var selectedTab: AppTab

    var body: some View {
        TabView(selection: $selectedTab) {
            ReportView(viewModel: reportViewModel)
                .tabItem {
                    Label("Signaler", systemImage: "exclamationmark.triangle")
                }
                .tag(AppTab.report)

            PlateListView(
                plateService: plateService,
                isTabActive: selectedTab == .plates
            )
                .tabItem {
                    Label("Mes plaques", systemImage: "car.fill")
                }
                .tag(AppTab.plates)
        }
        .tint(Theme.Colors.accentPrimary)
            .toolbarBackground(Theme.Colors.bgPrimary, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
    }
}
