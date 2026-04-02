import SwiftUI
import UIKit

// MARK: - SelectionTile

/// Tuile de selection reutilisable avec 3 etats : neutre, selectionne, presse.
/// Utilisee partout dans l'app pour les choix (zones, problemes, couleurs, parametres).
struct SelectionTile<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            content()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .fill(isSelected
                              ? Theme.Colors.accentInteractive.opacity(0.12)
                              : Theme.Colors.bgCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .stroke(
                            isSelected ? Theme.Colors.accentInteractive : Theme.Colors.bgSeparator,
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                .scaleEffect(isSelected ? 1.02 : 1.0)
                .animation(Theme.Animation.snappy, value: isSelected)
        }
        .buttonStyle(TilePressStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - TilePressStyle

/// ButtonStyle partage pour toutes les tuiles : scale-down au press + haptic.
struct TilePressStyle: ButtonStyle {
    private let impact = UIImpactFeedbackGenerator(style: .medium)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed {
                    impact.prepare()
                    impact.impactOccurred(intensity: 0.7)
                }
            }
    }
}
