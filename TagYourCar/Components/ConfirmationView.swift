import SwiftUI
import UIKit

struct ConfirmationView: View {
    let variant: Variant
    let onDismiss: () -> Void

    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    @State private var showCheck = false
    @State private var autoDismissTask: Task<Void, Never>?

    enum Variant {
        case success
        case notRegistered
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            switch variant {
            case .success:
                successContent
            case .notRegistered:
                notRegisteredContent
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())
        .onAppear {
            triggerHaptic()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showCheck = true
            }
            if variant == .success {
                autoDismissTask = Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    if !Task.isCancelled {
                        onDismiss()
                    }
                }
            }
        }
        .onDisappear {
            autoDismissTask?.cancel()
        }
    }

    // MARK: - Succes

    private var successContent: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white)
                .scaleEffect(showCheck ? 1.0 : 0.3)
                .opacity(showCheck ? 1.0 : 0.0)

            Text("C'est envoye !")
                .font(Theme.Typography.h1)
                .foregroundStyle(.white)

            Text("Le proprietaire sera notifie.")
                .font(Theme.Typography.body)
                .foregroundStyle(.white.opacity(0.9))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Signalement envoye avec succes. Le proprietaire sera notifie.")
    }

    // MARK: - Plaque non enregistree

    private var notRegisteredContent: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "car.badge.questionmark")
                .font(.system(size: 64))
                .foregroundStyle(Theme.Colors.warning)
                .scaleEffect(showCheck ? 1.0 : 0.3)
                .opacity(showCheck ? 1.0 : 0.0)

            Text("Ce conducteur n'est pas encore sur TagYourCar")
                .font(Theme.Typography.h2)
                .foregroundStyle(Theme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Laissez un petit mot sur le pare-brise pour qu'il decouvre l'app !")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            Button {
                onDismiss()
            } label: {
                Text("Compris")
                    .font(Theme.Typography.body)
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.accentInteractive)
                    .foregroundStyle(Theme.Colors.textOnAccent)
                    .cornerRadius(Theme.Radius.md)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.md)
            .accessibilityLabel("Fermer et revenir a l'accueil")
        }
    }

    // MARK: - Helpers

    private var backgroundColor: Color {
        switch variant {
        case .success: return Theme.Colors.success
        case .notRegistered: return Theme.Colors.bgPrimary
        }
    }

    private func triggerHaptic() {
        switch variant {
        case .success:
            impactHeavy.prepare()
            impactHeavy.impactOccurred()
        case .notRegistered:
            notificationFeedback.prepare()
            notificationFeedback.notificationOccurred(.warning)
        }
    }
}
