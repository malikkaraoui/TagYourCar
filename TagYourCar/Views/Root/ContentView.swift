import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if authService.isAuthenticated {
                HomeView()
            } else {
                LoginView(authService: authService)
            }
        }
    }
}

// Placeholder — sera remplace par le TabBar dans les stories suivantes
struct HomeView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            Text("TagYourCar")
                .font(Theme.Typography.display)
                .foregroundStyle(Theme.Colors.accentPrimary)

            if let user = authService.currentUser {
                Text("Bienvenue, \(user.displayName)")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            Spacer()

            Button {
                try? authService.signOut()
            } label: {
                Text("Se deconnecter")
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.bgCard)
                    .foregroundStyle(Theme.Colors.error)
                    .cornerRadius(Theme.Radius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.md)
                            .stroke(Theme.Colors.bgSeparator, lineWidth: 1)
                    )
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .background(Theme.Colors.bgPrimary.ignoresSafeArea())
    }
}
