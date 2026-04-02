import SwiftUI
import UIKit

struct ConfirmationView: View {
    let variant: Variant
    let onDismiss: () -> Void

    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    @State private var showCheck = false
    @State private var autoDismissTask: Task<Void, Never>?
    @State private var showShareSheet = false

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

            Text("C'est envoyé !")
                .font(Theme.Typography.display)
                .foregroundStyle(.white)
                .tracking(-0.5)

            Text("Le propriétaire sera notifié.")
                .font(Theme.Typography.bodyMedium)
                .foregroundStyle(.white.opacity(0.85))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Signalement envoye avec succes. Le propriétaire sera notifié.")
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

            Text("Laissez un petit mot sur le pare-brise pour qu'il découvre l'app !")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            // CTA carte pare-brise
            Button {
                showShareSheet = true
            } label: {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "doc.text")
                    Text("Carte pare-brise")
                        .font(Theme.Typography.bodyMedium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Theme.Colors.accentInteractive)
                .foregroundStyle(Theme.Colors.textOnAccent)
                .cornerRadius(Theme.Radius.lg)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .accentGlow()
            .accessibilityLabel("Partager une carte pare-brise")
            .accessibilityHint("Ouvre les options de partage pour une fiche a glisser sur le pare-brise")

            Button {
                onDismiss()
            } label: {
                Text("Fermer")
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.accentInteractive)
            }
            .accessibilityLabel("Fermer et revenir a l'accueil")
        }
        .sheet(isPresented: $showShareSheet) {
            WindshieldCardShareSheet()
        }
    }

    // MARK: - Helpers

    private var backgroundColor: Color {
        switch variant {
        case .success: return Theme.Colors.accentInteractive
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
