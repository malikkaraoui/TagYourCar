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
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.bgCard)
            .cornerRadius(Theme.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .stroke(borderColor(for: formatted), lineWidth: 2)
            )
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
