import SwiftUI

struct PlateCard: View {
    let plate: Plate

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Badge icone
            Image(systemName: "car.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.Colors.accentInteractive)
                .frame(width: 36, height: 36)
                .background(Theme.Colors.accentInteractive.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))

            Text(plate.maskedDisplay)
                .font(Theme.Typography.plate)
                .foregroundStyle(Theme.Colors.textPrimary)
                .tracking(1)

            Spacer()

            if plate.verified {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                    Text("Verifie")
                        .font(Theme.Typography.captionSmall)
                        .textCase(.uppercase)
                        .tracking(0.3)
                }
                .foregroundStyle(Theme.Colors.success)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .background(Theme.Colors.success.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding(Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.xs)
        .background(Theme.Colors.bgCard)
        .cornerRadius(Theme.Radius.lg)
        .cardShadow()
        .accessibilityLabel("Plaque enregistree, identifiant \(plate.maskedDisplay), protegee")
    }
}
