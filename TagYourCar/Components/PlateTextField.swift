import SwiftUI

struct PlateTextField: View {
    @Binding var text: String
    let isValid: Bool

    var body: some View {
        let formatted = PlateValidator.format(text)

        TextField("AA-123-AA", text: $text)
            .font(Theme.Typography.plate)
            .multilineTextAlignment(.center)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.characters)
            .keyboardType(.asciiCapable)
            .tracking(2)
            .padding(.vertical, Theme.Spacing.lg)
            .padding(.horizontal, Theme.Spacing.xl)
            .background(Theme.Colors.bgCard)
            .cornerRadius(Theme.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .stroke(borderColor(for: formatted), lineWidth: 2)
            )
            .cardShadow()
            .onChange(of: text) { newValue in
                let formatted = PlateValidator.format(newValue)
                if formatted != newValue {
                    text = formatted
                }
            }
    }

    private func borderColor(for input: String) -> Color {
        if input.isEmpty {
            return Theme.Colors.bgSeparator
        } else if PlateValidator.isValid(input) {
            return Theme.Colors.success
        } else {
            return Theme.Colors.error
        }
    }
}
