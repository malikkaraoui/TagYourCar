import SwiftUI
import UIKit

struct ColorSwatchGrid: View {
    @Binding var selectedColor: VehicleColor?
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.lg) {
            ForEach(VehicleColor.allCases, id: \.rawValue) { color in
                swatchButton(for: color)
            }
        }
        .padding(Theme.Spacing.lg)
    }

    @ViewBuilder
    private func swatchButton(for color: VehicleColor) -> some View {
        let isSelected = selectedColor == color

        Button {
            impactMedium.prepare()
            impactMedium.impactOccurred(intensity: 0.8)
            selectedColor = color
        } label: {
            ZStack {
                Circle()
                    .fill(swiftUIColor(for: color))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? Theme.Colors.accentInteractive : borderColor(for: color),
                                lineWidth: isSelected ? 3 : 1
                            )
                    )

                if color == .other {
                    Image(systemName: "questionmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Theme.Colors.textSecondary)
                }

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(checkmarkColor(for: color))
                }
            }
            .frame(minWidth: 44, minHeight: 44)
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isSelected)
        }
        .accessibilityLabel(accessibilityLabel(for: color))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func swiftUIColor(for color: VehicleColor) -> Color {
        switch color {
        case .white: return .white
        case .black: return .black
        case .gray: return .gray
        case .silver: return Color(white: 0.78)
        case .blue: return .blue
        case .red: return .red
        case .green: return .green
        case .beige: return Color(red: 0.96, green: 0.87, blue: 0.70)
        case .yellow: return .yellow
        case .orange: return .orange
        case .brown: return .brown
        case .other: return Theme.Colors.bgSecondary
        }
    }

    private func borderColor(for color: VehicleColor) -> Color {
        switch color {
        case .white, .beige, .yellow, .silver:
            return Theme.Colors.bgSeparator
        default:
            return .clear
        }
    }

    private func checkmarkColor(for color: VehicleColor) -> Color {
        switch color {
        case .white, .yellow, .beige, .silver, .other:
            return Theme.Colors.accentPrimary
        default:
            return .white
        }
    }

    private func accessibilityLabel(for color: VehicleColor) -> String {
        switch color {
        case .white: return "Blanc"
        case .black: return "Noir"
        case .gray: return "Gris"
        case .silver: return "Argent"
        case .blue: return "Bleu"
        case .red: return "Rouge"
        case .green: return "Vert"
        case .beige: return "Beige"
        case .yellow: return "Jaune"
        case .orange: return "Orange"
        case .brown: return "Marron"
        case .other: return "Autre couleur"
        }
    }
}
