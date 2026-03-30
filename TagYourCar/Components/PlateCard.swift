import SwiftUI

struct PlateCard: View {
    let plate: Plate

    var body: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundStyle(Theme.Colors.accentPrimary)
                .font(.caption)

            Text(plate.maskedDisplay)
                .font(Theme.Typography.plate)
                .foregroundStyle(Theme.Colors.textPrimary)

            Spacer()

            if plate.verified {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(Theme.Colors.success)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.bgCard)
        .cornerRadius(Theme.Radius.md)
        .cardShadow()
        .accessibilityLabel("Plaque enregistree, identifiant \(plate.maskedDisplay), protegee")
    }
}
