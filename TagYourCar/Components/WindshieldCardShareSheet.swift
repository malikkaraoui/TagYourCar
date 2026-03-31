import SwiftUI

struct WindshieldCardShareSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let cardText = """
    Bonjour,

    J'ai remarque un souci sur votre vehicule \
    et j'aurais aime vous prevenir instantanement.

    Avec l'app TagYourCar, vous recevez une notification \
    en temps reel quand quelqu'un signale un probleme \
    sur votre voiture (phares allumes, vitre ouverte, etc.).

    Gratuit et disponible sur l'App Store.
    Recherchez : TagYourCar

    Bonne route !
    """

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Apercu de la carte
                    VStack(spacing: Theme.Spacing.md) {
                        Text("TagYourCar")
                            .font(Theme.Typography.h1)
                            .foregroundStyle(Theme.Colors.accentPrimary)

                        Text(cardText)
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Colors.textPrimary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(Theme.Spacing.xl)
                    .background(Theme.Colors.bgCard)
                    .cornerRadius(Theme.Radius.lg)
                    .cardShadow()
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Bouton partager
                    ShareLink(item: cardText) {
                        HStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Partager cette carte")
                        }
                        .font(Theme.Typography.body)
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.accentInteractive)
                        .foregroundStyle(Theme.Colors.textOnAccent)
                        .cornerRadius(Theme.Radius.md)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .accessibilityLabel("Partager le texte de la carte pare-brise")

                    Text("Imprimez cette carte et glissez-la dans le joint de vitre conducteur.")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)
                }
                .padding(.top, Theme.Spacing.lg)
            }
            .background(Theme.Colors.bgPrimary.ignoresSafeArea())
            .navigationTitle("Carte pare-brise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .foregroundStyle(Theme.Colors.accentInteractive)
                }
            }
        }
    }
}
